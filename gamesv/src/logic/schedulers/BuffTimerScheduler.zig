const BuffTimerScheduler = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const buff_helper = @import("../helpers/buff.zig");
const ScheduledJob = @import("ScheduledJob.zig");

const Allocator = std.mem.Allocator;
const Entity = Scene.Entity;

pub const job: ScheduledJob = .{
    .interval = .ms50,
    .event_key = .buff_timer_tick,
};

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

pub fn popDue(scheduler: *BuffTimerScheduler, now_ms: i64) ?Entry {
    if (scheduler.heap.items.len == 0 or scheduler.heap.items[0].due_ms > now_ms) return null;
    return scheduler.removeAt(0);
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

pub fn syncBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    assets: *const Assets,
    buff_info: pb.FightBuffInformation,
    entity_id: i64,
    now_ms: i64,
) !void {
    if (!scheduler.initialized) return;

    scheduler.cancelHandle(entity_id, buff_info.HandleId);
    scheduler.registerBuff(gpa, assets, buff_info, entity_id, now_ms) catch |err| {
        scheduler.invalidate();
        return err;
    };
}

pub fn ensureInitialized(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    if (scheduler.initialized) return;

    scheduler.invalidate();
    errdefer scheduler.invalidate();

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

pub fn drainDue(
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

    while (scheduler.popDue(now_ms)) |entry| {
        switch (entry.kind) {
            .expiry => {
                const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                    scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                    continue;
                };
                syncLeftDuration(lookup[1], entry.due_ms, now_ms);
                const handle_ids = try alloc.arena.alloc(i32, 1);
                handle_ids[0] = entry.handle_id;
                scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                try events.enqueue(.buff_removal, .{
                    .entity = lookup[0],
                    .handle_ids = handle_ids,
                });
            },
            .periodic_pulse => {
                const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                    scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                    continue;
                };
                const buff_info = lookup[1];
                const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse {
                    scheduler.cancelHandle(entry.entity_id, entry.handle_id);
                    continue;
                };
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
                scheduler.upsert(alloc.gpa, .{
                    .kind = .periodic_pulse,
                    .entity_id = entry.entity_id,
                    .handle_id = entry.handle_id,
                    .due_ms = nextPeriodicDueMs(entry.due_ms, now_ms, entry.interval_ms),
                    .interval_ms = entry.interval_ms,
                }) catch |err| {
                    scheduler.invalidate();
                    return err;
                };
            },
        }
    }
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

    if (buff_data.DurationPolicy == .HasDuration and buff_info.LeftDuration > 0) {
        try scheduler.upsert(gpa, .{
            .kind = .expiry,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = now_ms + secondsToMs(buff_info.LeftDuration),
        });
    }

    if (buff_data.Period > 0) {
        const interval_ms = secondsToMs(buff_data.Period);
        try scheduler.upsert(gpa, .{
            .kind = .periodic_pulse,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = now_ms + interval_ms,
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
            .due_ms = now_ms + secondsToMs(buff_info.LeftDuration),
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
            .due_ms = now_ms + interval_ms,
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

fn invalidate(scheduler: *BuffTimerScheduler) void {
    scheduler.heap.clearRetainingCapacity();
    scheduler.positions.clearRetainingCapacity();
    scheduler.initialized = false;
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
    const remaining_ms = @max(due_ms - now_ms, 0);
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
    return @max(1, @as(i64, @intFromFloat(@ceil(seconds * 1000.0))));
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
