const PassiveGaSkill = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

skill_component_pb: []pb.SkillComponentPb = &.{},

pub fn toProto(comp: PassiveGaSkill) !pb.PassiveGaSkillComponentPb {
    return .{
        .SkillInfoList = .empty,
        .SkillComponentPb = sliceToArrayList(pb.SkillComponentPb, comp.skill_component_pb),
    };
}
