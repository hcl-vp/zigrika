const std = @import("std");
const State = @import("../network/State.zig");
const EventQueue = @import("EventQueue.zig");
const logic_handlers = @import("handlers.zig");

const scene_time_tick_interval_ms: i64 = 100;

pub fn nextWakeDelayMs(state: *State) ?i64 {
    if (state.scene == null) return null;

    const now_ms = nowMs(state);
    if (state.next_timed_logic_check_ms == 0 or state.next_timed_logic_check_ms <= now_ms) {
        return 0;
    }

    return state.next_timed_logic_check_ms - now_ms;
}

pub fn drainDue(state: *State) !bool {
    if (state.scene == null) return false;

    const now_ms = nowMs(state);
    if (state.next_timed_logic_check_ms == 0) {
        state.next_timed_logic_check_ms = now_ms;
    }

    if (state.next_timed_logic_check_ms > now_ms) return false;

    state.next_timed_logic_check_ms = now_ms + scene_time_tick_interval_ms;

    var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
    try event_queue.enqueue(.tick_time, .{});
    try logic_handlers.drainEventQueue(&event_queue, state);

    return true;
}

fn nowMs(state: *State) i64 {
    const rtc: std.Io.Clock = .real;
    return rtc.now(state.io).toMilliseconds();
}
