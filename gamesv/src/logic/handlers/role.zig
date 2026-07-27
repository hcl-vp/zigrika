const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerBasicComponent = @import("../component/player/PlayerBasicComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");
const PlayerCosmeticComponent = @import("../component/player/PlayerCosmeticComponent.zig");
const PlayerInventoryComponent = @import("../component/player/PlayerInventoryComponent.zig");
const CosmeticInfo = @import("../../fs/CosmeticInfo.zig");
const CosmeticsHelper = @import("../helpers/cosmetics.zig");
const RoleStats = @import("../helpers/role_stats.zig");
const RoleHelper = @import("../helpers/role.zig");

fn buildEmptyStorageRecord(
    red_dot_type: pb.EClientStorageSystemIdType,
    arena: std.mem.Allocator,
) !pb.ClientStorageInfo {
    var seen: pb.ClientStorageSetData = .default;
    try seen.Data.ensureTotalCapacity(arena, 0);

    return .{
        .SystemId = @intFromEnum(red_dot_type),
        .Data = .{ .SetData = seen },
    };
}

fn buildIntStorageRecord(
    red_dot_type: pb.EClientStorageSystemIdType,
    values: []const i32,
    arena: std.mem.Allocator,
) !pb.ClientStorageInfo {
    var seen: pb.ClientStorageSetData = .default;
    try seen.Data.ensureTotalCapacity(arena, values.len);
    for (values) |value| seen.Data.appendAssumeCapacity(@intCast(value));

    return .{
        .SystemId = @intFromEnum(red_dot_type),
        .Data = .{ .SetData = seen },
    };
}

fn appendFlyEquipRole(
    list: *std.ArrayList(pb.FlySkinEquipData),
    skin_id: i32,
    role_id: i32,
    arena: std.mem.Allocator,
) !void {
    if (skin_id == 0) return;

    for (list.items) |*item| {
        if (item.SkinId == skin_id) {
            try item.RoleIds.append(arena, role_id);
            return;
        }
    }

    var role_ids: std.ArrayList(i32) = .empty;
    try role_ids.append(arena, role_id);
    try list.append(arena, .{
        .SkinId = skin_id,
        .RoleIds = role_ids,
    });
}

fn buildFlyEquipData(
    role_comp: *PlayerRoleComponent,
    cosmetic_info: CosmeticInfo,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.FlySkinEquipData) {
    var list: std.ArrayList(pb.FlySkinEquipData) = .empty;

    for (cosmetic_info.fly_skins) |skin_id| {
        if (skin_id == 0) continue;
        try list.append(arena, .{
            .SkinId = skin_id,
            .RoleIds = .empty,
        });
    }

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        const role_id = kv.key_ptr.*;
        try appendFlyEquipRole(&list, kv.value_ptr.soar_skin_id, role_id, arena);
        try appendFlyEquipRole(&list, kv.value_ptr.paragliding_skin_id, role_id, arena);
    }

    return list;
}

pub fn ensureRoleAttributes(
    _: EventQueue.Dequeue(.enter_game),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        const id = kv.key_ptr.*;
        const role = kv.value_ptr;

        if (role.base_prop.len != @as(i32, @intFromEnum(pb.EAttributeType.MAX))) {
            // A new attribute type was introduced. Rebuild property table.
            try role.resetProperties(alloc.gpa, assets, id);
            try events.enqueue(.role_info_modified, .{ .role_id = id });
        }
    }
}

pub fn pushData(
    _: EventQueue.Dequeue(.push_data),
    conn: *Connection,
    alloc: mem.Alloc,
    assets: *const Assets,
    basic_comp: *PlayerBasicComponent,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    try conn.push(pb.NormalItemUpdateNotify{
        .NormalItemList = try inventory_comp.info.normalItemList(alloc.arena),
        .NoTips = true,
    });

    try conn.push(pb.UnlockSkinDataNotify{
        .PhantomSkinList = try CosmeticInfo.intList(cosmetic_comp.info.phantom_skins, alloc.arena),
        .IsLogin = true,
    });

    try conn.push(pb.FlyEquipAddNotify{
        .UnlockFlySkinIds = try CosmeticInfo.intList(cosmetic_comp.info.fly_skins, alloc.arena),
    });

    try conn.push(pb.RoleFlyEquipNotify{
        .FlySkinEquipData = try buildFlyEquipData(role_comp, cosmetic_comp.info, alloc.arena),
    });

    try conn.push(pb.OrnamentInfoNotify{
        .OrnamentInfo = .{
            .UnlockOrnamentIds = try CosmeticInfo.intList(cosmetic_comp.info.ornaments, alloc.arena),
            .OrnamentDressInfos = try CosmeticsHelper.buildOrnamentEquipMap(role_comp, alloc.arena),
            .RedPointOrnamentIds = try CosmeticInfo.intList(cosmetic_comp.info.viewed_ornaments, alloc.arena),
        },
    });

    var storage_info_notify: pb.StorageInfoNotify = .default;
    try storage_info_notify.Infos.ensureTotalCapacity(alloc.arena, 6);
    storage_info_notify.Infos.appendAssumeCapacity(try buildEmptyStorageRecord(.RoleSkinRedDot, alloc.arena));
    storage_info_notify.Infos.appendAssumeCapacity(try buildEmptyStorageRecord(.FlySkinRedDot, alloc.arena));
    storage_info_notify.Infos.appendAssumeCapacity(try buildEmptyStorageRecord(.WeaponSkinRedDot, alloc.arena));
    storage_info_notify.Infos.appendAssumeCapacity(try buildEmptyStorageRecord(.CalabashSkinRedDot, alloc.arena));
    storage_info_notify.Infos.appendAssumeCapacity(try buildIntStorageRecord(.Ornament, cosmetic_comp.info.viewed_ornaments, alloc.arena));
    storage_info_notify.Infos.appendAssumeCapacity(try buildEmptyStorageRecord(.GetOrnament, alloc.arena));
    try conn.push(storage_info_notify);

    const selected_main_role = RoleHelper.selectedMainRoleId(
        assets,
        role_comp,
        basic_comp.info.attributes.sex,
        basic_comp.info.selected_main_role_id,
    );
    try conn.push(pb.RoleChangeUnlockNotify{
        .UnlockRoleIds = try RoleHelper.mainRoleUnlockList(assets, basic_comp.info.attributes.sex, alloc.arena),
    });

    var notify: pb.PbGetRoleListNotify = .default;

    try notify.RoleList.ensureTotalCapacity(alloc.arena, role_comp.role_map.count());
    var iterator = role_comp.role_map.iterator();

    while (iterator.next()) |role| {
        if (selected_main_role) |selected| {
            if (RoleHelper.isMainRole(assets, role.key_ptr.*) and role.key_ptr.* != selected) continue;
        }

        notify.RoleList.appendAssumeCapacity(try RoleStats.toClientRoleInfo(
            alloc.gpa,
            alloc.arena,
            assets,
            role_comp,
            role.key_ptr.*,
            role.value_ptr,
            weapon_comp,
            echo_comp,
        ));
    }

    try conn.push(notify);
    try pushFavorList(conn, alloc, assets, role_comp);
    try pushMotionList(conn, alloc, assets, role_comp);
}

fn pushFavorList(
    conn: *Connection,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var favor_list: std.ArrayList(pb.RoleFavor) = .empty;

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |role_entry| {
        const role_id = role_entry.key_ptr.*;

        var role_favor: pb.RoleFavor = .{
            .RoleId = role_id,
            .Level = 5,
            .Exp = 16800,
        };

        for (assets.tables.favor_word.items) |word| {
            if (word.RoleId == role_id) {
                try role_favor.WordIds.append(alloc.arena, .{
                    .Id = word.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_story.items) |story| {
            if (story.RoleId == role_id) {
                try role_favor.StoryIds.append(alloc.arena, .{
                    .Id = story.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_goods.items) |goods| {
            if (goods.RoleId == role_id) {
                try role_favor.GoodsIds.append(alloc.arena, .{
                    .Id = goods.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        try favor_list.append(alloc.arena, role_favor);
    }

    try conn.push(pb.RoleFavorListNotify{
        .FavorList = favor_list,
    });
}

fn pushMotionList(
    conn: *Connection,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var motion_list: std.ArrayList(pb.RoleMotion) = .empty;

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |role_entry| {
        const role_id = role_entry.key_ptr.*;

        var role_motion: pb.RoleMotion = .{
            .RoleId = role_id,
        };

        for (assets.tables.motion.items) |motion| {
            if (motion.RoleId == role_id) {
                try role_motion.MotionIds.append(alloc.arena, .{
                    .Id = motion.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        if (role_motion.MotionIds.items.len > 0) {
            try motion_list.append(alloc.arena, role_motion);
        }
    }

    try conn.push(pb.RoleMotionListNotify{
        .MotionList = motion_list,
    });
}
