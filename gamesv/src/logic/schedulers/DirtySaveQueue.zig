const DirtySaveQueue = @This();
const std = @import("std");
const FileSystem = @import("common").FileSystem;
const comp_util = @import("../component/comp_util.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const BuffTimerScheduler = @import("BuffTimerScheduler.zig");
const Assets = @import("../../data/Assets.zig");

const Allocator = std.mem.Allocator;
const flush_delay_ms = 30_000;
const ScheduledJob = @import("ScheduledJob.zig");

pub const job: ScheduledJob = .{
    .interval = .s1,
    .event_key = .dirty_save_tick,
};

role_ids: std.ArrayListUnmanaged(i32) = .empty,
weapon_ids: std.ArrayListUnmanaged(i32) = .empty,
position_entity_ids: std.ArrayListUnmanaged(i64) = .empty,
buff_entity_ids: std.ArrayListUnmanaged(i64) = .empty,
scene_instance_dirty: bool = false,
flush_due_ms: ?i64 = null,

pub fn deinit(queue: *DirtySaveQueue, gpa: Allocator) void {
    queue.role_ids.deinit(gpa);
    queue.weapon_ids.deinit(gpa);
    queue.position_entity_ids.deinit(gpa);
    queue.buff_entity_ids.deinit(gpa);
}

pub fn nextWakeDelayMs(queue: *const DirtySaveQueue, now_ms: i64) ?i64 {
    const due_ms = queue.flush_due_ms orelse return null;
    if (due_ms <= now_ms) return 0;

    const delay: i128 = @as(i128, due_ms) - now_ms;
    return @intCast(@min(delay, std.math.maxInt(i64)));
}

pub fn isDue(queue: *const DirtySaveQueue, now_ms: i64) bool {
    const due_ms = queue.flush_due_ms orelse return false;
    return due_ms <= now_ms;
}

pub fn enqueueDue(
    queue: *const DirtySaveQueue,
    event_queue: *EventQueue,
    now_ms: i64,
) !bool {
    if (!queue.isDue(now_ms)) return false;
    try event_queue.enqueue(.dirty_save_tick, .{ .now_ms = now_ms });
    return true;
}

pub fn markRole(queue: *DirtySaveQueue, gpa: Allocator, role_id: i32, now_ms: i64) !void {
    try appendUnique(i32, gpa, &queue.role_ids, role_id);
    queue.armIfNeeded(now_ms);
}

pub fn markWeapon(queue: *DirtySaveQueue, gpa: Allocator, weapon_id: i32, now_ms: i64) !void {
    try appendUnique(i32, gpa, &queue.weapon_ids, weapon_id);
    queue.armIfNeeded(now_ms);
}

pub fn markMovement(queue: *DirtySaveQueue, gpa: Allocator, entity: Scene.Entity, now_ms: i64) !void {
    queue.scene_instance_dirty = true;
    errdefer queue.armIfNeeded(now_ms);
    try appendUnique(i64, gpa, &queue.position_entity_ids, entity.net_id);
    queue.armIfNeeded(now_ms);
}

pub fn markBuffChange(queue: *DirtySaveQueue, gpa: Allocator, entity: Scene.Entity, now_ms: i64) !void {
    queue.scene_instance_dirty = true;
    errdefer queue.armIfNeeded(now_ms);
    try appendUnique(i64, gpa, &queue.buff_entity_ids, entity.net_id);
    queue.armIfNeeded(now_ms);
}

pub fn flush(
    queue: *DirtySaveQueue,
    gpa: Allocator,
    fs: *FileSystem,
    role_comp: *const PlayerRoleComponent,
    weapon_comp: *const PlayerWeaponComponent,
    scene: ?*Scene,
    buff_timers: *BuffTimerScheduler,
    assets: *const Assets,
    now_ms: i64,
) !void {
    if (!queue.hasPending()) {
        queue.flush_due_ms = null;
        return;
    }

    queue.flushPending(gpa, fs, role_comp, weapon_comp, scene, buff_timers, assets, now_ms) catch |err| {
        queue.scheduleRetry(now_ms);
        return err;
    };
    queue.clearRetainingCapacity();
}

fn flushPending(
    queue: *DirtySaveQueue,
    gpa: Allocator,
    fs: *FileSystem,
    role_comp: *const PlayerRoleComponent,
    weapon_comp: *const PlayerWeaponComponent,
    scene: ?*Scene,
    buff_timers: *BuffTimerScheduler,
    assets: *const Assets,
    now_ms: i64,
) !void {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    for (queue.role_ids.items) |role_id| {
        const role_info = role_comp.role_map.getPtr(role_id) orelse continue;
        const path = try std.fmt.allocPrint(arena, "player/{}/role/{}", .{ role_comp.player_id, role_id });
        try comp_util.saveStruct(fs, role_info, path, arena);
    }

    for (queue.weapon_ids.items) |weapon_id| {
        const weapon_info = weapon_comp.weapon_map.getPtr(weapon_id) orelse continue;
        const path = try std.fmt.allocPrint(arena, "player/{}/weapon/{}", .{ weapon_comp.player_id, weapon_id });
        try comp_util.saveStruct(fs, weapon_info, path, arena);
    }

    if (scene) |scene_ref| {
        if (queue.scene_instance_dirty) {
            try scene_ref.saveInstance(fs, gpa);
        }

        for (queue.position_entity_ids.items) |entity_id| {
            const entity = entityByNetId(scene_ref, entity_id) orelse continue;
            try scene_ref.saveComponents(
                fs,
                gpa,
                entity,
                &.{Scene.Entity.PositionComponent},
            );
        }

        if (queue.buff_entity_ids.items.len != 0) {
            for (queue.buff_entity_ids.items) |entity_id| {
                try buff_timers.ensureEntityRegistered(
                    gpa,
                    scene_ref,
                    assets,
                    entity_id,
                    now_ms,
                );
            }
        }
        for (queue.buff_entity_ids.items) |entity_id| {
            const entity = entityByNetId(scene_ref, entity_id) orelse continue;
            buff_timers.syncEntityLeftDurations(scene_ref, entity_id, now_ms);
            try scene_ref.saveComponents(
                fs,
                gpa,
                entity,
                &.{Scene.Entity.FightBuffComponent},
            );
        }
    }
}

pub fn saveAllBuffs(
    gpa: Allocator,
    fs: *FileSystem,
    scene: *Scene,
    buff_timers: *BuffTimerScheduler,
    assets: *const Assets,
    now_ms: i64,
) !void {
    try buff_timers.ensureAllRegistered(gpa, scene, assets, now_ms);
    buff_timers.syncAllLeftDurations(scene, now_ms);

    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.buffs), 0..) |entity_id, maybe_buffs, index| {
        if (maybe_buffs == null) continue;
        try scene.saveComponents(
            fs,
            gpa,
            .{ .index = index, .net_id = entity_id.net_id },
            &.{Scene.Entity.FightBuffComponent},
        );
    }
}

fn hasPending(queue: *const DirtySaveQueue) bool {
    return queue.scene_instance_dirty or
        queue.role_ids.items.len != 0 or
        queue.weapon_ids.items.len != 0 or
        queue.position_entity_ids.items.len != 0 or
        queue.buff_entity_ids.items.len != 0;
}

fn clearRetainingCapacity(queue: *DirtySaveQueue) void {
    queue.role_ids.clearRetainingCapacity();
    queue.weapon_ids.clearRetainingCapacity();
    queue.position_entity_ids.clearRetainingCapacity();
    queue.buff_entity_ids.clearRetainingCapacity();
    queue.scene_instance_dirty = false;
    queue.flush_due_ms = null;
}

fn armIfNeeded(queue: *DirtySaveQueue, now_ms: i64) void {
    if (queue.flush_due_ms == null and queue.hasPending()) {
        queue.flush_due_ms = deadlineAfter(now_ms);
    }
}

fn scheduleRetry(queue: *DirtySaveQueue, now_ms: i64) void {
    queue.flush_due_ms = deadlineAfter(now_ms);
}

fn deadlineAfter(now_ms: i64) i64 {
    const deadline: i128 = @as(i128, now_ms) + flush_delay_ms;
    return @intCast(@min(deadline, std.math.maxInt(i64)));
}

fn entityByNetId(scene: *Scene, entity_id: i64) ?Scene.Entity {
    const index = scene.net_id_map.get(entity_id) orelse return null;
    return .{ .index = index, .net_id = entity_id };
}

fn appendUnique(
    comptime T: type,
    gpa: Allocator,
    list: *std.ArrayListUnmanaged(T),
    value: T,
) !void {
    if (std.mem.indexOfScalar(T, list.items, value) != null) return;
    try list.append(gpa, value);
}

test "dirty save deadline starts on the first mutation and is not postponed" {
    var queue: DirtySaveQueue = .{};
    defer queue.deinit(std.testing.allocator);

    try std.testing.expect(queue.nextWakeDelayMs(100) == null);
    try std.testing.expect(!queue.isDue(100));

    try queue.markRole(std.testing.allocator, 1, 100);
    try std.testing.expectEqual(@as(?i64, 30_000), queue.nextWakeDelayMs(100));
    try std.testing.expectEqual(@as(?i64, 1), queue.nextWakeDelayMs(30_099));
    try std.testing.expectEqual(@as(?i64, 0), queue.nextWakeDelayMs(30_100));
    try std.testing.expect(queue.isDue(30_100));

    try queue.markWeapon(std.testing.allocator, 2, 10_000);
    try std.testing.expectEqual(@as(?i64, 20_100), queue.nextWakeDelayMs(10_000));
}

test "all dirty paths arm one deadline and successful completion clears it" {
    var queue: DirtySaveQueue = .{};
    defer queue.deinit(std.testing.allocator);

    try queue.markMovement(std.testing.allocator, .{ .index = 0, .net_id = 10 }, 1_000);
    try queue.markBuffChange(std.testing.allocator, .{ .index = 0, .net_id = 20 }, 2_000);
    try queue.markRole(std.testing.allocator, 3, 3_000);
    try queue.markWeapon(std.testing.allocator, 4, 4_000);

    try std.testing.expect(queue.hasPending());
    try std.testing.expectEqual(@as(?i64, 31_000), queue.flush_due_ms);
    queue.clearRetainingCapacity();
    try std.testing.expect(!queue.hasPending());
    try std.testing.expect(queue.flush_due_ms == null);
}

test "failed completion retains dirty state and schedules a stable retry" {
    var queue: DirtySaveQueue = .{};
    defer queue.deinit(std.testing.allocator);

    try queue.markRole(std.testing.allocator, 1, 100);
    queue.scheduleRetry(40_000);
    try std.testing.expect(queue.hasPending());
    try std.testing.expectEqual(@as(?i64, 70_000), queue.flush_due_ms);

    try queue.markWeapon(std.testing.allocator, 2, 50_000);
    try std.testing.expectEqual(@as(?i64, 70_000), queue.flush_due_ms);
}

test "due dirty save enqueues one timestamped event" {
    var queue: DirtySaveQueue = .{};
    defer queue.deinit(std.testing.allocator);
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var event_queue: EventQueue = .{ .arena = arena.allocator() };

    try std.testing.expect(!try queue.enqueueDue(&event_queue, 100));
    try queue.markRole(std.testing.allocator, 1, 100);
    try std.testing.expect(!try queue.enqueueDue(&event_queue, 30_099));
    try std.testing.expect(try queue.enqueueDue(&event_queue, 30_100));

    const event = event_queue.deque.popFront().?;
    try std.testing.expectEqual(@as(i64, 30_100), event.dirty_save_tick.now_ms);
    try std.testing.expect(event_queue.deque.popFront() == null);
}

test "dirty save deadlines clamp without wrapping" {
    try std.testing.expectEqual(std.math.maxInt(i64), deadlineAfter(std.math.maxInt(i64)));
    try std.testing.expectEqual(
        @as(?i64, std.math.maxInt(i64)),
        (DirtySaveQueue{ .flush_due_ms = std.math.maxInt(i64) }).nextWakeDelayMs(std.math.minInt(i64)),
    );
}
