const BuffTimerScheduler = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Events = @import("../events.zig");
const Scene = @import("../Scene.zig");
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const buff_helper = @import("../helpers/buff.zig");

const Allocator = std.mem.Allocator;
const Entity = Scene.Entity;
const failure_retry_delay_ms = 50;

pub const Kind = enum(u1) {
    expiry,
    periodic_pulse,
};

pub const Entry = struct {
    kind: Kind,
    entity_id: i64,
    handle_id: i32,
    due_ms: i64,
    interval_ms: i64 = 0,
};

heap: std.ArrayListUnmanaged(Entry) = .empty,
positions: std.AutoHashMapUnmanaged(u128, usize) = .empty,
initialized: bool = false,
rebuild_due_ms: ?i64 = null,

pub fn deinit(scheduler: *BuffTimerScheduler, gpa: Allocator) void {
    scheduler.heap.deinit(gpa);
    scheduler.positions.deinit(gpa);
}

pub fn reset(scheduler: *BuffTimerScheduler, gpa: Allocator) void {
    scheduler.deinit(gpa);
    scheduler.* = .{};
}

pub fn upsert(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    entry: Entry,
) !void {
    const entry_key = key(entry.entity_id, entry.handle_id, entry.kind);
    if (scheduler.positions.get(entry_key)) |index| {
        const previous_due = scheduler.heap.items[index].due_ms;
        scheduler.heap.items[index] = entry;
        if (entry.due_ms < previous_due) {
            scheduler.siftUp(index);
        } else if (entry.due_ms > previous_due) {
            scheduler.siftDown(index);
        }
        return;
    }

    const index = scheduler.heap.items.len;
    try scheduler.heap.append(gpa, entry);
    errdefer _ = scheduler.heap.pop();
    try scheduler.positions.put(gpa, entry_key, index);
    scheduler.siftUp(index);
}

pub fn cancel(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
    kind: Kind,
) void {
    const index = scheduler.positions.get(key(entity_id, handle_id, kind)) orelse return;
    _ = scheduler.removeAt(index);
}

pub fn cancelHandle(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
) void {
    scheduler.cancel(entity_id, handle_id, .expiry);
    scheduler.cancel(entity_id, handle_id, .periodic_pulse);
}

pub fn cancelEntity(scheduler: *BuffTimerScheduler, entity_id: i64) void {
    var index: usize = 0;
    while (index < scheduler.heap.items.len) {
        if (scheduler.heap.items[index].entity_id == entity_id) {
            _ = scheduler.removeAt(index);
        } else {
            index += 1;
        }
    }
}

pub fn peekDueMs(scheduler: *const BuffTimerScheduler) ?i64 {
    return if (scheduler.heap.items.len == 0) null else scheduler.heap.items[0].due_ms;
}

pub fn nextWakeDelayMs(scheduler: *const BuffTimerScheduler, now_ms: i64) ?i64 {
    if (!scheduler.initialized) {
        return deadlineDelayMs(scheduler.rebuild_due_ms orelse return 0, now_ms);
    }
    return deadlineDelayMs(scheduler.peekDueMs() orelse return null, now_ms);
}

fn peekDueEntry(scheduler: *const BuffTimerScheduler, now_ms: i64) ?Entry {
    if (scheduler.heap.items.len == 0 or scheduler.heap.items[0].due_ms > now_ms) return null;
    return scheduler.heap.items[0];
}

pub fn popDue(scheduler: *BuffTimerScheduler, now_ms: i64) ?Entry {
    _ = scheduler.peekDueEntry(now_ms) orelse return null;
    return scheduler.removeAt(0);
}

fn rescheduleExisting(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
    kind: Kind,
    due_ms: i64,
) bool {
    const index = scheduler.positions.get(key(entity_id, handle_id, kind)) orelse return false;
    const previous_due_ms = scheduler.heap.items[index].due_ms;
    scheduler.heap.items[index].due_ms = due_ms;
    if (due_ms < previous_due_ms) {
        scheduler.siftUp(index);
    } else if (due_ms > previous_due_ms) {
        scheduler.siftDown(index);
    }
    return true;
}

fn failureRetryDueMs(now_ms: i64) i64 {
    const due_ms: i128 = @as(i128, now_ms) + failure_retry_delay_ms;
    return @intCast(@min(due_ms, std.math.maxInt(i64)));
}

fn nextPeriodicDueMs(previous_due_ms: i64, now_ms: i64, stored_interval_ms: i64) i64 {
    if (previous_due_ms > now_ms) return previous_due_ms;

    const interval_ms = @max(stored_interval_ms, 1);
    const previous_due: i128 = previous_due_ms;
    const now: i128 = now_ms;
    const interval: i128 = interval_ms;
    const elapsed_periods = @divFloor(now - previous_due, interval) + 1;
    const next_due = previous_due + elapsed_periods * interval;

    return @intCast(@min(next_due, std.math.maxInt(i64)));
}

const PeriodicDisposition = struct {
    execute_effect: bool,
    next_due_ms: i64,
};

const ExpirationDisposition = union(enum) {
    remove,
    retain: i32,
};

pub const ApplicationDisposition = struct {
    refresh_duration: bool,
    reset_period: bool,
    execute_periodic_now: bool,
};

pub fn applicationDisposition(
    buff_data: *const Assets.DataTables.Buff,
    is_new: bool,
    was_active: bool,
    is_active: bool,
) ApplicationDisposition {
    if (is_new) {
        return .{
            .refresh_duration = true,
            .reset_period = buff_data.Period > 0,
            .execute_periodic_now = is_active and
                buff_data.Period > 0 and
                buff_data.bExecutePeriodicEffectOnApplication,
        };
    }

    var disposition: ApplicationDisposition = .{
        .refresh_duration = buff_data.StackDurationRefreshPolicy == .Refresh,
        .reset_period = buff_data.Period > 0 and
            buff_data.StackPeriodResetPolicy == .Refresh,
        .execute_periodic_now = is_active and
            buff_data.Period > 0 and
            buff_data.bExecutePeriodicEffectOnApplication,
    };
    if (was_active == is_active) return disposition;

    disposition.reset_period = false;
    if (!is_active or buff_data.Period <= 0) return disposition;

    switch (buff_data.PeriodicInhibitionPolicy) {
        .None => {},
        .Reset => disposition.reset_period = true,
        .ResetAndExecute => {
            disposition.reset_period = true;
            disposition.execute_periodic_now = true;
        },
    }
    return disposition;
}

fn expirationDisposition(stack_count: i32, remove_number: u8) ExpirationDisposition {
    if (stack_count <= 0 or remove_number == 0 or remove_number >= stack_count) {
        return .remove;
    }
    return .{ .retain = stack_count - remove_number };
}

fn periodicDisposition(entry: Entry, now_ms: i64, is_active: bool) PeriodicDisposition {
    return .{
        .execute_effect = is_active,
        .next_due_ms = nextPeriodicDueMs(entry.due_ms, now_ms, entry.interval_ms),
    };
}

fn preparePeriodic(
    scheduler: *BuffTimerScheduler,
    entry: Entry,
    now_ms: i64,
    is_active: bool,
) ?PeriodicDisposition {
    const disposition = periodicDisposition(entry, now_ms, is_active);
    if (!scheduler.rescheduleExisting(
        entry.entity_id,
        entry.handle_id,
        .periodic_pulse,
        disposition.next_due_ms,
    )) return null;
    return disposition;
}

fn deferExpiryRetry(scheduler: *BuffTimerScheduler, entry: Entry, now_ms: i64) void {
    const retry_due_ms = failureRetryDueMs(now_ms);
    _ = scheduler.rescheduleExisting(
        entry.entity_id,
        entry.handle_id,
        .expiry,
        retry_due_ms,
    );
    if (scheduler.deadline(entry.entity_id, entry.handle_id, .periodic_pulse)) |periodic_due_ms| {
        if (periodic_due_ms <= retry_due_ms) {
            _ = scheduler.rescheduleExisting(
                entry.entity_id,
                entry.handle_id,
                .periodic_pulse,
                retry_due_ms,
            );
        }
    }
}

pub fn deferExpirationRetry(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
    now_ms: i64,
) void {
    const due_ms = scheduler.deadline(entity_id, handle_id, .expiry) orelse return;
    scheduler.deferExpiryRetry(.{
        .kind = .expiry,
        .entity_id = entity_id,
        .handle_id = handle_id,
        .due_ms = due_ms,
    }, now_ms);
}

pub fn scheduleNewBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    buff_info: pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    entity_id: i64,
    now_ms: i64,
) !void {
    if (!scheduler.initialized) return;

    scheduler.registerBuffData(gpa, buff_info, buff_data, entity_id, now_ms) catch |err| {
        scheduler.scheduleRebuild(now_ms);
        return err;
    };
}

pub fn refreshBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    buff_info: pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    entity_id: i64,
    now_ms: i64,
    disposition: ApplicationDisposition,
) !void {
    if (!scheduler.initialized) return;

    if (disposition.refresh_duration) {
        if (buff_data.DurationPolicy == .HasDuration and buff_info.LeftDuration > 0) {
            scheduler.upsert(gpa, .{
                .kind = .expiry,
                .entity_id = entity_id,
                .handle_id = buff_info.HandleId,
                .due_ms = deadlineAfterMs(now_ms, secondsToMs(buff_info.LeftDuration)),
            }) catch |err| {
                scheduler.scheduleRebuild(now_ms);
                return err;
            };
        } else {
            scheduler.cancel(entity_id, buff_info.HandleId, .expiry);
        }
    } else if (buff_data.DurationPolicy == .HasDuration and
        buff_info.LeftDuration > 0 and
        scheduler.deadline(entity_id, buff_info.HandleId, .expiry) == null)
    {
        scheduler.upsert(gpa, .{
            .kind = .expiry,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, secondsToMs(buff_info.LeftDuration)),
        }) catch |err| {
            scheduler.scheduleRebuild(now_ms);
            return err;
        };
    }

    if (buff_data.Period <= 0) {
        scheduler.cancel(entity_id, buff_info.HandleId, .periodic_pulse);
        return;
    }
    if (disposition.reset_period or
        scheduler.deadline(entity_id, buff_info.HandleId, .periodic_pulse) == null)
    {
        const interval_ms = secondsToMs(buff_data.Period);
        scheduler.upsert(gpa, .{
            .kind = .periodic_pulse,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, interval_ms),
            .interval_ms = interval_ms,
        }) catch |err| {
            scheduler.scheduleRebuild(now_ms);
            return err;
        };
    }
}

pub fn ensureInitialized(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    if (scheduler.initialized) return;

    scheduler.clear();
    errdefer scheduler.scheduleRebuild(now_ms);

    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.buffs)) |entity_id, maybe_buffs| {
        const buffs = maybe_buffs orelse continue;
        for (buffs.fight_buff_infos) |buff_info| {
            try scheduler.registerBuff(
                gpa,
                assets,
                buff_info,
                entity_id.net_id,
                now_ms,
            );
        }
    }

    scheduler.initialized = true;
    scheduler.rebuild_due_ms = null;
}

pub fn ensureEntityRegistered(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    entity_id: i64,
    now_ms: i64,
) !void {
    try scheduler.ensureInitialized(gpa, scene, assets, now_ms);

    const index = scene.net_id_map.get(entity_id) orelse return;
    const slice = scene.entities.slice();
    const buffs = slice.items(.buffs)[index] orelse return;
    for (buffs.fight_buff_infos) |buff_info| {
        try scheduler.registerMissingBuff(gpa, assets, buff_info, entity_id, now_ms);
    }
}

pub fn ensureAllRegistered(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    try scheduler.ensureInitialized(gpa, scene, assets, now_ms);

    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.buffs)) |entity_id, maybe_buffs| {
        const buffs = maybe_buffs orelse continue;
        for (buffs.fight_buff_infos) |buff_info| {
            try scheduler.registerMissingBuff(
                gpa,
                assets,
                buff_info,
                entity_id.net_id,
                now_ms,
            );
        }
    }
}

pub fn syncHandleLeftDuration(
    scheduler: *const BuffTimerScheduler,
    scene: *Scene,
    entity_id: i64,
    handle_id: i32,
    now_ms: i64,
) void {
    const lookup = scheduler.findEntityBuff(scene, entity_id, handle_id) orelse return;
    scheduler.syncBuffLeftDuration(lookup[1], entity_id, now_ms);
}

pub fn syncEntityLeftDurations(
    scheduler: *const BuffTimerScheduler,
    scene: *Scene,
    entity_id: i64,
    now_ms: i64,
) void {
    const index = scene.net_id_map.get(entity_id) orelse return;
    const slice = scene.entities.slice();
    const buffs = if (slice.items(.buffs)[index]) |*component| component else return;
    for (buffs.fight_buff_infos) |*buff_info| {
        scheduler.syncBuffLeftDuration(buff_info, entity_id, now_ms);
    }
}

pub fn syncAllLeftDurations(
    scheduler: *const BuffTimerScheduler,
    scene: *Scene,
    now_ms: i64,
) void {
    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.buffs)) |entity_id, maybe_buffs| {
        const buffs = if (maybe_buffs) |*component| component else continue;
        for (buffs.fight_buff_infos) |*buff_info| {
            scheduler.syncBuffLeftDuration(buff_info, entity_id.net_id, now_ms);
        }
    }
}

pub fn drainOneDue(
    scheduler: *BuffTimerScheduler,
    event: EventQueue.Dequeue(.buff_timer_tick),
    events: *EventQueue,
    scene: *Scene,
    assets: *const Assets,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    alloc: mem.Alloc,
) !void {
    const now_ms = event.data.now_ms;
    try scheduler.ensureInitialized(alloc.gpa, scene, assets, now_ms);

    const entry = scheduler.peekDueEntry(now_ms) orelse return;
    switch (entry.kind) {
        .expiry => {
            const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                return;
            };
            const buff_info = lookup[1];
            const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse {
                scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                return;
            };
            switch (expirationDisposition(
                buff_info.StackCount,
                buff_data.StackExpirationRemoveNumber,
            )) {
                .retain => |new_stack_count| {
                    scheduler.completePartialExpiration(
                        entry,
                        lookup[0],
                        buff_info,
                        &buff_data,
                        new_stack_count,
                        now_ms,
                        events,
                        combat_receive_pack,
                        alloc,
                    ) catch |err| {
                        scheduler.deferExpiryRetry(entry, now_ms);
                        return err;
                    };
                    return;
                },
                .remove => {},
            }

            const handle_ids = alloc.arena.alloc(i32, 1) catch |err| {
                scheduler.deferExpiryRetry(entry, now_ms);
                return err;
            };
            handle_ids[0] = entry.handle_id;
            const follow_up_buffs = routineExpirationEntries(
                alloc.arena,
                assets,
                buff_data.RoutineExpirationEffects,
            ) catch |err| {
                scheduler.deferExpiryRetry(entry, now_ms);
                return err;
            };
            const instigator = if (scene.net_id_map.get(buff_info.InstigatorId)) |index|
                Entity{ .index = index, .net_id = buff_info.InstigatorId }
            else
                lookup[0];
            events.enqueue(.buff_removal, .{
                .entity = lookup[0],
                .handle_ids = handle_ids,
                .natural_expiration = .{
                    .now_ms = now_ms,
                    .instigator = instigator,
                    .follow_up_buffs = follow_up_buffs,
                },
            }) catch |err| {
                scheduler.deferExpiryRetry(entry, now_ms);
                return err;
            };
        },
        .periodic_pulse => {
            const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                return;
            };
            const buff_info = lookup[1];
            const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse {
                scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                return;
            };
            const disposition = scheduler.preparePeriodic(entry, now_ms, buff_info.IsActive) orelse {
                scheduler.scheduleRebuild(now_ms);
                return error.MissingTimerEntry;
            };
            if (disposition.execute_effect) {
                try buff_helper.execute_periodic_buff_effects(
                    combat_receive_pack,
                    entry.entity_id,
                    buff_info.InstigatorId,
                    &buff_data,
                    scene,
                    fs,
                    io,
                    query,
                    alloc,
                );
            }
        },
    }
}

fn completePartialExpiration(
    scheduler: *BuffTimerScheduler,
    entry: Entry,
    entity: Entity,
    buff_info: *pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    new_stack_count: i32,
    now_ms: i64,
    events: *EventQueue,
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    alloc: mem.Alloc,
) !void {
    const configured_duration = buff_helper.configured_duration_seconds(buff_data);
    const duration = if (configured_duration > 0) configured_duration else -1;
    var stack_notify: pb.BuffStackCountNotify = .{
        .HandleId = entry.handle_id,
        .NewStackCount = new_stack_count,
        .InstigatorId = buff_info.InstigatorId,
        .Time = .{ .Duration = duration },
    };
    if (duration > 0) {
        stack_notify.gFs = .{ .LeftDuration = duration };
    }

    try combat_receive_pack.append(alloc.arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entry.entity_id },
            .Message = .{ .BuffStackCountNotify = stack_notify },
        },
    } });
    try events.enqueue(.buff_change, .{ .entity = entity });

    const reset_period = buff_data.Period > 0 and
        buff_data.StackPeriodResetPolicy == .Refresh;
    const periodic_due_ms = if (reset_period)
        deadlineAfterMs(now_ms, secondsToMs(buff_data.Period))
    else
        0;
    if (reset_period and
        scheduler.deadline(entry.entity_id, entry.handle_id, .periodic_pulse) == null)
    {
        const interval_ms = secondsToMs(buff_data.Period);
        try scheduler.upsert(alloc.gpa, .{
            .kind = .periodic_pulse,
            .entity_id = entry.entity_id,
            .handle_id = entry.handle_id,
            .due_ms = periodic_due_ms,
            .interval_ms = interval_ms,
        });
    }

    if (duration > 0) {
        const expiry_rescheduled = scheduler.rescheduleExisting(
            entry.entity_id,
            entry.handle_id,
            .expiry,
            deadlineAfterMs(now_ms, secondsToMs(duration)),
        );
        std.debug.assert(expiry_rescheduled);
    } else {
        scheduler.cancel(entry.entity_id, entry.handle_id, .expiry);
    }
    if (reset_period) {
        const period_rescheduled = scheduler.rescheduleExisting(
            entry.entity_id,
            entry.handle_id,
            .periodic_pulse,
            periodic_due_ms,
        );
        std.debug.assert(period_rescheduled);
    }

    buff_info.StackCount = new_stack_count;
    buff_info.Duration = duration;
    buff_info.LeftDuration = duration;
}

fn routineExpirationEntries(
    arena: Allocator,
    assets: *const Assets,
    ids: []const i64,
) ![]Events.BuffAdditionEntry {
    const entries = try arena.alloc(Events.BuffAdditionEntry, ids.len);
    var count: usize = 0;
    for (ids) |id| {
        if (assets.tables.buff.getDataById(id) == null) continue;
        entries[count] = .{ .id = id, .is_active = true };
        count += 1;
    }
    return entries[0..count];
}

fn registerBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    assets: *const Assets,
    buff_info: pb.FightBuffInformation,
    entity_id: i64,
    now_ms: i64,
) !void {
    const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse return;
    try scheduler.registerBuffData(gpa, buff_info, &buff_data, entity_id, now_ms);
}

fn registerBuffData(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    buff_info: pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    entity_id: i64,
    now_ms: i64,
) !void {
    if (buff_data.DurationPolicy == .HasDuration and buff_info.LeftDuration > 0) {
        try scheduler.upsert(gpa, .{
            .kind = .expiry,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, secondsToMs(buff_info.LeftDuration)),
        });
    }

    if (buff_data.Period > 0) {
        const interval_ms = secondsToMs(buff_data.Period);
        try scheduler.upsert(gpa, .{
            .kind = .periodic_pulse,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, interval_ms),
            .interval_ms = interval_ms,
        });
    }
}

fn registerMissingBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    assets: *const Assets,
    buff_info: pb.FightBuffInformation,
    entity_id: i64,
    now_ms: i64,
) !void {
    const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse return;

    if (buff_data.DurationPolicy == .HasDuration and
        buff_info.LeftDuration > 0 and
        scheduler.deadline(entity_id, buff_info.HandleId, .expiry) == null)
    {
        try scheduler.upsert(gpa, .{
            .kind = .expiry,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, secondsToMs(buff_info.LeftDuration)),
        });
    }

    if (buff_data.Period > 0 and
        scheduler.deadline(entity_id, buff_info.HandleId, .periodic_pulse) == null)
    {
        const interval_ms = secondsToMs(buff_data.Period);
        try scheduler.upsert(gpa, .{
            .kind = .periodic_pulse,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = deadlineAfterMs(now_ms, interval_ms),
            .interval_ms = interval_ms,
        });
    }
}

fn findEntityBuff(
    scheduler: *const BuffTimerScheduler,
    scene: *Scene,
    entity_id: i64,
    handle_id: i32,
) ?struct { Entity, *pb.FightBuffInformation } {
    _ = scheduler;
    const index = scene.net_id_map.get(entity_id) orelse return null;
    const slice = scene.entities.slice();
    const buffs = if (slice.items(.buffs)[index]) |*component| component else return null;
    const buff = buffs.getByHandleId(handle_id) orelse return null;
    return .{
        .{ .index = index, .net_id = entity_id },
        buff,
    };
}

fn deadline(
    scheduler: *const BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
    kind: Kind,
) ?i64 {
    const index = scheduler.positions.get(key(entity_id, handle_id, kind)) orelse return null;
    return scheduler.heap.items[index].due_ms;
}

fn clear(scheduler: *BuffTimerScheduler) void {
    scheduler.heap.clearRetainingCapacity();
    scheduler.positions.clearRetainingCapacity();
    scheduler.initialized = false;
    scheduler.rebuild_due_ms = null;
}

fn scheduleRebuild(scheduler: *BuffTimerScheduler, now_ms: i64) void {
    scheduler.clear();
    scheduler.rebuild_due_ms = failureRetryDueMs(now_ms);
}

fn deadlineDelayMs(due_ms: i64, now_ms: i64) i64 {
    if (due_ms <= now_ms) return 0;
    const delay: i128 = @as(i128, due_ms) - now_ms;
    return @intCast(@min(delay, std.math.maxInt(i64)));
}

fn removeAt(scheduler: *BuffTimerScheduler, index: usize) Entry {
    const removed = scheduler.heap.items[index];
    _ = scheduler.positions.remove(key(removed.entity_id, removed.handle_id, removed.kind));

    const last_index = scheduler.heap.items.len - 1;
    if (index == last_index) {
        _ = scheduler.heap.pop();
        return removed;
    }

    scheduler.heap.items[index] = scheduler.heap.items[last_index];
    _ = scheduler.heap.pop();
    scheduler.positions.getPtr(key(
        scheduler.heap.items[index].entity_id,
        scheduler.heap.items[index].handle_id,
        scheduler.heap.items[index].kind,
    )).?.* = index;

    if (index > 0 and lessThan(scheduler.heap.items[index], scheduler.heap.items[(index - 1) / 2])) {
        scheduler.siftUp(index);
    } else {
        scheduler.siftDown(index);
    }

    return removed;
}

fn siftUp(scheduler: *BuffTimerScheduler, start_index: usize) void {
    var index = start_index;
    while (index > 0) {
        const parent = (index - 1) / 2;
        if (!lessThan(scheduler.heap.items[index], scheduler.heap.items[parent])) break;
        scheduler.swapEntries(index, parent);
        index = parent;
    }
}

fn siftDown(scheduler: *BuffTimerScheduler, start_index: usize) void {
    var index = start_index;
    while (true) {
        const left = index * 2 + 1;
        if (left >= scheduler.heap.items.len) return;
        const right = left + 1;
        const child = if (right < scheduler.heap.items.len and
            lessThan(scheduler.heap.items[right], scheduler.heap.items[left])) right else left;
        if (!lessThan(scheduler.heap.items[child], scheduler.heap.items[index])) return;
        scheduler.swapEntries(index, child);
        index = child;
    }
}

fn swapEntries(scheduler: *BuffTimerScheduler, a: usize, b: usize) void {
    std.mem.swap(Entry, &scheduler.heap.items[a], &scheduler.heap.items[b]);
    scheduler.positions.getPtr(key(
        scheduler.heap.items[a].entity_id,
        scheduler.heap.items[a].handle_id,
        scheduler.heap.items[a].kind,
    )).?.* = a;
    scheduler.positions.getPtr(key(
        scheduler.heap.items[b].entity_id,
        scheduler.heap.items[b].handle_id,
        scheduler.heap.items[b].kind,
    )).?.* = b;
}

fn lessThan(a: Entry, b: Entry) bool {
    if (a.due_ms != b.due_ms) return a.due_ms < b.due_ms;
    if (a.entity_id != b.entity_id) return a.entity_id < b.entity_id;
    if (a.handle_id != b.handle_id) return a.handle_id < b.handle_id;
    return @intFromEnum(a.kind) < @intFromEnum(b.kind);
}

fn key(entity_id: i64, handle_id: i32, kind: Kind) u128 {
    const entity_bits: u64 = @bitCast(entity_id);
    const handle_bits: u32 = @bitCast(handle_id);
    return (@as(u128, entity_bits) << 33) |
        (@as(u128, handle_bits) << 1) |
        @intFromEnum(kind);
}

fn syncLeftDuration(
    buff_info: *pb.FightBuffInformation,
    due_ms: i64,
    now_ms: i64,
) void {
    const remaining_ms: i128 = @max(
        @as(i128, due_ms) - @as(i128, now_ms),
        0,
    );
    var remaining_seconds = @as(f32, @floatFromInt(remaining_ms)) / 1000.0;
    if (buff_info.Duration > 0 and remaining_seconds > buff_info.Duration) {
        remaining_seconds = buff_info.Duration;
    }

    buff_info.LeftDuration = remaining_seconds;
}

fn syncBuffLeftDuration(
    scheduler: *const BuffTimerScheduler,
    buff_info: *pb.FightBuffInformation,
    entity_id: i64,
    now_ms: i64,
) void {
    const due_ms = scheduler.deadline(entity_id, buff_info.HandleId, .expiry) orelse return;
    syncLeftDuration(buff_info, due_ms, now_ms);
}

fn secondsToMs(seconds: f32) i64 {
    const milliseconds = @as(f64, seconds) * 1000.0;
    if (std.math.isNan(milliseconds) or milliseconds <= 1.0) return 1;

    const max_ms: f64 = @floatFromInt(std.math.maxInt(i64));
    if (milliseconds >= max_ms) return std.math.maxInt(i64);
    return @intFromFloat(@ceil(milliseconds));
}

fn deadlineAfterMs(now_ms: i64, delay_ms: i64) i64 {
    const deadline_value: i128 = @as(i128, now_ms) + @as(i128, delay_ms);
    return @intCast(std.math.clamp(
        deadline_value,
        std.math.minInt(i64),
        std.math.maxInt(i64),
    ));
}

test "buff wake delays follow the exact earliest deadline" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    try std.testing.expectEqual(@as(?i64, 0), scheduler.nextWakeDelayMs(1_000));
    scheduler.initialized = true;
    try std.testing.expect(scheduler.nextWakeDelayMs(1_000) == null);

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .expiry,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 2_000,
    });
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 2,
        .handle_id = 1,
        .due_ms = 3_000,
    });
    try std.testing.expectEqual(@as(?i64, 1_000), scheduler.nextWakeDelayMs(1_000));

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 2,
        .handle_id = 1,
        .due_ms = 1_500,
    });
    try std.testing.expectEqual(@as(?i64, 500), scheduler.nextWakeDelayMs(1_000));
    try std.testing.expectEqual(@as(?i64, 0), scheduler.nextWakeDelayMs(1_500));
    try std.testing.expectEqual(@as(?i64, 0), scheduler.nextWakeDelayMs(1_501));

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 2,
        .handle_id = 1,
        .due_ms = 4_000,
    });
    try std.testing.expectEqual(@as(?i64, 1_000), scheduler.nextWakeDelayMs(1_000));
    scheduler.cancel(1, 1, .expiry);
    try std.testing.expectEqual(@as(?i64, 3_000), scheduler.nextWakeDelayMs(1_000));

    scheduler.cancel(2, 1, .periodic_pulse);
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .expiry,
        .entity_id = 3,
        .handle_id = 1,
        .due_ms = std.math.maxInt(i64),
    });
    try std.testing.expectEqual(
        @as(?i64, std.math.maxInt(i64)),
        scheduler.nextWakeDelayMs(std.math.minInt(i64)),
    );
}

test "invalidated buff timers use only a bounded rebuild backoff" {
    var scheduler: BuffTimerScheduler = .{ .initialized = true };
    defer scheduler.deinit(std.testing.allocator);

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .expiry,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 2_000,
    });
    scheduler.scheduleRebuild(1_000);

    try std.testing.expect(!scheduler.initialized);
    try std.testing.expect(scheduler.peekDueMs() == null);
    try std.testing.expectEqual(@as(?i64, 50), scheduler.nextWakeDelayMs(1_000));
    try std.testing.expectEqual(@as(?i64, 1), scheduler.nextWakeDelayMs(1_049));
    try std.testing.expectEqual(@as(?i64, 0), scheduler.nextWakeDelayMs(1_050));

    scheduler.scheduleRebuild(std.math.maxInt(i64));
    try std.testing.expectEqual(
        @as(?i64, 0),
        scheduler.nextWakeDelayMs(std.math.maxInt(i64)),
    );
}

test "periodic deadlines preserve phase while skipping missed pulses" {
    try std.testing.expectEqual(@as(i64, 1_100), nextPeriodicDueMs(1_000, 1_000, 100));
    try std.testing.expectEqual(@as(i64, 1_100), nextPeriodicDueMs(1_000, 1_025, 100));
    try std.testing.expectEqual(@as(i64, 1_400), nextPeriodicDueMs(1_000, 1_350, 100));
    try std.testing.expectEqual(@as(i64, 1_200), nextPeriodicDueMs(1_000, 1_100, 100));
}

test "periodic deadlines do not accumulate delayed-wake drift" {
    const first = nextPeriodicDueMs(1_000, 1_025, 100);
    const second = nextPeriodicDueMs(first, 1_235, 100);
    const third = nextPeriodicDueMs(second, 1_460, 100);

    try std.testing.expectEqual(@as(i64, 1_100), first);
    try std.testing.expectEqual(@as(i64, 1_300), second);
    try std.testing.expectEqual(@as(i64, 1_500), third);
}

test "periodic deadlines floor invalid intervals and cannot wrap" {
    try std.testing.expectEqual(@as(i64, 101), nextPeriodicDueMs(100, 100, 0));
    try std.testing.expectEqual(@as(i64, 101), nextPeriodicDueMs(100, 100, -10));
    try std.testing.expectEqual(
        std.math.maxInt(i64),
        nextPeriodicDueMs(std.math.maxInt(i64) - 1, std.math.maxInt(i64), 1),
    );
    try std.testing.expectEqual(@as(i64, 200), nextPeriodicDueMs(200, 100, 50));
}

test "inactive periodic buffs skip effects while retaining cadence" {
    const entry: Entry = .{
        .kind = .periodic_pulse,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 1_000,
        .interval_ms = 100,
    };

    const inactive = periodicDisposition(entry, 1_025, false);
    try std.testing.expect(!inactive.execute_effect);
    try std.testing.expectEqual(@as(i64, 1_100), inactive.next_due_ms);

    const delayed = periodicDisposition(entry, 1_350, false);
    try std.testing.expect(!delayed.execute_effect);
    try std.testing.expectEqual(@as(i64, 1_400), delayed.next_due_ms);
}

test "periodic activation changes execution without changing cadence" {
    const entry: Entry = .{
        .kind = .periodic_pulse,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 1_000,
        .interval_ms = 100,
    };

    const inactive = periodicDisposition(entry, 1_025, false);
    const active = periodicDisposition(entry, 1_025, true);

    try std.testing.expect(!inactive.execute_effect);
    try std.testing.expect(active.execute_effect);
    try std.testing.expectEqual(inactive.next_due_ms, active.next_due_ms);
}

test "application disposition honors refresh and inhibition policies" {
    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.Period = 0.5;
    buff_data.bExecutePeriodicEffectOnApplication = true;
    buff_data.StackDurationRefreshPolicy = .Refresh;
    buff_data.StackPeriodResetPolicy = .Refresh;
    buff_data.PeriodicInhibitionPolicy = .None;

    const new_active = applicationDisposition(&buff_data, true, false, true);
    try std.testing.expect(new_active.refresh_duration);
    try std.testing.expect(new_active.reset_period);
    try std.testing.expect(new_active.execute_periodic_now);

    const new_inactive = applicationDisposition(&buff_data, true, false, false);
    try std.testing.expect(!new_inactive.execute_periodic_now);

    buff_data.StackDurationRefreshPolicy = .NoRefresh;
    buff_data.StackPeriodResetPolicy = .NoRefresh;
    const unchanged = applicationDisposition(&buff_data, false, true, true);
    try std.testing.expect(!unchanged.refresh_duration);
    try std.testing.expect(!unchanged.reset_period);
    try std.testing.expect(unchanged.execute_periodic_now);

    buff_data.StackPeriodResetPolicy = .Refresh;
    const deactivated = applicationDisposition(&buff_data, false, true, false);
    try std.testing.expect(!deactivated.reset_period);
    try std.testing.expect(!deactivated.execute_periodic_now);

    buff_data.bExecutePeriodicEffectOnApplication = false;
    buff_data.PeriodicInhibitionPolicy = .None;
    const activated_preserving = applicationDisposition(&buff_data, false, false, true);
    try std.testing.expect(!activated_preserving.reset_period);
    try std.testing.expect(!activated_preserving.execute_periodic_now);

    buff_data.PeriodicInhibitionPolicy = .Reset;
    const activated_reset = applicationDisposition(&buff_data, false, false, true);
    try std.testing.expect(activated_reset.reset_period);
    try std.testing.expect(!activated_reset.execute_periodic_now);

    buff_data.PeriodicInhibitionPolicy = .ResetAndExecute;
    const activated_executing = applicationDisposition(&buff_data, false, false, true);
    try std.testing.expect(activated_executing.reset_period);
    try std.testing.expect(activated_executing.execute_periodic_now);

    buff_data.bExecutePeriodicEffectOnApplication = true;
    const overlapping_execution = applicationDisposition(&buff_data, false, false, true);
    try std.testing.expect(overlapping_execution.reset_period);
    try std.testing.expect(overlapping_execution.execute_periodic_now);
}

test "refresh policies preserve or replace independent deadlines" {
    var scheduler: BuffTimerScheduler = .{ .initialized = true };
    defer scheduler.deinit(std.testing.allocator);

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .expiry,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 500,
    });
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 400,
        .interval_ms = 500,
    });

    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationPolicy = .HasDuration;
    buff_data.Period = 0.5;
    const buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .LeftDuration = 2,
    };
    try scheduler.refreshBuff(
        std.testing.allocator,
        buff_info,
        &buff_data,
        10,
        100,
        .{
            .refresh_duration = false,
            .reset_period = false,
            .execute_periodic_now = false,
        },
    );
    try std.testing.expectEqual(@as(?i64, 500), scheduler.deadline(10, 20, .expiry));
    try std.testing.expectEqual(@as(?i64, 400), scheduler.deadline(10, 20, .periodic_pulse));

    try scheduler.refreshBuff(
        std.testing.allocator,
        buff_info,
        &buff_data,
        10,
        100,
        .{
            .refresh_duration = true,
            .reset_period = true,
            .execute_periodic_now = false,
        },
    );
    try std.testing.expectEqual(@as(?i64, 2_100), scheduler.deadline(10, 20, .expiry));
    try std.testing.expectEqual(@as(?i64, 600), scheduler.deadline(10, 20, .periodic_pulse));
}

test "preserved missing deadlines are reconstructed without application execution" {
    var scheduler: BuffTimerScheduler = .{ .initialized = true };
    defer scheduler.deinit(std.testing.allocator);

    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationPolicy = .HasDuration;
    buff_data.Period = 0.5;
    const buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .LeftDuration = 2,
    };
    try scheduler.refreshBuff(
        std.testing.allocator,
        buff_info,
        &buff_data,
        10,
        100,
        .{
            .refresh_duration = false,
            .reset_period = false,
            .execute_periodic_now = false,
        },
    );

    try std.testing.expectEqual(@as(?i64, 2_100), scheduler.deadline(10, 20, .expiry));
    try std.testing.expectEqual(@as(?i64, 600), scheduler.deadline(10, 20, .periodic_pulse));
}

test "new buff scheduling installs future deadlines only" {
    var scheduler: BuffTimerScheduler = .{ .initialized = true };
    defer scheduler.deinit(std.testing.allocator);

    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationPolicy = .HasDuration;
    buff_data.Period = 0.5;
    const buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .LeftDuration = 2,
    };
    try scheduler.scheduleNewBuff(
        std.testing.allocator,
        buff_info,
        &buff_data,
        10,
        100,
    );

    try std.testing.expectEqual(@as(?i64, 2_100), scheduler.deadline(10, 20, .expiry));
    try std.testing.expectEqual(@as(?i64, 600), scheduler.deadline(10, 20, .periodic_pulse));
}

test "peeking a due entry retains it until completion" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    const entry: Entry = .{
        .kind = .expiry,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 100,
    };
    try scheduler.upsert(std.testing.allocator, entry);

    try std.testing.expectEqual(entry, scheduler.peekDueEntry(100).?);
    try std.testing.expectEqual(@as(?i64, 100), scheduler.peekDueMs());
    try std.testing.expectEqual(@as(usize, 1), scheduler.heap.items.len);
    try std.testing.expectEqual(@as(usize, 1), scheduler.positions.count());
}

test "expiration disposition removes or retains configured stacks" {
    try std.testing.expect(expirationDisposition(0, 1) == .remove);
    try std.testing.expect(expirationDisposition(-1, 1) == .remove);
    try std.testing.expect(expirationDisposition(3, 0) == .remove);
    try std.testing.expect(expirationDisposition(3, 3) == .remove);
    try std.testing.expect(expirationDisposition(3, 4) == .remove);

    const retained = expirationDisposition(3, 1);
    try std.testing.expect(retained == .retain);
    try std.testing.expectEqual(@as(i32, 2), retained.retain);
}

test "partial expiration rearms duration and refreshes periodic cadence" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    const expiry: Entry = .{
        .kind = .expiry,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 100,
    };
    try scheduler.upsert(std.testing.allocator, expiry);
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 100,
        .interval_ms = 500,
    });

    var buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .StackCount = 3,
        .InstigatorId = 30,
        .Duration = 2,
        .LeftDuration = 0,
    };
    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationMagnitude = &.{2};
    buff_data.Period = 0.5;
    buff_data.StackPeriodResetPolicy = .Refresh;
    var events: EventQueue = .{ .arena = std.testing.allocator };
    defer events.deque.deinit(std.testing.allocator);
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer combat_receive_pack.deinit(std.testing.allocator);

    try scheduler.completePartialExpiration(
        expiry,
        .{ .index = 0, .net_id = 10 },
        &buff_info,
        &buff_data,
        2,
        100,
        &events,
        &combat_receive_pack,
        .{
            .gpa = std.testing.allocator,
            .arena = std.testing.allocator,
        },
    );

    try std.testing.expectEqual(@as(i32, 2), buff_info.StackCount);
    try std.testing.expectEqual(@as(f32, 2), buff_info.Duration);
    try std.testing.expectEqual(@as(f32, 2), buff_info.LeftDuration);
    try std.testing.expectEqual(@as(?i64, 2_100), scheduler.deadline(10, 20, .expiry));
    try std.testing.expectEqual(@as(?i64, 600), scheduler.deadline(10, 20, .periodic_pulse));
    try std.testing.expectEqual(@as(usize, 1), combat_receive_pack.items.len);
    const combat_notify = combat_receive_pack.items[0].Message.?.CombatNotifyData.?;
    const stack_notify = combat_notify.Message.?.BuffStackCountNotify.?;
    try std.testing.expectEqual(@as(i32, 20), stack_notify.HandleId);
    try std.testing.expectEqual(@as(i32, 2), stack_notify.NewStackCount);
    try std.testing.expectEqual(@as(f32, 2), stack_notify.Time.?.Duration);
    try std.testing.expectEqual(@as(f32, 2), stack_notify.gFs.?.LeftDuration);
    try std.testing.expectEqual(
        .buff_change,
        std.meta.activeTag(events.deque.popFront().?),
    );
}

test "partial expiration preserves periodic phase when configured" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    const expiry: Entry = .{
        .kind = .expiry,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 100,
    };
    try scheduler.upsert(std.testing.allocator, expiry);
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 350,
        .interval_ms = 500,
    });

    var buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .StackCount = 3,
    };
    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationMagnitude = &.{2};
    buff_data.Period = 0.5;
    buff_data.StackPeriodResetPolicy = .NoRefresh;
    var events: EventQueue = .{ .arena = std.testing.allocator };
    defer events.deque.deinit(std.testing.allocator);
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer combat_receive_pack.deinit(std.testing.allocator);

    try scheduler.completePartialExpiration(
        expiry,
        .{ .index = 0, .net_id = 10 },
        &buff_info,
        &buff_data,
        2,
        100,
        &events,
        &combat_receive_pack,
        .{
            .gpa = std.testing.allocator,
            .arena = std.testing.allocator,
        },
    );

    try std.testing.expectEqual(@as(?i64, 350), scheduler.deadline(10, 20, .periodic_pulse));
}

test "partial expiration cancels non-positive configured duration" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    const expiry: Entry = .{
        .kind = .expiry,
        .entity_id = 10,
        .handle_id = 20,
        .due_ms = 100,
    };
    try scheduler.upsert(std.testing.allocator, expiry);

    var buff_info: pb.FightBuffInformation = .{
        .HandleId = 20,
        .StackCount = 2,
        .Duration = 1,
        .LeftDuration = 0,
    };
    var buff_data: Assets.DataTables.Buff = undefined;
    buff_data.DurationMagnitude = &.{-1};
    buff_data.Period = 0;
    buff_data.StackPeriodResetPolicy = .NoRefresh;
    var events: EventQueue = .{ .arena = std.testing.allocator };
    defer events.deque.deinit(std.testing.allocator);
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer combat_receive_pack.deinit(std.testing.allocator);

    try scheduler.completePartialExpiration(
        expiry,
        .{ .index = 0, .net_id = 10 },
        &buff_info,
        &buff_data,
        1,
        100,
        &events,
        &combat_receive_pack,
        .{
            .gpa = std.testing.allocator,
            .arena = std.testing.allocator,
        },
    );

    try std.testing.expectEqual(@as(i32, 1), buff_info.StackCount);
    try std.testing.expectEqual(@as(f32, -1), buff_info.Duration);
    try std.testing.expectEqual(@as(f32, -1), buff_info.LeftDuration);
    try std.testing.expect(scheduler.deadline(10, 20, .expiry) == null);
    const combat_notify = combat_receive_pack.items[0].Message.?.CombatNotifyData.?;
    const stack_notify = combat_notify.Message.?.BuffStackCountNotify.?;
    try std.testing.expectEqual(@as(f32, -1), stack_notify.Time.?.Duration);
    try std.testing.expect(stack_notify.gFs == null);
}

test "failed expiry preparation defers its handle without blocking others" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    const expiry: Entry = .{
        .kind = .expiry,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 100,
    };
    try scheduler.upsert(std.testing.allocator, expiry);
    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 125,
        .interval_ms = 100,
    });
    const unrelated: Entry = .{
        .kind = .expiry,
        .entity_id = 2,
        .handle_id = 1,
        .due_ms = 110,
    };
    try scheduler.upsert(std.testing.allocator, unrelated);

    scheduler.deferExpiryRetry(expiry, 100);

    try std.testing.expectEqual(@as(?i64, 150), scheduler.deadline(1, 1, .expiry));
    try std.testing.expectEqual(@as(?i64, 150), scheduler.deadline(1, 1, .periodic_pulse));
    try std.testing.expectEqual(unrelated, scheduler.popDue(110).?);
    try std.testing.expectEqual(expiry.kind, scheduler.popDue(150).?.kind);
    try std.testing.expectEqual(Kind.periodic_pulse, scheduler.popDue(150).?.kind);
}

test "periodic failure retains the next aligned deadline" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(std.testing.allocator);

    try scheduler.upsert(std.testing.allocator, .{
        .kind = .periodic_pulse,
        .entity_id = 1,
        .handle_id = 1,
        .due_ms = 100,
        .interval_ms = 100,
    });

    const first = scheduler.peekDueEntry(125).?;
    const first_disposition = scheduler.preparePeriodic(first, 125, true).?;
    try std.testing.expect(first_disposition.execute_effect);
    try std.testing.expectEqual(@as(?i64, 200), scheduler.deadline(1, 1, .periodic_pulse));

    const second = scheduler.peekDueEntry(250).?;
    _ = scheduler.preparePeriodic(second, 250, true).?;
    try std.testing.expectEqual(@as(?i64, 300), scheduler.deadline(1, 1, .periodic_pulse));
    try std.testing.expectEqual(@as(usize, 1), scheduler.heap.items.len);
    try std.testing.expectEqual(@as(usize, 1), scheduler.positions.count());
}

test "failure retry deadlines clamp without wrapping" {
    try std.testing.expectEqual(@as(i64, 1_050), failureRetryDueMs(1_000));
    try std.testing.expectEqual(std.math.maxInt(i64), failureRetryDueMs(std.math.maxInt(i64)));
}

test "buff seconds convert to milliseconds with flooring and saturation" {
    try std.testing.expectEqual(@as(i64, 1), secondsToMs(0));
    try std.testing.expectEqual(@as(i64, 1), secondsToMs(-1));
    try std.testing.expectEqual(@as(i64, 1), secondsToMs(0.0001));
    try std.testing.expectEqual(@as(i64, 1_500), secondsToMs(1.5));
    try std.testing.expectEqual(std.math.maxInt(i64), secondsToMs(std.math.floatMax(f32)));
    try std.testing.expectEqual(std.math.maxInt(i64), secondsToMs(std.math.inf(f32)));
    try std.testing.expectEqual(@as(i64, 1), secondsToMs(std.math.nan(f32)));
}

test "buff deadlines saturate without wrapping" {
    try std.testing.expectEqual(@as(i64, 1_500), deadlineAfterMs(1_000, 500));
    try std.testing.expectEqual(
        std.math.maxInt(i64),
        deadlineAfterMs(std.math.maxInt(i64), 1),
    );
    try std.testing.expectEqual(
        std.math.minInt(i64),
        deadlineAfterMs(std.math.minInt(i64), -1),
    );
}

test "remaining buff duration handles integer timestamp limits" {
    var buff_info: pb.FightBuffInformation = .{
        .Duration = std.math.floatMax(f32),
        .LeftDuration = std.math.floatMax(f32),
    };

    syncLeftDuration(&buff_info, std.math.maxInt(i64), std.math.minInt(i64));
    try std.testing.expect(std.math.isFinite(buff_info.LeftDuration));
    try std.testing.expect(buff_info.LeftDuration > 0);

    syncLeftDuration(&buff_info, std.math.minInt(i64), std.math.maxInt(i64));
    try std.testing.expectEqual(@as(f32, 0), buff_info.LeftDuration);
}
