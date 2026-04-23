const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const sliceToArrayList = @import("../component/entity/EntityComponentStorage.zig").sliceToArrayList;
const Assets = @import("../../data/Assets.zig");
const RoleEntityHelpers = @import("../entity/RoleEntityHelpers.zig");
const PlayerEntityHelpers = @import("../entity/PlayerEntityHelpers.zig");
const EventQueue = @import("../EventQueue.zig");
const PlayerID = @import("../PlayerID.zig");
const Scene = @import("../Scene.zig");
const SceneInstance = @import("../../fs/SceneInstance.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerBasicComponent = @import("../component/player/PlayerBasicComponent.zig");
const PlayerSceneComponent = @import("../component/player/PlayerSceneComponent.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const file_util = @import("../../fs/file_util.zig");
const FormationInfo = @import("../../fs/FormationInfo.zig");
const RoleInfo = @import("../../fs/RoleInfo.zig");
const Entity = Scene.Entity;
const Io = std.Io;

pub fn exploreSkillNotify(alloc: mem.Alloc, scene: *Scene, conn: *Connection) !void {
    var roulette_info: std.ArrayList(pb.ExploreSkillRoulette) = .empty;
    defer roulette_info.deinit(alloc.gpa);
    try roulette_info.append(alloc.gpa, .{
        .SkillIds = sliceToArrayList(i32, scene.explore_tools_info.roulette),
        .ExploreSkill = scene.explore_tools_info.active_explore_skill,
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
    cur_scene: *?Scene,
) !void {
    const log = std.log.scoped(.initial_scene_join);
    const no_scene_data = !has_scene_data(fs, alloc.arena, scene_comp.player_id);

    if (cur_scene.*) |*scene| {
        scene.deinit(alloc.gpa, fs);
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
            const additional_roulette: []const i32 = &.{ 1015, 1029, 1009 };

            var list: std.ArrayList(i32) = .empty;
            for (assets.tables.explore_tools.items[0..3]) |tool| {
                try list.append(alloc.gpa, tool.PhantomSkillId);
            }
            for (assets.tables.explore_tools.items) |tool| {
                if (std.mem.indexOfScalar(i32, additional_roulette, tool.PhantomSkillId) != null) {
                    try list.append(alloc.gpa, tool.PhantomSkillId);
                }
            }
            break :blk try list.toOwnedSlice(alloc.gpa);
        };
        scene.explore_tools_info.active_explore_skill = 1001;

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
    scene: *Scene,
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
        .Hour = scene.instance.time.hour,
        .Minute = scene.instance.time.minute,
        .OwnerTimeClockTimeSpan = scene.instance.time.owner_clock_time_span,
    };

    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene_comp.last_scene_info.instance_id) orelse {
        // TODO: fallback to default instance id?
        log.err(
            "player({d}) last scene instance id {d} doesn't exist",
            .{ player_id.id, scene_comp.last_scene_info.instance_id },
        );
        return;
    };

    for (scene.instance.players) |scene_player| {
        if (scene_player.id == player_id.id) {
            var fight_role_groups: std.ArrayList(pb.FightRoleInfos) = .empty;

            const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
            var infos: pb.FightRoleInfos = .{
                .GroupType = scene_player.group_type,
                .CurRole = formation.cur_role,
                .LivingStatus = .Alive, // TODO: keep track of this
            };

            _ = try PlayerEntityHelpers.createPlayerSceneEntity(fs, scene, alloc, player_id.id, assets);
            _ = try PlayerEntityHelpers.createSceneBattleEntity(fs, scene, alloc, player_id.id, assets);

            for (&formation.roles) |*maybe_role| if (maybe_role.*) |*role| {
                const entity = try RoleEntityHelpers.createRoleEntity(
                    fs,
                    scene,
                    alloc,
                    player_id.id,
                    assets,
                    role_comp,
                    weapon_comp,
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
    try scene.save(fs, alloc.gpa);

    var aoi: pb.PlayerSceneAoiData = .{};

    const entities = scene.entities.slice();
    for (0..entities.len) |index| {
        const storage = entities.get(index);
        const entity = try storage.entityToProto(storage.entity_id.net_id, alloc);
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

            if (role.entity_id != -1) {
                if (query.byNetId(role.entity_id)) |comps| {
                    const attribute_comp = comps[1];
                    try role_infos.append(alloc.arena, pb.FormationRoleInfo{
                        .RoleId = role.role_id,
                        .MaxHp = attribute_comp.base_prop[@intFromEnum(pb.EAttributeType.LifeMax)],
                        .CurHp = attribute_comp.base_prop[@intFromEnum(pb.EAttributeType.Life)],
                        .Level = attribute_comp.base_prop[@intFromEnum(pb.EAttributeType.Lv)],
                        .RoleSkinId = role_info.role_skin_id,
                    });
                    continue;
                }
            }

            try role_infos.append(alloc.arena, pb.FormationRoleInfo{
                .RoleId = role.role_id,
                .MaxHp = role_info.base_prop[@intFromEnum(pb.EAttributeType.LifeMax)],
                .CurHp = role_info.base_prop[@intFromEnum(pb.EAttributeType.Life)],
                .Level = role_info.level,
                .RoleSkinId = role_info.role_skin_id,
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
    conn: *Connection,
    fs: *FileSystem,
    io: Io,
    player_id: PlayerID,
    alloc: mem.Alloc,
) !void {
    try conn.push(pb.AfterJoinSceneNotify{}, alloc.arena);
    try conn.push(pb.SwitchBattleModeNotify{}, alloc.arena);

    const rtc: Io.Clock = .real;
    const now_ms = rtc.now(io).toMilliseconds();
    try conn.push(pb.TimeCheckNotify{
        .ClientTime = 0,
        .ServerTime = now_ms,
        .ServerFlowTimestamp = now_ms,
        .ServerCombatTime = now_ms,
        .ServerStopTime = now_ms,
    }, alloc.arena);
    try events.enqueue(.update_formations, .{});

    var formation_attrs: std.ArrayList(pb.FormationAttr) = .empty;
    try formation_attrs.appendSlice(alloc.arena, &.{
        .{ .AttrId = 1, .Ratio = 2400, .BaseMaxValue = 24000, .MaxValue = 24000, .CurrentValue = 22000 },
        .{ .AttrId = 10, .Ratio = 2400, .BaseMaxValue = 7000, .MaxValue = 15000, .CurrentValue = 7000 },
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
        "assets/scripts/join_scene_patches/goon_camera_fix.js",
        "assets/scripts/join_scene_patches/bindata_patches.js",
        "assets/scripts/join_scene_patches/censorshipfix.js",
        "assets/scripts/join_scene_patches/debug_disable.js",
        "assets/scripts/join_scene_patches/main_watermask_disable.js",
        "assets/scripts/join_scene_patches/flight_fix.js",
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
