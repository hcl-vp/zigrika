const Component = @This();
const pb = @import("proto").pb;

vehicle_entity_id: i64 = 0,
seat: i32 = 0,

pub fn toProto(comp: Component) !pb.NpcDriveVehicleComponentPb {
    return .{
        .VehicleCreatureId = comp.vehicle_entity_id,
        .Seat = comp.seat,
    };
}
