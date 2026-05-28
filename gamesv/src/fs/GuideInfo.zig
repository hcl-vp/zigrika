const GuideInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: GuideInfo = .{};
pub const data_path = "guide_info";

finished_groups: []i32 = &.{},

pub fn hasFinished(info: GuideInfo, group_id: i32) bool {
    if (group_id == 0) return true;
    for (info.finished_groups) |id| {
        if (id == group_id) return true;
    }
    return false;
}

pub fn addFinished(info: *GuideInfo, gpa: Allocator, group_id: i32) !void {
    if (hasFinished(info.*, group_id)) return;

    const new_groups = try gpa.alloc(i32, info.finished_groups.len + 1);
    @memcpy(new_groups[0..info.finished_groups.len], info.finished_groups);
    new_groups[info.finished_groups.len] = group_id;

    if (info.finished_groups.len != 0) gpa.free(info.finished_groups);
    info.finished_groups = new_groups;
}

pub fn deinit(info: GuideInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
