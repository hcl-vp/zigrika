const TimeInfo = @This();
const std = @import("std");

flow_timestamp_at_anchor: f64 = 0.0,
monotonic_anchor_timestamp: i64 = 0,
dilation: f64 = 0.0,

pub fn currentFlowTimestamp(time: TimeInfo, monotonic_now: i64) i64 {
    return @intFromFloat(@trunc(time.currentFlowTimestampPrecise(monotonic_now)));
}

pub fn setDilation(time: *TimeInfo, monotonic_now: i64, new_dilation: f64) void {
    if (!std.math.isFinite(new_dilation)) return;

    time.flow_timestamp_at_anchor = time.currentFlowTimestampPrecise(monotonic_now);
    time.monotonic_anchor_timestamp = monotonic_now;
    time.dilation = new_dilation;
}

pub fn reset(time: *TimeInfo, real_now: i64, monotonic_now: i64) void {
    time.* = .{
        .flow_timestamp_at_anchor = @floatFromInt(real_now),
        .monotonic_anchor_timestamp = monotonic_now,
        .dilation = 1.0,
    };
}

fn currentFlowTimestampPrecise(time: TimeInfo, monotonic_now: i64) f64 {
    const elapsed = @max(monotonic_now - time.monotonic_anchor_timestamp, 0);
    return time.flow_timestamp_at_anchor +
        (@as(f64, @floatFromInt(elapsed)) * time.dilation);
}

test "current flow timestamp follows dilation" {
    var time: TimeInfo = .{};

    time.reset(1_000, 100);
    try std.testing.expectEqual(@as(i64, 1_250), time.currentFlowTimestamp(350));

    time.reset(1_000, 100);
    time.setDilation(100, 0.0);
    try std.testing.expectEqual(@as(i64, 1_000), time.currentFlowTimestamp(350));

    time.reset(1_000, 100);
    time.setDilation(100, 0.5);
    try std.testing.expectEqual(@as(i64, 1_125), time.currentFlowTimestamp(350));

    time.reset(1_000, 100);
    time.setDilation(100, 2.0);
    try std.testing.expectEqual(@as(i64, 1_500), time.currentFlowTimestamp(350));

    time.reset(1_000, 100);
    time.setDilation(100, -1.0);
    try std.testing.expectEqual(@as(i64, 750), time.currentFlowTimestamp(350));
}

test "dilation changes materialize elapsed flow at the previous rate" {
    var time: TimeInfo = .{};
    time.reset(1_000, 100);

    time.setDilation(200, 0.5);
    time.setDilation(300, 2.0);

    try std.testing.expectEqual(@as(i64, 1_350), time.currentFlowTimestamp(400));
}

test "lazy reads do not mutate or accumulate rounding drift" {
    var time: TimeInfo = .{};
    time.reset(1_000, 0);
    time.setDilation(0, 0.5);

    for (1..1_001) |now| {
        _ = time.currentFlowTimestamp(@intCast(now));
    }

    try std.testing.expectEqual(@as(i64, 1_500), time.currentFlowTimestamp(1_000));
    try std.testing.expectEqual(@as(f64, 1_000.0), time.flow_timestamp_at_anchor);
    try std.testing.expectEqual(@as(i64, 0), time.monotonic_anchor_timestamp);
}

test "fractional flow survives repeated reanchoring" {
    var time: TimeInfo = .{};
    time.reset(1_000, 0);
    time.setDilation(0, 0.5);

    for (1..1_001) |now| {
        time.setDilation(@intCast(now), 0.5);
    }

    try std.testing.expectEqual(@as(i64, 1_500), time.currentFlowTimestamp(1_000));
}

test "non-finite dilation is ignored" {
    var time: TimeInfo = .{};
    time.reset(1_000, 0);
    time.setDilation(100, 2.0);
    const expected = time;

    time.setDilation(200, std.math.inf(f64));
    try std.testing.expectEqual(expected.flow_timestamp_at_anchor, time.flow_timestamp_at_anchor);
    try std.testing.expectEqual(expected.monotonic_anchor_timestamp, time.monotonic_anchor_timestamp);
    try std.testing.expectEqual(expected.dilation, time.dilation);

    time.setDilation(200, std.math.nan(f64));
    try std.testing.expectEqual(expected.flow_timestamp_at_anchor, time.flow_timestamp_at_anchor);
    try std.testing.expectEqual(expected.monotonic_anchor_timestamp, time.monotonic_anchor_timestamp);
    try std.testing.expectEqual(expected.dilation, time.dilation);
}
