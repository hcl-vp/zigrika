const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const CosmeticsHelper = @import("../../logic/helpers/cosmetics.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerCosmeticComponent = @import("../../logic/component/player/PlayerCosmeticComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const CosmeticInfo = @import("../../fs/CosmeticInfo.zig");
const RoleHelper = @import("../../logic/helpers/role.zig");
const std = @import("std");
const BuffTimerScheduler = @import("../../logic/schedulers/BuffTimerScheduler.zig");
const buff_helper = @import("../../logic/helpers/buff.zig");

fn buildFlyEquipData(role_comp: *PlayerRoleComponent, arena: std.mem.Allocator, skin_id: i32) !std.ArrayList(pb.EquipFlySkinData) {
    var list: std.ArrayList(pb.EquipFlySkinData) = .empty;
    try list.ensureTotalCapacity(arena, role_comp.role_map.count());

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        list.appendAssumeCapacity(.{ .RoleId = kv.key_ptr.*, .SkinId = skin_id });
    }
    return list;
}

fn findRoleSkin(assets: *const Assets, role_id: i32, skin_id: i32) ?Assets.DataTables.RoleSkin {
    const skin = assets.tables.role_skin.getDataById(skin_id) orelse return null;
    if (skin.RoleId != role_id) return null;
    return skin;
}

fn isOwnedRoleSkin(cosmetic_info: CosmeticInfo, skin_id: i32) bool {
    return CosmeticInfo.has(cosmetic_info.role_skins, skin_id);
}

fn isOwnedFlySkin(cosmetic_info: CosmeticInfo, skin_id: i32) bool {
    return CosmeticInfo.has(cosmetic_info.fly_skins, skin_id);
}

fn isOwnedWeaponSkin(cosmetic_info: CosmeticInfo, skin_id: i32) bool {
    return CosmeticInfo.has(cosmetic_info.weapon_skins, skin_id);
}

fn isOwnedOrnament(cosmetic_info: CosmeticInfo, ornament_id: i32) bool {
    return CosmeticInfo.has(cosmetic_info.ornaments, ornament_id);
}

fn roleDefaultSkin(assets: *const Assets, role_id: i32) ?i32 {
    const role_info = assets.tables.role_info.getDataById(role_id) orelse return null;
    return role_info.SkinId;
}

fn roleIdForSkin(assets: *const Assets, role_skin_id: i32) ?i32 {
    if (assets.tables.role_skin.getDataById(role_skin_id)) |skin| return skin.RoleId;

    for (assets.tables.role_info.items) |role| {
        if (role.SkinId == role_skin_id) return role.Id;
    }
    return null;
}

fn findFlySkin(assets: *const Assets, skin_id: i32) ?Assets.DataTables.FlySkinConfig {
    return assets.tables.fly_skin_config.getDataById(skin_id);
}

fn setFlySkin(role: anytype, skin: Assets.DataTables.FlySkinConfig) void {
    if (skin.SkinType == 0) {
        role.soar_skin_id = skin.Id;
    } else {
        role.paragliding_skin_id = skin.Id;
    }
}

fn pushEntityFlySkinChange(
    txn: anytype,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    role_id: i32,
    skin: Assets.DataTables.FlySkinConfig,
) !void {
    const slice = scene.entities.slice();

    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id != role_id) continue;

        if (slice.items(.base_skin)[i]) |*base_skin| {
            if (skin.SkinType == 0) {
                base_skin.soar_skin_id = skin.Id;
            } else {
                base_skin.paragliding_skin_id = skin.Id;
            }
        } else {
            slice.items(.base_skin)[i] = if (skin.SkinType == 0)
                .{ .soar_skin_id = skin.Id }
            else
                .{ .paragliding_skin_id = skin.Id };
        }

        const entity: Scene.Entity = .{
            .index = i,
            .net_id = slice.items(.entity_id)[i].net_id,
        };
        try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.BaseSkinComponent});

        var fly_skin_config_data: std.ArrayList(pb.FlySkinConfigData) = .empty;
        try fly_skin_config_data.append(alloc.arena, .{
            .SkinId = skin.Id,
            .FlySkinId = skin.SkinType,
        });

        var fly_skin_data: std.ArrayList(pb.EntityFlySkinChangeData) = .empty;
        try fly_skin_data.append(alloc.arena, .{
            .EntityId = entity.net_id,
            .FlySkinConfigData = fly_skin_config_data,
        });

        try txn.conn.push(pb.SoarWingOrParaglidingSkinChangeNotify{
            .FlySkinData = fly_skin_data,
        });
        return;
    }
}

fn pushEntityWeaponSkinChange(
    txn: anytype,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    role_id: i32,
    skin_id: i32,
) !void {
    const slice = scene.entities.slice();

    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id != role_id) continue;

        if (slice.items(.weapon_skin)[i]) |*weapon_skin| {
            weapon_skin.skin_id = skin_id;
        } else {
            slice.items(.weapon_skin)[i] = .{ .skin_id = skin_id };
        }

        const entity: Scene.Entity = .{
            .index = i,
            .net_id = slice.items(.entity_id)[i].net_id,
        };

        try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.WeaponSkinComponent});
        try txn.conn.push(pb.EntityEquipSkinChangeNotify{
            .EntityId = entity.net_id,
            .WeaponSkinComponentPb = .{ .WeaponSkinId = skin_id },
        });

        return;
    }
}

fn pushWeaponSkinEquipTakeOnNotify(txn: anytype, alloc: mem.Alloc, role_id: i32, skin_id: i32) !void {
    var data_list: std.ArrayList(pb.RoleLoadEquipData) = .empty;
    try data_list.append(alloc.arena, .{
        .RoleId = role_id,
        .Pos = .WeaponSkin,
        .EquipIncId = skin_id,
    });

    try txn.conn.push(pb.EquipTakeOnNotify{ .DataList = data_list });
}

fn buildSingleWeaponSkinEquipList(alloc: mem.Alloc, role_id: i32, skin_id: i32) !std.ArrayList(pb.LoadEquipData) {
    var list: std.ArrayList(pb.LoadEquipData) = .empty;
    try list.append(alloc.arena, .{ .RoleId = role_id, .SkinId = skin_id });
    return list;
}

fn refreshRoleOrnamentEntity(
    txn: anytype,
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    role_id: i32,
    role: anytype,
    stale_ornament_ids: []const i32,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
    now_ms: i64,
) !void {
    _ = events;
    const slice = scene.entities.slice();

    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id != role_id) continue;

        const ornament_ids = try CosmeticsHelper.buildOrnamentIdsForRoleSkin(assets, role.*, role.role_skin_id, alloc.gpa);
        if (slice.items(.ornament)[i]) |*ornament| {
            if (ornament.ornament_ids.len != 0) alloc.gpa.free(ornament.ornament_ids);
            ornament.ornament_ids = ornament_ids;
        } else {
            slice.items(.ornament)[i] = .{ .ornament_ids = ornament_ids };
        }
        const ornament_comp: Scene.Entity.OrnamentComponent = slice.items(.ornament)[i].?;

        const stale_ornament_buffs = try CosmeticsHelper.buildOrnamentBuffsForIds(assets, stale_ornament_ids, alloc.arena);
        const ornament_buffs = try CosmeticsHelper.buildOrnamentBuffsForIds(assets, ornament_ids, alloc.arena);
        const ornament_born_buff_ids = try CosmeticsHelper.buildOrnamentBornBuffIdsForIds(assets, ornament_ids, alloc.gpa);
        const entity: Scene.Entity = .{
            .index = i,
            .net_id = slice.items(.entity_id)[i].net_id,
        };
        try buff_timers.ensureEntityRegistered(
            alloc.gpa,
            scene,
            assets,
            entity.net_id,
            now_ms,
        );
        const combat_common: pb.CombatCommon = .{ .EntityId = entity.net_id };
        var combat_notify: pb.CombatReceivePackNotify = .{};

        if (slice.items(.buffs)[i]) |*buffs| {
            for (stale_ornament_buffs.items) |entry| {
                if (buffs.getByBuffId(entry.id)) |buff| {
                    const handle_id = buff.HandleId;
                    buff_timers.cancelHandle(entity.net_id, handle_id);
                    buffs.removeByHandleId(alloc.gpa, handle_id);
                    try combat_notify.Data.append(alloc.arena, .{ .Message = .{
                        .CombatNotifyData = .{
                            .CombatCommon = combat_common,
                            .Message = .{
                                .RemoveGameplayEffectNotify = .{
                                    .EntityId = entity.net_id,
                                    .Handle = handle_id,
                                },
                            },
                        },
                    } });
                }
            }
            for (ornament_buffs.items) |entry| {
                const buff_data = assets.tables.buff.getDataById(entry.id) orelse continue;
                scene.*.instance.buff_handle += 1;
                buffs.fight_buff_infos = try alloc.gpa.realloc(buffs.fight_buff_infos, buffs.fight_buff_infos.len + 1);
                buffs.fight_buff_infos[buffs.fight_buff_infos.len - 1] = .{
                    .HandleId = scene.instance.buff_handle,
                    .BuffId = entry.id,
                    .StackCount = entry.stack_count,
                    .InstigatorId = entity.net_id,
                    .EntityId = entity.net_id,
                    .IsActive = entry.is_active,
                };
                try buff_timers.scheduleNewBuff(
                    alloc.gpa,
                    buffs.fight_buff_infos[buffs.fight_buff_infos.len - 1],
                    &buff_data,
                    entity.net_id,
                    now_ms,
                );
                try combat_notify.Data.append(alloc.arena, .{ .Message = .{
                    .CombatNotifyData = .{
                        .CombatCommon = combat_common,
                        .Message = .{
                            .ApplyGameplayEffectNotify = .{
                                .Handle = scene.instance.buff_handle,
                                .Id = entry.id,
                                .EntityId = entity.net_id,
                                .InstigatorId = entity.net_id,
                                .IsActive = entry.is_active,
                                .StackCount = entry.stack_count,
                            },
                        },
                    },
                } });
                const disposition = BuffTimerScheduler.applicationDisposition(
                    &buff_data,
                    true,
                    false,
                    entry.is_active,
                );
                if (disposition.execute_periodic_now) {
                    try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.FightBuffComponent});
                    const effect_query: Scene.Query(&.{
                        Scene.Entity,
                        *Scene.Entity.FightBuffComponent,
                        ?*Scene.Entity.AttributeComponent,
                    }) = .{ .iterator = .{ .entities = &scene.entities } };
                    try buff_helper.execute_periodic_buff_effects(
                        &combat_notify.Data,
                        entity.net_id,
                        entity.net_id,
                        &buff_data,
                        scene,
                        fs,
                        io,
                        effect_query,
                        alloc,
                    );
                }
            }
            if (buffs.born_buff_ids.len != 0) alloc.gpa.free(buffs.born_buff_ids);
            buffs.born_buff_ids = ornament_born_buff_ids;
            buffs.born_message_id = if (ornament_born_buff_ids.len == 0) 0 else slice.items(.entity_id)[i].net_id;
        }

        buff_timers.syncEntityLeftDurations(scene, entity.net_id, now_ms);
        try scene.saveComponents(fs, alloc.gpa, entity, &.{ Scene.Entity.OrnamentComponent, Scene.Entity.FightBuffComponent });

        var entity_ornament_ids: std.ArrayList(i32) = .empty;
        try entity_ornament_ids.ensureTotalCapacity(alloc.arena, ornament_ids.len);
        for (ornament_ids) |id| entity_ornament_ids.appendAssumeCapacity(id);
        try txn.conn.push(pb.EntityDressOrnamentChangeNotify{
            .EntityId = entity.net_id,
            .OrnamentComponentPb = try ornament_comp.toProto(),
        });

        if (combat_notify.Data.items.len != 0) try txn.conn.push(combat_notify);
        return;
    }
}

fn pushOrnamentEquipMap(txn: anytype, alloc: mem.Alloc, role_comp: *PlayerRoleComponent) !void {
    try txn.conn.push(pb.OrnamentDressInfoUpdateNotify{
        .OrnamentDressInfos = try CosmeticsHelper.buildOrnamentEquipMap(role_comp, alloc.arena),
    });
}

fn equippedCalabashSkinId(assets: *const Assets, role_comp: *PlayerRoleComponent) i32 {
    var roles = role_comp.role_map.iterator();
    while (roles.next()) |role| {
        if (!RoleHelper.isMainRole(assets, role.key_ptr.*)) continue;
        if (role.value_ptr.calabash_skin_id != 0) return role.value_ptr.calabash_skin_id;
    }

    return 0;
}

fn calabashSkinIdList(assets: *const Assets, arena: std.mem.Allocator) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.ensureTotalCapacity(arena, assets.tables.calabash_skin.items.len);

    for (assets.tables.calabash_skin.items) |skin| {
        list.appendAssumeCapacity(skin.Id);
    }

    return list;
}

fn pushEntityCalabashSkinChange(
    txn: anytype,
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    skin_id: i32,
) !void {
    const slice = scene.entities.slice();

    for (slice.items(.config), 0..) |config, i| {
        if (!RoleHelper.isMainRole(assets, config.config_id)) continue;

        if (slice.items(.calabash_skin)[i]) |*calabash_skin| {
            calabash_skin.skin_id = skin_id;
        } else {
            slice.items(.calabash_skin)[i] = .{ .skin_id = skin_id };
        }

        const entity: Scene.Entity = .{
            .index = i,
            .net_id = slice.items(.entity_id)[i].net_id,
        };
        try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.CalabashSkinComponent});
        try txn.conn.push(pb.EntityCalabashSkinChangeNotify{
            .EntityId = entity.net_id,
            .CalabashSkinCoponent = .{ .CalabashSkinId = skin_id },
        });
    }
}

pub fn onCalabashSkinDataRequest(
    txn: *Transaction(pb.CalabashSkinDataRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    txn.respond(.{
        .ErrorCode = .Success,
        .EquipedSkinId = equippedCalabashSkinId(assets, role_comp),
        .SkinIdList = try calabashSkinIdList(assets, alloc.arena),
    });
}

pub fn onCalabashSkinTakeOnRequest(
    txn: *Transaction(pb.CalabashSkinTakeOnRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
) !void {
    const skin_id = txn.message.SkinId;
    if (skin_id != 0 and assets.tables.calabash_skin.getDataById(skin_id) == null) {
        txn.respond(.{ .ErrorCode = .CalabashSkinUnLockErr });
        return;
    }

    var changed_roles: std.ArrayList(i32) = .empty;
    defer changed_roles.deinit(alloc.gpa);

    var roles = role_comp.role_map.iterator();
    while (roles.next()) |role| {
        const role_id = role.key_ptr.*;
        if (!RoleHelper.isMainRole(assets, role_id)) continue;
        if (role.value_ptr.calabash_skin_id == skin_id) continue;

        role.value_ptr.calabash_skin_id = skin_id;
        try changed_roles.append(alloc.gpa, role_id);
    }

    for (changed_roles.items) |role_id| {
        try events.enqueue(.role_info_modified, .{ .role_id = role_id });
    }

    try pushEntityCalabashSkinChange(txn, alloc, fs, assets, scene, skin_id);
    txn.respond(.{ .ErrorCode = .Success, .SkinId = skin_id });
}

pub fn onUnlockRoleSkinListRequest(
    txn: *Transaction(pb.UnlockRoleSkinListRequest),
    alloc: mem.Alloc,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    txn.respond(.{ .RoleSkinList = try CosmeticInfo.intList(cosmetic_comp.info.role_skins, alloc.arena) });
}

pub fn onWeaponSkinRequest(
    txn: *Transaction(pb.WeaponSkinRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    _: *PlayerCosmeticComponent,
) !void {
    txn.respond(.{
        .ErrorCode = .Success,
        .EquipList = try CosmeticsHelper.buildWeaponSkinCurrentEquipList(assets, role_comp, alloc.arena),
    });
}

pub fn onEquipWeaponSkinRequest(
    txn: *Transaction(pb.EquipWeaponSkinRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    const data = txn.message.Data orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const role = role_comp.role_map.getPtr(data.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    if (!isOwnedWeaponSkin(cosmetic_comp.info, data.SkinId) or !CosmeticsHelper.isWeaponSkinCompatible(assets, data.RoleId, data.SkinId)) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }

    role.weapon_skin_id = data.SkinId;
    try events.enqueue(.role_info_modified, .{ .role_id = data.RoleId });
    try events.enqueue(.update_formations, .{});
    try pushEntityWeaponSkinChange(txn, alloc, fs, scene, data.RoleId, data.SkinId);
    try pushWeaponSkinEquipTakeOnNotify(txn, alloc, data.RoleId, data.SkinId);

    txn.respond(.{
        .ErrorCode = .Success,
        .DataList = try buildSingleWeaponSkinEquipList(alloc, data.RoleId, data.SkinId),
    });
}

pub fn onFlySkinWearRequest(
    txn: *Transaction(pb.FlySkinWearRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    const request = txn.message;
    if (!isOwnedFlySkin(cosmetic_comp.info, request.SkinId)) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }
    const skin = findFlySkin(assets, request.SkinId) orelse {
        txn.respond(.{ .ErrorCode = .FlySkinItemNoConfig });
        return;
    };

    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    setFlySkin(role, skin);
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });
    try pushEntityFlySkinChange(txn, alloc, fs, scene, request.RoleId, skin);
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onFlySkinWearAllRoleRequest(
    txn: *Transaction(pb.FlySkinWearAllRoleRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    const request = txn.message;
    if (!isOwnedFlySkin(cosmetic_comp.info, request.SkinId)) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }
    const skin = findFlySkin(assets, request.SkinId) orelse {
        txn.respond(.{ .ErrorCode = .FlySkinItemNoConfig });
        return;
    };

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        setFlySkin(kv.value_ptr, skin);
        try events.enqueue(.role_info_modified, .{ .role_id = kv.key_ptr.* });
        try pushEntityFlySkinChange(txn, alloc, fs, scene, kv.key_ptr.*, skin);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .FlySkinData = try buildFlyEquipData(role_comp, alloc.arena, request.SkinId),
    });
}

pub fn onSendEquipSkinRequest(
    txn: *Transaction(pb.SendEquipSkinRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
) !void {
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    role.weapon_skin_id = 0;
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });
    try events.enqueue(.update_formations, .{});
    try pushEntityWeaponSkinChange(txn, alloc, fs, scene, request.RoleId, 0);
    try txn.conn.push(pb.WeaponSkinDeleteNotify{
        .RoleId = request.RoleId,
        .SkinId = 0,
    });
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onRoleSkinChangeRequest(
    txn: *Transaction(pb.RoleSkinChangeRequest),
    events: *EventQueue,
    scene: *Scene,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    role_comp: *PlayerRoleComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const skin_id = if (request.SkinId == 0)
        roleDefaultSkin(assets, request.RoleId) orelse {
            txn.respond(.{ .ErrorCode = .ErrRoleSkinConfig });
            return;
        }
    else blk: {
        if (!isOwnedRoleSkin(cosmetic_comp.info, request.SkinId)) {
            txn.respond(.{ .ErrorCode = .ErrRoleSkinNotMatch });
            return;
        }
        const skin = findRoleSkin(assets, request.RoleId, request.SkinId) orelse {
            txn.respond(.{ .ErrorCode = .ErrRoleSkinNotMatch });
            return;
        };
        break :blk skin.Id;
    };

    const skin = findRoleSkin(assets, request.RoleId, skin_id);
    const stale_ornament_ids = try CosmeticsHelper.buildOrnamentIdsForRoleSkin(assets, role.*, role.role_skin_id, alloc.arena);
    role.role_skin_id = skin_id;
    if (request.IsWearWeaponSkin) {
        if (skin) |role_skin| {
            if (isOwnedWeaponSkin(cosmetic_comp.info, role_skin.SuitWeaponSkinId) and CosmeticsHelper.isWeaponSkinCompatible(assets, request.RoleId, role_skin.SuitWeaponSkinId)) {
                role.weapon_skin_id = role_skin.SuitWeaponSkinId;
                try pushEntityWeaponSkinChange(txn, alloc, fs, scene, request.RoleId, role.weapon_skin_id);
                try pushWeaponSkinEquipTakeOnNotify(txn, alloc, request.RoleId, role.weapon_skin_id);
            }
        }
    }
    try RoleHelper.resetRoles(
        scene,
        fs,
        assets,
        role_comp,
        weapon_comp,
        echo_comp,
        txn.conn,
        alloc,
        &.{request.RoleId},
        buff_timers,
        now_ms,
    );

    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });
    try events.enqueue(.update_formations, .{});
    try refreshRoleOrnamentEntity(txn, events, alloc, assets, fs, scene, request.RoleId, role, stale_ornament_ids, buff_timers, io, now_ms);

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onChangeOrnamentRequest(
    txn: *Transaction(pb.ChangeOrnamentRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    const role_skin_id = txn.message.RoleSkinId;
    const ornament_id = txn.message.OrnamentId;
    const role_id = roleIdForSkin(assets, role_skin_id) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    if (ornament_id == 0 or !isOwnedOrnament(cosmetic_comp.info, ornament_id) or CosmeticsHelper.ornamentForRoleSkin(assets, role_skin_id, ornament_id) == null) {
        txn.respond(.{ .ErrorCode = .ErrOrnamentConfig });
        return;
    }

    const role = role_comp.role_map.getPtr(role_id) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const stale_ornament_ids = try CosmeticsHelper.buildOrnamentIdsForRoleSkin(assets, role.*, role_skin_id, alloc.arena);
    const changed = if (txn.message.IsDress)
        try role.dressOrnament(alloc.gpa, assets, role_skin_id, ornament_id)
    else
        try role.undressOrnament(alloc.gpa, role_skin_id, ornament_id);

    if (changed) {
        try events.enqueue(.role_info_modified, .{ .role_id = role_id });
        try events.enqueue(.update_formations, .{});
        try refreshRoleOrnamentEntity(txn, events, alloc, assets, fs, scene, role_id, role, stale_ornament_ids, buff_timers, io, now_ms);
    }

    txn.respond(.{ .ErrorCode = .Success });
    try pushOrnamentEquipMap(txn, alloc, role_comp);
}
