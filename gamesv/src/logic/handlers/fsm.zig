const std = @import("std");
const FileSystem = @import("common").FileSystem;
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

const FsmQuery = Scene.Query(&.{
    Entity,
    *Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.FightBuffComponent,
    ?*Entity.LogicStateComponent,
    ?*Entity.TagComponent,
    ?*Entity.PartComponent,
});

pub fn handleFsmTick(
    event: EventQueue.Dequeue(.fsm_timer_tick),
    scene: *Scene,
    conn: *Connection,
    assets: *const Assets,
    events: *EventQueue,
    alloc: mem.Alloc,
    io: std.Io,
    fs: *FileSystem,
    query: FsmQuery,
) !void {
    const now_ms = event.data.now_ms;
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;

    while (scene.fsm_wakes.popDue(now_ms)) |due| {
        switch (due.kind) {
            .root_timer => try scene.markFsmRootDirty(
                alloc.gpa,
                due.entity_id,
                due.fsm_id,
                Entity.FsmComponent.WakeReason.timer,
            ),
            .pending_timeout, .paralysis => try scene.queueFsmSync(alloc.gpa, due.entity_id),
            .delayed_suicide => {
                const item = query.byNetId(due.entity_id) orelse continue;
                const entity, const fsm, _, _, _, _, _ = item;
                try fsm.initRuntime(alloc.gpa, now_ms);
                if (!fsm.consumeDelayedSuicide(due.fsm_id, due.due_ms)) continue;

                var death_data: std.ArrayList(pb.CombatReceiveData) = .empty;
                try death_data.append(alloc.arena, .{ .Message = .{ .CombatNotifyData = .{
                    .CombatCommon = .{ .EntityId = entity.net_id },
                    .Message = .{ .EntityLivingStatusNotify = .{
                        .Id = entity.net_id,
                        .LivingStatus = .Dead,
                    } },
                } } });
                try scene.setBattleEntityActive(alloc.gpa, entity.net_id, false);
                _ = try scene.appendBattleStateNotify(alloc.arena, &death_data);
                try conn.push(pb.CombatReceivePackNotify{ .Data = death_data }, alloc.arena);
                try scene.syncFsmDeadlines(alloc.gpa, entity.net_id, fsm);
            },
            .delayed_destroy => {
                const item = query.byNetId(due.entity_id) orelse continue;
                const entity, const fsm, _, _, _, _, _ = item;
                try fsm.initRuntime(alloc.gpa, now_ms);
                if (!fsm.delayedDestroyIsDue(due.fsm_id, due.due_ms)) continue;

                try scene.remove(alloc.gpa, fs, entity.net_id);
                var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;
                try remove_infos.append(alloc.arena, .{ .EntityId = entity.net_id });
                try conn.push(pb.EntityRemoveNotify{
                    .IsRemove = true,
                    .RemoveInfos = remove_infos,
                }, alloc.arena);
            },
        }
    }

    while (scene.fsm_wakes.popDirty()) |entity_id| {
        const item = query.byNetId(entity_id) orelse continue;
        const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
        try fsm.initRuntime(alloc.gpa, now_ms);

        if (fsm.paralysis_active and fsm.paralysis_next_ms != null and fsm.paralysis_next_ms.? <= now_ms) {
            try updateParalysis(entity, fsm, attribute, now_ms, alloc, conn, io);
        }

        if (try fsm.recoverExpiredPending(alloc.gpa, now_ms)) {
            try fsm.appendResetNotify(entity.net_id, alloc.arena, &data, assets);
        }
        const lifecycle_deferred = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);
        if (!lifecycle_deferred) {
            try fsm.appendDirtyStateTransitions(entity.net_id, alloc.arena, &data, .{
                .attribute = attribute,
                .buffs = buffs,
                .logic_state = logic_state,
                .tags = tags,
                .parts = if (parts) |part| part.states() else null,
                .now_ms = now_ms,
            });
            fsm.finishTick(now_ms);
        }
        try scene.syncFsmDeadlines(alloc.gpa, entity.net_id, fsm);
    }

    if (data.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    }
}

pub fn handleFsmServerAction(
    event: EventQueue.Dequeue(.fsm_server_action),
    scene: *Scene,
    conn: *Connection,
    events: *EventQueue,
    buff_timers: *BuffTimerScheduler,
    alloc: mem.Alloc,
    io: std.Io,
    query: FsmQuery,
) !void {
    const item = query.byNetId(event.data.entity.net_id) orelse return;
    const entity, const fsm, const attribute, const buffs, _, const tags, const parts = item;

    switch (event.data.kind) {
        .enter_fight => {
            try scene.setBattleEntityActive(alloc.gpa, entity.net_id, true);
            var data: std.ArrayList(pb.CombatReceiveData) = .empty;
            if (try scene.appendBattleStateNotify(alloc.arena, &data)) {
                try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
            }
        },
        .cue_paralysis => {
            const now_ms = std.Io.Clock.awake.now(io).toMilliseconds();
            fsm.activateParalysis(now_ms);
            try scene.queueFsmSync(alloc.gpa, entity.net_id);
        },
        .reset_status => {
            if (attribute) |attr| try resetStatusAttributes(entity.net_id, attr, conn, alloc, io);
            if (buffs) |buff_comp| {
                const handles = try alloc.arena.alloc(i32, buff_comp.fight_buff_infos.len);
                for (buff_comp.fight_buff_infos, 0..) |buff, index| handles[index] = buff.HandleId;
                try buff_handlers.removeBuffHandles(entity, handles, buff_comp, conn, events, alloc, buff_timers);
            }
            try scene.markFsmDirty(
                alloc.gpa,
                entity.net_id,
                Entity.FsmComponent.WakeReason.attribute | Entity.FsmComponent.WakeReason.buff,
            );
        },
        .set_rage_full => if (attribute) |attr| {
            const changed = try setRageFullAttributes(attr, alloc);
            try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
            if (changed.items.len != 0) {
                try scene.markFsmDirty(alloc.gpa, entity.net_id, Entity.FsmComponent.WakeReason.attribute);
            }
        },
        .instance_state => |tag_id| {
            try applyInstanceState(entity, fsm, tags, tag_id, events, alloc);
            try scene.markFsmDirty(alloc.gpa, entity.net_id, Entity.FsmComponent.WakeReason.tag);
        },
        .activate_part => |action| if (parts) |part| {
            var changed: std.ArrayList(usize) = .empty;
            defer changed.deinit(alloc.gpa);
            try part.activate(action.name, action.activate, tags, &changed, alloc.gpa);
            try pushPartChanges(entity.net_id, part, changed.items, conn, alloc);
            if (changed.items.len != 0) {
                try scene.markFsmDirty(
                    alloc.gpa,
                    entity.net_id,
                    Entity.FsmComponent.WakeReason.part | Entity.FsmComponent.WakeReason.tag,
                );
            }
        },
        .reset_part => |action| if (parts) |part| {
            var changed: std.ArrayList(usize) = .empty;
            defer changed.deinit(alloc.gpa);
            try part.reset(action.name, action.reset_activate, action.reset_life, tags, &changed, alloc.gpa);
            try pushPartChanges(entity.net_id, part, changed.items, conn, alloc);
            if (changed.items.len != 0) {
                try scene.markFsmDirty(
                    alloc.gpa,
                    entity.net_id,
                    Entity.FsmComponent.WakeReason.part | Entity.FsmComponent.WakeReason.tag,
                );
            }
        },
    }
}

pub fn handleFsmBuffChange(
    event: EventQueue.Dequeue(.buff_change),
    scene: *Scene,
    alloc: mem.Alloc,
) !void {
    try scene.markFsmDirty(
        alloc.gpa,
        event.data.entity.net_id,
        Entity.FsmComponent.WakeReason.buff | Entity.FsmComponent.WakeReason.attribute,
    );
}

pub fn handleFsmGameplayTagChange(
    event: EventQueue.Dequeue(.gameplay_tag_change),
    scene: *Scene,
    alloc: mem.Alloc,
) !void {
    try scene.markFsmDirty(alloc.gpa, event.data.entity.net_id, Entity.FsmComponent.WakeReason.tag);
}

fn pushPartChanges(
    entity_id: i64,
    parts: *const Entity.PartComponent,
    changed: []const usize,
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    if (changed.len == 0) return;

    var part_infos: std.ArrayList(pb.PartInformation) = .empty;
    for (changed) |index| try parts.appendPartInfo(index, &part_infos, alloc.arena);

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    try data.append(alloc.arena, .{ .Message = .{ .CombatNotifyData = .{
        .CombatCommon = .{ .EntityId = entity_id },
        .Message = .{ .PartUpdateNotify = .{
            .EntityId = entity_id,
            .PartInfos = part_infos,
        } },
    } } });
    try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
}

fn applyInstanceState(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    tags: ?*Entity.TagComponent,
    tag_id: i32,
    events: *EventQueue,
    alloc: mem.Alloc,
) !void {
    const previous = fsm.instance_state_tag;
    if (previous) |old_tag| {
        if (old_tag == tag_id) return;
    }
    fsm.instance_state_tag = tag_id;

    if (tags) |tag_comp| {
        if (previous) |old_tag| try tag_comp.removeGameplayTag(alloc.gpa, old_tag);
        try tag_comp.setGameplayTagCount(alloc.gpa, tag_id, 1);
    }

    const add_tags = try alloc.arena.alloc(i32, 1);
    add_tags[0] = tag_id;
    const remove_tags: []i32 = if (previous) |old_tag| blk: {
        const old_tags = try alloc.arena.alloc(i32, 1);
        old_tags[0] = old_tag;
        break :blk old_tags;
    } else try alloc.arena.alloc(i32, 0);
    try events.enqueue(.gameplay_tag_change, .{
        .entity = entity,
        .add_tag_ids = add_tags,
        .remove_tag_ids = remove_tags,
        .remove_before_add = previous != null,
    });
}

fn updateParalysis(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    attribute: ?*Entity.AttributeComponent,
    now_ms: i64,
    alloc: mem.Alloc,
    conn: *Connection,
    io: std.Io,
) !void {
    if (!fsm.paralysis_active) return;
    const attr = attribute orelse {
        fsm.paralysis_active = false;
        fsm.paralysis_next_ms = null;
        return;
    };
    const time_index = @intFromEnum(pb.EAttributeType.ParalysisTime);
    const recover_index = @intFromEnum(pb.EAttributeType.ParalysisTimeRecover);
    if (time_index >= attr.attributes.len or recover_index >= attr.attributes.len) {
        fsm.paralysis_active = false;
        fsm.paralysis_next_ms = null;
        return;
    }

    const elapsed_ms = @max(now_ms - fsm.paralysis_last_ms, 0);
    const changed = try advanceParalysisAttributes(fsm, attr, elapsed_ms, alloc);
    try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
    if (changed.items.len != 0) _ = fsm.markDirty(Entity.FsmComponent.WakeReason.attribute);
    fsm.paralysis_last_ms = @max(fsm.paralysis_last_ms, now_ms);
    fsm.paralysis_next_ms = if (fsm.paralysis_active) now_ms + 50 else null;
}

fn advanceParalysisAttributes(
    fsm: *Entity.FsmComponent,
    attr: *Entity.AttributeComponent,
    elapsed_ms: i64,
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
    const time_index = @intFromEnum(pb.EAttributeType.ParalysisTime);
    const recover_index = @intFromEnum(pb.EAttributeType.ParalysisTimeRecover);
    var changed: std.ArrayList(pb.EAttributeType) = .empty;
    const recover = attr.attributes[@intCast(recover_index)].current;
    const delta = scaledParalysisRecovery(recover, elapsed_ms);
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
    return changed;
}

fn scaledParalysisRecovery(recover: i32, elapsed_ms: i64) i32 {
    if (elapsed_ms <= 0 or recover == 0) return 0;
    const delta = @divTrunc(@as(i128, recover) * @as(i128, elapsed_ms), 1000);
    if (delta < std.math.minInt(i32)) return std.math.minInt(i32);
    if (delta > std.math.maxInt(i32)) return std.math.maxInt(i32);
    return @intCast(delta);
}

fn resetStatusAttributes(
    entity_id: i64,
    attr: *Entity.AttributeComponent,
    conn: *Connection,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    const changed = try resetStatusAttributeValues(attr, alloc);
    try pushAttributeChanges(entity_id, attr, &changed, conn, alloc, io);
}

fn resetStatusAttributeValues(
    attr: *Entity.AttributeComponent,
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
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
    return changed;
}

fn setRageFullAttributes(
    attr: *Entity.AttributeComponent,
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
    const rage_max_index = @intFromEnum(pb.EAttributeType.RageMax);
    if (rage_max_index >= attr.attributes.len) return .empty;
    return attributes.change_attr(
        attr,
        .Rage,
        .Override,
        .Current,
        attr.attributes[@intCast(rage_max_index)].current,
        alloc,
    );
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
    scene: *Scene,
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    query: FsmQuery,
) !void {
    const item = query.byNetId(event.data.entity.net_id) orelse return;
    const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;

    fsm.completeLifecycleEffects();
    const recheck = event.data.recheck or fsm.takeLifecycleRecheckRequest();
    const lifecycle_deferred = if (recheck)
        try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, event.data.now_ms)
    else
        try FsmLifecycle.enqueueEffectsWithoutRecheck(entity, fsm, events, alloc, event.data.now_ms);
    if (!lifecycle_deferred) {
        var data: std.ArrayList(pb.CombatReceiveData) = .empty;
        const ctx: Entity.FsmComponent.EvalContext = .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
            .now_ms = event.data.now_ms,
        };
        if (recheck) {
            try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, &data, ctx);
        } else {
            fsm.clearDirtyReason(Entity.FsmComponent.WakeReason.initial);
            try fsm.appendDirtyStateTransitions(entity.net_id, alloc.arena, &data, ctx);
        }
        if (data.items.len != 0) {
            try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
        }
    }
    fsm.finishTick(event.data.now_ms);
    try scene.syncFsmDeadlines(alloc.gpa, entity.net_id, fsm);
}
