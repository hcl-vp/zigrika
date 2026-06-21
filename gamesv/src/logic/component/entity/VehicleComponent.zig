const pb = @import("proto").pb;

source: ?pb.VehicleSource = null,
occupied: bool = false,

pub fn toProto(comp: @This()) pb.VehiclePb {
    return .{
        .Source = comp.source,
    };
}
