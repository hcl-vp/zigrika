const std = @import("std");
const BuffTimerScheduler = @import("logic/schedulers/BuffTimerScheduler.zig");
const DirtySaveQueue = @import("logic/schedulers/DirtySaveQueue.zig");
const SessionConnection = @import("network/Connection.zig");
const Scene = @import("logic/Scene.zig");
const EntityComponentStorage = @import("logic/component/entity/EntityComponentStorage.zig");
const pb = @import("proto").pb;

const Entry = BuffTimerScheduler.Entry;
const Kind = BuffTimerScheduler.Kind;
const testing = std.testing;

test "include dirty save queue tests" {
    _ = DirtySaveQueue;
}

test "include session connection tests" {
    _ = SessionConnection;
}

fn entry(entity_id: i64, handle_id: i32, kind: Kind, due_ms: i64) Entry {
    return .{
        .entity_id = entity_id,
        .handle_id = handle_id,
        .kind = kind,
        .due_ms = due_ms,
        .interval_ms = if (kind == .periodic_pulse) 100 else 0,
    };
}

fn initScene() Scene {
    return .{
        .player_id = 1,
        .instance_id = 1,
        .instance = undefined,
        .formation_info = undefined,
        .explore_tools_info = undefined,
    };
}

fn appendEntity(scene: *Scene, entity_id: i64, infos: []pb.FightBuffInformation) !void {
    const index = scene.entities.len;
    try scene.entities.append(testing.allocator, EntityComponentStorage{
        .entity_id = .{ .net_id = entity_id },
        .config = .{
            .camp = 0,
            .config_id = 1,
            .config_type = .level,
            .entity_type = .player,
            .state = .default,
        },
        .buffs = .{ .fight_buff_infos = infos },
    });
    try scene.net_id_map.put(testing.allocator, entity_id, index);
}

fn deinitScene(scene: *Scene) void {
    const slice = scene.entities.slice();
    for (slice.items(.buffs)) |maybe_buffs| {
        if (maybe_buffs) |buffs| testing.allocator.free(buffs.fight_buff_infos);
    }
    scene.entities.deinit(testing.allocator);
    scene.net_id_map.deinit(testing.allocator);
}

test "orders deadlines and stable tie breakers" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);

    try scheduler.upsert(testing.allocator, entry(2, 1, .periodic_pulse, 100));
    try scheduler.upsert(testing.allocator, entry(1, 2, .expiry, 100));
    try scheduler.upsert(testing.allocator, entry(1, 1, .periodic_pulse, 100));
    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 100));
    try scheduler.upsert(testing.allocator, entry(3, 1, .expiry, 50));

    try testing.expectEqual(@as(i64, 50), scheduler.peekDueMs().?);
    try testing.expectEqual(entry(3, 1, .expiry, 50), scheduler.popDue(50).?);
    try testing.expectEqual(entry(1, 1, .expiry, 100), scheduler.popDue(100).?);
    try testing.expectEqual(entry(1, 1, .periodic_pulse, 100), scheduler.popDue(100).?);
    try testing.expectEqual(entry(1, 2, .expiry, 100), scheduler.popDue(100).?);
    try testing.expectEqual(entry(2, 1, .periodic_pulse, 100), scheduler.popDue(100).?);
    try testing.expect(scheduler.popDue(100) == null);
}

test "upsert reorders deadlines without duplicating keys" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);

    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 100));
    try scheduler.upsert(testing.allocator, entry(2, 1, .expiry, 200));
    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 300));
    try testing.expectEqual(@as(i64, 200), scheduler.peekDueMs().?);

    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 50));
    try testing.expectEqual(entry(1, 1, .expiry, 50), scheduler.popDue(50).?);
    try testing.expectEqual(entry(2, 1, .expiry, 200), scheduler.popDue(200).?);
    try testing.expect(scheduler.peekDueMs() == null);
}

test "cancel operations preserve heap indexes" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);

    try scheduler.upsert(testing.allocator, entry(1, 10, .expiry, 40));
    try scheduler.upsert(testing.allocator, entry(1, 10, .periodic_pulse, 50));
    try scheduler.upsert(testing.allocator, entry(1, 20, .expiry, 30));
    try scheduler.upsert(testing.allocator, entry(2, 10, .expiry, 20));
    try scheduler.upsert(testing.allocator, entry(2, 20, .expiry, 10));

    scheduler.cancel(2, 10, .expiry);
    scheduler.cancelHandle(1, 10);
    try scheduler.upsert(testing.allocator, entry(1, 20, .expiry, 5));

    try testing.expectEqual(entry(1, 20, .expiry, 5), scheduler.popDue(5).?);
    try testing.expectEqual(entry(2, 20, .expiry, 10), scheduler.popDue(10).?);
    try testing.expect(scheduler.peekDueMs() == null);

    try scheduler.upsert(testing.allocator, entry(3, 10, .expiry, 10));
    try scheduler.upsert(testing.allocator, entry(3, 20, .periodic_pulse, 20));
    try scheduler.upsert(testing.allocator, entry(4, 10, .expiry, 30));
    scheduler.cancelEntity(3);

    try testing.expectEqual(entry(4, 10, .expiry, 30), scheduler.popDue(30).?);
    try testing.expect(scheduler.peekDueMs() == null);
}

test "pop due leaves future entries queued" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);

    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 100));
    try testing.expect(scheduler.popDue(99) == null);
    try testing.expectEqual(@as(i64, 100), scheduler.peekDueMs().?);
    try testing.expectEqual(entry(1, 1, .expiry, 100), scheduler.popDue(100).?);
}

test "reset releases state and permits reuse" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);

    try scheduler.upsert(testing.allocator, entry(1, 1, .expiry, 100));
    scheduler.reset(testing.allocator);
    try testing.expect(scheduler.peekDueMs() == null);

    try scheduler.upsert(testing.allocator, entry(2, 2, .periodic_pulse, 200));
    try testing.expectEqual(entry(2, 2, .periodic_pulse, 200), scheduler.popDue(200).?);
}

test "materializes remaining duration without changing deadlines" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);
    var scene = initScene();
    defer deinitScene(&scene);

    const infos = try testing.allocator.dupe(pb.FightBuffInformation, &.{
        .{ .HandleId = 1, .Duration = 2, .LeftDuration = 2 },
    });
    try appendEntity(&scene, 10, infos);
    try scheduler.upsert(testing.allocator, entry(10, 1, .expiry, 2_000));

    scheduler.syncEntityLeftDurations(&scene, 10, 500);
    try testing.expectApproxEqAbs(@as(f32, 1.5), infos[0].LeftDuration, 0.0001);
    scheduler.syncEntityLeftDurations(&scene, 10, 500);
    try testing.expectApproxEqAbs(@as(f32, 1.5), infos[0].LeftDuration, 0.0001);
    try testing.expectEqual(@as(i64, 2_000), scheduler.peekDueMs().?);

    scheduler.syncHandleLeftDuration(&scene, 10, 1, 2_000);
    try testing.expectEqual(@as(f32, 0), infos[0].LeftDuration);
    scheduler.syncHandleLeftDuration(&scene, 10, 1, 3_000);
    try testing.expectEqual(@as(f32, 0), infos[0].LeftDuration);
}

test "clamps updated deadlines and leaves missing expiry values unchanged" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);
    var scene = initScene();
    defer deinitScene(&scene);

    const infos = try testing.allocator.dupe(pb.FightBuffInformation, &.{
        .{ .HandleId = 1, .Duration = 2, .LeftDuration = 2 },
        .{ .HandleId = 2, .Duration = 8, .LeftDuration = 7 },
        .{ .HandleId = 3, .Duration = -1, .LeftDuration = -1 },
    });
    try appendEntity(&scene, 10, infos);

    try scheduler.upsert(testing.allocator, entry(10, 1, .expiry, 5_000));
    scheduler.syncEntityLeftDurations(&scene, 10, 0);
    try testing.expectEqual(@as(f32, 2), infos[0].LeftDuration);
    try testing.expectEqual(@as(f32, 7), infos[1].LeftDuration);
    try testing.expectEqual(@as(f32, -1), infos[2].LeftDuration);

    try scheduler.upsert(testing.allocator, entry(10, 1, .expiry, 1_000));
    scheduler.syncEntityLeftDurations(&scene, 10, 250);
    try testing.expectApproxEqAbs(@as(f32, 0.75), infos[0].LeftDuration, 0.0001);
}

test "entity and scene synchronization stay within their requested scope" {
    var scheduler: BuffTimerScheduler = .{};
    defer scheduler.deinit(testing.allocator);
    var scene = initScene();
    defer deinitScene(&scene);

    const first = try testing.allocator.dupe(pb.FightBuffInformation, &.{
        .{ .HandleId = 1, .Duration = 5, .LeftDuration = 5 },
        .{ .HandleId = 2, .Duration = 5, .LeftDuration = 5 },
    });
    const second = try testing.allocator.dupe(pb.FightBuffInformation, &.{
        .{ .HandleId = 1, .Duration = 5, .LeftDuration = 5 },
    });
    try appendEntity(&scene, 10, first);
    try appendEntity(&scene, 20, second);
    try scheduler.upsert(testing.allocator, entry(10, 1, .expiry, 1_000));
    try scheduler.upsert(testing.allocator, entry(10, 2, .expiry, 2_000));
    try scheduler.upsert(testing.allocator, entry(20, 1, .expiry, 3_000));

    scheduler.syncHandleLeftDuration(&scene, 10, 1, 500);
    try testing.expectApproxEqAbs(@as(f32, 0.5), first[0].LeftDuration, 0.0001);
    try testing.expectEqual(@as(f32, 5), first[1].LeftDuration);
    try testing.expectEqual(@as(f32, 5), second[0].LeftDuration);

    scheduler.syncEntityLeftDurations(&scene, 10, 500);
    try testing.expectApproxEqAbs(@as(f32, 1.5), first[1].LeftDuration, 0.0001);
    try testing.expectEqual(@as(f32, 5), second[0].LeftDuration);

    scheduler.syncAllLeftDurations(&scene, 500);
    try testing.expectApproxEqAbs(@as(f32, 2.5), second[0].LeftDuration, 0.0001);
}
