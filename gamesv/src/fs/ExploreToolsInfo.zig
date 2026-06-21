const ExploreToolsInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: ExploreToolsInfo = .{};

unlocked_explore_skills: []i32 = &.{},
active_explore_skill: i32 = 1001,
roulette: []i32 = &.{},
explore_extra_item_id: i32 = 0,
active_function_skill: i32 = 0,
function_roulette: []i32 = &.{},
function_extra_item_id: i32 = 0,
active_motorcycle_skill: i32 = 0,
motorcycle_roulette: []i32 = &.{},
motorcycle_extra_item_id: i32 = 0,

pub fn deinit(inst: ExploreToolsInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, inst);
}
