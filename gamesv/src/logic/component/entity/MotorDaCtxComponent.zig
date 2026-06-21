const pb = @import("proto").pb;

context_id: i64 = 0,

pub fn toProto(comp: @This()) pb.MotorDaCtxComponentPb {
    return .{
        .MotorDaCtxId = comp.context_id,
    };
}
