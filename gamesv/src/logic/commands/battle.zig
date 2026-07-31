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
        const formation = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
        const cur_role_entity_id = blk: {
            for (formation.roles) |maybe_role| {
                if (maybe_role) |role| {
                    if (role.role_id == formation.cur_role) {
                        break :blk role.entity_id;
                    }
                }
            }
            break :blk -1;
        };

        var notify: pb.CombatReceivePackNotify = .{};
        try notify.Data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = cur_role_entity_id },
                .Message = .{
                    .PlayerBattleStateChangeNotify = .{
                        .PlayerId = scene.player_id,
                        .InBattle = mode,
                    },
                },
            },
        } });
        try conn.push(notify);
        try events.enqueue(.chat_command_response, .{ .content = "changed battle state" });
    }
};
