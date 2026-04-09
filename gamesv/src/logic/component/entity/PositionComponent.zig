const Component = @This();
const pb = @import("proto").pb;

location: [3]f32 = @splat(0),
rotation: [3]f32 = @splat(0),

pub fn toProto(comp: Component) pb.Transform {
    return .{
        .Pos = .{ .X = comp.location[0], .Y = comp.location[1], .Z = comp.location[2] },
        .Rot = .{ .Pitch = comp.rotation[0], .Yaw = comp.rotation[1], .Roll = comp.rotation[2] },
    };
}
