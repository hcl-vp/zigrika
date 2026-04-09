const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");

skin_id: i32 = 0,

pub fn toProto(comp: Component) !pb.CalabashSkinComponentPb {
    return .{ .CalabashSkinId = comp.skin_id };
}
