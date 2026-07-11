const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Entity = Scene.Entity;
const Connection = @import("../../network/Connection.zig");

const FSM_TICK_MS = 500;

pub fn handleFsmTick(
    event: EventQueue.Dequeue(.fsm_timer_tick),
    scene: *Scene,
    conn: *Connection,
    alloc: mem.Alloc,
    query: Scene.Query(&.{
        Entity,
        *Entity.FsmComponent,
        ?*Entity.AttributeComponent,
        ?*Entity.LogicStateComponent,
    }),
) !void {
    const now_ms = event.data.now_ms;
    if (scene.scene_time.last_fsm_tick_time != 0 and now_ms - scene.scene_time.last_fsm_tick_time < FSM_TICK_MS) {
        return;
    }
    scene.scene_time.last_fsm_tick_time = now_ms;

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;

    var it = query.iterator;
    while (it.next()) |item| {
        const entity, const fsm, const attribute, const logic_state = item;
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        if (!fsm.needsServerTick()) continue;

        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, &data, .{
            .attribute = attribute,
            .logic_state = logic_state,
            .now_ms = now_ms,
        });
    }

    if (data.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    }
}
