const std = @import("std");
const pb = @import("proto").pb;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Io = std.Io;

pub const sequence_patch = struct {
    pub const alias = "sp";
    pub const description = "deploys the sequence patch onto your client via JsPatchNotify.\nusage: sequence_patch [mode]\nmodes (mode is a number):\n- 0: disabled, undo any previous effects of any sequence patch from before.\n- 1: partial, only show ui in sequences.\n- 2: full, fully detach camera during a sequence.";
    pub fn call(
        events: *EventQueue,
        conn: *Connection,
        alloc: mem.Alloc,
        io: Io,
        mode: u3,
    ) !void {
        const js_path = try std.fmt.allocPrint(alloc.arena, "assets/scripts/sequence_patch_profiles/{d}.js", .{mode});
        const js = try Io.Dir.readFileAlloc(Io.Dir.cwd(), io, js_path, alloc.arena, Io.Limit.unlimited);

        try conn.push(pb.JSPatchNotify{
            .Content = js,
        }, alloc.arena);

        try events.enqueue(.chat_command_response, .{ .content = "successfully applied sequence patch mode." });
    }
};

pub const weather = struct {
    pub const alias = "wx";
    pub const description = "sets the current weather to the inputted id.\nusage: weather [id]";
    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        conn: *Connection,
        io: Io,
        weather_id: i32,
    ) !void {
        const js_raw = try Io.Dir.readFileAlloc(Io.Dir.cwd(), io, "assets/scripts/misc_patches/weather_controller.js", alloc.arena, Io.Limit.unlimited);
        const weather_id_str = try std.fmt.allocPrint(alloc.arena, "{d}", .{weather_id});
        const js = try std.mem.replaceOwned(u8, alloc.arena, js_raw, "{WEATHER_ID}", weather_id_str);

        try conn.push(pb.JSPatchNotify{
            .Content = js,
        }, alloc.arena);
        try events.enqueue(.chat_command_response, .{ .content = "set weather successfully" });
    }
};
