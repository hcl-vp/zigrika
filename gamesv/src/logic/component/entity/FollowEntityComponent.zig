const Component = @This();
const pb = @import("proto").pb;

entity_id: i64 = 0,

pub fn toProto(comp: Component) !pb.FollowEntityComponentPb {
    return .{ .EntityId = comp.entity_id };
}
