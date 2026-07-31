const TimedLogicScheduler = @This();
const std = @import("std");
const EventQueue = @import("../EventQueue.zig");
const BuffTimerScheduler = @import("BuffTimerScheduler.zig");
const DirtySaveQueue = @import("DirtySaveQueue.zig");
const ScheduledJob = @import("ScheduledJob.zig");

const Interval = ScheduledJob.Interval;
const intervals = std.enums.values(Interval);
const scene_time_job: ScheduledJob = .{
    .interval = .ms50,
    .event_key = .tick_time,
};
const fsm_timer_job: ScheduledJob = .{
    .interval = .ms50,
    .event_key = .fsm_timer_tick,
};
const level_play_job: ScheduledJob = .{
    .interval = .ms250,
    .event_key = .level_play_timer_tick,
};
const scene_cleanup_job: ScheduledJob = .{
    .interval = .s1,
    .event_key = .scene_cleanup_tick,
};
const jobs = [_]ScheduledJob{
    scene_time_job,
    BuffTimerScheduler.job,
    fsm_timer_job,
    level_play_job,
    scene_cleanup_job,
    DirtySaveQueue.job,
};

comptime {
    for (intervals) |interval| {
        var has_job = false;
        for (jobs) |job| {
            if (job.interval == interval) has_job = true;
        }
        if (!has_job) @compileError("scheduled interval has no jobs: " ++ @tagName(interval));
    }

    for (jobs, 0..) |job, index| {
        const Payload = @FieldType(EventQueue.Event, @tagName(job.event_key));
        if (!@hasField(Payload, "now_ms")) {
            @compileError("scheduled event has no now_ms field: " ++ @tagName(job.event_key));
        } else if (@FieldType(Payload, "now_ms") != i64) {
            @compileError("scheduled event now_ms field is not i64: " ++ @tagName(job.event_key));
        }

        for (jobs[index + 1 ..]) |other| {
            if (job.event_key == other.event_key) {
                @compileError("scheduled event is registered more than once: " ++ @tagName(job.event_key));
            }
        }
    }
}

next_due_ms: [intervals.len]i64 = [_]i64{0} ** intervals.len,

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

    inline for (intervals, 0..) |interval, index| {
        if (scheduler.next_due_ms[index] <= now_ms) {
            scheduler.next_due_ms[index] = now_ms + @intFromEnum(interval);
            inline for (jobs) |job| {
                if (job.interval == interval) {
                    try event_queue.enqueue(job.event_key, .{ .now_ms = now_ms });
                }
            }
            did_enqueue = true;
        }
    }

    return did_enqueue;
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
