const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const mem = @import("../../mem.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerInventoryComponent = @import("../../logic/component/player/PlayerInventoryComponent.zig");
const FightBuffComponent = @import("../../logic/component/entity/FightBuffComponent.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Events = @import("../../logic/events.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");
const comp_util = @import("../../logic/component/comp_util.zig");

fn appendEquipTakeOnData(
    list: *std.ArrayList(pb.RoleLoadEquipData),
    arena: std.mem.Allocator,
    role_id: i32,
    equip_inc_id: i32,
    pos: pb.EquipPos,
) !void {
    try list.append(arena, .{
        .RoleId = role_id,
        .Pos = pos,
        .EquipIncId = equip_inc_id,
    });
}

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

    txn.respond(.{ .WeaponItemList = list });
}

fn weaponLevelExp(assets: *const Assets, level_id: i32, level: i32) i32 {
    for (assets.tables.weapon_level.items) |entry| {
        if (entry.LevelId == level_id and entry.Level == level) return entry.Exp;
    }
    return 0;
}

fn weaponLevelLimit(assets: *const Assets, breach_id: i32, breach: i32) i32 {
    for (assets.tables.weapon_breach.items) |entry| {
        if (entry.BreachId == breach_id and entry.Level == breach) return entry.LevelLimit;
    }
    return 90;
}

fn weaponExpItemValue(assets: *const Assets, item_id: i32) i32 {
    const item = assets.tables.weapon_exp_item.getDataById(item_id) orelse return 0;
    return item.BasicExp;
}

fn saveInventoryInfo(
    alloc: mem.Alloc,
    fs: *FileSystem,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}", .{ inventory_comp.player_id, InventoryInfo.data_path });
    try comp_util.saveStruct(fs, inventory_comp.info, path, alloc.arena);
}

fn consumeWeaponBreachItems(
    info: *InventoryInfo,
    alloc: mem.Alloc,
    breach: anytype,
) !?std.ArrayList(pb.NormalItem) {
    var iterator = breach.Consume.map.iterator();
    while (iterator.next()) |entry| {
        if (info.normalItemCount(entry.key_ptr.*) < entry.value_ptr.*) return null;
    }

    var updated_items: std.ArrayList(pb.NormalItem) = .empty;
    iterator = breach.Consume.map.iterator();
    while (iterator.next()) |entry| {
        _ = try InventoryInfo.consumeNormalItem(info, alloc.gpa, entry.key_ptr.*, entry.value_ptr.*);
        try updated_items.append(alloc.arena, .{
            .Id = entry.key_ptr.*,
            .Count = info.normalItemCount(entry.key_ptr.*),
            .ExpireTime = 0,
        });
    }

    return updated_items;
}

pub fn onWeaponLevelUpRequest(
    txn: *Transaction(pb.WeaponLevelUpRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    weapon_comp: *PlayerWeaponComponent,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    const request = txn.message;
    const weapon = weapon_comp.weapon_map.getPtr(request.IncId) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponConsumeItemNotFound });
        return;
    };
    const config = assets.tables.weapon_conf.getDataById(weapon.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponResonConfigNotFound });
        return;
    };

    const limit = weaponLevelLimit(assets, config.BreachId, weapon.breach);
    if (weapon.level >= limit) {
        txn.respond(.{
            .ErrorCode = .ErrWeaponLevelLimit,
            .IncId = request.IncId,
            .WeaponLevel = weapon.level,
            .WeaponExp = weapon.exp,
        });
        return;
    }

    var gained_exp: i32 = 0;
    var item_map: std.ArrayList(pb.MapEntry(i32, i32)) = .empty;
    for (request.ConsumeList.items) |item| {
        if (item.ItemId == 0 or item.Count <= 0) continue;
        const exp = weaponExpItemValue(assets, item.ItemId);
        if (exp == 0) continue;
        gained_exp += exp * item.Count;
        try item_map.append(alloc.arena, .{ .key = item.ItemId, .value = inventory_comp.info.normalItemCount(item.ItemId) });
    }

    if (gained_exp <= 0) {
        txn.respond(.{
            .ErrorCode = .ErrWeaponLevelUpNoExp,
            .IncId = request.IncId,
            .WeaponLevel = weapon.level,
            .WeaponExp = weapon.exp,
        });
        return;
    }

    weapon.exp += gained_exp;
    while (weapon.level < limit) {
        const needed_exp = weaponLevelExp(assets, config.LevelId, weapon.level);
        if (needed_exp <= 0 or weapon.exp < needed_exp) break;
        weapon.exp -= needed_exp;
        weapon.level += 1;
    }

    if (weapon.level >= limit) weapon.exp = 0;
    try events.enqueue(.weapon_info_modified, .{ .incr_id = request.IncId });

    txn.respond(.{
        .ErrorCode = .Success,
        .IncId = request.IncId,
        .WeaponLevel = weapon.level,
        .WeaponExp = weapon.exp,
        .ItemMap = item_map,
    });
}

pub fn onWeaponBreachRequest(
    txn: *Transaction(pb.WeaponBreachRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.EquipComponent,
    }),
    assets: *const Assets,
    weapon_comp: *PlayerWeaponComponent,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    const request = txn.message;
    const weapon = weapon_comp.weapon_map.getPtr(request.IncId) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponConsumeItemNotFound });
        return;
    };
    const config = assets.tables.weapon_conf.getDataById(weapon.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponResonConfigNotFound });
        return;
    };

    const breach = for (assets.tables.weapon_breach.items) |entry| {
        if (entry.BreachId == config.BreachId and entry.Level == weapon.breach) break entry;
    } else {
        txn.respond(.{ .ErrorCode = .ErrWeaponLevelLimit, .IncId = request.IncId, .WeaponBreach = weapon.breach });
        return;
    };

    const updated_items = try consumeWeaponBreachItems(&inventory_comp.info, alloc, breach) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponConsumeItemNotFound, .IncId = request.IncId, .WeaponBreach = weapon.breach });
        return;
    };

    weapon.breach += 1;
    try events.enqueue(.weapon_info_modified, .{ .incr_id = request.IncId });
    try saveInventoryInfo(alloc, fs, inventory_comp);
    try txn.conn.push(pb.NormalItemUpdateNotify{
        .NormalItemList = updated_items,
        .NoTips = true,
    }, alloc.arena);

    var it = query.iterator;
    while (it.next()) |item| {
        const entity, const config_item, const equip = item;
        if (config_item.config_id != weapon.role_id) continue;

        equip.weapon_breach_level = weapon.breach;

        try txn.conn.push(pb.EntityEquipChangeNotify{
            .EntityId = entity.net_id,
            .EquipComponent = try equip.toProto(),
        }, alloc.arena);
        break;
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .IncId = request.IncId,
        .WeaponBreach = weapon.breach,
    });
}

pub fn onWeaponResonUpRequest(
    txn: *Transaction(pb.WeaponResonUpRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.FightBuffComponent,
    }),
    assets: *const Assets,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    const request = txn.message;
    const weapon = weapon_comp.weapon_map.getPtr(request.IncId) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponConsumeItemNotFound });
        return;
    };
    const config = assets.tables.weapon_conf.getDataById(weapon.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponResonConfigNotFound });
        return;
    };

    if (weapon.reson_level >= config.ResonLevelLimit) {
        txn.respond(.{ .ErrorCode = .ErrWeaponResonLevelLimit, .IncId = request.IncId, .ResonLevel = weapon.reson_level });
        return;
    }

    var removed_ids: std.ArrayList(i32) = .empty;
    for (request.ConsumeList.items) |consume_id| {
        if (consume_id == request.IncId) continue;
        const consumed = weapon_comp.weapon_map.get(consume_id) orelse continue;
        if (consumed.id != weapon.id or consumed.role_id != null) continue;
        _ = weapon_comp.weapon_map.orderedRemove(consume_id);
        try removed_ids.append(alloc.arena, consume_id);
        try fs.deleteFile(try std.fmt.allocPrint(alloc.arena, "player/{}/weapon/{}", .{ weapon_comp.player_id, consume_id }));
        if (removed_ids.items.len >= 1) break;
    }
    for (request.ConsumeItemList.items) |item| {
        if (removed_ids.items.len >= 1) break;
        const consume_id = item.IncId;
        if (consume_id == request.IncId) continue;
        const consumed = weapon_comp.weapon_map.get(consume_id) orelse continue;
        if (consumed.id != weapon.id or consumed.role_id != null) continue;
        _ = weapon_comp.weapon_map.orderedRemove(consume_id);
        try removed_ids.append(alloc.arena, consume_id);
        try fs.deleteFile(try std.fmt.allocPrint(alloc.arena, "player/{}/weapon/{}", .{ weapon_comp.player_id, consume_id }));
    }

    if (removed_ids.items.len == 0) {
        txn.respond(.{ .ErrorCode = .ErrWeaponResonConsumeItem, .IncId = request.IncId, .ResonLevel = weapon.reson_level });
        return;
    }

    const target_weapon = weapon_comp.weapon_map.getPtr(request.IncId) orelse {
        txn.respond(.{ .ErrorCode = .ErrWeaponConsumeItemNotFound });
        return;
    };
    target_weapon.reson_level += 1;
    try events.enqueue(.weapon_info_modified, .{ .incr_id = request.IncId });
    try txn.conn.push(pb.WeaponItemRemoveNotify{ .WeaponItemIncrIdList = removed_ids }, alloc.arena);

    if (target_weapon.role_id) |role_id| {
        const old_reson = assets.tables.getWeaponReson(config.ResonId, target_weapon.reson_level - 1);
        const new_reson = assets.tables.getWeaponReson(config.ResonId, target_weapon.reson_level);

        var it = query.iterator;
        while (it.next()) |item| {
            const entity, const config_item, const buffs = item;
            if (config_item.config_id != role_id) continue;

            if (old_reson) |old| {
                var handles_to_remove: std.ArrayList(i32) = .empty;
                for (old.Effect) |buff_id| {
                    const buff = buffs.getByBuffId(buff_id) orelse continue;
                    try handles_to_remove.append(alloc.arena, buff.HandleId);
                }
                try events.enqueue(.buff_removal, .{ .entity = entity, .handle_ids = handles_to_remove.items });
            }

            if (new_reson) |new| {
                var buffs_to_add: std.ArrayList(Events.BuffAdditionEntry) = .empty;
                for (new.Effect) |buff_id| {
                    try buffs_to_add.append(alloc.arena, .{ .id = buff_id, .is_active = true, .stack_count = 1 });
                }
                try events.enqueue(.buff_addition, .{ .target = entity, .instigator = entity, .buffs = buffs_to_add.items });
            }
            break;
        }
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .IncId = request.IncId,
        .ResonLevel = target_weapon.reson_level,
    });
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

        try appendEquipTakeOnData(&send_data, alloc.arena, old_role_id, current_role.weapon, .Weapon);
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
        try appendEquipTakeOnData(&send_data, alloc.arena, 0, current_role.weapon, .Weapon);
    }

    weapon.role_id = data.RoleId;
    current_role.weapon = data.EquipIncId;

    try appendEquipTakeOnData(&send_data, alloc.arena, data.RoleId, data.EquipIncId, .Weapon);
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
    txn.respond(.{ .ErrorCode = .Success, .DataList = send_data });
}
