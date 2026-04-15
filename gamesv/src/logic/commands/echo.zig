const EventQueue = @import("../../logic/EventQueue.zig");

pub const echo = struct {
    pub const alias = "ec";
    pub const description = "test command, repeats the first parameter back.\nusage: echo [text]";
    pub fn call(events: *EventQueue, message: []const u8) !void {
        try events.enqueue(.chat_command_response, .{ .content = message });
    }
};
