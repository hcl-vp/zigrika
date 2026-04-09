const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const FileSystem = @import("common").FileSystem;
const Scene = @import("../../logic/Scene.zig");
const mem = @import("../../mem.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const EventQueue = @import("../../logic/EventQueue.zig");

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

pub fn onEquipTakeOnRequest(
    txn: *Transaction(pb.EquipTakeOnRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.EquipComponent,
        *Scene.Entity.ConfigComponent,
    }),
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    const data = txn.message.Data orelse return;

    var send_data: std.ArrayList(pb.RoleLoadEquipData) = .empty;
    defer send_data.deinit(alloc.arena);

    const current_role = role_comp.role_map.getPtr(data.RoleId) orelse return;
    var weapon = weapon_comp.weapon_map.getPtr(data.EquipIncId) orelse return;
    var old_weapon = weapon_comp.weapon_map.getPtr(current_role.weapon) orelse return;

    if (weapon.role_id) |old_role_id| {
        var old_role = role_comp.role_map.getPtr(old_role_id) orelse {
            return;
        };
        old_weapon.role_id = old_role_id;
        old_role.weapon = current_role.weapon;

        try send_data.append(alloc.arena, .{ .EquipIncId = current_role.weapon, .RoleId = old_role_id });
        var iterator = query.iterator;
        while (iterator.next()) |item| {
            const entity, const equip, const config = item;
            if (config.config_id == old_role_id) {
                equip.weapon_id = old_weapon.id;
                equip.weapon_breach_level = old_weapon.breach;

                try txn.conn.push(pb.EntityEquipChangeNotify{
                    .EntityId = entity.net_id,
                    .EquipComponent = try equip.toProto(),
                }, alloc.arena);
                break;
            }
        }
        try events.enqueue(.weapon_info_modified, .{ .incr_id = current_role.weapon });
        try events.enqueue(.role_info_modified, .{ .role_id = old_role_id });
    } else {
        try send_data.append(alloc.arena, .{ .EquipIncId = current_role.weapon });
    }

    weapon.role_id = data.RoleId;
    current_role.weapon = data.EquipIncId;

    try send_data.append(alloc.arena, .{ .EquipIncId = data.EquipIncId, .RoleId = data.RoleId });
    var iterator = query.iterator;
    while (iterator.next()) |item| {
        const entity, const equip, const config = item;
        if (config.config_id == data.RoleId) {
            equip.weapon_id = weapon.id;
            equip.weapon_breach_level = weapon.breach;

            try txn.conn.push(pb.EntityEquipChangeNotify{
                .EntityId = entity.net_id,
                .EquipComponent = try equip.toProto(),
            }, alloc.arena);
            break;
        }
    }

    try events.enqueue(.role_info_modified, .{ .role_id = data.RoleId });
    try events.enqueue(.weapon_info_modified, .{ .incr_id = data.EquipIncId });
    try txn.conn.push(pb.EquipTakeOnNotify{ .DataList = send_data }, alloc.arena);
    try txn.respond(.{ .DataList = send_data });
}
