const pb = @import("proto").pb;
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

ornament_ids: []i32 = &.{},

pub fn toProto(comp: @This()) !pb.OrnamentComponentPb {
    return .{
        .OrnamentIds = sliceToArrayList(i32, comp.ornament_ids),
    };
}
