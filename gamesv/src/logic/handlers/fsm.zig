const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const FsmLifecycle = @import("../FsmLifecycle.zig");
const Scene = @import("../Scene.zig");
const Entity = Scene.Entity;
const Connection = @import("../../network/Connection.zig");

const FSM_TICK_MS = 500;

const FsmQuery = Scene.Query(&.{
    Entity,
    *Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.FightBuffComponent,
    ?*Entity.LogicStateComponent,
    ?*Entity.TagComponent,
});

pub fn handleFsmTick(
    event: EventQueue.Dequeue(.fsm_timer_tick),
    scene: *Scene,
    conn: *Connection,
    assets: *const Assets,
    events: *EventQueue,
    alloc: mem.Alloc,
    query: FsmQuery,
) !void {
    const now_ms = event.data.now_ms;
    if (scene.scene_time.last_fsm_tick_time != 0 and now_ms - scene.scene_time.last_fsm_tick_time < FSM_TICK_MS) {
        return;
    }
    scene.scene_time.last_fsm_tick_time = now_ms;

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;

    var it = query.iterator;
    while (it.next()) |item| {
        const entity, const fsm, const attribute, const buffs, const logic_state, const tags = item;
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        if (!fsm.needsServerTick()) continue;

        if (try fsm.recoverExpiredPending(alloc.gpa, now_ms)) {
            try fsm.appendResetNotify(entity.net_id, alloc.arena, &data, assets);
        }
        if (try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) continue;
        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, &data, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .now_ms = now_ms,
        });
    }

    if (data.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    }
}

pub fn handleFsmLifecycleComplete(
    event: EventQueue.Dequeue(.fsm_lifecycle_complete),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    query: FsmQuery,
) !void {
    const item = query.byNetId(event.data.entity.net_id) orelse return;
    const entity, const fsm, const attribute, const buffs, const logic_state, const tags = item;

    fsm.completeLifecycleEffects();
    defer fsm.finishTick(event.data.now_ms);
    const recheck = event.data.recheck or fsm.takeLifecycleRecheckRequest();
    const lifecycle_deferred = if (recheck)
        try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, event.data.now_ms)
    else
        try FsmLifecycle.enqueueEffectsWithoutRecheck(entity, fsm, events, alloc, event.data.now_ms);
    if (lifecycle_deferred or !recheck) return;

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, &data, .{
        .attribute = attribute,
        .buffs = buffs,
        .logic_state = logic_state,
        .tags = tags,
        .now_ms = event.data.now_ms,
    });
    if (data.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    }
}
