const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");

const chat_bot_uid: i32 = @import("../../network/handlers/friend.zig").bot_details.PlayerId;

pub fn chatCommandResponse(
    event: EventQueue.Dequeue(.chat_command_response),
    conn: *Connection,
) !void {
    try conn.push(pb.PrivateMessageNotify{ .ChatContent = .{
        .SenderUid = chat_bot_uid,
        .ChatContentType = .Text,
        .Content = event.data.content,
        .OfflineMsg = false,
        .UtcTime = 0,
    } });
}
