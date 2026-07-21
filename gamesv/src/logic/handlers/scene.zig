const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const sliceToArrayList = @import("../component/entity/EntityComponentStorage.zig").sliceToArrayList;
const Assets = @import("../../data/Assets.zig");
const RoleEntityTemplates = @import("../templates/RoleEntityTemplates.zig");
const PlayerEntityTemplates = @import("../templates/PlayerEntityTemplates.zig");
const EventQueue = @import("../EventQueue.zig");
const PlayerID = @import("../PlayerID.zig");
const Scene = @import("../Scene.zig");
const SceneInstance = @import("../../fs/SceneInstance.zig");
const Connection = @import("../../network/Connection.zig");
const Timers = @import("../../network/State.zig").Timers;
const DirtySaveQueue = @import("../schedulers/DirtySaveQueue.zig");
const PlayerBasicComponent = @import("../component/player/PlayerBasicComponent.zig");
const PlayerSceneComponent = @import("../component/player/PlayerSceneComponent.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const PlayerMotorComponent = @import("../component/player/PlayerMotorComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");
const file_util = @import("../../fs/file_util.zig");
const FormationInfo = @import("../../fs/FormationInfo.zig");
const RoleInfo = @import("../../fs/RoleInfo.zig");
const autopilot = @import("../helpers/autopilot.zig");
const Entity = Scene.Entity;
const Io = std.Io;
const lahai_roi_dungeon_id = 906;
const roulette_slot_count = 8;

fn rouletteSkillIds(arena: std.mem.Allocator, ids: []const i32) !std.ArrayList(i32) {
    const items = try arena.alloc(i32, roulette_slot_count);
    @memset(items, 0);
    const count = @min(ids.len, roulette_slot_count);
    @memcpy(items[0..count], ids[0..count]);
    return sliceToArrayList(i32, items);
}

fn notifyTransportRoadways(fs: *FileSystem, alloc: mem.Alloc, scene: *Scene, conn: *Connection, assets: *const Assets) !void {
    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene.instance_id) orelse return;
    const roads = try autopilot.roadIdsForMap(fs, alloc, instance_dungeon.MapConfigId);
    if (roads.items.len == 0) return;

    try conn.push(pb.SceneRoadSyncNotify{
        .InstanceId = scene.instance_id,
        .EnabledRoads = roads,
    }, alloc.arena);
}

fn notifyInfrastructureRoadData(alloc: mem.Alloc, conn: *Connection, assets: *const Assets) !void {
    var roads: std.ArrayList(pb.InfrOneRoad) = .empty;
    for (assets.tables.infr_road_build.items) |cfg| {
        if (cfg.DungeonId != lahai_roi_dungeon_id) continue;

        try roads.append(alloc.arena, .{
            .RoadId = cfg.Id,
            .status = .InfrStatusComplete,
            .CompleteTime = 0,
            .TotalGiftCount = 0,
            .LastGiftTime = 0,
        });
    }

    try conn.push(pb.InfrRoadUpdateNotify{
        .RoadInfo = .{ .Roads = roads },
    }, alloc.arena);
}

fn containsI32(items: []const i32, value: i32) bool {
    for (items) |item| {
        if (item == value) return true;
    }
    return false;
}

fn appendUniqueI32(items: *std.ArrayList(i32), arena: std.mem.Allocator, value: i32) !void {
    if (containsI32(items.items, value)) return;
    try items.append(arena, value);
}

fn appendCompletedRoadDataLayers(scene_info: *pb.SceneInformation, assets: *const Assets, arena: std.mem.Allocator) !void {
    var repaired_layers: std.ArrayList(i32) = .empty;
    var unrepaired_layers: std.ArrayList(i32) = .empty;

    for (assets.tables.infr_road_build.items) |cfg| {
        if (cfg.DungeonId != lahai_roi_dungeon_id) continue;

        for (cfg.LoadDataLayers) |layer| {
            try appendUniqueI32(&repaired_layers, arena, layer);
        }
        for (cfg.UnloadDataLayers) |layer| {
            try appendUniqueI32(&unrepaired_layers, arena, layer);
        }
    }

    var data_layers: std.ArrayList(i32) = .empty;
    for (scene_info.DataLayers.items) |layer| {
        if (!containsI32(unrepaired_layers.items, layer)) {
            try appendUniqueI32(&data_layers, arena, layer);
        }
    }
    for (repaired_layers.items) |layer| {
        try appendUniqueI32(&data_layers, arena, layer);
    }

    scene_info.DataLayers = data_layers;
}

pub fn handleSceneCleanupTick(
    _: EventQueue.Dequeue(.scene_cleanup_tick),
    scene: *Scene,
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    _ = try scene.appendBattleStateNotify(alloc.arena, &data);
    const combine_detaches = scene.pendingCombineDetaches();
    for (combine_detaches) |detach| try data.append(alloc.arena, Scene.removeCombineNotify(detach));
    if (data.items.len == 0) return;

    try conn.push(pb.CombatReceivePackNotify{ .Data = data }, alloc.arena);
    for (combine_detaches) |detach| try scene.signalFsmDissolveCombine(alloc.gpa, detach.combine_entity_id);
    scene.clearPendingCombineDetaches();
}

pub fn exploreSkillNotify(alloc: mem.Alloc, scene: *Scene, conn: *Connection) !void {
    var roulette_info: std.ArrayList(pb.ExploreSkillRoulette) = .empty;
    defer roulette_info.deinit(alloc.gpa);
    try roulette_info.append(alloc.gpa, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.roulette),
        .ExtraItemId = scene.explore_tools_info.explore_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_explore_skill,
    });
    try roulette_info.append(alloc.gpa, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.function_roulette),
        .ExtraItemId = scene.explore_tools_info.function_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_function_skill,
    });
    try roulette_info.append(alloc.gpa, .{});
    try roulette_info.append(alloc.gpa, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.motorcycle_roulette),
        .ExtraItemId = scene.explore_tools_info.motorcycle_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_motorcycle_skill,
    });

    const vision_explore_notify: pb.VisionExploreSkillNotify = .{
        .ExploreSkill = 1001,
    };
    try conn.push(pb.ExploreToolAllNotify{
        .ExploreSkill = scene.explore_tools_info.active_explore_skill,
        .SkillList = sliceToArrayList(i32, scene.explore_tools_info.unlocked_explore_skills),
    }, alloc.arena);
    try conn.push(pb.ExploreSkillRouletteUpdateNotify{
        .RouletteInfo = roulette_info,
    }, alloc.arena);
    try conn.push(vision_explore_notify, alloc.arena);
}

fn has_scene_data(fs: *FileSystem, arena: std.mem.Allocator, player_id: i32) bool {
    const path = std.fmt.allocPrint(arena, "state/player/{d}/scene", .{player_id}) catch return false;
    const dir = std.Io.Dir.cwd().openDir(fs.io, path, .{ .iterate = true }) catch return false;
    defer dir.close(fs.io);
    var it = dir.iterate();
    while (it.next(fs.io) catch return false) |entry| {
        if (entry.kind == .directory) return true;
    }
    return false;
}

pub fn onInitialSceneJoin(
    event: EventQueue.Dequeue(.initial_scene_join),
    events: *EventQueue,
    fs: *FileSystem,
    alloc: mem.Alloc,
    player_id: PlayerID,
    assets: *const Assets,
    scene_comp: *PlayerSceneComponent,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    cur_scene: *?Scene,
    timers: *Timers,
    dirty_saves: *DirtySaveQueue,
) !void {
    const log = std.log.scoped(.initial_scene_join);
    const no_scene_data = !has_scene_data(fs, alloc.arena, scene_comp.player_id);

    try dirty_saves.flush(
        alloc.gpa,
        fs,
        role_comp,
        weapon_comp,
        if (cur_scene.*) |*active_scene| active_scene else null,
    );

    if (cur_scene.*) |*scene| {
        scene.deinit(alloc.gpa, fs);
        cur_scene.* = null;
    }

    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene_comp.last_scene_info.instance_id) orelse {
        // TODO: fallback to default instance id?
        log.err(
            "player({d}) last scene instance id {d} doesn't exist",
            .{ player_id.id, scene_comp.last_scene_info.instance_id },
        );
        return;
    };

    var scene = try Scene.init(alloc.gpa, fs, player_id.id, instance_dungeon.Id);
    errdefer scene.deinit(alloc.gpa, fs);

    if (scene.instance.players.len == 0) {
        // A new scene. Player should be spawned.
        // TODO: add a check that actually searches for a player with matching ID. However this is only useful for MP, I guess?

        scene.instance.players = try alloc.gpa.alloc(SceneInstance.Player, 1);
        scene.instance.players[0] = .{
            .id = player_id.id,
            .location = event.data.location orelse .{
                @floatFromInt(instance_dungeon.BornPosition[0]),
                @floatFromInt(instance_dungeon.BornPosition[1]),
                @floatFromInt(instance_dungeon.BornPosition[2]),
            },
            .rotation = event.data.rotation orelse .{
                @floatFromInt(instance_dungeon.BornRotation[0]),
                @floatFromInt(instance_dungeon.BornRotation[1]),
                @floatFromInt(instance_dungeon.BornRotation[2]),
            },
        };
    } else if (event.data.location) |location| {
        scene.instance.players[0] = .{
            .id = player_id.id,
            .location = location,
            .rotation = event.data.rotation orelse .{
                @floatFromInt(instance_dungeon.BornRotation[0]),
                @floatFromInt(instance_dungeon.BornRotation[1]),
                @floatFromInt(instance_dungeon.BornRotation[2]),
            },
        };
    }

    if (no_scene_data) {
        // The first Scene. Basic data should be initialized.

        scene.explore_tools_info.unlocked_explore_skills = blk: {
            var list: std.ArrayList(i32) = .empty;
            for (assets.tables.explore_tools.items) |tool| {
                if (tool.Authorization.map.entries.len == 0) {
                    try list.append(alloc.gpa, tool.PhantomSkillId);
                }
            }
            break :blk try list.toOwnedSlice(alloc.gpa);
        };

        scene.explore_tools_info.roulette = blk: {
            const default_roulette: []const i32 = &.{ 6002, 1001, 1007 };
            const additional_roulette: []const i32 = &.{ 1015, 1029, 1009 };

            var list: std.ArrayList(i32) = .empty;
            for (default_roulette) |skill_id| {
                try list.append(alloc.gpa, skill_id);
            }
            for (assets.tables.explore_tools.items) |tool| {
                if (std.mem.indexOfScalar(i32, additional_roulette, tool.PhantomSkillId) != null) {
                    try list.append(alloc.gpa, tool.PhantomSkillId);
                }
            }
            while (list.items.len < roulette_slot_count) {
                try list.append(alloc.gpa, 0);
            }
            break :blk try list.toOwnedSlice(alloc.gpa);
        };
        scene.explore_tools_info.active_explore_skill = 1001;
        scene.explore_tools_info.active_function_skill = 0;
        scene.explore_tools_info.motorcycle_roulette = try alloc.gpa.dupe(i32, &[_]i32{ 6001, 6003, 6007, 6011, 6012, 6020, 0, 0 });
        scene.explore_tools_info.active_motorcycle_skill = 6001;

        const roles = [_]i32{ 1211, 1108, 1506 };

        scene.formation_info.formations = try alloc.gpa.alloc(FormationInfo.Formation, 1);
        scene.formation_info.formations[0] = .{
            .cur_role = roles[0],
            .roles = undefined,
        };
        scene.formation_info.cur_formation = 0;

        for (roles, 0..) |role, i| {
            scene.formation_info.formations[0].roles[i] = .{
                .role_id = role,
                .entity_id = -1,
                .on_stage_without_control = false,
            };
        }
    }

    try scene.save(fs, alloc.gpa);
    timers.reset(alloc.gpa);
    try events.enqueue(.scene_switch, .{
        .pending_flow = event.data.pending_flow,
    });
    cur_scene.* = scene;
}

pub fn notifyJoinScene(
    event: EventQueue.Dequeue(.scene_switch),
    events: *EventQueue,
    fs: *FileSystem,
    assets: *const Assets,
    conn: *Connection,
    alloc: mem.Alloc,
    player_id: PlayerID,
    scene_comp: *PlayerSceneComponent,
    basic_comp: *PlayerBasicComponent, // we'll have to be able to query for component of each individual player if we're going to implement MP
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    motor_comp: *PlayerMotorComponent,
    echo_comp: *PlayerEchoComponent,
    scene: *Scene,
    io: Io,
) !void {
    const log = std.log.scoped(.scene_join);
    try exploreSkillNotify(alloc, scene, conn);
    var scene_info: pb.SceneInformation = .{
        .InstanceId = scene.instance_id,
        .OwnerId = scene.instance.owner_id,
        .CurContextId = player_id.id,
        .Mode = .Single,
        .SceneBulletOwnerId = 2, // todo: unhardcode this
    };

    scene_info.TimeInfo = .{
        .Hour = scene.instance.map_time.hour,
        .Minute = scene.instance.map_time.minute,
        .OwnerTimeClockTimeSpan = scene.instance.map_time.owner_clock_time_span,
    };

    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene_comp.last_scene_info.instance_id) orelse {
        // TODO: fallback to default instance id?
        log.err(
            "player({d}) last scene instance id {d} doesn't exist",
            .{ player_id.id, scene_comp.last_scene_info.instance_id },
        );
        return;
    };
    if (instance_dungeon.Id == lahai_roi_dungeon_id) {
        try appendCompletedRoadDataLayers(&scene_info, assets, alloc.arena);
    }

    for (scene.instance.players) |scene_player| {
        if (scene_player.id == player_id.id) {
            var fight_role_groups: std.ArrayList(pb.FightRoleInfos) = .empty;

            const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
            var infos: pb.FightRoleInfos = .{
                .GroupType = scene_player.group_type,
                .CurRole = formation.cur_role,
                .LivingStatus = .Alive, // TODO: keep track of this
            };

            const motorcycle_entity = try PlayerEntityTemplates.createMotorcycleEntity(
                fs,
                scene,
                alloc,
                player_id.id,
                assets,
                motor_comp,
            );
            const player_scene_entity = try PlayerEntityTemplates.createPlayerSceneEntity(fs, scene, alloc, player_id.id, assets, motorcycle_entity.net_id);
            _ = try PlayerEntityTemplates.ensureMotorcycleCompanionEntity(
                fs,
                scene,
                alloc,
                player_id.id,
                assets,
                motorcycle_entity,
                player_scene_entity,
            );
            _ = try PlayerEntityTemplates.createSceneBattleEntity(fs, scene, alloc, player_id.id, assets);

            for (&formation.roles) |*maybe_role| if (maybe_role.*) |*role| {
                const entity = try RoleEntityTemplates.createRoleEntity(
                    fs,
                    scene,
                    alloc,
                    player_id.id,
                    assets,
                    role_comp,
                    weapon_comp,
                    echo_comp,
                    instance_dungeon,
                    role.role_id,
                );
                role.entity_id = entity.net_id;
                try infos.FightRoleInfos.append(alloc.arena, .{
                    .RoleId = role.role_id,
                    .EntityId = entity.net_id,
                    .OnStageWithoutControl = role.on_stage_without_control,
                });
            };

            try fight_role_groups.append(alloc.arena, infos);

            try scene_info.PlayerInfos.append(alloc.arena, .{
                .PlayerId = player_id.id,
                .PlayerName = basic_comp.info.attributes.name,
                .Level = basic_comp.info.attributes.level,
                .GroupType = scene_player.group_type,
                .Location = .{ // maybe it should be extracted from the active entity instead of storing it? Not quite sure.
                    .X = scene_player.location[0],
                    .Y = scene_player.location[1],
                    .Z = scene_player.location[2],
                },
                .Rotation = .{
                    .Roll = scene_player.rotation[0],
                    .Pitch = scene_player.rotation[1],
                    .Yaw = scene_player.rotation[2],
                },
                .FightRoleInfos = fight_role_groups,
                .CurRole = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)].cur_role,
                .VehiclePlayerData = .{},
                .PlayerPrefix = 1,
                .PlayerGEIncHandle = 0,
                .Gravity = .{},
            });

            break;
        }
    } else {
        // Shouldn't happen unless scene instance file is corrupted. Maybe should log it as well?
        return error.PlayerNotFoundInScene;
    }
    const fsm_clock: Io.Clock = .awake;
    try scene.initFsmRuntimes(alloc.gpa, fsm_clock.now(io).toMilliseconds());
    try scene.save(fs, alloc.gpa);

    var aoi: pb.PlayerSceneAoiData = .{};

    const entities = scene.entities.slice();
    for (0..entities.len) |index| {
        const storage = entities.get(index);
        const entity = try storage.entityToProto(storage.entity_id.net_id, alloc, assets);
        try aoi.Entities.append(alloc.arena, entity);
    }

    scene_info.AoiData = aoi;

    try conn.push(pb.JoinSceneNotify{
        .MaxEntityId = 0,
        .SceneInfo = scene_info,
        .TransitionOption = .{},
    }, alloc.arena);

    try events.enqueue(.after_scene_join, .{
        .pending_flow = event.data.pending_flow,
    });
}

pub fn formationUpdateNotify(
    _: EventQueue.Dequeue(.update_formations),
    conn: *Connection,
    scene: *Scene,
    query: Scene.Query(&.{
        Entity,
        *Entity.AttributeComponent,
    }),
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    alloc: mem.Alloc,
) !void {
    const log = std.log.scoped(.update_formations);

    var update_formation_notify: pb.UpdateFormationNotify = .default;
    const main_scene_player = scene.instance.players[0];
    var formations: std.ArrayList(pb.FightFormationNotifyInfo) = .empty;

    for (scene.formation_info.formations, 1..) |formation, i| {
        const id: i32 = @intCast(i);
        var role_infos: std.ArrayList(pb.FormationRoleInfo) = .empty;

        for (formation.roles) |maybe_role| {
            const role = maybe_role orelse continue;

            const role_info = role_comp.role_map.get(role.role_id) orelse {
                log.warn("role {} not found in role_map, skipping", .{role.role_id});
                continue;
            };
            const weapon_info = weapon_comp.weapon_map.get(role_info.weapon) orelse {
                log.warn("weapon {} not found for formation role {}, skipping", .{ role_info.weapon, role.role_id });
                continue;
            };
            var dress_list: std.ArrayList(i32) = .empty;
            defer dress_list.deinit(alloc.arena);
            for (role_info.ornaments) |ornament| {
                try dress_list.append(alloc.arena, ornament.ornament_id);
            }

            if (role.entity_id != -1) {
                if (query.byNetId(role.entity_id)) |comps| {
                    const attribute_comp = comps[1];
                    try role_infos.append(alloc.arena, pb.FormationRoleInfo{
                        .roleId = role.role_id,
                        .MaxHp = attribute_comp.attributes[@intFromEnum(pb.EAttributeType.LifeMax)].current,
                        .CurHp = attribute_comp.attributes[@intFromEnum(pb.EAttributeType.Life)].current,
                        .Level = attribute_comp.attributes[@intFromEnum(pb.EAttributeType.Lv)].current,
                        .RoleSkinId = role_info.role_skin_id,
                        .WeaponBreachLevel = weapon_info.breach,
                        .WeaponId = weapon_info.id,
                        .WeaponSkinId = role_info.weapon_skin_id,
                        .DressList = dress_list,
                    });
                    continue;
                }
            }

            try role_infos.append(alloc.arena, pb.FormationRoleInfo{
                .roleId = role.role_id,
                .MaxHp = role_info.base_prop[@intFromEnum(pb.EAttributeType.LifeMax)],
                .CurHp = role_info.base_prop[@intFromEnum(pb.EAttributeType.Life)],
                .Level = role_info.level,
                .RoleSkinId = role_info.role_skin_id,
                .WeaponBreachLevel = weapon_info.breach,
                .WeaponId = weapon_info.id,
                .WeaponSkinId = role_info.weapon_skin_id,
                .DressList = dress_list,
            });
        }

        try formations.append(alloc.arena, pb.FightFormationNotifyInfo{
            .FormationId = id,
            .CurRole = formation.cur_role,
            .RoleInfos = role_infos,
            .IsCurrent = scene.formation_info.cur_formation == i - 1,
        });
    }

    try update_formation_notify.PlayersFormations.append(alloc.arena, pb.PlayerFightFormations{
        .Formations = formations,
        .PlayerId = main_scene_player.id,
    });

    for (update_formation_notify.PlayersFormations.items) |pf| {
        log.debug("Player {} formations:", .{pf.PlayerId});
        for (pf.Formations.items) |f| {
            log.debug(
                "  Formation {} cur={} roles={any}, is_current {}",
                .{ f.FormationId, f.CurRole, f.RoleInfos.items, f.IsCurrent },
            );
        }
    }

    try conn.push(update_formation_notify, alloc.arena);
}

pub fn afterSceneJoin(
    event: EventQueue.Dequeue(.after_scene_join),
    events: *EventQueue,
    scene: *Scene,
    conn: *Connection,
    fs: *FileSystem,
    assets: *const Assets,
    io: Io,
    player_id: PlayerID,
    alloc: mem.Alloc,
) !void {
    try conn.push(pb.AfterJoinSceneNotify{}, alloc.arena);
    try conn.push(pb.SwitchBattleModeNotify{}, alloc.arena);
    try notifyTransportRoadways(fs, alloc, scene, conn, assets);
    try notifyInfrastructureRoadData(alloc, conn, assets);

    const rtc: Io.Clock = .real;
    const fsm_clock: Io.Clock = .awake;
    const now_ms = rtc.now(io).toMilliseconds();
    const fsm_now_ms = fsm_clock.now(io).toMilliseconds();
    scene.scene_time = .{
        .timestamp = now_ms,
        .last_packet_time = now_ms,
        .dilation = 1.0,
    };
    try scene.initFsmRuntimes(alloc.gpa, fsm_now_ms);
    try conn.push(pb.TimeCheckNotify{
        .ClientTime = 0,
        .ServerTime = now_ms,
        .ServerCombatTime = now_ms,
        .ServerStopTime = now_ms,
        .ServerFlowTimestamp = scene.scene_time.timestamp,
    }, alloc.arena);
    try events.enqueue(.update_formations, .{});

    var formation_attrs: std.ArrayList(pb.FormationAttr) = .empty;
    try formation_attrs.appendSlice(alloc.arena, &.{
        .{ .AttrId = 1, .Ratio = 2400, .BaseMaxValue = 24000, .MaxValue = 24000, .CurrentValue = 22000 },
        .{ .AttrId = 10, .Ratio = 2400, .BaseMaxValue = 7000, .MaxValue = 15000, .CurrentValue = 7000 },
        .{ .AttrId = 14, .Ratio = 0, .BaseMaxValue = 10000, .MaxValue = 10000, .CurrentValue = 10000 },
    });
    const formation_attr_notify: pb.FormationAttrNotify = .{
        .Duration = 1534854458,
        .FormationAttrs = formation_attrs,
    };
    try conn.push(formation_attr_notify, alloc.arena);

    const no_uid_watermark = try Io.Dir.readFileAlloc(Io.Dir.cwd(), fs.io, "assets/scripts/join_scene_patches/uid_watermark.js", alloc.gpa, Io.Limit.unlimited);
    defer alloc.gpa.free(no_uid_watermark);

    const uid_str = try std.fmt.allocPrint(alloc.gpa, "{d}", .{player_id.id});
    defer alloc.gpa.free(uid_str);

    const watermark_js = try std.mem.replaceOwned(u8, alloc.gpa, no_uid_watermark, "{PLR_UID}", uid_str);
    defer alloc.gpa.free(watermark_js);
    try conn.push(pb.JSPatchNotify{ .Content = watermark_js }, alloc.arena);

    const patch_files = [_][]const u8{
        "assets/scripts/join_scene_patches/goon_camera.js",
        "assets/scripts/join_scene_patches/camera_bindata.js",
        "assets/scripts/join_scene_patches/censorshipfix.js",
        "assets/scripts/join_scene_patches/debug_disable.js",
        "assets/scripts/join_scene_patches/main_watermask_disable.js",
        "assets/scripts/join_scene_patches/flight_fix.js",
        "assets/scripts/join_scene_patches/motorcycle.js",
        "assets/scripts/join_scene_patches/global_spawn.js",
        "assets/scripts/join_scene_patches/red_dot_remover.js",
        "assets/scripts/join_scene_patches/chat_limit.js",
    };

    for (patch_files) |path| {
        const content = try Io.Dir.readFileAlloc(Io.Dir.cwd(), fs.io, path, alloc.gpa, Io.Limit.unlimited);
        defer alloc.gpa.free(content);
        try conn.push(pb.JSPatchNotify{ .Content = content }, alloc.arena);
    }

    // shitty solution for a shitty problem...
    if (event.data.pending_flow) |flow| {
        try conn.push(pb.FlowStartNotify{
            .FlowIncId = flow.inc_id,
            .FlowListName = flow.namespace,
            .FlowId = flow.id,
            .StateId = flow.state,
        }, alloc.arena);
    }
}
