const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

pb_combine_part_info_list: []pb.CharacterAttachInfo = &.{},
pb_combine_target_server_id: i64 = 0,

pub fn toProto(comp: Component) !pb.CharacterAttachComponentPb {
    return .{
        .PbCombinePartInfoList = sliceToArrayList(pb.CharacterAttachInfo, comp.pb_combine_part_info_list),
        .PbCombineTargetServerId = comp.pb_combine_target_server_id,
    };
}
