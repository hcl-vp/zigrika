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

pub fn buildFightBuffInfos(
    role_buffs: std.ArrayListUnmanaged(Assets.DataTables.RoleBuffEntry),
    net_id: i64,
    scene: *Scene,
    gpa: Allocator,
) ![]pb.FightBuffInformation {
    var infos: std.ArrayList(pb.FightBuffInformation) = .empty;
    errdefer infos.deinit(gpa);
    for (role_buffs.items) |entry| {
        scene.*.instance.buff_handle += 1;
        try infos.append(gpa, .{
            .HandleId = scene.instance.buff_handle,
            .BuffId = entry.id,
            .Level = 1,
            .StackCount = 1,
            .InstigatorId = net_id,
            .EntityId = net_id,
            .Duration = -1.0,
            .LeftDuration = -1.0,
            .IsActive = entry.is_active,
            .ApplyType = .Common,
            .MessageId = -1,
            .ServerId = 0,
        });
    }
    return infos.toOwnedSlice(gpa);
}

pub fn buffListFromIds(allocator: std.mem.Allocator, ids: []const i64) !std.ArrayListUnmanaged(Assets.DataTables.RoleBuffEntry) {
    var list: std.ArrayListUnmanaged(Assets.DataTables.RoleBuffEntry) = .empty;
    try list.ensureTotalCapacity(allocator, ids.len);
    for (ids) |id| {
        list.appendAssumeCapacity(.{ .id = id, .is_active = true });
    }
    return list;
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

    const incr_path = try std.fmt.allocPrint(
        alloc.gpa,
        "player/{d}/scene/{d}/entity/next",
        .{ scene.player_id, scene.instance_id },
    );
    defer alloc.gpa.free(incr_path);

    const net_id = try incr.peek(i64, fs, incr_path);

    var born_buffs = try buffListFromIds(alloc.gpa, summon_cfg.BornBuffId);
    defer born_buffs.deinit(alloc.gpa);
    const fight_buff_infos = try buildFightBuffInfos(born_buffs, net_id, scene, alloc.gpa);

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
        Entity.FightBuffComponent{ .fight_buff_infos = fight_buff_infos },
        Entity.AttributeComponent{ .base_prop = try alloc.gpa.dupe(i32, role_info.base_prop) },
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
        Entity.CharacterAttachComponent{
            .pb_combine_part_info_list = &.{},
            .pb_combine_target_server_id = 0,
        },
    });

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

    var role_autobuffs = try assets.tables.getRoleAutoBuffs(role, alloc.gpa);
    defer role_autobuffs.deinit(alloc.gpa);

    const incr_path = try std.fmt.allocPrint(
        alloc.gpa,
        "player/{d}/scene/{d}/entity/next",
        .{ scene.player_id, scene.instance_id },
    );
    defer alloc.gpa.free(incr_path);

    const net_id = try incr.peek(i64, fs, incr_path);

    const fight_buff_infos = try buildFightBuffInfos(role_autobuffs, net_id, scene, alloc.gpa);

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
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.VisibleMarker{},
        Entity.ActorVisibleMarker{},
        Entity.DirectControlMarker{},
        Entity.AttributeComponent{ .base_prop = try alloc.gpa.dupe(i32, role_info.base_prop) },
        Entity.ConcomitantComponent{},
        Entity.PassiveGaSkillComponent{
            .skill_component_pb = try alloc.gpa.dupe(pb.SkillComponentPb, &.{
                .{ .SkillId = 100005, .ConstateId = -1 },
            }),
        },
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
            .weapon_id = blk: {
                for (weapon_comp.weapon_map.values()) |weapon| {
                    if (weapon.role_id == role) break :blk weapon.id;
                }
                break :blk 0;
            },
            .weapon_breach_level = 0,
        },
        Entity.LogicStateComponent{
            .direction_state = 0,
            .move_state = 0,
            .position_state = 0,
            .position_sub_state = 0,
        },
        Entity.RoleSkinComponent{
            .role_skin = 8100 * 10_000 + role,
        },
    });

    var blueprint_configs: std.ArrayList(*const Assets.DataTables.BlueprintConfig) = .empty;
    defer blueprint_configs.deinit(alloc.gpa);

    for (assets.tables.blueprint_config.items) |*cfg| {
        if (!std.mem.eql(u8, cfg.EntityType, "Monster")) continue;
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
                net_id,
            ));
        }
    }

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

    const slice = scene.entities.slice();

    slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos_filtered;
    slice.items(.concomitant)[entity.index].?.custom_entity_ids = blk: {
        var ids = try std.ArrayListUnmanaged(i64).initCapacity(alloc.gpa, concomitants.items.len);
        for (concomitants.items) |e| ids.appendAssumeCapacity(e.net_id);
        break :blk try ids.toOwnedSlice(alloc.gpa);
    };

    const storage = scene.entities.get(entity.index);
    try storage.save(alloc.arena, fs, player_id, scene.instance_id);
    log.debug("buffs: {any}", .{storage.buffs});

    slice.items(.attribute)[entity.index].?.base_prop[60] =
        slice.items(.attribute)[entity.index].?.base_prop[59];

    return entity;
}
