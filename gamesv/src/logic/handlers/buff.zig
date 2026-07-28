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
    var buff_change_enqueued = false;
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
            buff_timers.syncHandleLeftDuration(
                scene,
                event.data.target.net_id,
                buff.HandleId,
                now_ms,
            );
            const was_active = buff.IsActive;
            const disposition = BuffTimerScheduler.applicationDisposition(
                &buff_data,
                false,
                was_active,
                entry.is_active,
            );
            var next_buff = buff.*;
            next_buff.Level = 1;
            next_buff.StackCount = stack_count;
            next_buff.InstigatorId = event.data.instigator.net_id;
            next_buff.EntityId = event.data.target.net_id;
            if (disposition.refresh_duration) {
                applyBuffDuration(&next_buff, &buff_data, entry.duration_seconds);
            }
            next_buff.ApplyType = .Common;
            next_buff.IsActive = entry.is_active;
            next_buff.MessageId = -1;

            try appendStackCountNotify(
                &notify.Data,
                combat_common,
                next_buff,
                disposition,
                alloc.arena,
            );
            if (was_active != next_buff.IsActive) {
                try appendActivateBuffNotify(
                    &notify.Data,
                    combat_common,
                    next_buff.HandleId,
                    next_buff.IsActive,
                    alloc.arena,
                );
            }
            try enqueueBuffChangeOnce(
                events,
                event.data.target,
                &buff_change_enqueued,
            );
            try buff_timers.refreshBuff(
                alloc.gpa,
                next_buff,
                &buff_data,
                event.data.target.net_id,
                now_ms,
                disposition,
            );
            buff.* = next_buff;

            if (disposition.execute_periodic_now) {
                try buff_helper.execute_periodic_buff_effects(
                    &notify.Data,
                    event.data.target.net_id,
                    next_buff.InstigatorId,
                    &buff_data,
                    scene,
                    fs,
                    io,
                    query,
                    alloc,
                );
            }
        } else {
            const handle_id = scene.instance.buff_handle + 1;
            var new_buff = Assets.DataTables.createBuffInformation(
                handle_id,
                entry.id,
                event.data.instigator.net_id,
                event.data.target.net_id,
                entry.is_active,
            );
            new_buff.StackCount = stack_count;
            applyBuffDuration(&new_buff, &buff_data, entry.duration_seconds);
            const disposition = BuffTimerScheduler.applicationDisposition(
                &buff_data,
                true,
                false,
                entry.is_active,
            );
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = combat_common,
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = new_buff.HandleId,
                            .Id = new_buff.BuffId,
                            .Level = new_buff.Level,
                            .EntityId = new_buff.EntityId,
                            .InstigatorId = new_buff.InstigatorId,
                            .ApplyType = if (new_buff.ApplyType) |apply_type| @intFromEnum(apply_type) else 0,
                            .IsActive = new_buff.IsActive,
                            .ServerId = new_buff.ServerId,
                            .StackCount = new_buff.StackCount,
                            .CRoundAction = .{ .Duration = new_buff.Duration },
                            .Time = .{ .LeftDuration = new_buff.LeftDuration },
                            .ConfBuffId = new_buff.ConfBuffId,
                        },
                    },
                },
            } });
            try enqueueBuffChangeOnce(
                events,
                event.data.target,
                &buff_change_enqueued,
            );
            try buff_timers.scheduleNewBuff(
                alloc.gpa,
                new_buff,
                &buff_data,
                event.data.target.net_id,
                now_ms,
            );
            buff_component.fight_buff_infos = alloc.gpa.realloc(
                buff_component.fight_buff_infos,
                buff_component.fight_buff_infos.len + 1,
            ) catch |err| {
                buff_timers.cancelHandle(event.data.target.net_id, handle_id);
                return err;
            };
            buff_component.fight_buff_infos[buff_component.fight_buff_infos.len - 1] = new_buff;
            scene.instance.buff_handle = handle_id;

            if (disposition.execute_periodic_now) {
                try buff_helper.execute_periodic_buff_effects(
                    &notify.Data,
                    event.data.target.net_id,
                    new_buff.InstigatorId,
                    &buff_data,
                    scene,
                    fs,
                    io,
                    query,
                    alloc,
                );
            }
        }
    }

    try conn.push(notify);

    log.debug("eid {d}: added these buffs to {d}: {any}", .{
        event.data.instigator.net_id,
        event.data.target.net_id,
        event.data.buffs,
    });
}

fn appendStackCountNotify(
    data: *std.ArrayList(pb.CombatReceiveData),
    combat_common: pb.CombatCommon,
    buff: pb.FightBuffInformation,
    disposition: BuffTimerScheduler.ApplicationDisposition,
    arena: std.mem.Allocator,
) !void {
    var stack_notify: pb.BuffStackCountNotify = .{
        .HandleId = buff.HandleId,
        .NewStackCount = buff.StackCount,
        .InstigatorId = buff.InstigatorId,
        .NotRefreshDuration = !disposition.refresh_duration,
        .NotRefreshPeriod = !disposition.reset_period,
    };
    if (disposition.refresh_duration) {
        stack_notify.Time = .{ .Duration = buff.Duration };
        if (buff.LeftDuration > 0) {
            stack_notify.gFs = .{ .LeftDuration = buff.LeftDuration };
        }
    }
    try data.append(arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = combat_common,
            .Message = .{ .BuffStackCountNotify = stack_notify },
        },
    } });
}

fn appendActivateBuffNotify(
    data: *std.ArrayList(pb.CombatReceiveData),
    combat_common: pb.CombatCommon,
    handle_id: i32,
    is_active: bool,
    arena: std.mem.Allocator,
) !void {
    try data.append(arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = combat_common,
            .Message = .{ .ActivateBuffNotify = .{
                .Handle = handle_id,
                .On = is_active,
            } },
        },
    } });
}

fn enqueueBuffChangeOnce(
    events: *EventQueue,
    entity: Entity,
    enqueued: *bool,
) !void {
    if (enqueued.*) return;
    try events.enqueue(.buff_change, .{ .entity = entity });
    enqueued.* = true;
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

test "stack refresh notify omits preserved duration" {
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer data.deinit(std.testing.allocator);

    try appendStackCountNotify(
        &data,
        .{ .EntityId = 10 },
        .{
            .HandleId = 20,
            .StackCount = 3,
            .InstigatorId = 30,
            .Duration = 2,
            .LeftDuration = 1,
        },
        .{
            .refresh_duration = false,
            .reset_period = false,
            .execute_periodic_now = false,
        },
        std.testing.allocator,
    );

    const notify = data.items[0].Message.?.CombatNotifyData.?
        .Message.?.BuffStackCountNotify.?;
    try std.testing.expect(notify.NotRefreshDuration);
    try std.testing.expect(notify.NotRefreshPeriod);
    try std.testing.expect(notify.Time == null);
    try std.testing.expect(notify.gFs == null);
}

test "stack refresh notify includes refreshed duration" {
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer data.deinit(std.testing.allocator);

    try appendStackCountNotify(
        &data,
        .{ .EntityId = 10 },
        .{
            .HandleId = 20,
            .StackCount = 3,
            .InstigatorId = 30,
            .Duration = 2,
            .LeftDuration = 2,
        },
        .{
            .refresh_duration = true,
            .reset_period = true,
            .execute_periodic_now = false,
        },
        std.testing.allocator,
    );

    const notify = data.items[0].Message.?.CombatNotifyData.?
        .Message.?.BuffStackCountNotify.?;
    try std.testing.expect(!notify.NotRefreshDuration);
    try std.testing.expect(!notify.NotRefreshPeriod);
    try std.testing.expectEqual(@as(f32, 2), notify.Time.?.Duration);
    try std.testing.expectEqual(@as(f32, 2), notify.gFs.?.LeftDuration);
}

test "activation notify carries the changed active state" {
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer data.deinit(std.testing.allocator);

    try appendActivateBuffNotify(
        &data,
        .{ .EntityId = 10 },
        20,
        true,
        std.testing.allocator,
    );

    const notify = data.items[0].Message.?.CombatNotifyData.?
        .Message.?.ActivateBuffNotify.?;
    try std.testing.expectEqual(@as(i32, 20), notify.Handle);
    try std.testing.expect(notify.On);
}
