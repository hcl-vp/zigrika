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
    query: FsmQuery,
) !void {
    const now_ms = event.data.now_ms;
    const elapsed_ms = takeFsmElapsedMs(scene, now_ms);

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;

    var it = query.iterator;
    while (it.next()) |item| {
        const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        if (!fsm.needsServerTick()) continue;

        try updateParalysis(entity, fsm, attribute, elapsed_ms, alloc, conn, io);

        if (try fsm.recoverExpiredPending(alloc.gpa, now_ms)) {
            try fsm.appendResetNotify(entity.net_id, alloc.arena, &data, assets);
        }
        if (try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) continue;
        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, &data, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
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
    const entity, const fsm, const attribute, const buffs, _, const tags, const parts = item;

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
            const changed = try setRageFullAttributes(attr, alloc);
            try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
        },
        .instance_state => |tag_id| try applyInstanceState(entity, fsm, tags, tag_id, events, alloc),
        .activate_part => |action| if (parts) |part| {
            var changed: std.ArrayList(usize) = .empty;
            defer changed.deinit(alloc.gpa);
            try part.activate(action.name, action.activate, tags, &changed, alloc.gpa);
            try pushPartChanges(entity.net_id, part, changed.items, conn, alloc);
        },
        .reset_part => |action| if (parts) |part| {
            var changed: std.ArrayList(usize) = .empty;
            defer changed.deinit(alloc.gpa);
            try part.reset(action.name, action.reset_activate, action.reset_life, tags, &changed, alloc.gpa);
            try pushPartChanges(entity.net_id, part, changed.items, conn, alloc);
        },
    }
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

test "fsm instance state replacement requests remove before add" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var events: EventQueue = .{ .arena = std.testing.allocator };
    defer events.deque.deinit(std.testing.allocator);
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = arena.allocator() };
    const entity: Entity = .{ .index = 0, .net_id = 1001 };
    var fsm: Entity.FsmComponent = undefined;

    fsm.instance_state_tag = 11;
    try applyInstanceState(entity, &fsm, null, 22, &events, alloc);
    const replacement = events.deque.popFront().?;
    try std.testing.expectEqual(@as(std.meta.Tag(EventQueue.Event), .gameplay_tag_change), std.meta.activeTag(replacement));
    try std.testing.expect(replacement.gameplay_tag_change.remove_before_add);
    try std.testing.expectEqualSlices(i32, &.{22}, replacement.gameplay_tag_change.add_tag_ids);
    try std.testing.expectEqualSlices(i32, &.{11}, replacement.gameplay_tag_change.remove_tag_ids);

    fsm.instance_state_tag = null;
    try applyInstanceState(entity, &fsm, null, 33, &events, alloc);
    const initial = events.deque.popFront().?;
    try std.testing.expect(!initial.gameplay_tag_change.remove_before_add);
    try std.testing.expectEqualSlices(i32, &.{33}, initial.gameplay_tag_change.add_tag_ids);
    try std.testing.expectEqual(@as(usize, 0), initial.gameplay_tag_change.remove_tag_ids.len);

    try applyInstanceState(entity, &fsm, null, 33, &events, alloc);
    try std.testing.expect(events.deque.popFront() == null);
}

fn updateParalysis(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    attribute: ?*Entity.AttributeComponent,
    elapsed_ms: i64,
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

    const changed = try advanceParalysisAttributes(fsm, attr, elapsed_ms, alloc);
    try pushAttributeChanges(entity.net_id, attr, &changed, conn, alloc, io);
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

fn takeFsmElapsedMs(scene: *Scene, now_ms: i64) i64 {
    const previous_ms = scene.scene_time.last_fsm_tick_time;
    if (now_ms <= previous_ms) return 0;
    scene.scene_time.last_fsm_tick_time = now_ms;
    if (previous_ms == 0) return 0;
    return now_ms - previous_ms;
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

test "fsm status reset preserves death and restores current attributes" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = arena.allocator() };
    const attribute_count = @intFromEnum(pb.EAttributeType.ParalysisTimeRecover) + 1;
    var values: [attribute_count]Entity.AttributeComponent.Attribute = @splat(.{ .base = 0, .increment = 0, .current = 0 });
    values[@intFromEnum(pb.EAttributeType.LifeMax)] = .{ .base = 100, .increment = 0, .current = 100 };
    values[@intFromEnum(pb.EAttributeType.Life)] = .{ .base = 100, .increment = 0, .current = 0 };
    values[@intFromEnum(pb.EAttributeType.RageMax)] = .{ .base = 100, .increment = 0, .current = 100 };
    values[@intFromEnum(pb.EAttributeType.Rage)] = .{ .base = 10, .increment = 2, .current = 0 };
    var attr: Entity.AttributeComponent = .{ .attributes = &values };

    const changed = try resetStatusAttributeValues(&attr, alloc);
    try std.testing.expect(changed.items.len != 0);
    try std.testing.expectEqual(@as(i32, 0), values[@intFromEnum(pb.EAttributeType.Life)].current);
    try std.testing.expectEqual(@as(i32, 12), values[@intFromEnum(pb.EAttributeType.Rage)].current);
}

test "fsm rage action fills current rage" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = arena.allocator() };
    const attribute_count = @intFromEnum(pb.EAttributeType.Rage) + 1;
    var values: [attribute_count]Entity.AttributeComponent.Attribute = @splat(.{ .base = 0, .increment = 0, .current = 0 });
    values[@intFromEnum(pb.EAttributeType.RageMax)].current = 75;
    var attr: Entity.AttributeComponent = .{ .attributes = &values };

    const changed = try setRageFullAttributes(&attr, alloc);
    try std.testing.expectEqual(@as(usize, 1), changed.items.len);
    try std.testing.expectEqual(@as(i32, 75), values[@intFromEnum(pb.EAttributeType.Rage)].current);
}

test "fsm tick elapsed time follows scheduler events" {
    var scene: Scene = undefined;
    scene.scene_time.last_fsm_tick_time = 1_000;

    try std.testing.expectEqual(@as(i64, 50), takeFsmElapsedMs(&scene, 1_050));
    try std.testing.expectEqual(@as(i64, 175), takeFsmElapsedMs(&scene, 1_225));
    try std.testing.expectEqual(@as(i64, 0), takeFsmElapsedMs(&scene, 1_225));
    try std.testing.expectEqual(@as(i64, 0), takeFsmElapsedMs(&scene, 1_100));
    try std.testing.expectEqual(@as(i64, 1_225), scene.scene_time.last_fsm_tick_time);
}

test "fsm paralysis recovery uses actual elapsed time" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = arena.allocator() };
    const attribute_count = @intFromEnum(pb.EAttributeType.ParalysisTimeRecover) + 1;
    var values: [attribute_count]Entity.AttributeComponent.Attribute = @splat(.{ .base = 0, .increment = 0, .current = 0 });
    values[@intFromEnum(pb.EAttributeType.ParalysisTimeMax)].current = 100;
    values[@intFromEnum(pb.EAttributeType.ParalysisTime)].current = 100;
    values[@intFromEnum(pb.EAttributeType.ParalysisTimeRecover)].current = -200;
    var attr: Entity.AttributeComponent = .{ .attributes = &values };
    var fsm: Entity.FsmComponent = .{ .paralysis_active = true };

    const first_changed = try advanceParalysisAttributes(&fsm, &attr, 50, alloc);
    try std.testing.expect(first_changed.items.len != 0);
    try std.testing.expect(fsm.paralysis_active);
    try std.testing.expectEqual(@as(i32, 90), values[@intFromEnum(pb.EAttributeType.ParalysisTime)].current);

    const delayed_changed = try advanceParalysisAttributes(&fsm, &attr, 450, alloc);
    try std.testing.expect(delayed_changed.items.len != 0);
    try std.testing.expect(!fsm.paralysis_active);
    try std.testing.expectEqual(@as(i32, 0), values[@intFromEnum(pb.EAttributeType.ParalysisTime)].current);
    try std.testing.expectEqual(@as(i32, 0), values[@intFromEnum(pb.EAttributeType.ParalysisTimeRecover)].current);
}

test "fsm paralysis recovery scaling saturates safely" {
    try std.testing.expectEqual(@as(i32, -10), scaledParalysisRecovery(-200, 50));
    try std.testing.expectEqual(@as(i32, -25), scaledParalysisRecovery(-200, 125));
    try std.testing.expectEqual(@as(i32, 0), scaledParalysisRecovery(-200, 0));
    try std.testing.expectEqual(std.math.maxInt(i32), scaledParalysisRecovery(std.math.maxInt(i32), std.math.maxInt(i64)));
    try std.testing.expectEqual(std.math.minInt(i32), scaledParalysisRecovery(std.math.minInt(i32), std.math.maxInt(i64)));
}

pub fn handleFsmLifecycleComplete(
    event: EventQueue.Dequeue(.fsm_lifecycle_complete),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    query: FsmQuery,
) !void {
    const item = query.byNetId(event.data.entity.net_id) orelse return;
    const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;

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
        .parts = if (parts) |part| part.states() else null,
        .now_ms = event.data.now_ms,
    });
    if (data.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    }
}
