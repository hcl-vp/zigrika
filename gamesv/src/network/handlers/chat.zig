const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const State = @import("../State.zig");
const commands = @import("../../logic/commands.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Transaction = @import("../handlers.zig").Transaction;

const chat_bot_uid: i32 = @import("friend.zig").bot_details.PlayerId;
const starter_bot_msg = "use \"help\" to get a list of commands.";

pub fn onPrivateChatDataRequest(
    txn: *Transaction(pb.PrivateChatDataRequest),
    alloc: mem.Alloc,
) !void {
    var chat_content_history: std.ArrayList(pb.ChatContentProto) = .empty;
    defer chat_content_history.deinit(alloc.gpa);
    try chat_content_history.append(alloc.gpa, .{
        .SenderUid = chat_bot_uid,
        .ChatContentType = .Text,
        .Content = starter_bot_msg,
        .OfflineMsg = false,
        .UtcTime = 0,
    });

    var chat_history: std.ArrayList(pb.PrivateChatHistoryContentProto) = .empty;
    defer chat_history.deinit(alloc.gpa);
    try chat_history.append(alloc.gpa, .{
        .TargetUid = chat_bot_uid,
        .Chats = chat_content_history,
        .HistoryIsEnd = false,
        .TotalNums = 1,
    });
    try txn.conn.push(pb.PrivateChatHistoryNotify{ .AllChats = chat_history }, alloc.arena);
    txn.respond(.{ .LoadSucc = true });
}

pub fn onPrivateChatHistoryRequest(
    txn: *Transaction(pb.PrivateChatHistoryRequest),
    alloc: mem.Alloc,
) !void {
    if (txn.message.TargetUid == chat_bot_uid) {
        try txn.conn.push(pb.PrivateMessageNotify{ .ChatContent = .{
            .SenderUid = chat_bot_uid,
            .ChatContentType = .Text,
            .Content = starter_bot_msg,
            .OfflineMsg = false,
            .UtcTime = 0,
        } }, alloc.arena);
    }
    txn.respond(.{});
}

pub fn onPrivateChatRequest(
    txn: *Transaction(pb.PrivateChatRequest),
    state: *State,
    events: *EventQueue,
) !void {
    commands.dispatch(state, events, txn.message.Content) catch |err| {
        try events.enqueue(.chat_command_response, .{ .content = @errorName(err) });
    };

    txn.respond(.{ .TargetUid = txn.message.TargetUid, .FilterMsg = txn.message.Content });
}
