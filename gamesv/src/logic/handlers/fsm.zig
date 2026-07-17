const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const FsmLifecycle = @import("../FsmLifecycle.zig");
const Scene = @import("../Scene.zig");
const Entity = Scene.Entity;
const Connection = @import("../../network/Connection.zig");
const attributes = @import("../helpers/attributes.zig");
const buff_handlers = @import("buff.zig");
const BuffTimerScheduler = @import("../schedulers/BuffTimerScheduler.zig");

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
    io: std.Io,
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

        try updateParalysis(entity, fsm, attribute, alloc, conn, io);

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

pub fn handleFsmServerAction(
    event: EventQueue.Dequeue(.fsm_server_action),
    conn: *Connection,
    events: *EventQueue,
    buff_timers: *BuffTimerScheduler,
    alloc: mem.Alloc,
    io: std.Io,
    query: FsmQuery,
) !void {
    const item = query.byNetId(event.data.entity.net_id) orelse return;
    const entity, const fsm, const attribute, const buffs, _, _ = item;

    switch (event.data.kind) {
        .cue_paralysis => fsm.paralysis_active = true,
        .reset_status => {
            if (attribute) |attr| try resetStatusAttributes(entity.net_id, attr, conn, alloc, io);
            if (buffs) |buff_comp| {
                const handles = try alloc.arena.alloc(i32, buff_comp.fight_buff_infos.len);
                for (buff_comp.fight_buff_infos, 0..) |buff, index| handles[index] = buff.HandleId;
                try buff_handlers.removeBuffHandles(entity, handles, buff_comp, conn, events, alloc, buff_timers);
            }
        },
        .set_rage_full => if (attribute) |attr| {
            const rage_max_index = @intFromEnum(pb.EAttributeType.RageMax);
            if (rage_max_index < attr.attributes.len) {
                const changed = try attributes.change_attr(
                    attr,
                    .Rage,
                    .Override,
                    .Current,
                    attr.attributes[@intCast(rage_max_index)].current,
                    alloc,
                );
                try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
            }
        },
    }
}

fn updateParalysis(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    attribute: ?*Entity.AttributeComponent,
    alloc: mem.Alloc,
    conn: *Connection,
    io: std.Io,
) !void {
    if (!fsm.paralysis_active) return;
    const attr = attribute orelse {
        fsm.paralysis_active = false;
        return;
    };
    const time_index = @intFromEnum(pb.EAttributeType.ParalysisTime);
    const recover_index = @intFromEnum(pb.EAttributeType.ParalysisTimeRecover);
    if (time_index >= attr.attributes.len or recover_index >= attr.attributes.len) {
        fsm.paralysis_active = false;
        return;
    }

    var changed: std.ArrayList(pb.EAttributeType) = .empty;
    const recover = attr.attributes[@intCast(recover_index)].current;
    const delta_i64 = @divTrunc(@as(i64, recover) * FSM_TICK_MS, 1000);
    const delta = std.math.cast(i32, delta_i64) orelse if (delta_i64 < 0)
        @as(i32, std.math.minInt(i32))
    else
        @as(i32, std.math.maxInt(i32));
    if (attr.attributes[@intCast(time_index)].current > 0 and delta != 0) {
        const time_change = try attributes.change_attr(attr, .ParalysisTime, .Delta, .Current, delta, alloc);
        try changed.appendSlice(alloc.arena, time_change.items);
    }

    if (attr.attributes[@intCast(time_index)].current <= 0) {
        fsm.paralysis_active = false;
        if (recover != 0) {
            const recover_change = try attributes.change_attr(attr, .ParalysisTimeRecover, .Override, .Current, 0, alloc);
            try changed.appendSlice(alloc.arena, recover_change.items);
        }
    }
    try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
}

fn resetStatusAttributes(
    entity_id: i64,
    attr: *Entity.AttributeComponent,
    conn: *Connection,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    var changed: std.ArrayList(pb.EAttributeType) = .empty;
    for (std.enums.values(pb.EAttributeType)) |attr_type| {
        const index = @intFromEnum(attr_type);
        if (index >= attr.attributes.len) continue;
        const current = &attr.attributes[@intCast(index)];
        const desired_i64 = @as(i64, current.base) + current.increment;
        const desired = std.math.cast(i32, desired_i64) orelse if (desired_i64 < 0)
            @as(i32, std.math.minInt(i32))
        else
            @as(i32, std.math.maxInt(i32));
        if (current.current == desired) continue;
        const attr_change = try attributes.change_attr(attr, attr_type, .Override, .Current, desired, alloc);
        try changed.appendSlice(alloc.arena, attr_change.items);
    }
    try pushAttributeChanges(entity_id, attr, &changed, conn, alloc, io);
}

fn pushAttributeChanges(
    entity_id: i64,
    attr: *Entity.AttributeComponent,
    changed: *const std.ArrayList(pb.EAttributeType),
    conn: *Connection,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    if (changed.items.len == 0) return;
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    try attributes.generate_attr_messages(&data, entity_id, attr, changed, alloc, io);
    if (data.items.len != 0) try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
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
