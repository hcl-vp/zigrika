const std = @import("std");
const BuffTimerScheduler = @import("logic/schedulers/BuffTimerScheduler.zig");

const Entry = BuffTimerScheduler.Entry;
const Kind = BuffTimerScheduler.Kind;
const testing = std.testing;

fn entry(entity_id: i64, handle_id: i32, kind: Kind, due_ms: i64) Entry {
    return .{
        .entity_id = entity_id,
        .handle_id = handle_id,
        .kind = kind,
        .due_ms = due_ms,
        .interval_ms = if (kind == .periodic_pulse) 100 else 0,
    };
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
