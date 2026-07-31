const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const Connection = @import("../../network/Connection.zig");

pub const battle = struct {
    pub const alias = "bt";
    pub const description = "change if the current player is in battle mode or not.\nusage: battle [mode]\nmode is a true or false value.";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        conn: *Connection,
        alloc: mem.Alloc,
        mode: bool,
    ) !void {
        scene.forceBattleState(mode);
        var data: std.ArrayList(pb.CombatReceiveData) = .empty;
        if (try scene.appendBattleStateNotify(alloc.arena, &data)) {
            try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
        }
        try events.enqueue(.chat_command_response, .{ .content = "changed battle state" });
    }
};
