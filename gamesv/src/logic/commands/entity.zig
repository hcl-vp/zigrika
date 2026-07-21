const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const Assets = @import("../../data/Assets.zig");
const Entity = @import("../../logic/Scene.zig").Entity;
const FileSystem = @import("common").FileSystem;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const ConfigComponent = @import("../../logic/component/entity/ConfigComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const PlayerBasicComponent = @import("../../logic/component/player/PlayerBasicComponent.zig");
const RoleHelper = @import("../../logic/helpers/role.zig");
const RoleEntityTemplates = @import("../../logic/templates/RoleEntityTemplates.zig");
const entity_attributes = @import("../../logic/helpers/entity_attributes.zig");
const gameplay_tags = @import("../../logic/helpers/gameplay_tags.zig");
const respond = @import("../commands.zig").respond;

const EntitySpawnBase = struct {
    config_type: ConfigComponent.ConfigType,
    entity_type: ConfigComponent.EntityType,
    entity_state: ConfigComponent.EntityState,
};

const FROZEN_BUFFS: *const [1]i64 = &.{10010001};
const TUNE_BROKEN_BUFFS: *const [5]i64 = &.{ 3161, 3162, 3163, 3164, 9000000000 };
const buffListFromIds = @import("../../data/tables/Buff.zig").buffListFromIds;

const LevelEntityConfig = Assets.DataTables.LevelEntityConfig;
const BlueprintConfig = Assets.DataTables.BlueprintConfig;
const TemplateConfig = Assets.DataTables.TemplateConfig;
const Components = @import("../../data/tables/entity_components/Components.zig");
const EntityLogic = @FieldType(BlueprintConfig, "EntityLogic");
const repeat_boss_tag_id = 1639442014;
const story_boss_tag_id = -1276461747;

const SpawnConfig = struct {
    entity_config: LevelEntityConfig,
    blueprint_config: BlueprintConfig,
    template_config: TemplateConfig,
    score: i32,
};

fn spawnBaseFromLogic(entity_logic: EntityLogic) ?EntitySpawnBase {
    return switch (entity_logic) {
        .Item => .{ .config_type = .level, .entity_type = .scene_item, .entity_state = .default },
        .Animal => .{ .config_type = .level, .entity_type = .animal, .entity_state = .default },
        .Monster => .{ .config_type = .level, .entity_type = .monster, .entity_state = .born },
        .Vehicle => .{ .config_type = .level, .entity_type = .vehicle, .entity_state = .default },
        .Npc => .{ .config_type = .level, .entity_type = .npc, .entity_state = .default },
        .Vision => .{ .config_type = .level, .entity_type = .vision, .entity_state = .default },
        .ClientOnly => .{ .config_type = .level, .entity_type = .client_only, .entity_state = .default },
        .Custom => .{ .config_type = .level, .entity_type = .custom, .entity_state = .default },
        .ServerOnly, .SimpleCombat => null,
    };
}

fn useAiRuntime(entity_type: ConfigComponent.EntityType) bool {
    return switch (entity_type) {
        .animal, .monster, .npc, .vision => true,
        else => false,
    };
}

fn findBlueprintConfig(assets: *const Assets, blueprint_type: []const u8) ?BlueprintConfig {
    for (assets.tables.blueprint_config.items) |bp_cfg| {
        if (std.mem.eql(u8, bp_cfg.BlueprintType, blueprint_type)) return bp_cfg;
    }

    return null;
}

fn findTemplateConfig(assets: *const Assets, blueprint_type: []const u8) ?TemplateConfig {
    for (assets.tables.template_config.items) |tp_cfg| {
        if (std.mem.eql(u8, tp_cfg.BlueprintType, blueprint_type)) return tp_cfg;
    }

    return null;
}

fn hasUsableFsm(assets: *const Assets, components: *const Components) bool {
    if (components.AiComponent) |ai_comp| return Entity.FsmComponent.hasUsableAiBaseId(ai_comp.AiId, assets);
    return false;
}

fn useRepeatBossStartup(ai_id: ?i32, assets: *const Assets) bool {
    const id = ai_id orelse return false;
    const ai_base = assets.tables.ai_base.getDataById(id) orelse return false;
    const config = assets.tables.ai_state_machine_config.getDataById(ai_base.StateMachine) orelse return false;

    for (config.StateMachineJson.Nodes) |node| {
        for (node.Transitions) |repeat_transition| {
            if (!transitionHasTag(repeat_transition, repeat_boss_tag_id)) continue;

            for (node.Transitions) |story_transition| {
                if (story_transition.From == repeat_transition.From and
                    transitionHasTag(story_transition, story_boss_tag_id)) return true;
            }
        }
    }

    return false;
}

fn initialTagComponent(
    components: *const Components,
    tag_remaps: *const Assets.DataTables.GameplayTagRemapTable,
    repeat_boss_startup: bool,
    gpa: std.mem.Allocator,
) !Entity.TagComponent {
    var result: Entity.TagComponent = .{};
    errdefer result.deinit(gpa);

    const monster = components.MonsterComponent orelse return result;
    const startup_tags = monster.InitGasTag orelse return result;
    for (startup_tags) |tag_name| {
        var tag_id = try gameplay_tags.idFromName(tag_remaps, tag_name);
        if (tag_id == 0) continue;
        if (repeat_boss_startup and tag_id == story_boss_tag_id) tag_id = repeat_boss_tag_id;
        _ = try result.adjustGameplayTagCount(gpa, tag_id, 1);
    }

    return result;
}

fn transitionHasTag(transition: Assets.DataTables.AiStateMachineConfig.StateMachineTransition, tag_id: i32) bool {
    for (transition.Conditions) |condition| {
        if (condition.CondTag) |tag| {
            if (tag.TagId == tag_id) return true;
        }
    }

    return false;
}

fn hasCombatAttributes(components: *const Components) bool {
    if (components.AttributeComponent) |attr_comp| return !(attr_comp.Disabled orelse false);
    return false;
}

fn spawnCandidateScore(assets: *const Assets, scene_map_id: i32, entity_config: *const LevelEntityConfig, blueprint_config: *const BlueprintConfig) i32 {
    var score: i32 = 0;
    const spawn_base = spawnBaseFromLogic(blueprint_config.EntityLogic);

    if (entity_config.MapId == scene_map_id) score += 10000;

    if (spawn_base) |base| {
        if (useAiRuntime(base.entity_type)) score += 1000;
        if (base.entity_type == .monster) score += 3000;
    }

    if (hasUsableFsm(assets, &entity_config.ComponentsData)) score += 2500;
    if (hasCombatAttributes(&entity_config.ComponentsData)) score += 1500;
    if (!entity_config.IsHidden) score += 100;
    if (!entity_config.InSleep) score += 50;

    return score;
}

fn selectSpawnConfig(assets: *const Assets, entity_id: i64, scene_map_id: i32, source_map_id: ?i32) ?SpawnConfig {
    var best: ?SpawnConfig = null;

    for (assets.tables.level_entity_config.items) |cfg| {
        if (cfg.EntityId != entity_id) continue;
        if (source_map_id) |map_id| {
            if (cfg.MapId != map_id) continue;
        }

        const blueprint_config = findBlueprintConfig(assets, cfg.BlueprintType) orelse continue;
        var template_config = findTemplateConfig(assets, cfg.BlueprintType) orelse continue;
        var entity_config = cfg;
        template_config.ComponentsData.mergeInto(&entity_config.ComponentsData);

        const score = spawnCandidateScore(assets, source_map_id orelse scene_map_id, &entity_config, &blueprint_config);
        if (best == null or score > best.?.score) {
            best = .{
                .entity_config = entity_config,
                .blueprint_config = blueprint_config,
                .template_config = template_config,
                .score = score,
            };
        }
    }

    return best;
}

fn templateCamp(template_config: *const TemplateConfig) ?i32 {
    if (template_config.ComponentsData.BaseInfoComponent) |base_info| return base_info.Camp;
    return null;
}

fn spawnCamp(base_info: anytype, template_config: *const TemplateConfig, spawn_base: EntitySpawnBase) i32 {
    const base_camp = base_info.Camp;
    const tpl_camp = templateCamp(template_config);

    if (spawn_base.entity_type == .monster) {
        if (tpl_camp) |camp| {
            if (base_camp == null or base_camp.? == 0 or base_camp.? == 2) return camp;
        }
    }

    return base_camp orelse tpl_camp orelse 0;
}

fn appendConfiguredBuffIds(buff_ids: *std.ArrayList(i64), components: *const Components, gpa: std.mem.Allocator) !void {
    const attr = components.AttributeComponent orelse return;
    const configured_ids = attr.AppendBuffIds orelse return;
    try buff_ids.appendSlice(gpa, configured_ids);
}

fn publishDebugSpawn(
    scene: *Scene,
    fs: *FileSystem,
    assets: *const Assets,
    conn: *Connection,
    alloc: mem.Alloc,
    entity: Scene.Entity,
    config_id: i64,
    source_map_id: i32,
    repeat_boss: bool,
    components: *const Components,
    is_frozen: bool,
    is_tune_broken: bool,
    route_patch_sent: *bool,
) !void {
    try scene.registerDebugSpawnRoute(
        alloc.gpa,
        entity.net_id,
        config_id,
        source_map_id,
        repeat_boss,
    );

    var buff_ids: std.ArrayList(i64) = .empty;
    defer buff_ids.deinit(alloc.gpa);
    try appendConfiguredBuffIds(&buff_ids, components, alloc.gpa);
    if (is_tune_broken) try buff_ids.appendSlice(alloc.gpa, TUNE_BROKEN_BUFFS);
    if (is_frozen) try buff_ids.appendSlice(alloc.gpa, FROZEN_BUFFS);
    if (buff_ids.items.len > 0) {
        var born_buffs = try buffListFromIds(alloc.gpa, buff_ids.items);
        defer born_buffs.deinit(alloc.gpa);
        const fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);
        const slice = scene.entities.slice();
        slice.items(.buffs)[entity.index].?.fight_buff_infos = fight_buff_infos;
        try scene.saveEntity(fs, alloc.gpa, entity);
    }

    var entity_pbs: std.ArrayList(pb.EntityPb) = try .initCapacity(alloc.gpa, 1);
    defer entity_pbs.deinit(alloc.gpa);
    const storage = scene.entities.get(entity.index);
    entity_pbs.appendAssumeCapacity(try storage.entityToProto(entity.net_id, alloc, assets));

    try conn.push(pb.JSPatchNotify{
        .Content = try std.fmt.allocPrint(
            alloc.arena,
            "globalThis.__zigrikaSetEntitySourceMap?.({d},{d},{s},{d});",
            .{ config_id, source_map_id, if (repeat_boss) "true" else "false", entity.net_id },
        ),
    }, alloc.arena);
    route_patch_sent.* = true;

    try conn.push(pb.EntityAddNotify{ .EntityPbs = entity_pbs }, alloc.arena);
}

fn removeClientDebugSpawnOwner(
    conn: *Connection,
    alloc: mem.Alloc,
    config_id: i64,
    net_id: i64,
) void {
    const content = std.fmt.allocPrint(
        alloc.arena,
        "globalThis.__zigrikaRemoveEntitySourceOwner?.({d},{d});",
        .{ config_id, net_id },
    ) catch return;
    conn.push(pb.JSPatchNotify{ .Content = content }, alloc.arena) catch {};
}

pub const spawn = struct {
    pub const alias = "s";
    pub const description = "spawns an entity.\nusage: spawn [entity_id] [freeze?] [tune_break?]";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        assets: *const Assets,
        conn: *Connection,
        basic_comp: *const PlayerBasicComponent,
        alloc: mem.Alloc,
        entity_id: i64,
        is_frozen: ?bool,
        is_tune_broken: ?bool,
    ) !void {
        try callWithSourceMap(events, scene, fs, assets, conn, basic_comp, alloc, entity_id, is_frozen, is_tune_broken, null);
    }

    fn callWithSourceMap(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        assets: *const Assets,
        conn: *Connection,
        basic_comp: *const PlayerBasicComponent,
        alloc: mem.Alloc,
        entity_id: i64,
        is_frozen: ?bool,
        is_tune_broken: ?bool,
        source_map_id: ?i32,
    ) !void {
        const selected = selectSpawnConfig(assets, entity_id, scene.instance_id, source_map_id) orelse {
            if (source_map_id) |map_id| {
                try respond(events, alloc.arena, "{d} couldn't be spawned, no LevelEntityConfig row for map {d}", .{ entity_id, map_id });
            } else {
                try respond(events, alloc.arena, "{d} couldn't be spawned, couldn't find it in LevelEntityConfig", .{entity_id});
            }
            return;
        };
        const entity_config = selected.entity_config;
        const blueprint_config = selected.blueprint_config;
        const template_config = selected.template_config;

        const spawn_base = spawnBaseFromLogic(blueprint_config.EntityLogic) orelse {
            try respond(events, alloc.arena, "{d} couldn't be spawned, unhandled entity logic: {s}", .{ entity_id, @tagName(blueprint_config.EntityLogic) });
            return;
        };
        const components_data = entity_config.ComponentsData;

        const base_info = components_data.BaseInfoComponent orelse {
            try respond(events, alloc.arena, "{d} couldn't be spawned, it had no baseinfo comp and we dont support that :)", .{entity_id});
            return;
        };

        const ai_comp = components_data.AiComponent;
        const ai_id = if (ai_comp) |comp| comp.AiId else null;
        const repeat_boss_startup = useRepeatBossStartup(ai_id, assets);
        if (scene.debugSpawnRoute(entity_id)) |route| {
            if (!route.matches(entity_config.MapId, repeat_boss_startup)) {
                try respond(
                    events,
                    alloc.arena,
                    "{d} couldn't be spawned, active instances use map {d} with repeat_boss={s}",
                    .{ entity_id, route.source_map_id, if (route.repeat_boss) "true" else "false" },
                );
                return;
            }
        }
        const weapon_id = if (ai_comp) |comp| parseOptionalInt(comp.WeaponId) else 0;
        const final_camp = spawnCamp(base_info, &template_config, spawn_base);
        const use_ai_runtime = useAiRuntime(spawn_base.entity_type);
        const fsm_component = if (use_ai_runtime)
            Entity.FsmComponent.fromAiBaseId(ai_id, assets)
        else
            null;
        const combat_attributes: ?Entity.AttributeComponent = if (use_ai_runtime)
            (try entity_attributes.createCombatAttributes(
                assets,
                &components_data,
                blueprint_config.EntityLogic,
                entity_config.AreaId,
                basic_comp.info.attributes.cur_world_level,
                alloc,
            ))
        else
            null;
        const attribute_component: ?Entity.AttributeComponent = if (use_ai_runtime)
            combat_attributes orelse Entity.AttributeComponent{}
        else
            null;
        var tag_component: ?Entity.TagComponent = if (use_ai_runtime)
            try initialTagComponent(
                &components_data,
                &assets.tables.gameplay_tag_remap,
                repeat_boss_startup,
                alloc.gpa,
            )
        else
            null;
        errdefer if (tag_component) |*tags| tags.deinit(alloc.gpa);
        const model_id = if (components_data.ModelComponent) |model| model.ModelType.ModelId else 0;
        const life_max_index = @intFromEnum(pb.EAttributeType.LifeMax);
        const life_max = if (attribute_component) |attribute|
            if (life_max_index < attribute.attributes.len) attribute.attributes[life_max_index].current else 0
        else
            0;
        var part_component: ?Entity.PartComponent = if (use_ai_runtime)
            if (assets.tables.character_part_config.getDataById(model_id)) |config|
                try Entity.PartComponent.init(config, life_max, alloc.gpa)
            else
                null
        else
            null;
        errdefer if (part_component) |*part| part.deinit(alloc.gpa);
        if (part_component) |*part| {
            const tags = if (tag_component) |*component| component else null;
            try part.syncActiveTags(tags, alloc.gpa);
        }
        const entity = if (fsm_component) |fsm| try scene.spawn(alloc.gpa, fs, .{
            Entity.ConfigComponent{
                .camp = final_camp,
                .config_id = @intCast(entity_id),
                .config_type = spawn_base.config_type,
                .entity_type = spawn_base.entity_type,
                .state = spawn_base.entity_state,
            },
            Entity.ActorVisibleMarker{},
            Entity.VisibleMarker{},
            Entity.PositionComponent{
                .location = scene.instance.players[0].location,
                .rotation = scene.instance.players[0].rotation,
            },
            Entity.FightBuffComponent{},
            attribute_component.?,
            Entity.LogicStateComponent{},
            Entity.MonsterAiComponent{
                .weapon_id = weapon_id,
                .hatred_group_id = 0,
                .ai_team_init_id = 100,
                .combat_message_id = 0,
            },
            Entity.CharacterAttachComponent{},
            tag_component.?,
            part_component,
            fsm,
        }) else if (use_ai_runtime) try scene.spawn(alloc.gpa, fs, .{
            Entity.ConfigComponent{
                .camp = final_camp,
                .config_id = @intCast(entity_id),
                .config_type = spawn_base.config_type,
                .entity_type = spawn_base.entity_type,
                .state = spawn_base.entity_state,
            },
            Entity.ActorVisibleMarker{},
            Entity.VisibleMarker{},
            Entity.PositionComponent{
                .location = scene.instance.players[0].location,
                .rotation = scene.instance.players[0].rotation,
            },
            Entity.FightBuffComponent{},
            attribute_component.?,
            Entity.LogicStateComponent{},
            Entity.MonsterAiComponent{
                .weapon_id = weapon_id,
                .hatred_group_id = 0,
                .ai_team_init_id = 100,
                .combat_message_id = 0,
            },
            Entity.CharacterAttachComponent{},
            tag_component.?,
            part_component,
        }) else try scene.spawn(alloc.gpa, fs, .{
            Entity.ConfigComponent{
                .camp = final_camp,
                .config_id = @intCast(entity_id),
                .config_type = spawn_base.config_type,
                .entity_type = spawn_base.entity_type,
                .state = spawn_base.entity_state,
            },
            Entity.ActorVisibleMarker{},
            Entity.VisibleMarker{},
            Entity.PositionComponent{
                .location = scene.instance.players[0].location,
                .rotation = scene.instance.players[0].rotation,
            },
            Entity.FightBuffComponent{},
        });
        tag_component = null;
        part_component = null;
        var route_patch_sent = false;
        publishDebugSpawn(
            scene,
            fs,
            assets,
            conn,
            alloc,
            entity,
            entity_id,
            entity_config.MapId,
            repeat_boss_startup,
            &components_data,
            is_frozen orelse false,
            is_tune_broken orelse false,
            &route_patch_sent,
        ) catch |publish_err| {
            if (route_patch_sent) removeClientDebugSpawnOwner(conn, alloc, entity_id, entity.net_id);
            scene.rollbackSpawn(alloc.gpa, fs, entity.net_id) catch |rollback_err| return rollback_err;
            return publish_err;
        };

        try respond(events, alloc.arena, "spawned {d}, map: {d}, bp: {s}, camp: {d}, ai_id: {any}", .{ entity_id, entity_config.MapId, entity_config.BlueprintType, final_camp, ai_id });
    }
};

pub const spawn_map = struct {
    pub const alias = "sm";
    pub const description = "spawns an entity using an exact source map row.\nusage: spawn_map [entity_id] [source_map_id] [freeze?] [tune_break?]";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        assets: *const Assets,
        conn: *Connection,
        basic_comp: *const PlayerBasicComponent,
        alloc: mem.Alloc,
        entity_id: i64,
        source_map_id: i32,
        is_frozen: ?bool,
        is_tune_broken: ?bool,
    ) !void {
        try spawn.callWithSourceMap(events, scene, fs, assets, conn, basic_comp, alloc, entity_id, is_frozen, is_tune_broken, source_map_id);
    }
};

fn parseOptionalInt(value: ?std.json.Value) i32 {
    const raw = value orelse return 0;
    return switch (raw) {
        .integer => |v| @intCast(v),
        .float => |v| @intFromFloat(v),
        .number_string => |v| std.fmt.parseInt(i32, v, 10) catch 0,
        .string => |v| std.fmt.parseInt(i32, v, 10) catch 0,
        else => 0,
    };
}

pub const reset_formation = struct {
    pub const alias = "rf";
    pub const description = "resets the current formation by respawning all role entities.\nusage: reset_formation";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        assets: *const Assets,
        role_comp: *PlayerRoleComponent,
        weapon_comp: *PlayerWeaponComponent,
        echo_comp: *PlayerEchoComponent,
        conn: *Connection,
        alloc: mem.Alloc,
    ) !void {
        try RoleHelper.resetRoles(
            scene,
            fs,
            assets,
            role_comp,
            weapon_comp,
            echo_comp,
            conn,
            alloc,
            null,
        );
        try respond(events, alloc.arena, "reset formation successfully", .{});
    }
};
