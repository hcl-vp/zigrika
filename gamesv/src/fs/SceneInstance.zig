const SceneInstance = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: SceneInstance = .{};

owner_id: i32 = 0,
buff_handle: i32 = 0,
time: Time = .{},
players: []Player = &.{},

pub const Time = struct {
    hour: i32 = 8,
    minute: i32 = 0,
    owner_clock_time_span: i64 = 0,
};

pub const Player = struct {
    id: i32,
    group_type: i32 = 1,
    location: [3]f32,
    rotation: [3]f32,
};

pub fn deinit(inst: SceneInstance, gpa: Allocator) void {
    std.zon.parse.free(gpa, inst);
}
