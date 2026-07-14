const ScheduledJob = @This();
const std = @import("std");
const EventQueue = @import("../EventQueue.zig");

pub const Interval = enum(i64) {
    ms50 = 50,
    ms250 = 250,
    s1 = 1_000,
    s30 = 30_000,
};

pub const EventKey = std.meta.Tag(EventQueue.Event);

interval: Interval,
event_key: EventKey,
