const TimeInfo = @This();
const std = @import("std");

const min_timestamp_f64: f64 = @floatFromInt(std.math.minInt(i64));
const max_timestamp_f64: f64 = @floatFromInt(std.math.maxInt(i64));

flow_timestamp_at_anchor: f64 = 0.0,
monotonic_anchor_timestamp: i64 = 0,
dilation: f64 = 0.0,

pub fn currentFlowTimestamp(time: TimeInfo, monotonic_now: i64) i64 {
    return saturatingTimestamp(time.currentFlowTimestampPrecise(monotonic_now));
}

pub fn setDilation(time: *TimeInfo, monotonic_now: i64, new_dilation: f64) void {
    if (!std.math.isFinite(new_dilation) or @abs(new_dilation) > max_timestamp_f64) return;

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
    const elapsed: i128 = @max(
        @as(i128, monotonic_now) - @as(i128, time.monotonic_anchor_timestamp),
        0,
    );
    const timestamp = time.flow_timestamp_at_anchor +
        (@as(f64, @floatFromInt(elapsed)) * time.dilation);
    return @min(@max(timestamp, min_timestamp_f64), max_timestamp_f64);
}

fn saturatingTimestamp(timestamp: f64) i64 {
    if (timestamp <= min_timestamp_f64) return std.math.minInt(i64);
    if (timestamp >= max_timestamp_f64) return std.math.maxInt(i64);
    return @intFromFloat(@trunc(timestamp));
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

test "huge finite dilation is ignored" {
    var time: TimeInfo = .{};
    time.reset(1_000, 0);
    time.setDilation(100, 2.0);
    const expected = time;

    time.setDilation(200, std.math.floatMax(f64));
    try std.testing.expectEqual(expected.flow_timestamp_at_anchor, time.flow_timestamp_at_anchor);
    try std.testing.expectEqual(expected.monotonic_anchor_timestamp, time.monotonic_anchor_timestamp);
    try std.testing.expectEqual(expected.dilation, time.dilation);

    time.setDilation(200, -std.math.floatMax(f64));
    try std.testing.expectEqual(expected.flow_timestamp_at_anchor, time.flow_timestamp_at_anchor);
    try std.testing.expectEqual(expected.monotonic_anchor_timestamp, time.monotonic_anchor_timestamp);
    try std.testing.expectEqual(expected.dilation, time.dilation);
}

test "flow timestamps saturate in both directions" {
    var time: TimeInfo = .{};
    time.reset(std.math.maxInt(i64), 0);
    time.setDilation(0, 2.0);
    try std.testing.expectEqual(std.math.maxInt(i64), time.currentFlowTimestamp(1));

    time.reset(std.math.minInt(i64), 0);
    time.setDilation(0, -2.0);
    try std.testing.expectEqual(std.math.minInt(i64), time.currentFlowTimestamp(1));
}

test "extreme monotonic timestamps do not overflow elapsed time" {
    var time: TimeInfo = .{};
    time.reset(0, std.math.minInt(i64));

    try std.testing.expectEqual(
        std.math.maxInt(i64),
        time.currentFlowTimestamp(std.math.maxInt(i64)),
    );
}

test "reanchoring after saturation remains safe" {
    var time: TimeInfo = .{};
    time.reset(std.math.maxInt(i64), 0);
    time.setDilation(0, 2.0);
    time.setDilation(1, -1.0);

    try std.testing.expectEqual(
        std.math.maxInt(i64),
        time.currentFlowTimestamp(2),
    );
}
