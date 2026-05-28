const Scene = @import("../Scene.zig");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const std = @import("std");
const Allocator = std.mem.Allocator;
const pb = @import("proto").pb;
const incr = @import("../../fs/incr.zig");
const BuffAdditionEntry = @import("../../logic/events.zig").BuffAdditionEntry;
const CosmeticsHelper = @import("../helpers/cosmetics.zig");

const buffListFromIds = @import("../../data/tables/Buff.zig").buffListFromIds;

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

pub fn createRoleEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    instance_dungeon: Assets.DataTables.InstanceDungeon,
    role: i32,
) !Entity {
    const log = std.log.scoped(.role_entity_creator);
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

    // ornaments!!!!
    var ornament_buffs = try CosmeticsHelper.buildOrnamentBuffsForRoleSkin(
        assets,
        role_info.getOrnament(role_info.role_skin_id),
        alloc.gpa,
    );
    defer ornament_buffs.deinit(alloc.gpa);
    for (ornament_buffs.items) |entry| {
        try role_base_buffs.append(alloc.gpa, entry);
    }

    const ornament_born_buff_ids = try CosmeticsHelper.buildOrnamentBornBuffIds(
        assets,
        role_info.getOrnament(role_info.role_skin_id),
        alloc.gpa,
    );

    const ornament_ids = try CosmeticsHelper.buildOrnamentIdsForRoleSkin(
        assets,
        role_info.*,
        role_info.role_skin_id,
        alloc.gpa,
    );

    const formation = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
    const is_cur_role = formation.cur_role == role;

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
        try Entity.AttributeComponent.create(
            try alloc.arena.dupe(i32, role_info.base_prop),
            alloc.gpa,
        ),
        Entity.ConcomitantComponent{},
        Entity.PassiveGaSkillComponent{},
        Entity.FsmComponent{
            .hash_code = 340617276,
            .common_hash_code = 2075276641,
            .fsms = try alloc.gpa.dupe(pb.DFsm, &.{
                .{
                    .FsmId = 10263,
                    .CurrentState = 10265,
                    .Flag = 1,
                    .StateElapseTime = 0,
                },
            }),
        },
        Entity.VisionSkillComponent{
            .vision_skills = try alloc.gpa.dupe(
                pb.VisionSkillInformation,
                &.{
                    .{
                        .SkillId = scene.explore_tools_info.active_explore_skill,
                        .Index = 2,
                    },
                },
            ),
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

        log.debug("Blueprint adding for role: {d}, which is: {s}", .{ role, cfg.BlueprintType });
        try blueprint_configs.append(alloc.gpa, cfg);
    }

    var concomitants: std.ArrayList(Entity) = .empty;
    defer concomitants.deinit(alloc.gpa);
    var concomitant_buff_ids: std.array_hash_map.Auto(i64, void) = .empty;
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

    var passive_skills: std.ArrayList(pb.SkillComponentPb) = .empty;
    defer passive_skills.deinit(alloc.gpa);

    var role_str_buf: [4]u8 = undefined;
    const role_str = std.fmt.bufPrint(&role_str_buf, "{d}", .{role}) catch unreachable;

    for (assets.tables.entity_skill_preload.items) |entry| {
        var skill_str_buf: [10]u8 = undefined;
        const skill_str = std.fmt.bufPrint(&skill_str_buf, "{d}", .{entry.SkillId}) catch continue;
        if (!std.mem.startsWith(u8, skill_str, role_str)) continue;
        try passive_skills.append(alloc.gpa, .{ .SkillId = entry.SkillId, .ConstateId = -1 });
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
            try passive_skills.append(alloc.gpa, .{ .SkillId = id, .ConstateId = -1 });
        }
    }

    try passive_skills.append(alloc.gpa, .{ .SkillId = 100005, .ConstateId = -1 });

    const slice = scene.entities.slice();

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
    log.debug("buffs: {any}", .{storage.buffs});

    return entity;
}
