const ExploreToolsInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: ExploreToolsInfo = .{};

unlocked_explore_skills: []i32 = &.{},
active_explore_skill: i32 = 1001,
roulette: []i32 = &.{},

pub fn deinit(inst: ExploreToolsInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, inst);
}
