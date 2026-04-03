const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;

const chat_bot_uid: i32 = @import("friend.zig").bot_details.PlayerId;

pub fn onPrivateChatDataRequest(
    txn: *Transaction(pb.PrivateChatDataRequest),
    alloc: mem.Alloc,
) !void {
    var chat_content_history: std.ArrayList(pb.ChatContentProto) = .empty;
    defer chat_content_history.deinit(alloc.gpa);
    try chat_content_history.append(alloc.gpa, .{
        .SenderUid = chat_bot_uid,
        .ChatContentType = .Text,
        .Content = "chat commands are not implemented yet, come back in like a day and git pull",
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
    try txn.respond(.{ .LoadSucc = true });
}

pub fn onPrivateChatHistoryRequest(
    txn: *Transaction(pb.PrivateChatHistoryRequest),
    alloc: mem.Alloc,
) !void {
    if (txn.message.TargetUid == chat_bot_uid) {
        try txn.conn.push(pb.PrivateMessageNotify{ .ChatContent = .{
            .SenderUid = chat_bot_uid,
            .ChatContentType = .Text,
            .Content = "chat commands are not implemented yet, come back in like a day and git pull",
            .OfflineMsg = false,
            .UtcTime = 0,
        } }, alloc.arena);
    }
    try txn.respond(.{});
}
