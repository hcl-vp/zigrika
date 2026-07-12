const TimedLogicScheduler = @This();
const std = @import("std");
const EventQueue = @import("../EventQueue.zig");

const Lane = enum {
    fast,
    level_play,
    cleanup,
    dirty_save,
};

const lanes = std.enums.values(Lane);

next_due_ms: [lanes.len]i64 = [_]i64{0} ** lanes.len,

pub fn reset(scheduler: *TimedLogicScheduler) void {
    scheduler.* = .{};
}

pub fn nextWakeDelayMs(
    scheduler: *const TimedLogicScheduler,
    io: std.Io,
    scene_active: bool,
) ?i64 {
    if (!scene_active) return null;

    const now_ms = nowMs(io);
    var delay_ms: i64 = std.math.maxInt(i64);
    for (scheduler.next_due_ms) |next_ms| {
        delay_ms = @min(delay_ms, bucketDelayMs(next_ms, now_ms));
    }

    return delay_ms;
}

pub fn shouldDrain(
    scheduler: *const TimedLogicScheduler,
    scene_active: bool,
    now_ms: i64,
) bool {
    if (!scene_active) return false;

    for (scheduler.next_due_ms) |next_ms| {
        if (isDue(next_ms, now_ms)) return true;
    }

    return false;
}

pub fn drainDue(
    scheduler: *TimedLogicScheduler,
    io: std.Io,
    scene_active: bool,
    event_queue: *EventQueue,
) !bool {
    if (!scene_active) return false;

    const now_ms = nowMs(io);
    for (&scheduler.next_due_ms) |*next_ms| {
        if (next_ms.* == 0) next_ms.* = now_ms;
    }

    var did_enqueue = false;

    inline for (lanes, 0..) |lane, index| {
        if (scheduler.next_due_ms[index] <= now_ms) {
            scheduler.next_due_ms[index] = now_ms + intervalMs(lane);
            switch (lane) {
                .fast => {
                    try event_queue.enqueue(.tick_time, .{});
                    try event_queue.enqueue(.buff_timer_tick, .{ .now_ms = now_ms });
                    try event_queue.enqueue(.fsm_timer_tick, .{ .now_ms = now_ms });
                },
                .level_play => try event_queue.enqueue(.level_play_timer_tick, .{ .now_ms = now_ms }),
                .cleanup => try event_queue.enqueue(.scene_cleanup_tick, .{ .now_ms = now_ms }),
                .dirty_save => try event_queue.enqueue(.dirty_save_tick, .{ .now_ms = now_ms }),
            }
            did_enqueue = true;
        }
    }

    return did_enqueue;
}

fn intervalMs(lane: Lane) i64 {
    return switch (lane) {
        .fast => 50,
        .level_play => 250,
        .cleanup => 1_000,
        .dirty_save => 30_000,
    };
}

fn bucketDelayMs(next_ms: i64, now_ms: i64) i64 {
    if (next_ms == 0 or next_ms <= now_ms) return 0;
    return next_ms - now_ms;
}

fn isDue(next_ms: i64, now_ms: i64) bool {
    return next_ms == 0 or next_ms <= now_ms;
}

fn nowMs(io: std.Io) i64 {
    const clock: std.Io.Clock = .awake;
    return clock.now(io).toMilliseconds();
}
