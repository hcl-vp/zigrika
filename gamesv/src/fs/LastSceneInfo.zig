const LastSceneInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: LastSceneInfo = .{};

instance_id: i32 = 8,
// TODO: controlled entity? position?

pub fn deinit(info: LastSceneInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
