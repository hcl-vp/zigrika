const Scene = @import("../Scene.zig");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const std = @import("std");
const Allocator = std.mem.Allocator;
const pb = @import("proto").pb;
const incr = @import("../../fs/incr.zig");
const BuffAdditionEntry = @import("../../logic/events.zig").BuffAdditionEntry;
const CosmeticsHelper = @import("../helpers/cosmetics.zig");
const RoleStats = @import("../helpers/role_stats.zig");

const buffListFromIds = @import("../../data/tables/Buff.zig").buffListFromIds;

fn appendPassiveSkill(gpa: Allocator, skills: *std.ArrayList(pb.SkillComponentPb), skill_id: i32) !void {
    if (skill_id == 0) return;
    for (skills.items) |skill| {
        if (skill.SkillId == skill_id) return;
    }
    try skills.append(gpa, .{ .SkillId = skill_id, .ConstateId = -1 });
}

fn appendVisionPassiveSkills(
    assets: *const Assets,
    gpa: Allocator,
    skills: *std.ArrayList(pb.SkillComponentPb),
    summon_ids: []const i32,
    vision_skills: []const pb.VisionSkillInformation,
) !void {
    var has_vision_summon = false;
    for (summon_ids) |summon_id| {
        if (summon_id == 0) continue;
        has_vision_summon = true;
        try appendVisionEntityPassiveSkills(assets, gpa, skills, summon_id);
    }
    if (!has_vision_summon) return;

    for (vision_skills) |skill| {
        if (skill.Index >= 5) continue;
        try appendPassiveSkill(gpa, skills, skill.SkillId);
    }

    for (assets.tables.common_skill_preload.items) |entry| {
        if (!entry.IsCommon) continue;
        const is_vision_skill = for (entry.Others) |path| {
            if (std.mem.indexOf(u8, path, "/Character/Vision/GA/GA_") != null or
                std.mem.indexOf(u8, path, "/Character/Vision/GA/Role/GA_Role_Bianshen.") != null or
                std.mem.indexOf(u8, path, "/Character/Vision/GA/Role/GA_Role_Zhaohuan.") != null)
            {
                break true;
            }
        } else false;
        if (is_vision_skill) try appendPassiveSkill(gpa, skills, entry.Id);
    }
}

fn appendVisionEntityPassiveSkills(
    assets: *const Assets,
    gpa: Allocator,
    skills: *std.ArrayList(pb.SkillComponentPb),
    summon_id: i32,
) !void {
    const actor_path = visionSummonActorPath(assets, summon_id) orelse return;
    for (assets.tables.entity_skill_preload.items) |entry| {
        if (entry.ActorBlueprint.len == 0) continue;
        if (!std.mem.eql(u8, entry.ActorBlueprint, actor_path)) continue;
        try appendPassiveSkill(gpa, skills, entry.SkillId);
    }
}

fn visionSummonActorPath(assets: *const Assets, summon_id: i32) ?[]const u8 {
    const summon_cfg = assets.tables.summon_cfg.getDataById(summon_id) orelse return null;
    const template_config = for (assets.tables.template_config.items) |entry| {
        if (std.mem.eql(u8, entry.BlueprintType, summon_cfg.BlueprintType)) break entry;
    } else return null;
    const model_component = template_config.ComponentsData.ModelComponent orelse return null;
    const model_id = model_component.ModelType.ModelId;
    if (model_id == 0) return null;
    const model = assets.tables.model_config_preload.getDataById(model_id) orelse return null;
    return model.ActorClassPath;
}

pub fn createConcomitantEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    role_comp: *PlayerRoleComponent,
    instance_dungeon: Assets.DataTables.InstanceDungeon,
    summon_cfg: Assets.DataTables.SummonCfg,
    template_config: Assets.DataTables.TemplateConfig,
    role: i32,
    summoner_id: i64,
) !Entity {
    const role_info = role_comp.role_map.getPtr(role).?;

    var born_buffs = try buffListFromIds(alloc.gpa, summon_cfg.BornBuffId);
    defer born_buffs.deinit(alloc.gpa);

    const entity = try scene.spawn(alloc.gpa, fs, .{
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .monster,
            .config_type = .template,
            .config_id = template_config.Id,
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.PositionComponent{
            .location = .{
                @floatFromInt(instance_dungeon.BornPosition[0]),
                @floatFromInt(instance_dungeon.BornPosition[1]),
                @floatFromInt(instance_dungeon.BornPosition[2]),
            },
            .rotation = .{
                @floatFromInt(instance_dungeon.BornRotation[0]),
                @floatFromInt(instance_dungeon.BornRotation[1]),
                @floatFromInt(instance_dungeon.BornRotation[2]),
            },
        },
        Entity.ActorVisibleMarker{},
        Entity.FightBuffComponent{},
        try Entity.AttributeComponent.create(
            try alloc.arena.dupe(i32, role_info.base_prop),
            alloc.gpa,
        ),
        Entity.SummonerComponent{
            .player_id = player_id,
            .summon_cfg_id = summon_cfg.Id,
            .summon_skill_id = 0,
            .summon_type = .ESummonTypeConcomitantCustom,
            .summoner_id = summoner_id,
        },
        Entity.LogicStateComponent{
            .direction_state = 0,
            .move_state = 0,
            .position_state = 0,
            .position_sub_state = 0,
        },
        Entity.MonsterAiComponent{
            .ai_team_init_id = 0,
            .combat_message_id = 1,
            .hatred_group_id = 0,
            .weapon_id = 0,
        },
        Entity.EquipComponent{},
        Entity.CharacterAttachComponent{
            .pb_combine_part_info_list = &.{},
            .pb_combine_target_server_id = 0,
        },
    });

    const slice = scene.entities.slice();

    const fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);
    slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos;

    return entity;
}

pub fn createVisionEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    role_info: *const @import("../../fs/RoleInfo.zig"),
    instance_dungeon: Assets.DataTables.InstanceDungeon,
    summon_skill_id: i32,
    summoner_id: i64,
) !?Entity {
    const summon_cfg = assets.tables.summon_cfg.getDataById(summon_skill_id) orelse return null;
    if (summon_cfg.BlueprintType.len == 0) return null;

    const template_config = for (assets.tables.template_config.items) |entry| {
        if (std.mem.eql(u8, entry.BlueprintType, summon_cfg.BlueprintType)) break entry;
    } else return null;

    const entity = try scene.spawn(alloc.gpa, fs, .{
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .vision,
            .config_type = .template,
            .config_id = template_config.Id,
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.PositionComponent{
            .location = .{
                @floatFromInt(instance_dungeon.BornPosition[0]),
                @floatFromInt(instance_dungeon.BornPosition[1]),
                @floatFromInt(instance_dungeon.BornPosition[2]),
            },
            .rotation = .{
                @floatFromInt(instance_dungeon.BornRotation[0]),
                @floatFromInt(instance_dungeon.BornRotation[1]),
                @floatFromInt(instance_dungeon.BornRotation[2]),
            },
        },
        Entity.ActorVisibleMarker{},
        Entity.FightBuffComponent{},
        try Entity.AttributeComponent.create(
            try alloc.arena.dupe(i32, role_info.base_prop),
            alloc.gpa,
        ),
        Entity.SummonerComponent{
            .player_id = player_id,
            .summon_cfg_id = summon_cfg.Id,
            .summon_skill_id = summon_skill_id,
            .summon_type = .ESummonTypeConcomitantVision,
            .summoner_id = summoner_id,
        },
        Entity.LogicStateComponent{
            .direction_state = 0,
            .move_state = 0,
            .position_state = 0,
            .position_sub_state = 0,
        },
        Entity.MonsterAiComponent{
            .ai_team_init_id = 0,
            .combat_message_id = 1,
            .hatred_group_id = 0,
            .weapon_id = 0,
        },
        Entity.EquipComponent{},
        Entity.CharacterAttachComponent{
            .pb_combine_part_info_list = &.{},
            .pb_combine_target_server_id = 0,
        },
        Entity.VisionSkillComponent{},
    });

    var born_buffs = try buffListFromIds(alloc.gpa, summon_cfg.BornBuffId);
    defer born_buffs.deinit(alloc.gpa);

    const slice = scene.entities.slice();
    const fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);
    slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos;

    return entity;
}

pub fn createProjectorVisionEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    summon_skill_id: i32,
    summoner_id: i64,
    net_id: i64,
    pos: pb.Vector,
    rot: pb.Rotator,
) !?Entity {
    const summon_cfg = assets.tables.summon_cfg.getDataById(summon_skill_id) orelse return null;
    if (summon_cfg.BlueprintType.len == 0) return null;

    const template_config = for (assets.tables.template_config.items) |entry| {
        if (std.mem.eql(u8, entry.BlueprintType, summon_cfg.BlueprintType)) break entry;
    } else return null;

    var passive_skills: std.ArrayList(pb.SkillComponentPb) = .empty;
    errdefer passive_skills.deinit(alloc.gpa);
    try appendVisionPassiveSkills(assets, alloc.gpa, &passive_skills, &.{summon_skill_id}, &.{});
    const passive_skill_slice = try passive_skills.toOwnedSlice(alloc.gpa);
    var passive_skill_owned = false;
    errdefer if (!passive_skill_owned) alloc.gpa.free(passive_skill_slice);

    const entity = try scene.spawnWithNetId(alloc.gpa, fs, net_id, .{
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .vision,
            .config_type = .template,
            .config_id = template_config.Id,
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.PositionComponent{
            .location = .{ pos.X, pos.Y, pos.Z },
            .rotation = .{ rot.Roll, rot.Pitch, rot.Yaw },
        },
        Entity.ActorVisibleMarker{},
        Entity.FightBuffComponent{},
        Entity.AttributeComponent{},
        Entity.SummonerComponent{
            .player_id = player_id,
            .summon_cfg_id = summon_cfg.Id,
            .summon_skill_id = summon_skill_id,
            .summon_type = .ESummonTypeConcomitantVision,
            .summoner_id = summoner_id,
        },
        Entity.LogicStateComponent{
            .direction_state = 0,
            .move_state = 0,
            .position_state = 0,
            .position_sub_state = 0,
        },
        Entity.MonsterAiComponent{
            .ai_team_init_id = 0,
            .combat_message_id = 1,
            .hatred_group_id = 0,
            .weapon_id = 0,
        },
        Entity.EquipComponent{},
        Entity.CharacterAttachComponent{
            .pb_combine_part_info_list = &.{},
            .pb_combine_target_server_id = 0,
        },
        Entity.VisionSkillComponent{},
        Entity.PassiveGaSkillComponent{ .skill_component_pb = passive_skill_slice },
    });
    passive_skill_owned = true;

    var born_buffs = try buffListFromIds(alloc.gpa, summon_cfg.BornBuffId);
    defer born_buffs.deinit(alloc.gpa);

    const slice = scene.entities.slice();
    const fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);
    slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos;

    return entity;
}

pub fn createRoleEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    instance_dungeon: Assets.DataTables.InstanceDungeon,
    role: i32,
) !Entity {
    const role_info = role_comp.role_map.getPtr(role).?;

    const weapon = weapon_comp.weapon_map.get(role_info.weapon) orelse unreachable;
    var role_base_buffs = try assets.tables.getRoleAutoBuffs(role, weapon, alloc.gpa);
    defer role_base_buffs.deinit(alloc.gpa);

    // resonant chain buffs
    for (assets.tables.resonant_chain.items) |chain| {
        if (chain.GroupId != role) continue;
        if (chain.GroupIndex > role_info.resonant_chain_group_index) continue;
        for (chain.BuffIds) |buff_id| {
            try role_base_buffs.append(alloc.gpa, .{
                .id = buff_id,
                .is_active = true,
            });
        }
    }

    const ornament_ids = try CosmeticsHelper.buildOrnamentIdsForRoleSkin(
        assets,
        role_info.*,
        role_info.role_skin_id,
        alloc.gpa,
    );

    // ornaments!!!!
    var ornament_buffs = try CosmeticsHelper.buildOrnamentBuffsForIds(assets, ornament_ids, alloc.gpa);
    defer ornament_buffs.deinit(alloc.gpa);
    for (ornament_buffs.items) |entry| {
        try role_base_buffs.append(alloc.gpa, entry);
    }

    const active_echo_buffs = try echo_comp.activeEchoBuffEffects(alloc.gpa, assets, role);
    defer alloc.gpa.free(active_echo_buffs);
    for (active_echo_buffs) |buff_id| {
        try role_base_buffs.append(alloc.gpa, .{
            .id = buff_id,
            .is_active = true,
        });
    }

    const ornament_born_buff_ids = try CosmeticsHelper.buildOrnamentBornBuffIdsForIds(assets, ornament_ids, alloc.gpa);

    const formation = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
    const is_cur_role = formation.cur_role == role;
    const be_hit_state_machine = Assets.DataTables.RoleBeHitMap.stateMachineName(
        assets.tables.role_be_hit_map.getDataById(role),
    );

    const role_snapshot = try RoleStats.buildSnapshot(alloc.gpa, assets, role_comp, weapon_comp, echo_comp, role);
    defer role_snapshot.deinit(alloc.gpa);

    const entity = try scene.spawn(alloc.gpa, fs, .{
        Entity.PlayerBattleBinder{
            .player_entity_id = 1,
            .battle_scene_entity_id = 2,
        },
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .player,
            .config_type = .character,
            .config_id = role,
        },
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = .{
                scene.instance.players[0].location[0],
                scene.instance.players[0].location[1],
                scene.instance.players[0].location[2],
            },
            .rotation = .{
                scene.instance.players[0].rotation[0],
                scene.instance.players[0].rotation[1],
                scene.instance.players[0].rotation[2],
            },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.ActorVisibleMarker{},
        Entity.DirectControlMarker{},
        try Entity.AttributeComponent.createWithIncrements(
            role_snapshot.base_props,
            role_snapshot.add_props,
            alloc.gpa,
        ),
        Entity.ConcomitantComponent{},
        Entity.PassiveGaSkillComponent{},
        try Entity.FsmComponent.fromStateMachineId(be_hit_state_machine, assets),
        Entity.VisionSkillComponent{
            .vision_skills = &.{},
        },
        Entity.EquipComponent{
            .weapon_id = weapon.id,
            .weapon_breach_level = weapon.breach,
        },
        Entity.LogicStateComponent{
            .direction_state = 0,
            .move_state = 0,
            .position_state = 0,
            .position_sub_state = 0,
        },
        Entity.BaseSkinComponent{
            .role_skin_id = role_info.role_skin_id,
            .paragliding_skin_id = role_info.paragliding_skin_id,
            .soar_skin_id = role_info.soar_skin_id,
        },
        Entity.WeaponSkinComponent{
            .skin_id = role_info.weapon_skin_id,
        },
        Entity.OrnamentComponent{
            .ornament_ids = ornament_ids,
        },
        Entity.CalabashSkinComponent{
            .skin_id = role_info.calabash_skin_id,
        },
    });

    var role_vision_entity_id: i64 = 0;
    var combo_vision_entity_id: i64 = 0;
    var role_vision_summon_id: i32 = 0;
    var combo_vision_summon_id: i32 = 0;
    if (echo_comp.mainEchoSummonId(assets, role)) |summon_id| {
        role_vision_summon_id = summon_id;
        if (try createVisionEntity(
            fs,
            scene,
            alloc,
            player_id,
            assets,
            role_info,
            instance_dungeon,
            summon_id,
            entity.net_id,
        )) |vision_entity| {
            role_vision_entity_id = vision_entity.net_id;
        }
    }
    if (echo_comp.comboEchoSummonId(assets, role)) |summon_id| {
        combo_vision_summon_id = summon_id;
        if (try createVisionEntity(
            fs,
            scene,
            alloc,
            player_id,
            assets,
            role_info,
            instance_dungeon,
            summon_id,
            entity.net_id,
        )) |vision_entity| {
            combo_vision_entity_id = vision_entity.net_id;
        }
    }

    var blueprint_configs: std.ArrayList(*const Assets.DataTables.BlueprintConfig) = .empty;
    defer blueprint_configs.deinit(alloc.gpa);

    for (assets.tables.blueprint_config.items) |*cfg| {
        if (cfg.EntityType != .Monster) continue;
        if (std.mem.indexOf(u8, cfg.BlueprintType, "Player") == null) continue;
        if (std.mem.indexOf(u8, cfg.BlueprintType, "_") == null) continue;

        const role_skin = blk: {
            for (assets.tables.role_skin.items) |*r| {
                if (r.RoleId == role) break :blk r;
            }
            continue;
        };

        const model = assets.tables.model_config_preload.getDataById(cfg.ModelId) orelse continue;
        const model_name = blk: {
            var it = std.mem.splitScalar(u8, role_skin.UiScenePerformanceABP, '/');
            var i: usize = 0;
            while (it.next()) |seg| : (i += 1) {
                if (i == 6) break :blk seg;
            }
            continue;
        };

        const actor_lower = try std.ascii.allocLowerString(alloc.gpa, model.ActorClassPath);
        defer alloc.gpa.free(actor_lower);
        const name_lower = try std.ascii.allocLowerString(alloc.gpa, model_name);
        defer alloc.gpa.free(name_lower);

        if (std.mem.indexOf(u8, actor_lower, name_lower) == null) continue;

        try blueprint_configs.append(alloc.gpa, cfg);
    }

    var concomitants: std.ArrayList(Entity) = .empty;
    defer concomitants.deinit(alloc.gpa);
    var concomitant_buff_ids: std.AutoArrayHashMapUnmanaged(i64, void) = .empty;
    defer concomitant_buff_ids.deinit(alloc.gpa);
    outer: for (blueprint_configs.items) |bp_config| {
        const summon_cfg = blk: {
            for (assets.tables.summon_cfg.items) |summon_cfg| {
                if (std.mem.eql(u8, summon_cfg.BlueprintType, bp_config.BlueprintType)) {
                    break :blk summon_cfg;
                }
            }
            continue :outer;
        };
        const template_config = blk: {
            for (assets.tables.template_config.items) |template_config| {
                if (std.mem.eql(u8, template_config.BlueprintType, bp_config.BlueprintType)) {
                    break :blk template_config;
                }
            }
            continue :outer;
        };

        for (summon_cfg.BornBuffId) |buff_id| {
            try concomitant_buff_ids.put(alloc.gpa, buff_id, {});
        }
        for (0..Assets.DataTables.SummonCfg.getConcomCount(role) orelse 1) |_| {
            try concomitants.append(alloc.gpa, try createConcomitantEntity(
                fs,
                scene,
                alloc,
                player_id,
                role_comp,
                instance_dungeon,
                summon_cfg,
                template_config,
                role,
                entity.net_id,
            ));
        }
    }

    const fight_buff_infos = try scene.buildFightBuffInfos(role_base_buffs, entity.net_id, alloc.gpa);

    std.mem.sort(pb.FightBuffInformation, fight_buff_infos, {}, struct {
        fn lessThan(_: void, a: pb.FightBuffInformation, b: pb.FightBuffInformation) bool {
            return a.BuffId < b.BuffId;
        }
    }.lessThan);

    var filtered: std.ArrayList(pb.FightBuffInformation) = .empty;
    defer filtered.deinit(alloc.gpa);
    for (fight_buff_infos) |buff| {
        if (!concomitant_buff_ids.contains(buff.BuffId)) {
            try filtered.append(alloc.gpa, buff);
        }
    }
    alloc.gpa.free(fight_buff_infos);
    const fight_buff_infos_filtered = try filtered.toOwnedSlice(alloc.gpa);

    const vision_skills = try echo_comp.buildVisionSkills(
        alloc.gpa,
        assets,
        role,
        role_vision_entity_id,
        combo_vision_entity_id,
        scene.explore_tools_info.active_explore_skill,
    );
    errdefer alloc.gpa.free(vision_skills);

    var passive_skills: std.ArrayList(pb.SkillComponentPb) = .empty;
    defer passive_skills.deinit(alloc.gpa);

    var role_str_buf: [4]u8 = undefined;
    const role_str = std.fmt.bufPrint(&role_str_buf, "{d}", .{role}) catch unreachable;

    for (assets.tables.entity_skill_preload.items) |entry| {
        var skill_str_buf: [10]u8 = undefined;
        const skill_str = std.fmt.bufPrint(&skill_str_buf, "{d}", .{entry.SkillId}) catch continue;
        if (!std.mem.startsWith(u8, skill_str, role_str)) continue;
        try appendPassiveSkill(alloc.gpa, &passive_skills, entry.SkillId);
    }

    for (fight_buff_infos_filtered) |buff_info| {
        const buff = assets.tables.buff.getDataById(@intCast(buff_info.BuffId)) orelse continue;
        if (buff.ExtraEffectID != 35) continue;
        const skill_id_list = if (buff.ExtraEffectParameters.len > 0)
            buff.ExtraEffectParameters[0]
        else
            continue;

        var it = std.mem.splitScalar(u8, skill_id_list, '|');
        while (it.next()) |s| {
            const trimmed = std.mem.trim(u8, s, " ");
            const id = std.fmt.parseInt(i32, trimmed, 10) catch continue;
            try appendPassiveSkill(alloc.gpa, &passive_skills, id);
        }
    }

    try appendPassiveSkill(alloc.gpa, &passive_skills, 100005);
    try appendVisionPassiveSkills(assets, alloc.gpa, &passive_skills, &.{ role_vision_summon_id, combo_vision_summon_id }, vision_skills);

    const slice = scene.entities.slice();

    if (role_vision_entity_id != 0 and combo_vision_entity_id != 0) {
        slice.items(.concomitant)[entity.index].?.vision_entity_id = try alloc.gpa.dupe(i64, &.{ role_vision_entity_id, combo_vision_entity_id });
    } else if (role_vision_entity_id != 0) {
        slice.items(.concomitant)[entity.index].?.vision_entity_id = try alloc.gpa.dupe(i64, &.{role_vision_entity_id});
    }
    slice.items(.vision_skills)[entity.index].?.vision_skills = vision_skills;

    slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos_filtered;
    slice.items(.buffs)[entity.index].?.born_buff_ids = ornament_born_buff_ids;
    slice.items(.buffs)[entity.index].?.born_message_id = entity.net_id;
    slice.items(.passive_ga_skill)[entity.index].?.skill_component_pb = try passive_skills.toOwnedSlice(alloc.gpa);
    slice.items(.concomitant)[entity.index].?.custom_entity_ids = blk: {
        var ids = try std.ArrayListUnmanaged(i64).initCapacity(alloc.gpa, concomitants.items.len);
        for (concomitants.items) |e| ids.appendAssumeCapacity(e.net_id);
        break :blk try ids.toOwnedSlice(alloc.gpa);
    };
    if (is_cur_role) {
        slice.items(.visible)[entity.index] = .{};
    }
    const storage = scene.entities.get(entity.index);
    try storage.save(alloc.arena, fs, player_id, scene.instance_id);

    return entity;
}
