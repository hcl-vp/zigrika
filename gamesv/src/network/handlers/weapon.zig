const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const mem = @import("../../mem.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const FightBuffComponent = @import("../../logic/component/entity/FightBuffComponent.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Events = @import("../../logic/events.zig");

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

// TODO: split this into events when implementing role element change
pub fn onEquipTakeOnRequest(
    txn: *Transaction(pb.EquipTakeOnRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.EquipComponent,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.FightBuffComponent,
    }),
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    const data = txn.message.Data orelse return;
    std.log.debug("equip data: {any}", .{data});

    var send_data: std.ArrayList(pb.RoleLoadEquipData) = .empty;
    defer send_data.deinit(alloc.arena);

    const current_role = role_comp.role_map.getPtr(data.RoleId) orelse unreachable;
    var weapon = weapon_comp.weapon_map.getPtr(data.EquipIncId) orelse unreachable;
    var old_weapon = weapon_comp.weapon_map.getPtr(current_role.weapon) orelse unreachable;
    const current_weapon_reson = assets.tables.getWeaponReson((assets.tables.weapon_conf.getDataById(weapon.id) orelse unreachable).ResonId, weapon.reson_level) orelse unreachable;
    const old_weapon_reson = assets.tables.getWeaponReson((assets.tables.weapon_conf.getDataById(old_weapon.id) orelse unreachable).ResonId, old_weapon.reson_level) orelse unreachable;

    if (weapon.role_id) |old_role_id| {
        var old_role = role_comp.role_map.getPtr(old_role_id) orelse {
            unreachable;
        };
        old_weapon.role_id = old_role_id;
        old_role.weapon = current_role.weapon;

        try send_data.append(alloc.arena, .{ .EquipIncId = current_role.weapon, .RoleId = old_role_id });
        var iterator = query.iterator;
        while (iterator.next()) |item| {
            const entity, const equip, const config, const buffs: *FightBuffComponent = item;
            if (config.config_id == old_role_id) {
                var handles_to_remove: std.ArrayList(i32) = .empty;
                for (current_weapon_reson.Effect) |buff_id| {
                    const buff = buffs.getByBuffId(buff_id) orelse continue;
                    try handles_to_remove.append(alloc.arena, buff.HandleId);
                }
                try events.enqueue(.buff_removal, .{ .entity = entity, .handle_ids = handles_to_remove.items });

                var buffs_to_add: std.ArrayList(Events.BuffAdditionEntry) = .empty;
                for (old_weapon_reson.Effect) |buff_id| {
                    try buffs_to_add.append(alloc.arena, .{ .id = buff_id, .is_active = true, .stack_count = 1 });
                }
                try events.enqueue(.buff_addition, .{ .target = entity, .instigator = entity, .buffs = buffs_to_add.items });

                equip.weapon_id = old_weapon.id;
                equip.weapon_breach_level = old_weapon.breach;
                try scene.saveComponents(
                    fs,
                    alloc.gpa,
                    entity,
                    &.{Scene.Entity.EquipComponent},
                );

                try txn.conn.push(pb.EntityEquipChangeNotify{
                    .EntityId = entity.net_id,
                    .EquipComponent = try equip.toProto(),
                }, alloc.arena);
                break;
            }
            try scene.saveEntity(fs, alloc.gpa, entity);
        }
        try events.enqueue(.weapon_info_modified, .{ .incr_id = current_role.weapon });
        try events.enqueue(.role_info_modified, .{ .role_id = old_role_id });
    } else {
        old_weapon.role_id = null;
        try events.enqueue(.weapon_info_modified, .{ .incr_id = current_role.weapon });
        try send_data.append(alloc.arena, .{ .EquipIncId = current_role.weapon });
    }

    weapon.role_id = data.RoleId;
    current_role.weapon = data.EquipIncId;

    try send_data.append(alloc.arena, .{ .EquipIncId = data.EquipIncId, .RoleId = data.RoleId });
    var iterator = query.iterator;
    while (iterator.next()) |item| {
        const entity, const equip, const config, const buffs = item;
        if (config.config_id == data.RoleId) {
            var handles_to_remove: std.ArrayList(i32) = .empty;
            for (old_weapon_reson.Effect) |buff_id| {
                const buff = buffs.getByBuffId(buff_id) orelse continue;
                try handles_to_remove.append(alloc.arena, buff.HandleId);
            }
            try events.enqueue(.buff_removal, .{ .entity = entity, .handle_ids = handles_to_remove.items });

            var buffs_to_add: std.ArrayList(Events.BuffAdditionEntry) = .empty;
            for (current_weapon_reson.Effect) |buff_id| {
                try buffs_to_add.append(alloc.arena, .{ .id = buff_id, .is_active = true, .stack_count = 1 });
            }
            try events.enqueue(.buff_addition, .{ .target = entity, .instigator = entity, .buffs = buffs_to_add.items });

            equip.weapon_id = weapon.id;
            equip.weapon_breach_level = weapon.breach;
            try scene.saveComponents(
                fs,
                alloc.gpa,
                entity,
                &.{Scene.Entity.EquipComponent},
            );

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
