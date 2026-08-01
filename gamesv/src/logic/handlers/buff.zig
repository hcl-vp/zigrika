const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const mem = @import("../../mem.zig");
const Connection = @import("../../network/Connection.zig");
const BuffTimerScheduler = @import("../schedulers/BuffTimerScheduler.zig");

const BuffQuery = Scene.Query(&.{ *Entity.FightBuffComponent, ?*Entity.AttributeComponent });

pub fn removeBuffFromEntity(
    event: EventQueue.Dequeue(.buff_removal),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
    query: BuffQuery,
) !void {
    const log = std.log.scoped(.buff_removal);
    const item = query.byEntityHandle(event.data.entity) orelse return;
    try removeBuffHandles(event.data.entity, event.data.handle_ids, item[0], conn, events, alloc, buff_timers);

    log.debug("removed these buffs from {d}: {any}", .{
        event.data.entity.net_id,
        event.data.handle_ids,
    });
}

pub fn removeBuffFromEntityById(
    event: EventQueue.Dequeue(.buff_removal_by_id),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
    query: BuffQuery,
) !void {
    const item = query.byEntityHandle(event.data.entity) orelse return;
    const buff = item[0].getByBuffId(event.data.buff_id) orelse return;
    const handles = [_]i32{buff.HandleId};
    try removeBuffHandles(event.data.entity, &handles, item[0], conn, events, alloc, buff_timers);
}

pub fn removeBuffFromEntityByFsmBind(
    event: EventQueue.Dequeue(.buff_removal_by_fsm_bind),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
    query: BuffQuery,
) !void {
    const item = query.byEntityHandle(event.data.entity) orelse return;
    const release = item[0].releaseFsmBindLease(alloc.gpa, event.data.source) orelse return;
    switch (release) {
        .preserve => try events.enqueue(.buff_change, .{ .entity = event.data.entity }),
        .remove => |handle_id| {
            if (item[0].getByHandleId(handle_id) != null) {
                const handles = [_]i32{handle_id};
                try removeBuffHandles(event.data.entity, &handles, item[0], conn, events, alloc, buff_timers);
            } else {
                try events.enqueue(.buff_change, .{ .entity = event.data.entity });
            }
        },
    }
}

pub fn removeBuffHandles(
    entity: Entity,
    handle_ids: []const i32,
    buffs: *Entity.FightBuffComponent,
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
) !void {
    const combat_common: pb.CombatCommon = .{ .EntityId = entity.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (handle_ids) |handle_id| {
        if (buffs.getByHandleId(handle_id) == null) continue;
        buffs.removeByHandleId(alloc.gpa, handle_id);
        buff_timers.cancelHandle(entity.net_id, handle_id);
        try notify.Data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = combat_common,
                .Message = .{
                    .RemoveGameplayEffectNotify = .{
                        .EntityId = entity.net_id,
                        .Handle = handle_id,
                    },
                },
            },
        } });
    }

    if (notify.Data.items.len == 0) return;
    try conn.push(notify);
    try events.enqueue(.buff_change, .{ .entity = entity });
}

pub fn addBuffToEntity(
    event: EventQueue.Dequeue(.buff_addition),
    conn: *Connection,
    events: *EventQueue,
    scene: *Scene,
    buff_timers: *BuffTimerScheduler,
    assets: *const Assets,
    alloc: mem.Alloc,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, ?*Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_addition);
    const item = query.byEntityHandle(event.data.target) orelse return;
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.target.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (event.data.buffs) |entry| {
        const buff_data = assets.tables.buff.getDataById(entry.id) orelse continue;
        if (entry.fsm_bind_source) |source| {
            if (!item[0].prepareFsmBindAcquire(alloc.gpa, source)) continue;
        }
        const existing = item[0].getByBuffId(entry.id);
        const stack_count = if (entry.stack_count > 0) entry.stack_count else 1;
        if (existing) |buff| { // no dupes
            if (entry.fsm_bind_source) |source| {
                try item[0].addFsmBindLease(alloc.gpa, source, buff.HandleId, false);
            } else {
                item[0].markFsmBindHandleExternal(alloc.gpa, buff.HandleId);
            }
            buff_timers.cancelHandle(event.data.target.net_id, buff.HandleId);
            buff.Level = 1;
            buff.StackCount = stack_count;
            buff.InstigatorId = event.data.instigator.net_id;
            buff.EntityId = event.data.target.net_id;
            applyBuffDuration(buff, &buff_data, entry.duration_seconds);
            buff.ApplyType = .Common;
            buff.IsActive = entry.is_active;
            buff.MessageId = -1;
        } else {
            scene.*.instance.buff_handle += 1;
            item[0].fight_buff_infos = try alloc.gpa.realloc(item[0].fight_buff_infos, item[0].fight_buff_infos.len + 1);
            item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1] = Assets.DataTables.createBuffInformation(
                scene.instance.buff_handle,
                entry.id,
                event.data.instigator.net_id,
                event.data.target.net_id,
                entry.is_active,
            );
            item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1].StackCount = stack_count;
            applyBuffDuration(&item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1], &buff_data, entry.duration_seconds);
            const buff = item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1];
            if (entry.fsm_bind_source) |source| {
                item[0].addFsmBindLease(alloc.gpa, source, buff.HandleId, true) catch |err| {
                    item[0].removeByHandleId(alloc.gpa, buff.HandleId);
                    return err;
                };
            }
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = combat_common,
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = buff.HandleId,
                            .Id = buff.BuffId,
                            .Level = buff.Level,
                            .EntityId = buff.EntityId,
                            .InstigatorId = buff.InstigatorId,
                            .ApplyType = if (buff.ApplyType) |apply_type| @intFromEnum(apply_type) else 0,
                            .IsActive = buff.IsActive,
                            .ServerId = buff.ServerId,
                            .StackCount = buff.StackCount,
                            .CRoundAction = .{ .Duration = buff.Duration },
                            .Time = .{ .LeftDuration = buff.LeftDuration },
                            .ConfBuffId = buff.ConfBuffId,
                        },
                    },
                },
            } });
        }
    }

    try conn.push(notify);

    try events.enqueue(.buff_change, .{ .entity = event.data.target });

    log.debug("eid {d}: added these buffs to {d}: {any}", .{
        event.data.instigator.net_id,
        event.data.target.net_id,
        event.data.buffs,
    });
}

pub fn handleBuffTimerTick(
    event: EventQueue.Dequeue(.buff_timer_tick),
    conn: *Connection,
    events: *EventQueue,
    buff_timers: *BuffTimerScheduler,
    scene: *Scene,
    assets: *const Assets,
    fs: *FileSystem,
    io: std.Io,
    alloc: mem.Alloc,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
) !void {
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    const max_iterations = 1000;
    for (0..max_iterations) |_| {
        const before = combat_receive_pack.items.len;
        const peek_due = buff_timers.peekDueMs();
        try buff_timers.drainOneDue(
            event,
            events,
            scene,
            assets,
            fs,
            io,
            query,
            &combat_receive_pack,
            alloc,
        );
        // If nothing was processed, stop
        if (combat_receive_pack.items.len == before and
            (buff_timers.peekDueMs() == peek_due or buff_timers.peekDueMs() == null)) break;
    }

    if (combat_receive_pack.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = combat_receive_pack });
    }
}

fn applyBuffDuration(
    buff: *pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    requested_duration: ?f32,
) void {
    switch (buff_data.DurationPolicy) {
        .Instant => {
            buff.Duration = 0;
            buff.LeftDuration = 0;
        },
        .Infinite => {
            buff.Duration = -1;
            buff.LeftDuration = -1;
        },
        .HasDuration => {
            const duration = requested_duration orelse dataDuration(buff_data);
            if (duration > 0) {
                buff.Duration = duration;
                buff.LeftDuration = duration;
            } else {
                buff.Duration = -1;
                buff.LeftDuration = -1;
            }
        },
    }
}

fn dataDuration(buff_data: *const Assets.DataTables.Buff) f32 {
    return if (buff_data.DurationMagnitude.len > 0) buff_data.DurationMagnitude[0] else 0;
}
