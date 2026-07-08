const std = @import("std");
const State = @import("../network/State.zig");
const EventQueue = @import("EventQueue.zig");
const logic_handlers = @import("handlers.zig");

const fast_tick_interval_ms: i64 = 100;
const levelplay_timer_tick_interval_ms: i64 = 250;

pub fn nextWakeDelayMs(state: *State) ?i64 {
    if (state.scene == null) return null;

    const now_ms = nowMs(state);
    return @min(
        bucketDelayMs(state.next_timed_logic_check_ms, now_ms),
        bucketDelayMs(state.next_levelplay_timer_tick_ms, now_ms),
    );
}

pub fn drainDue(state: *State) !bool {
    if (state.scene == null) return false;

    const now_ms = nowMs(state);
    if (state.next_timed_logic_check_ms == 0) {
        state.next_timed_logic_check_ms = now_ms;
    }
    if (state.next_levelplay_timer_tick_ms == 0) {
        state.next_levelplay_timer_tick_ms = now_ms;
    }

    var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
    var did_enqueue = false;

    if (state.next_timed_logic_check_ms <= now_ms) {
        state.next_timed_logic_check_ms = now_ms + fast_tick_interval_ms;
        try event_queue.enqueue(.tick_time, .{});
        try event_queue.enqueue(.buff_timer_tick, .{ .now_ms = now_ms });
        try event_queue.enqueue(.fsm_timer_tick, .{ .now_ms = now_ms });
        did_enqueue = true;
    }

    if (state.next_levelplay_timer_tick_ms <= now_ms) {
        state.next_levelplay_timer_tick_ms = now_ms + levelplay_timer_tick_interval_ms;
        try event_queue.enqueue(.level_play_timer_tick, .{ .now_ms = now_ms });
        did_enqueue = true;
    }

    if (!did_enqueue) return false;

    try logic_handlers.drainEventQueue(&event_queue, state);

    return true;
}

fn bucketDelayMs(next_ms: i64, now_ms: i64) i64 {
    if (next_ms == 0 or next_ms <= now_ms) return 0;
    return next_ms - now_ms;
}

fn nowMs(state: *State) i64 {
    const rtc: std.Io.Clock = .real;
    return rtc.now(state.io).toMilliseconds();
}
