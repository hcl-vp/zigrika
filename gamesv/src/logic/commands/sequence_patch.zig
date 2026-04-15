const std = @import("std");
const pb = @import("proto").pb;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const FileSystem = @import("common").FileSystem;

fn readEntireFile(gpa: std.mem.Allocator, io: std.Io, path: []const u8) ![]const u8 {
    var file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var reader = file.reader(io, "");
    return try reader.interface.allocRemaining(gpa, .unlimited);
}

pub const sequence_patch = struct {
    pub const alias = "sp";
    pub const description = "deploys the sequence patch onto your client via JsPatchNotify.\nusage: sequence_patch [mode]\nmodes (mode is a number):\n- 0: disabled, undo any previous effects of any sequence patch from before.\n- 1: partial, only show ui in sequences.\n- 2: full, fully detach camera during a sequence.";
    pub fn call(
        events: *EventQueue,
        fs: *FileSystem,
        conn: *Connection,
        alloc: mem.Alloc,
        mode: u3,
    ) !void {
        const js_path = try std.fmt.allocPrint(alloc.gpa, "assets/scripts/sequence_patch_profiles/{d}.js", .{mode});
        defer alloc.gpa.free(js_path);

        const js = try readEntireFile(alloc.gpa, fs.io, js_path);
        defer alloc.gpa.free(js);
        try conn.push(pb.JSPatchNotify{
            .Content = js,
        }, alloc.arena);

        try events.enqueue(.chat_command_response, .{ .content = "successfully applied sequence patch mode." });
    }
};
