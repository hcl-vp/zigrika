const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const Connection = @import("../Connection.zig");
const MotorInfo = @import("../../fs/MotorInfo.zig");
const PlayerMotorComponent = @import("../../logic/component/player/PlayerMotorComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const Scene = @import("../../logic/Scene.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const PlayerEntityTemplates = @import("../../logic/templates/PlayerEntityTemplates.zig");
const BuffTimerScheduler = @import("../../logic/schedulers/BuffTimerScheduler.zig");
const entity_proto = @import("../../logic/helpers/entity_proto.zig");

fn intList(arena: std.mem.Allocator, items: []const i32) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.ensureTotalCapacity(arena, items.len);
    for (items) |id| {
        list.appendAssumeCapacity(id);
    }
    return list;
}

fn timedIdList(arena: std.mem.Allocator, items: []const i32) !std.ArrayList(pb.MotorOutlookIdTimePairPb) {
    var list: std.ArrayList(pb.MotorOutlookIdTimePairPb) = .empty;
    try list.ensureTotalCapacity(arena, items.len);
    for (items) |id| {
        list.appendAssumeCapacity(.{ .Id = id, .OpenTime = 0 });
    }
    return list;
}

fn motorTaskType(value: i32) pb.MotorTaskTypePb {
    return switch (value) {
        1 => .Single,
        2 => .Limited,
        3 => .Cycle,
        else => .Unknown,
    };
}

fn buildTechTrees(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !std.ArrayList(pb.MotorTechOneTreePb) {
    var tree_ids: std.ArrayList(i32) = .empty;
    for (motor_comp.info.tech_nodes) |node| {
        var found = false;
        for (tree_ids.items) |tree_id| {
            if (tree_id == node.tree_type) {
                found = true;
                break;
            }
        }
        if (!found) try tree_ids.append(alloc.arena, node.tree_type);
    }

    var trees: std.ArrayList(pb.MotorTechOneTreePb) = .empty;
    try trees.ensureTotalCapacity(alloc.arena, tree_ids.items.len);
    for (tree_ids.items) |tree_id| {
        var tech_list: std.ArrayList(pb.MotorTechPb) = .empty;
        for (motor_comp.info.tech_nodes) |node| {
            if (node.tree_type != tree_id) continue;
            try tech_list.append(alloc.arena, .{
                .Id = node.id,
                .Level = node.level,
                .Unlock = node.unlocked,
                .Current = node.current,
                .Target = node.target,
            });
        }
        trees.appendAssumeCapacity(.{
            .TreeId = tree_id,
            .Tech = tech_list,
        });
    }
    return trees;
}

fn buildTaskTrees(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !std.ArrayList(pb.MotorTaskTreePb) {
    var tree_ids: std.ArrayList(i32) = .empty;
    for (motor_comp.info.task_nodes) |task| {
        var found = false;
        for (tree_ids.items) |tree_id| {
            if (tree_id == task.tree_type) {
                found = true;
                break;
            }
        }
        if (!found) try tree_ids.append(alloc.arena, task.tree_type);
    }

    var trees: std.ArrayList(pb.MotorTaskTreePb) = .empty;
    try trees.ensureTotalCapacity(alloc.arena, tree_ids.items.len);
    for (tree_ids.items) |tree_id| {
        var task_list: std.ArrayList(pb.MotorTaskPb) = .empty;
        for (motor_comp.info.task_nodes) |task| {
            if (task.tree_type != tree_id) continue;
            try task_list.append(alloc.arena, .{
                .Id = task.id,
                .Type = motorTaskType(task.type),
                .Process = .{
                    .Current = task.current,
                    .Target = task.target,
                },
                .Reward = .{
                    .Rewarded = task.rewarded,
                    .WaitReward = task.wait_reward,
                    .MaxReward = task.max_reward,
                },
            });
        }
        trees.appendAssumeCapacity(.{
            .TreeId = tree_id,
            .Tasks = task_list,
            .TpRewarded = 0,
        });
    }
    return trees;
}

fn buildMotorTechTreeData(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc, tree_id: i32) !pb.MotorTechOneTreePb {
    var tech_list: std.ArrayList(pb.MotorTechPb) = .empty;
    for (motor_comp.info.tech_nodes) |node| {
        if (node.tree_type != tree_id) continue;
        try tech_list.append(alloc.arena, .{
            .Id = node.id,
            .Level = node.level,
            .Unlock = node.unlocked,
            .Current = node.current,
            .Target = node.target,
        });
    }
    return .{
        .TreeId = tree_id,
        .Tech = tech_list,
    };
}

fn buildMotorTaskListData(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc, tree_id: i32) !std.ArrayList(pb.MotorTaskPb) {
    var task_list: std.ArrayList(pb.MotorTaskPb) = .empty;
    for (motor_comp.info.task_nodes) |task| {
        if (task.tree_type != tree_id) continue;
        try task_list.append(alloc.arena, .{
            .Id = task.id,
            .Type = @enumFromInt(task.type),
            .Process = .{
                .Current = task.current,
                .Target = task.target,
            },
            .Reward = .{
                .Rewarded = task.rewarded,
                .WaitReward = task.wait_reward,
                .MaxReward = task.max_reward,
            },
        });
    }
    return task_list;
}

fn replaceList(gpa: std.mem.Allocator, target: *[]i32, source: []const i32) !void {
    if (target.len != 0) gpa.free(target.*);
    target.* = try gpa.dupe(i32, source);
}

fn motorOutlookErrorCode(err: anyerror) ?pb.ErrorCode {
    return switch (err) {
        error.MotorOutlookNotOwned => .MotorOutlookNotOwned,
        error.MotorFrameCfgNotFound => .MotorFrameCfgNotFound,
        error.MotorStickerCfgNotFound => .MotorStickerCfgNotFound,
        error.MotorStickerPartIdError => .MotorStickerPartIdError,
        error.MotorDecorationsCfgNotFound => .MotorDecorationsCfgNotFound,
        error.MotorDecorationsPartIdError => .MotorDecorationsPartIdError,
        else => null,
    };
}

fn partIndex(part_id: i32, count: usize) ?usize {
    if (part_id <= 0) return null;
    const index: usize = @intCast(part_id - 1);
    return if (index < count) index else null;
}

fn initPartList(gpa: std.mem.Allocator, count: usize, previous: ?[]const i32) ![]i32 {
    const result = try gpa.alloc(i32, count);
    for (result, 0..) |*slot, i| {
        slot.* = if (previous) |items|
            if (i < items.len) items[i] else 0
        else
            0;
    }
    return result;
}

fn normalizeStickers(gpa: std.mem.Allocator, assets: *const Assets, source: []const i32, previous: ?[]const i32) ![]i32 {
    const result = try initPartList(gpa, assets.tables.motor_sticker_part.items.len, previous);
    errdefer gpa.free(result);

    for (source, 0..) |id, i| {
        if (id == 0) {
            if (i < result.len) result[i] = 0;
            continue;
        }

        const sticker = assets.tables.motor_sticker.getDataById(id) orelse return error.MotorStickerCfgNotFound;
        const index = partIndex(sticker.PartId, result.len) orelse return error.MotorStickerPartIdError;
        result[index] = id;
    }

    return result;
}

fn normalizeDecorations(gpa: std.mem.Allocator, assets: *const Assets, source: []const i32, previous: ?[]const i32) ![]i32 {
    const result = try initPartList(gpa, assets.tables.motor_decorations_part.items.len, previous);
    errdefer gpa.free(result);

    for (source, 0..) |id, i| {
        if (id == 0) {
            if (i < result.len) result[i] = 0;
            continue;
        }

        const decoration = assets.tables.motor_decorations.getDataById(id) orelse return error.MotorDecorationsCfgNotFound;
        const index = partIndex(decoration.PartId, result.len) orelse return error.MotorDecorationsPartIdError;
        result[index] = id;
    }

    return result;
}

fn resolveFrame(assets: *const Assets, requested: i32, previous: i32) !i32 {
    const frame = if (requested == 0) previous else requested;
    if (frame != 0 and assets.tables.motor_frame.getDataById(frame) == null) {
        return error.MotorFrameCfgNotFound;
    }
    return frame;
}

fn buildPresetData(alloc: mem.Alloc, preset: MotorInfo.Preset) !pb.MotorOutlookPresetPlanPb {
    return .{
        .Id = preset.id,
        .Mame = preset.name,
        .Preset = .{
            .SkinEquipped = preset.skin,
            .StickerEquipped = try intList(alloc.arena, preset.stickers),
            .DecorationsEquipped = try intList(alloc.arena, preset.decorations),
            .FrameEquipped = preset.frame,
        },
    };
}

fn buildPresetList(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !pb.MotorOutlookPlayerPresetPb {
    var presets: std.ArrayList(pb.MotorOutlookPresetPlanPb) = .empty;
    try presets.ensureTotalCapacity(alloc.arena, motor_comp.info.presets.len);
    for (motor_comp.info.presets) |preset| {
        presets.appendAssumeCapacity(try buildPresetData(alloc, preset));
    }
    return .{ .Plan = presets };
}

fn buildCleanPresetList(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !pb.MotorOutlookPlayerPresetPb {
    var presets: std.ArrayList(pb.MotorOutlookPresetPlanPb) = .empty;
    try presets.ensureTotalCapacity(alloc.arena, motor_comp.info.presets.len);
    for (motor_comp.info.presets) |preset| {
        presets.appendAssumeCapacity(.{
            .Id = preset.id,
            .Mame = preset.name,
            .Preset = .{
                .SkinEquipped = preset.skin,
                .StickerEquipped = try intList(alloc.arena, preset.stickers),
                .DecorationsEquipped = try intList(alloc.arena, preset.decorations),
                .FrameEquipped = preset.frame,
            },
        });
    }
    return .{ .Plan = presets };
}

fn buildEquippedOutlook(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !pb.MotorDiyEquippedPb {
    return .{
        .SkinEquipped = motor_comp.info.equipped_skin,
        .StickerEquipped = try intList(alloc.arena, motor_comp.info.equipped_stickers),
        .DecorationsEquipped = try intList(alloc.arena, motor_comp.info.equipped_decorations),
        .FrameEquipped = motor_comp.info.equipped_frame,
    };
}

fn findMotorEntity(scene: *Scene, assets: *const Assets) ?Scene.Entity {
    const motorcycle_config_id = assets.tables.getMotorcycleConfigId() orelse return null;
    const slice = scene.entities.slice();
    for (slice.items(.follower)) |maybe_follower| {
        const follower = maybe_follower orelse continue;
        for (follower.list) |entry| {
            if (entry.Type != @intFromEnum(pb.FollowerType.EPlayerFollowerMotor) or entry.EntityId == 0) continue;

            const index = scene.net_id_map.get(entry.EntityId) orelse continue;
            const config = slice.items(.config)[index];
            if (config.config_id == motorcycle_config_id) {
                return .{
                    .index = index,
                    .net_id = entry.EntityId,
                };
            }
        }
    }

    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id == motorcycle_config_id) {
            return .{
                .index = i,
                .net_id = slice.items(.entity_id)[i].net_id,
            };
        }
    }

    return null;
}

fn isFormationEntity(scene: *Scene, entity_id: i64) bool {
    for (scene.formation_info.formations) |formation| {
        for (formation.roles) |maybe_role| {
            const role = maybe_role orelse continue;
            if (role.entity_id == entity_id) return true;
        }
    }
    return false;
}

fn pushEntityAddNotify(
    conn: *Connection,
    alloc: mem.Alloc,
    scene: *Scene,
    entity: Scene.Entity,
    assets: *const Assets,
    buff_timers: *BuffTimerScheduler,
    now_ms: i64,
) !void {
    var role_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
    defer role_entity_pbs.deinit(alloc.gpa);
    var concom_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
    defer concom_entity_pbs.deinit(alloc.gpa);

    const storage = scene.entities.get(entity.index);
    try role_entity_pbs.append(
        alloc.gpa,
        try entity_proto.build(alloc, assets, scene, buff_timers, entity.net_id, now_ms),
    );

    if (storage.concomitant) |concomitant| {
        for (concomitant.custom_entity_ids) |concom_id| {
            if (!scene.net_id_map.contains(concom_id)) continue;
            const concom_pb = try entity_proto.build(
                alloc,
                assets,
                scene,
                buff_timers,
                concom_id,
                now_ms,
            );
            try concom_entity_pbs.append(alloc.gpa, concom_pb);
        }
    }

    var role_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
    role_entity_add_notify.EntityPbs = role_entity_pbs;
    try conn.push(role_entity_add_notify, alloc.arena);

    if (concom_entity_pbs.items.len != 0) {
        var concom_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
        concom_entity_add_notify.EntityPbs = concom_entity_pbs;
        try conn.push(concom_entity_add_notify, alloc.arena);
    }
}

fn pushEntityRefreshNotify(
    conn: *Connection,
    alloc: mem.Alloc,
    scene: *Scene,
    entity: Scene.Entity,
    assets: *const Assets,
    buff_timers: *BuffTimerScheduler,
    now_ms: i64,
) !void {
    const storage = scene.entities.get(entity.index);
    var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;

    if (storage.concomitant) |concomitant| {
        for (concomitant.custom_entity_ids) |concom_id| {
            try remove_infos.append(alloc.arena, .{ .EntityId = concom_id });
        }
    }

    try remove_infos.append(alloc.arena, .{ .EntityId = entity.net_id });
    try conn.push(pb.EntityRemoveNotify{
        .IsRemove = true,
        .RemoveInfos = remove_infos,
    }, alloc.arena);
    try pushEntityAddNotify(conn, alloc, scene, entity, assets, buff_timers, now_ms);
}

fn pushEntityRemoveNotify(
    conn: *Connection,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    entity: Scene.Entity,
) !void {
    if (isFormationEntity(scene, entity.net_id)) return;

    const storage = scene.entities.get(entity.index);
    var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;
    defer remove_infos.deinit(alloc.gpa);

    if (storage.concomitant) |concomitant| {
        for (concomitant.custom_entity_ids) |concom_id| {
            try scene.remove(alloc.gpa, fs, concom_id);
            try remove_infos.append(alloc.gpa, .{ .EntityId = concom_id });
        }
    }

    try scene.remove(alloc.gpa, fs, entity.net_id);
    try remove_infos.append(alloc.gpa, .{ .EntityId = entity.net_id });

    var remove_notify: pb.EntityRemoveNotify = .{ .IsRemove = true };
    remove_notify.RemoveInfos = remove_infos;
    try conn.push(remove_notify, alloc.arena);
}

fn pushRideSharingSeatNotify(
    conn: *Connection,
    alloc: mem.Alloc,
    role_entity_id: i64,
    motor_entity_id: i64,
    seat: i32,
    occupied: bool,
) !void {
    try conn.push(pb.VehicleUpdateEntityNotify{
        .EntityId = role_entity_id,
        .VehicleCreatureId = motor_entity_id,
        .Seat = seat,
        .IsEntering = occupied,
        .ExitType = .ExitVehicleTypeSeatStandUp,
    }, alloc.arena);
}

fn updateMotorOutlookEntity(
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    assets: *const Assets,
    motor_comp: *PlayerMotorComponent,
) !?Scene.Entity {
    const slice = scene.entities.slice();
    const entity = findMotorEntity(scene, assets) orelse return null;
    const i = entity.index;

    if (slice.items(.motor_outlook)[i]) |*outlook| {
        outlook.skin = motor_comp.info.equipped_skin;
        try replaceList(alloc.gpa, &outlook.stickers, motor_comp.info.equipped_stickers);
        try replaceList(alloc.gpa, &outlook.decorations, motor_comp.info.equipped_decorations);
        outlook.frame = motor_comp.info.equipped_frame;
    } else {
        slice.items(.motor_outlook)[i] = .{
            .skin = motor_comp.info.equipped_skin,
            .stickers = try alloc.gpa.dupe(i32, motor_comp.info.equipped_stickers),
            .decorations = try alloc.gpa.dupe(i32, motor_comp.info.equipped_decorations),
            .frame = motor_comp.info.equipped_frame,
        };
    }

    try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.MotorOutlookComponent});
    return entity;
}

fn freePreset(gpa: std.mem.Allocator, preset: MotorInfo.Preset) void {
    if (preset.name.len != 0) gpa.free(preset.name);
    if (preset.stickers.len != 0) gpa.free(preset.stickers);
    if (preset.decorations.len != 0) gpa.free(preset.decorations);
}

fn makePreset(gpa: std.mem.Allocator, id: i32, name: []const u8, equipped: pb.MotorDiyEquippedPb, fallback_skin: i32) !MotorInfo.Preset {
    return .{
        .id = id,
        .name = try gpa.dupe(u8, name),
        .skin = if (equipped.SkinEquipped == 0) fallback_skin else equipped.SkinEquipped,
        .stickers = try gpa.dupe(i32, equipped.StickerEquipped.items),
        .decorations = try gpa.dupe(i32, equipped.DecorationsEquipped.items),
        .frame = equipped.FrameEquipped,
    };
}

fn buildMotorDiy(motor_comp: *PlayerMotorComponent, alloc: mem.Alloc) !pb.MotorDiyPb {
    return .{
        .MotorDiyOnwer = .{
            .SkinOwned = try intList(alloc.arena, motor_comp.info.owned_skins),
            .StickerOnwed = try intList(alloc.arena, motor_comp.info.owned_stickers),
            .DecorationsOwned = try intList(alloc.arena, motor_comp.info.owned_decorations),
            .FrameOwned = try intList(alloc.arena, motor_comp.info.owned_frames),
        },
        .MotorDiyEquipped = .{
            .SkinEquipped = motor_comp.info.equipped_skin,
            .StickerEquipped = try intList(alloc.arena, motor_comp.info.equipped_stickers),
            .DecorationsEquipped = try intList(alloc.arena, motor_comp.info.equipped_decorations),
            .FrameEquipped = motor_comp.info.equipped_frame,
        },
        .MotorOutlookPreset = try buildCleanPresetList(motor_comp, alloc),
    };
}

pub fn onMotorInfoRequest(
    txn: *Transaction(pb.MotorInfoRequest),
    alloc: mem.Alloc,
    motor_comp: *PlayerMotorComponent,
) !void {
    txn.respond(.{
        .ErrorCode = .Success,
        .Motor = .{
            .MotorLevel = motor_comp.info.level,
            .MotorExp = motor_comp.info.exp,
            .MotorRewardedLvMax = motor_comp.info.rewarded_max_level,
            .UnlockedTree = try buildTechTrees(motor_comp, alloc),
            .TreeInUse = motor_comp.info.tree_in_use,
            .TaskTrees = try buildTaskTrees(motor_comp, alloc),
            .MotorExpLimitGainDaily = motor_comp.info.daily_exp_gain,
            .MotorExpMonsterDropDailyLimit = motor_comp.info.daily_exp_limit,
        },
    });
}

pub fn onMotorDiyInfoRequest(
    txn: *Transaction(pb.MotorDiyInfoRequest),
    alloc: mem.Alloc,
    motor_comp: *PlayerMotorComponent,
) !void {
    try txn.conn.push(pb.MotorOutlookRegionInfoNotify{
        .MotorOutlookRegion = .{
            .MotorSticker = try timedIdList(alloc.arena, motor_comp.info.owned_stickers),
            .MotorDecoration = try timedIdList(alloc.arena, motor_comp.info.owned_decorations),
            .MotorFrame = try timedIdList(alloc.arena, motor_comp.info.owned_frames),
        },
    }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .MotorDiy = try buildMotorDiy(motor_comp, alloc),
    });
}

pub fn onMotorCreateRequest(txn: *Transaction(pb.MotorCreateRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onSendMovieModeRideSharingRequest(
    txn: *Transaction(pb.SendMovieModeRideSharingRequest),
    alloc: mem.Alloc,
    player_id: PlayerID,
) !void {
    try txn.conn.push(pb.VehicleShareNotify{
        .PlayerId = player_id.id,
        .ShareRideMode = txn.message.ShareRideMode,
        .IsInMovieRideSharingMode = txn.message.IsInMovieRideSharingMode,
        .Reason = .ClientRequest,
    }, alloc.arena);

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onChangeVehicleRideSharingRequest(
    txn: *Transaction(pb.ChangeVehicleRideSharingRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    player_id: PlayerID,
    scene: *Scene,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const passenger_seat = 1;
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();

    if (txn.message.RoleId <= 0) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }
    if (!role_comp.role_map.contains(txn.message.RoleId)) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }

    const motor_entity = findMotorEntity(scene, assets) orelse {
        txn.respond(.{ .ErrorCode = .InternalError });
        return;
    };
    const player_scene_entity = PlayerEntityTemplates.findPlayerSceneEntity(scene, player_id.id) orelse {
        txn.respond(.{ .ErrorCode = .InternalError });
        return;
    };
    const companion = try PlayerEntityTemplates.ensureMotorcycleCompanionEntity(
        fs,
        scene,
        alloc,
        player_id.id,
        assets,
        motor_entity,
        player_scene_entity,
    );
    if (companion.created) {
        try pushEntityAddNotify(
            txn.conn,
            alloc,
            scene,
            companion.entity,
            assets,
            buff_timers,
            now_ms,
        );
    }

    if (PlayerEntityTemplates.findMotorcyclePassengerEntity(scene, assets)) |old_passenger| {
        try pushRideSharingSeatNotify(txn.conn, alloc, old_passenger.net_id, motor_entity.net_id, passenger_seat, false);
        try pushEntityRemoveNotify(txn.conn, alloc, fs, scene, old_passenger);
    }

    const passenger_entity = PlayerEntityTemplates.createMotorcyclePassengerEntity(
        fs,
        scene,
        alloc,
        player_id.id,
        assets,
        txn.message.RoleId,
        motor_entity,
        passenger_seat,
    ) catch |err| switch (err) {
        error.MotorcyclePassengerTemplateNotFound => {
            txn.respond(.{ .ErrorCode = .RequestParamError });
            return;
        },
        else => return err,
    };
    try pushEntityAddNotify(
        txn.conn,
        alloc,
        scene,
        passenger_entity,
        assets,
        buff_timers,
        now_ms,
    );

    try txn.conn.push(pb.UpdateVehicleRideSharingNotify{
        .PlayerId = player_id.id,
        .RoleId = txn.message.RoleId,
        .Seat = passenger_seat,
        .EntityId = passenger_entity.net_id,
    }, alloc.arena);
    try pushRideSharingSeatNotify(txn.conn, alloc, passenger_entity.net_id, motor_entity.net_id, passenger_seat, true);

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn RemoveRideSharingPassengerRequest(
    txn: *Transaction(pb.RemoveRideSharingPassengerRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    player_id: PlayerID,
    scene: *Scene,
    assets: *const Assets,
) !void {
    const passenger_seat = 1;

    if (PlayerEntityTemplates.findMotorcyclePassengerEntity(scene, assets)) |entity| {
        if (findMotorEntity(scene, assets)) |motor_entity| {
            try pushRideSharingSeatNotify(txn.conn, alloc, entity.net_id, motor_entity.net_id, passenger_seat, false);
        }

        try txn.conn.push(pb.UpdateVehicleRideSharingNotify{
            .PlayerId = player_id.id,
            .RoleId = 0,
            .Seat = passenger_seat,
            .EntityId = entity.net_id,
        }, alloc.arena);

        try pushEntityRemoveNotify(txn.conn, alloc, fs, scene, entity);
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onMotorTechLevelUpRequest(
    txn: *Transaction(pb.MotorTechLevelUpRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
    scene: *Scene,
    assets: *const Assets,
) !void {
    for (motor_comp.info.tech_nodes) |*node| {
        if (node.id != txn.message.TechId) continue;
        if (node.level < node.target) {
            node.level += 1;
            node.current = node.level;
            node.unlocked = true;
            try motor_comp.save(fs, alloc.arena);
        }
        if (findMotorEntity(scene, assets)) |entity| {
            try PlayerEntityTemplates.refreshMotorcycleBornBuffs(events, scene, alloc, assets, motor_comp, entity);
        }
        const tree = try buildMotorTechTreeData(motor_comp, alloc, node.tree_type);
        try txn.conn.push(pb.MotorLockedTechUpdateNotify{
            .TreeId = node.tree_type,
            .Tech = tree.Tech,
        }, alloc.arena);
        txn.respond(.{
            .ErrorCode = .Success,
            .Tree = tree,
        });
        return;
    }

    txn.respond(.{
        .ErrorCode = .MotorTechCfgNotFound,
    });
}

pub fn onMotorTechTreeSwitchRequest(
    txn: *Transaction(pb.MotorTechTreeSwitchRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
    scene: *Scene,
    assets: *const Assets,
) !void {
    motor_comp.info.tree_in_use = txn.message.TreeId;
    try motor_comp.save(fs, alloc.arena);
    if (findMotorEntity(scene, assets)) |entity| {
        try PlayerEntityTemplates.refreshMotorcycleBornBuffs(events, scene, alloc, assets, motor_comp, entity);
    }
    txn.respond(.{
        .ErrorCode = .Success,
        .TreeInUse = motor_comp.info.tree_in_use,
    });
}

pub fn onMotorLevelOneKeyRewardRequest(
    txn: *Transaction(pb.MotorLevelOneKeyRewardRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
) !void {
    motor_comp.info.rewarded_max_level = motor_comp.info.level;
    try motor_comp.save(fs, alloc.arena);
    txn.respond(.{
        .ErrorCode = .Success,
        .MotorRewardedLvMax = motor_comp.info.rewarded_max_level,
    });
}

pub fn onMotorTaskOneKeyRewardRequest(
    txn: *Transaction(pb.MotorTaskOneKeyRewardRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
) !void {
    var updated_tree: ?i32 = null;
    for (txn.message.TaskIds.items) |task_id| {
        for (motor_comp.info.task_nodes) |*task| {
            if (task.id != task_id) continue;
            if (task.wait_reward > 0) {
                task.rewarded += task.wait_reward;
                task.wait_reward = 0;
            }
            updated_tree = task.tree_type;
            break;
        }
    }

    if (updated_tree) |tree_id| {
        try motor_comp.save(fs, alloc.arena);
        try txn.conn.push(pb.MotorTaskUpdateNotify{
            .Task = try buildMotorTaskListData(motor_comp, alloc, tree_id),
        }, alloc.arena);
    }

    txn.respond(.{
        .ErrorCode = .Success,
    });
}

pub fn onMotorUseSkinRequest(
    txn: *Transaction(pb.MotorUseSkinRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
    scene: *Scene,
    assets: *const Assets,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const previous_frame = motor_comp.info.equipped_frame;
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    const skin = assets.tables.motor_skin.getDataById(txn.message.SkinId) orelse {
        txn.respond(.{
            .ErrorCode = .MotorOutlookNotOwned,
        });
        return;
    };
    const frame = resolveFrame(assets, skin.BindFrame, motor_comp.info.equipped_frame) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    const stickers = normalizeStickers(alloc.gpa, assets, skin.BindSticker, null) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    defer alloc.gpa.free(stickers);
    const decorations = normalizeDecorations(alloc.gpa, assets, skin.BindDecorations, null) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    defer alloc.gpa.free(decorations);

    motor_comp.info.equipped_skin = txn.message.SkinId;
    motor_comp.info.equipped_frame = frame;
    try replaceList(alloc.gpa, &motor_comp.info.equipped_stickers, stickers);
    try replaceList(alloc.gpa, &motor_comp.info.equipped_decorations, decorations);
    try motor_comp.save(fs, alloc.arena);
    try txn.conn.push(pb.MotorOutlookEquippedChangeNotify{
        .MotorDiyEquipped = try buildEquippedOutlook(motor_comp, alloc),
    }, alloc.arena);
    if (try updateMotorOutlookEntity(alloc, fs, scene, assets, motor_comp)) |entity| {
        if (previous_frame != frame) {
            try pushEntityRefreshNotify(
                txn.conn,
                alloc,
                scene,
                entity,
                assets,
                buff_timers,
                now_ms,
            );
        } else {
            try txn.conn.push(pb.EntityMotorOutlookChangeNotify{
                .EntityId = entity.net_id,
                .MotorDiyEquipped = try buildEquippedOutlook(motor_comp, alloc),
            }, alloc.arena);
        }
    }
    txn.respond(.{
        .ErrorCode = .Success,
    });
}

pub fn onMotorChangeOutlookRequest(
    txn: *Transaction(pb.MotorChangeOutlookRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
    scene: *Scene,
    assets: *const Assets,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const previous_frame = motor_comp.info.equipped_frame;
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    const frame = resolveFrame(assets, txn.message.FrameEquipped, motor_comp.info.equipped_frame) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    const stickers = normalizeStickers(alloc.gpa, assets, txn.message.StickerEquipped.items, motor_comp.info.equipped_stickers) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    defer alloc.gpa.free(stickers);
    const decorations = normalizeDecorations(alloc.gpa, assets, txn.message.DecorationsEquipped.items, motor_comp.info.equipped_decorations) catch |err| {
        if (motorOutlookErrorCode(err)) |code| {
            txn.respond(.{ .ErrorCode = code });
            return;
        }
        return err;
    };
    defer alloc.gpa.free(decorations);

    try replaceList(alloc.gpa, &motor_comp.info.equipped_stickers, stickers);
    try replaceList(alloc.gpa, &motor_comp.info.equipped_decorations, decorations);
    motor_comp.info.equipped_frame = frame;
    try motor_comp.save(fs, alloc.arena);
    try txn.conn.push(pb.MotorOutlookEquippedChangeNotify{
        .MotorDiyEquipped = try buildEquippedOutlook(motor_comp, alloc),
    }, alloc.arena);
    if (try updateMotorOutlookEntity(alloc, fs, scene, assets, motor_comp)) |entity| {
        if (previous_frame != frame) {
            try pushEntityRefreshNotify(
                txn.conn,
                alloc,
                scene,
                entity,
                assets,
                buff_timers,
                now_ms,
            );
        } else {
            try txn.conn.push(pb.EntityMotorOutlookChangeNotify{
                .EntityId = entity.net_id,
                .MotorDiyEquipped = try buildEquippedOutlook(motor_comp, alloc),
            }, alloc.arena);
        }
    }
    txn.respond(.{
        .ErrorCode = .Success,
    });
}

pub fn MotorOutlookCreatePresetRequest(
    txn: *Transaction(pb.MotorOutlookCreatePresetRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
) !void {
    const equipped = txn.message.Preset orelse {
        txn.respond(.{ .ErrorCode = @intFromEnum(pb.ErrorCode.MotorOutlookPresetInputInvalid) });
        return;
    };

    const preset = try makePreset(
        alloc.gpa,
        motor_comp.info.next_preset_id,
        txn.message.name,
        equipped,
        motor_comp.info.equipped_skin,
    );
    motor_comp.info.next_preset_id += 1;

    const old_presets = motor_comp.info.presets;
    const new_presets = try alloc.gpa.alloc(MotorInfo.Preset, old_presets.len + 1);
    @memcpy(new_presets[0..old_presets.len], old_presets);
    new_presets[old_presets.len] = preset;
    if (old_presets.len != 0) alloc.gpa.free(old_presets);
    motor_comp.info.presets = new_presets;

    try motor_comp.save(fs, alloc.arena);
    txn.respond(.{
        .ErrorCode = @intFromEnum(pb.ErrorCode.Success),
        .MotorOutlookPreset = try buildPresetList(motor_comp, alloc),
    });
}

pub fn onMotorOutlookDeletePresetRequest(
    txn: *Transaction(pb.MotorOutlookDeletePresetRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
) !void {
    var index: ?usize = null;
    for (motor_comp.info.presets, 0..) |preset, i| {
        if (preset.id == txn.message.id) {
            index = i;
            break;
        }
    }

    const remove_index = index orelse {
        txn.respond(.{ .ErrorCode = @intFromEnum(pb.ErrorCode.MotorOutlookPresetNotExist) });
        return;
    };

    freePreset(alloc.gpa, motor_comp.info.presets[remove_index]);
    const old_presets = motor_comp.info.presets;
    const new_presets = try alloc.gpa.alloc(MotorInfo.Preset, old_presets.len - 1);
    if (remove_index > 0) @memcpy(new_presets[0..remove_index], old_presets[0..remove_index]);
    if (remove_index + 1 < old_presets.len) {
        @memcpy(new_presets[remove_index..], old_presets[remove_index + 1 ..]);
    }
    alloc.gpa.free(old_presets);
    motor_comp.info.presets = new_presets;

    try motor_comp.save(fs, alloc.arena);
    txn.respond(.{
        .ErrorCode = @intFromEnum(pb.ErrorCode.Success),
        .MotorOutlookPreset = try buildPresetList(motor_comp, alloc),
    });
}

pub fn onMotorOutlookEditPresetRequest(
    txn: *Transaction(pb.MotorOutlookEditPresetRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    motor_comp: *PlayerMotorComponent,
) !void {
    const request = txn.message.PresetPlan orelse {
        txn.respond(.{ .ErrorCode = @intFromEnum(pb.ErrorCode.MotorOutlookPresetInputInvalid) });
        return;
    };
    const equipped = request.Preset orelse {
        txn.respond(.{ .ErrorCode = @intFromEnum(pb.ErrorCode.MotorOutlookPresetInputInvalid) });
        return;
    };

    for (motor_comp.info.presets) |*preset| {
        if (preset.id != request.Id) continue;
        freePreset(alloc.gpa, preset.*);
        preset.* = try makePreset(alloc.gpa, request.Id, request.Mame, equipped, motor_comp.info.equipped_skin);
        try motor_comp.save(fs, alloc.arena);
        txn.respond(.{
            .ErrorCode = @intFromEnum(pb.ErrorCode.Success),
            .MotorOutlookPreset = try buildPresetList(motor_comp, alloc),
        });
        return;
    }

    txn.respond(.{
        .ErrorCode = @intFromEnum(pb.ErrorCode.MotorOutlookPresetNotExist),
    });
}
