const VisionSkillComponent = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

vision_skills: []pb.VisionSkillInformation = &.{},

pub fn toProto(comp: VisionSkillComponent) !pb.VisionSkillComponentPb {
    return .{
        .VisionSkillInfos = sliceToArrayList(pb.VisionSkillInformation, comp.vision_skills),
    };
}
