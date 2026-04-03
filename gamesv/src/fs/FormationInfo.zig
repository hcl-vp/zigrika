const FormationInfo = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const default: FormationInfo = .{};

cur_formation: i32 = 0,
formations: []Formation = &.{},

pub const Formation = struct {
    cur_role: i32,
    roles: [3]?Role,

    pub const Role = struct {
        role_id: i32,
        entity_id: i64 = -1,
        on_stage_without_control: bool = false,
    };
};

pub fn deinit(inst: FormationInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, inst);
}
