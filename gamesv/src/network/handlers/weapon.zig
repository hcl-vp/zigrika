const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const mem = @import("../../mem.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");

pub fn onWeaponItemRequest(
    txn: *Transaction(pb.WeaponItemRequest),
    alloc: mem.Alloc,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    var list: std.ArrayList(pb.WeaponItem) = .empty;
    try list.ensureTotalCapacity(alloc.arena, weapon_comp.weapon_map.count());

    var iterator = weapon_comp.weapon_map.iterator();
    while (iterator.next()) |kv| {
        list.appendAssumeCapacity(kv.value_ptr.toProto(kv.key_ptr.*));
    }

    try txn.respond(.{ .WeaponItemList = list });
}
