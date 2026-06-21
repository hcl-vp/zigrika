const Component = @This();
const pb = @import("proto").pb;
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

skill_component_pb: []pb.SkillComponentPb = &.{},

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.skill_component_pb);
}

pub fn toProto(comp: Component) !pb.PassiveGaSkillComponentPb {
    return .{
        .SkillInfoList = .empty,
        .SkillComponentPb = sliceToArrayList(pb.SkillComponentPb, comp.skill_component_pb),
    };
}
