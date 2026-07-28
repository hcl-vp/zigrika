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
const buff_helper = @import("../helpers/buff.zig");

pub fn removeBuffFromEntity(
    event: EventQueue.Dequeue(.buff_removal),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, ?*Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_removal);
    const item = query.byEntityHandle(event.data.entity) orelse {
        for (event.data.handle_ids) |handle_id| {
            buff_timers.cancelHandle(event.data.entity.net_id, handle_id);
        }
        return;
    };
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.entity.net_id };
    var notify: pb.CombatReceivePackNotify = .{};
    var committed = false;
    errdefer if (!committed) {
        if (event.data.natural_expiration) |expiration| {
            for (event.data.handle_ids) |handle_id| {
                buff_timers.deferExpirationRetry(
                    event.data.entity.net_id,
                    handle_id,
                    expiration.now_ms,
                );
            }
        }
    };

    for (event.data.handle_ids) |handle_id| {
        try notify.Data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = combat_common,
                .Message = .{
                    .RemoveGameplayEffectNotify = .{
                        .EntityId = event.data.entity.net_id,
                        .Handle = handle_id,
                    },
                },
            },
        } });
    }

    try events.enqueue(.buff_change, .{ .entity = event.data.entity });
    if (event.data.natural_expiration) |expiration| {
        if (expiration.follow_up_buffs.len != 0) {
            try events.enqueue(.buff_addition, .{
                .target = event.data.entity,
                .instigator = expiration.instigator,
                .buffs = expiration.follow_up_buffs,
            });
        }
    }

    for (event.data.handle_ids) |handle_id| {
        buff_timers.cancelHandle(event.data.entity.net_id, handle_id);
        item[0].removeByHandleId(alloc.gpa, handle_id);
    }
    committed = true;

    try conn.push(notify);

    log.debug("removed these buffs from {d}: {any}", .{
        event.data.entity.net_id,
        event.data.handle_ids,
    });
}

pub fn addBuffToEntity(
    event: EventQueue.Dequeue(.buff_addition),
    conn: *Connection,
    events: *EventQueue,
    scene: *Scene,
    buff_timers: *BuffTimerScheduler,
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
    const log = std.log.scoped(.buff_addition);
    const item = query.byEntityHandle(event.data.target) orelse return;
    const buff_component = item[1];
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.target.net_id };
    var notify: pb.CombatReceivePackNotify = .{};
    var persisted_buff_changed = false;
    const clock: std.Io.Clock = .awake;
    const now_ms = clock.now(io).toMilliseconds();
    try buff_timers.ensureEntityRegistered(
        alloc.gpa,
        scene,
        assets,
        event.data.target.net_id,
        now_ms,
    );

    for (event.data.buffs) |entry| {
        const buff_data = assets.tables.buff.getDataById(entry.id) orelse continue;
        if (buff_data.DurationPolicy == .Instant) {
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = combat_common,
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = -2,
                            .Id = buff_data.Id,
                            .EntityId = event.data.target.net_id,
                            .InstigatorId = event.data.instigator.net_id,
                            .IsActive = true,
                        },
                    },
                },
            } });
            try buff_helper.execute_buff_effects(
                &notify.Data,
                event.data.target.net_id,
                event.data.instigator.net_id,
                &buff_data,
                scene,
                fs,
                io,
                query,
                alloc,
            );
            continue;
        }
        const existing = buff_component.getByBuffId(entry.id);
        const stack_count = if (entry.stack_count > 0) entry.stack_count else 1;
        if (existing) |buff| { // no dupes
            buff.Level = 1;
            buff.StackCount = stack_count;
            buff.InstigatorId = event.data.instigator.net_id;
            buff.EntityId = event.data.target.net_id;
            applyBuffDuration(buff, &buff_data, entry.duration_seconds);
            buff.ApplyType = .Common;
            buff.IsActive = entry.is_active;
            buff.MessageId = -1;
            try buff_timers.syncBuff(
                alloc.gpa,
                assets,
                buff.*,
                event.data.target.net_id,
                now_ms,
            );
            buff_timers.syncHandleLeftDuration(
                scene,
                event.data.target.net_id,
                buff.HandleId,
                now_ms,
            );
            persisted_buff_changed = true;
        } else {
            scene.*.instance.buff_handle += 1;
            buff_component.fight_buff_infos = try alloc.gpa.realloc(buff_component.fight_buff_infos, buff_component.fight_buff_infos.len + 1);
            buff_component.fight_buff_infos[buff_component.fight_buff_infos.len - 1] = Assets.DataTables.createBuffInformation(
                scene.instance.buff_handle,
                entry.id,
                event.data.instigator.net_id,
                event.data.target.net_id,
                entry.is_active,
            );
            buff_component.fight_buff_infos[buff_component.fight_buff_infos.len - 1].StackCount = stack_count;
            applyBuffDuration(&buff_component.fight_buff_infos[buff_component.fight_buff_infos.len - 1], &buff_data, entry.duration_seconds);
            const buff = buff_component.fight_buff_infos[buff_component.fight_buff_infos.len - 1];
            try buff_timers.syncBuff(
                alloc.gpa,
                assets,
                buff,
                event.data.target.net_id,
                now_ms,
            );
            buff_timers.syncHandleLeftDuration(
                scene,
                event.data.target.net_id,
                buff.HandleId,
                now_ms,
            );
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
            persisted_buff_changed = true;
        }
    }

    try conn.push(notify);

    if (persisted_buff_changed) {
        try events.enqueue(.buff_change, .{ .entity = event.data.target });
    }

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
            const duration = requested_duration orelse
                buff_helper.configured_duration_seconds(buff_data);
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
