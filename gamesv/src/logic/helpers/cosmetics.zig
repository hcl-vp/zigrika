const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const RoleInfo = @import("../../fs/RoleInfo.zig");
const CosmeticInfo = @import("../../fs/CosmeticInfo.zig");
const BuffAdditionEntry = @import("../events.zig").BuffAdditionEntry;

fn containsBuffEntry(items: []const BuffAdditionEntry, id: i64) bool {
    for (items) |item| {
        if (item.id == id) return true;
    }
    return false;
}

fn appendBuffEntry(list: *std.ArrayListUnmanaged(BuffAdditionEntry), gpa: std.mem.Allocator, id: i64) !void {
    if (id == 0 or containsBuffEntry(list.items, id)) return;
    try list.append(gpa, .{ .id = id, .is_active = true });
}

fn roleSkinContains(ornament: Assets.DataTables.Ornament, role_skin_id: i32) bool {
    for (ornament.RoleSkinIds) |id| {
        if (id == role_skin_id) return true;
    }
    return false;
}

pub fn isWeaponSkinCompatible(assets: *const Assets, role_id: i32, skin_id: i32) bool {
    if (skin_id == 0) return true;
    const role = assets.tables.role_info.getDataById(role_id) orelse return false;
    const skin = assets.tables.weapon_skin.getDataById(skin_id) orelse return false;
    return skin.IsShow and !skin.HideInSkinView and skin.WeaponSkinType == role.WeaponType;
}

fn appendLoadEquipData(list: *std.ArrayList(pb.LoadEquipData), arena: std.mem.Allocator, role_id: i32, skin_id: i32) !void {
    for (list.items) |item| {
        if (item.RoleId == role_id and item.SkinId == skin_id) return;
    }
    try list.append(arena, .{ .RoleId = role_id, .SkinId = skin_id });
}

pub fn buildWeaponSkinCurrentEquipList(
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.LoadEquipData) {
    const log = std.log.scoped(.weapon_skin_equips);
    var list: std.ArrayList(pb.LoadEquipData) = .empty;
    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        if (kv.value_ptr.weapon_skin_id == 0) continue;
        const role_id = kv.key_ptr.*;
        const skin_id = if (isWeaponSkinCompatible(assets, role_id, kv.value_ptr.weapon_skin_id)) kv.value_ptr.weapon_skin_id else 0;
        if (skin_id == 0) {
            log.warn("invalid weapon skin, {d}, for {d}", .{ skin_id, role_id });
            continue;
        }
        try appendLoadEquipData(&list, arena, role_id, skin_id);
    }
    return list;
}

pub fn ornamentForRoleSkin(assets: *const Assets, role_skin_id: i32, ornament_id: i32) ?Assets.DataTables.Ornament {
    if (ornament_id == 0) return null;
    const ornament = assets.tables.ornament.getDataById(ornament_id) orelse return null;
    if (!roleSkinContains(ornament, role_skin_id)) return null;
    return ornament;
}

pub fn buildOrnamentEquipMap(
    role_comp: *PlayerRoleComponent,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.OrnamentDressInfo) {
    var list: std.ArrayList(pb.OrnamentDressInfo) = .empty;
    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        for (kv.value_ptr.ornaments) |entry| {
            var ids: std.ArrayList(i32) = .empty;
            if (entry.ornament_id != 0) try ids.append(arena, entry.ornament_id);
            try list.append(arena, .{
                .RoleSkinId = entry.role_skin_id,
                .DressOrnamentIds = ids,
            });
        }
    }
    return list;
}

pub fn buildOrnamentIdsForRoleSkin(
    assets: *const Assets,
    role: RoleInfo,
    role_skin_id: i32,
    gpa: std.mem.Allocator,
) ![]i32 {
    _ = assets;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa);

    const equipped = role.getOrnament(role_skin_id);
    if (equipped != 0) try list.append(gpa, equipped);

    return try list.toOwnedSlice(gpa);
}

pub fn buildOrnamentBuffsForRoleSkin(
    assets: *const Assets,
    ornament_id: i32,
    gpa: std.mem.Allocator,
) !std.ArrayListUnmanaged(BuffAdditionEntry) {
    var list: std.ArrayListUnmanaged(BuffAdditionEntry) = .empty;
    const ornament = assets.tables.ornament.getDataById(ornament_id) orelse return list;

    for (ornament.OrnamentBuff) |buff_id| try appendBuffEntry(&list, gpa, buff_id);
    for (ornament.OrnamentUiBuff) |buff_id| try appendBuffEntry(&list, gpa, buff_id);

    return list;
}

pub fn buildOrnamentBornBuffIds(
    assets: *const Assets,
    ornament_id: i32,
    gpa: std.mem.Allocator,
) ![]i64 {
    const ornament = assets.tables.ornament.getDataById(ornament_id) orelse return &.{};
    var ids: std.ArrayList(i64) = .empty;
    defer ids.deinit(gpa);

    for (ornament.OrnamentBuff) |buff_id| {
        if (buff_id != 0) try ids.append(gpa, buff_id);
    }
    for (ornament.OrnamentUiBuff) |buff_id| {
        if (buff_id != 0) try ids.append(gpa, buff_id);
    }

    return try ids.toOwnedSlice(gpa);
}
