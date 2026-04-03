const Equip = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");

weapon_id: i32 = 0,
weapon_breach_level: i32 = 0,

pub fn toProto(comp: Equip) !pb.EquipComponentPb {
    return .{
        .WeaponId = comp.weapon_id,
        .WeaponBreachLevel = comp.weapon_breach_level,
    };
}
