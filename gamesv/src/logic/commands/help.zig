const std = @import("std");
const EventQueue = @import("../../logic/EventQueue.zig");
const namespaces = @import("../commands.zig").namespaces;
const mem = @import("../../mem.zig");

pub const help = struct {
    pub const description = "outputs information regarding commands.\nusage: help [command?]";
    pub fn call(events: *EventQueue, alloc: mem.Alloc, command: ?[]const u8) !void {
        inline for (namespaces) |namespace| {
            inline for (comptime std.meta.declarations(namespace)) |decl| {
                const item = @field(namespace, decl.name);
                if (@TypeOf(item) != type) continue;
                if (@typeInfo(item) != .@"struct") continue;
                if (!@hasDecl(item, "description")) continue;
                if (command == null or std.mem.eql(u8, decl.name, command.?)) {
                    var buf: [4096]u8 = undefined;
                    var writer: std.Io.Writer = .fixed(&buf);
                    if (@hasDecl(item, "alias")) {
                        try writer.writeAll(decl.name ++ " (" ++ item.alias ++ "): " ++ item.description);
                    } else {
                        try writer.writeAll(decl.name ++ ": " ++ item.description);
                    }
                    const result = try alloc.arena.dupe(u8, writer.buffered());
                    try events.enqueue(.chat_command_response, .{ .content = result });
                }
            }
        }

        if (command != null) {
            try events.enqueue(.chat_command_response, .{ .content = "no matching commands found" });
        }
    }
};
