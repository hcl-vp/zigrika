const ScheduledJob = @This();
const std = @import("std");
const EventQueue = @import("../EventQueue.zig");

pub const Interval = enum(i64) {
    ms50 = 50,
    ms250 = 250,
    s1 = 1000,
};

interval: Interval,
event_key: std.meta.Tag(EventQueue.Event),
