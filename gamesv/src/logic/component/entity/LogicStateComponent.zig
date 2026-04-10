const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");

position_state: i32 = 0,
move_state: i32 = 0,
direction_state: i32 = 0,
position_sub_state: i32 = 0,

pub fn toProto(comp: Component) !pb.LogicStateComponentPb {
    return .{
        .PositionState = comp.position_state,
        .MoveState = comp.move_state,
        .DirectionState = comp.direction_state,
        .PositionSubState = comp.position_sub_state,
    };
}
