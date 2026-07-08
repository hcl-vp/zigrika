const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const Connection = @import("../../network/Connection.zig");
const State = @import("../../network/State.zig");

pub fn handleFsmTimerTick(
    event: EventQueue.Dequeue(.fsm_timer_tick),
    conn: *Connection,
    state: *State,
    scene: *Scene,
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    try state.fsm_timers.drainDue(
        event,
        scene,
        assets,
        &combat_receive_pack,
        alloc,
    );

    if (combat_receive_pack.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = combat_receive_pack }, alloc.arena);
    }
}
