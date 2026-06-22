const Scene = @import("../Scene.zig");
const std = @import("std");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerMotorComponent = @import("../component/player/PlayerMotorComponent.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const pb = @import("proto").pb;
const incr = @import("../../fs/incr.zig");
const BuffAdditionEntry = @import("../events.zig").BuffAdditionEntry;
const EventQueue = @import("../EventQueue.zig");
const buffListFromIds = @import("../../data/tables/Buff.zig").buffListFromIds;

const motorcycle_companion_summon_cfg_id = 24000030;
const motorcycle_companion_template_id = 36700001;
const motorcycle_companion_property_id = 90000004;

// Work in progress bike skills: keep Charged Leap and Vectored Thrust enabled until full motor tech activation is data-driven.
const forced_motorcycle_born_buff_ids = [_]i64{
    3000000801,
    3000020024,
};

const forced_motorcycle_gameplay_tag_ids = [_]i32{
    -849916103,
};

pub const MotorcycleCompanionResult = struct {
    entity: Entity,
    created: bool,
};

pub fn createPlayerSceneEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    motorcycle_entity_id: i64,
) !Entity {
    const followers = try alloc.gpa.dupe(Entity.FollowerComponent.Entry, &[_]Entity.FollowerComponent.Entry{
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerDefault) },
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerExploreSkill) },
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerAuxiliary) },
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerSpecialItem) },
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerMotor), .EntityId = motorcycle_entity_id },
        .{ .Type = @intFromEnum(pb.FollowerType.EPlayerFollowerMax) },
    });
    const entity = try scene.spawn(alloc.gpa, fs, .{
        Entity.FollowerComponent{ .list = followers },
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(390077025, alloc.arena),
            alloc.gpa,
        ),
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .player_entity,
            .config_type = .template,
            .config_id = 14750001,
        },
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = [_]f32{
                -10000.0,
                -10000.0,
                -10000.0,
            },
            .rotation = [_]f32{ 0.0, 0.0, 0.0 },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.VisibleMarker{},
        Entity.ActorVisibleMarker{},
    });

    return entity;
}

pub fn createMotorcycleEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    motor_comp: *PlayerMotorComponent,
) !Entity {
    const props = try assets.tables.getProps(90000015, alloc.arena);
    const motorcycle_config_id = assets.tables.getMotorcycleConfigId() orelse return error.MotorcycleConfigNotFound;
    var born_buffs = try buildMotorcycleBornBuffs(alloc.gpa, assets);
    defer born_buffs.deinit(alloc.gpa);
    const gameplay_tags = try buildMotorcycleGameplayTags(alloc.gpa);
    errdefer alloc.gpa.free(gameplay_tags);

    const entity = try scene.spawn(alloc.gpa, fs, .{
        try Entity.AttributeComponent.create(
            props,
            alloc.gpa,
        ),
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .vehicle,
            .config_type = .template,
            .config_id = motorcycle_config_id,
        },
        Entity.VehicleComponent{},
        Entity.TagComponent{
            .gameplay_tags = gameplay_tags,
            .init_gameplay_tag = true,
        },
        Entity.MotorOutlookComponent{
            .skin = motor_comp.info.equipped_skin,
            .stickers = try alloc.gpa.dupe(i32, motor_comp.info.equipped_stickers),
            .decorations = try alloc.gpa.dupe(i32, motor_comp.info.equipped_decorations),
            .frame = motor_comp.info.equipped_frame,
        },
        Entity.MotorDaCtxComponent{},
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = [_]f32{
                -10000.0,
                -10000.0,
                -10000.0,
            },
            .rotation = [_]f32{ 0.0, 0.0, 0.0 },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.ActorVisibleMarker{},
    });

    const slice = scene.entities.slice();
    slice.items(.buffs)[entity.index].?.fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);

    return entity;
}

pub fn findPlayerSceneEntity(scene: *Scene, player_id: i32) ?Entity {
    const slice = scene.entities.slice();
    for (slice.items(.config), 0..) |config, i| {
        if (config.entity_type != .player_entity) continue;
        if (slice.items(.player_id)[i]) |pid| {
            if (pid.id == player_id) {
                return .{
                    .index = i,
                    .net_id = slice.items(.entity_id)[i].net_id,
                };
            }
        }
    }

    return null;
}

fn findMotorcycleCompanionEntity(scene: *Scene, motorcycle_entity: Entity) ?Entity {
    const slice = scene.entities.slice();
    const follow_entity = slice.items(.follow_entity)[motorcycle_entity.index] orelse return null;
    if (follow_entity.entity_id == 0) return null;

    const index = scene.net_id_map.get(follow_entity.entity_id) orelse return null;
    return .{
        .index = index,
        .net_id = follow_entity.entity_id,
    };
}

pub fn ensureMotorcycleCompanionEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    motorcycle_entity: Entity,
    player_scene_entity: Entity,
) !MotorcycleCompanionResult {
    if (findMotorcycleCompanionEntity(scene, motorcycle_entity)) |entity| {
        return .{ .entity = entity, .created = false };
    }

    const summon_cfg = assets.tables.summon_cfg.getDataById(motorcycle_companion_summon_cfg_id) orelse
        return error.MotorcycleCompanionSummonCfgNotFound;
    const template_config = assets.tables.template_config.getDataById(motorcycle_companion_template_id) orelse
        return error.MotorcycleCompanionTemplateNotFound;

    var born_buffs = try buffListFromIds(alloc.gpa, summon_cfg.BornBuffId);
    defer born_buffs.deinit(alloc.gpa);

    const location = if (scene.instance.players.len != 0)
        scene.instance.players[0].location
    else
        [_]f32{ -10000.0, -10000.0, -10000.0 };
    const rotation = if (scene.instance.players.len != 0)
        scene.instance.players[0].rotation
    else
        [_]f32{ 0.0, 0.0, 0.0 };

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
            .location = location,
            .rotation = rotation,
        },
        Entity.ActorVisibleMarker{},
        Entity.FightBuffComponent{},
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(motorcycle_companion_property_id, alloc.arena),
            alloc.gpa,
        ),
        Entity.SummonerComponent{
            .player_id = player_id,
            .summon_cfg_id = summon_cfg.Id,
            .summon_skill_id = 0,
            .summon_type = .ESummonTypeConcomitantMotorcycle,
            .summoner_id = motorcycle_entity.net_id,
        },
        Entity.FollowShooterComponent{
            .player_entity_id = player_scene_entity.net_id,
            .summon_config_id = summon_cfg.Id,
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
    slice.items(.buffs)[entity.index].?.fight_buff_infos = try scene.buildFightBuffInfos(born_buffs, entity.net_id, alloc.gpa);
    slice.items(.follow_entity)[motorcycle_entity.index] = .{ .entity_id = entity.net_id };
    try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.FightBuffComponent});
    try scene.saveComponents(fs, alloc.gpa, motorcycle_entity, &.{Scene.Entity.FollowEntityComponent});

    return .{ .entity = entity, .created = true };
}

fn asciiEqlIgnoreCase(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |a_ch, b_ch| {
        if (std.ascii.toLower(a_ch) != std.ascii.toLower(b_ch)) return false;
    }
    return true;
}

fn containsIgnoreCaseAscii(haystack: []const u8, needle: []const u8) bool {
    if (needle.len < 3 or needle.len > haystack.len) return false;

    var i: usize = 0;
    while (i + needle.len <= haystack.len) : (i += 1) {
        if (asciiEqlIgnoreCase(haystack[i .. i + needle.len], needle)) return true;
    }
    return false;
}

fn roleAssetToken(role: Assets.DataTables.RoleInfo) []const u8 {
    var previous: []const u8 = "";
    var parts = std.mem.splitScalar(u8, role.UiScenePerformanceABP, '/');
    while (parts.next()) |part| {
        if (std.mem.startsWith(u8, part, "R2T1")) return previous;
        previous = part;
    }
    return "";
}

fn passengerTemplateMatchesRole(assets: *const Assets, blueprint_type: []const u8, role_id: i32) bool {
    var role_buf: [32]u8 = undefined;
    const role_text = std.fmt.bufPrint(role_buf[0..], "{d}", .{role_id}) catch return false;

    if (std.mem.endsWith(u8, blueprint_type, role_text)) {
        const start = blueprint_type.len - role_text.len;
        if (start > 0 and blueprint_type[start - 1] == '_') return true;
    }

    var needle_buf: [34]u8 = undefined;
    const needle = std.fmt.bufPrint(needle_buf[0..], "_{s}_", .{role_text}) catch return false;
    if (std.mem.indexOf(u8, blueprint_type, needle) != null) return true;

    const role = assets.tables.role_info.getDataById(role_id) orelse return false;
    return containsIgnoreCaseAscii(blueprint_type, roleAssetToken(role));
}

fn isNpcPassengerBlueprint(assets: *const Assets, blueprint_type: []const u8) bool {
    for (assets.tables.blueprint_config.items) |blueprint| {
        if (!std.mem.eql(u8, blueprint.BlueprintType, blueprint_type)) continue;
        return blueprint.EntityLogic == .Npc and std.mem.indexOf(u8, blueprint.BlueprintType, "Passenger") != null;
    }

    return false;
}

fn findMotorcyclePassengerTemplate(assets: *const Assets, role_id: i32) ?*const Assets.DataTables.TemplateConfig {
    var candidate: ?*const Assets.DataTables.TemplateConfig = null;
    for (assets.tables.template_config.items) |*template| {
        if (!passengerTemplateMatchesRole(assets, template.BlueprintType, role_id)) continue;
        if (!isNpcPassengerBlueprint(assets, template.BlueprintType)) continue;
        candidate = template;
    }

    return candidate;
}

pub fn findMotorcyclePassengerEntity(scene: *Scene, assets: *const Assets) ?Entity {
    const slice = scene.entities.slice();
    for (slice.items(.config), 0..) |config, i| {
        if (config.entity_type != .npc or config.config_type != .template) continue;
        const template = assets.tables.template_config.getDataById(config.config_id) orelse continue;
        if (!isNpcPassengerBlueprint(assets, template.BlueprintType)) continue;

        return .{
            .index = i,
            .net_id = slice.items(.entity_id)[i].net_id,
        };
    }

    return null;
}

pub fn createMotorcyclePassengerEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
    role_id: i32,
    motorcycle_entity: Entity,
    seat: i32,
) !Entity {
    const template = findMotorcyclePassengerTemplate(assets, role_id) orelse
        return error.MotorcyclePassengerTemplateNotFound;
    const base_info = template.ComponentsData.BaseInfoComponent;

    const location = if (scene.instance.players.len != 0)
        scene.instance.players[0].location
    else
        [_]f32{ -10000.0, -10000.0, -10000.0 };
    const rotation = if (scene.instance.players.len != 0)
        scene.instance.players[0].rotation
    else
        [_]f32{ 0.0, 0.0, 0.0 };
    const property_id = if (base_info) |info| info.EntityPropertyId orelse 2 else 2;

    return scene.spawn(alloc.gpa, fs, .{
        Entity.ConfigComponent{
            .camp = if (base_info) |info| info.Camp orelse 0 else 0,
            .state = .default,
            .entity_type = .npc,
            .config_type = .template,
            .config_id = template.Id,
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.PositionComponent{
            .location = location,
            .rotation = rotation,
        },
        Entity.VisibleMarker{},
        Entity.ActorVisibleMarker{},
        Entity.FightBuffComponent{},
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(property_id, alloc.arena),
            alloc.gpa,
        ),
        Entity.NpcDriveVehicleComponent{
            .vehicle_entity_id = motorcycle_entity.net_id,
            .seat = seat,
        },
    });
}

pub fn buildMotorcycleBornBuffs(
    gpa: std.mem.Allocator,
    assets: *const Assets,
) !std.ArrayListUnmanaged(BuffAdditionEntry) {
    var buffs: std.ArrayListUnmanaged(BuffAdditionEntry) = .empty;

    for (forced_motorcycle_born_buff_ids) |buff_id| {
        if (assets.tables.buff.getDataById(buff_id) == null) continue;
        try buffs.append(gpa, .{ .id = buff_id, .is_active = true });
    }

    return buffs;
}

pub fn buildMotorcycleGameplayTags(
    gpa: std.mem.Allocator,
) ![]pb.GameplayTagData {
    var tags: std.ArrayListUnmanaged(pb.GameplayTagData) = .empty;
    errdefer tags.deinit(gpa);

    for (forced_motorcycle_gameplay_tag_ids) |tag_id| {
        try tags.append(gpa, .{ .Id = tag_id, .TagCount = 1 });
    }

    return tags.toOwnedSlice(gpa);
}

pub fn refreshMotorcycleBornBuffs(
    events: *EventQueue,
    scene: *Scene,
    alloc: mem.Alloc,
    assets: *const Assets,
    _: *PlayerMotorComponent,
    entity: Entity,
) !void {
    const slice = scene.entities.slice();
    if (slice.items(.buffs)[entity.index]) |*buff_comp| {
        var desired = try buildMotorcycleBornBuffs(alloc.gpa, assets);
        defer desired.deinit(alloc.gpa);

        var add_buffs: std.ArrayList(BuffAdditionEntry) = .empty;
        defer add_buffs.deinit(alloc.gpa);

        var remove_handles: std.ArrayList(i32) = .empty;
        defer remove_handles.deinit(alloc.gpa);

        for (desired.items) |entry| {
            if (buff_comp.getByBuffId(entry.id) == null) {
                try add_buffs.append(alloc.gpa, entry);
            }
        }

        for (buff_comp.fight_buff_infos) |info| {
            if (isMotorTechBornBuff(info.BuffId) and !containsBuffEntry(desired.items, info.BuffId)) {
                try remove_handles.append(alloc.gpa, info.HandleId);
            }
        }

        if (add_buffs.items.len != 0) {
            try events.enqueue(.buff_addition, .{
                .target = entity,
                .instigator = entity,
                .buffs = try alloc.arena.dupe(BuffAdditionEntry, add_buffs.items),
            });
        }

        if (remove_handles.items.len != 0) {
            try events.enqueue(.buff_removal, .{
                .entity = entity,
                .handle_ids = try alloc.arena.dupe(i32, remove_handles.items),
            });
        }
    }

    if (slice.items(.tag)[entity.index]) |*tag_comp| {
        try refreshMotorcycleGameplayTags(events, alloc, entity, tag_comp);
    }
}

fn containsBuffEntry(items: []const BuffAdditionEntry, id: i64) bool {
    for (items) |item| {
        if (item.id == id) return true;
    }
    return false;
}

fn isMotorTechBornBuff(id: i64) bool {
    for (forced_motorcycle_born_buff_ids) |buff_id| {
        if (buff_id == id) return true;
    }
    return false;
}

fn refreshMotorcycleGameplayTags(
    events: *EventQueue,
    alloc: mem.Alloc,
    entity: Entity,
    tag_comp: *Entity.TagComponent,
) !void {
    const desired = try buildMotorcycleGameplayTags(alloc.gpa);
    defer alloc.gpa.free(desired);

    var add_tags: std.ArrayList(i32) = .empty;
    defer add_tags.deinit(alloc.gpa);

    var remove_tags: std.ArrayList(i32) = .empty;
    defer remove_tags.deinit(alloc.gpa);

    for (desired) |entry| {
        if (getGameplayTagCount(tag_comp, entry.Id) == 0) {
            try add_tags.append(alloc.gpa, entry.Id);
        }
    }

    for (tag_comp.gameplay_tags) |entry| {
        if (isMotorTechGameplayTag(entry.Id) and !containsGameplayTag(desired, entry.Id)) {
            try remove_tags.append(alloc.gpa, entry.Id);
        }
    }

    for (add_tags.items) |tag_id| {
        try setGameplayTagCount(alloc.gpa, tag_comp, tag_id, 1);
    }
    for (remove_tags.items) |tag_id| {
        try removeGameplayTag(alloc.gpa, tag_comp, tag_id);
    }

    if (add_tags.items.len != 0 or remove_tags.items.len != 0) {
        try events.enqueue(.gameplay_tag_change, .{
            .entity = entity,
            .add_tag_ids = try alloc.arena.dupe(i32, add_tags.items),
            .remove_tag_ids = try alloc.arena.dupe(i32, remove_tags.items),
        });
    }
}

fn containsGameplayTag(items: []const pb.GameplayTagData, id: i32) bool {
    for (items) |item| {
        if (item.Id == id and item.TagCount > 0) return true;
    }
    return false;
}

fn isMotorTechGameplayTag(id: i32) bool {
    for (forced_motorcycle_gameplay_tag_ids) |tag_id| {
        if (tag_id == id) return true;
    }
    return false;
}

fn getGameplayTagCount(tag_comp: *const Entity.TagComponent, id: i32) i32 {
    for (tag_comp.gameplay_tags) |entry| {
        if (entry.Id == id) return entry.TagCount;
    }
    return 0;
}

fn setGameplayTagCount(
    gpa: std.mem.Allocator,
    tag_comp: *Entity.TagComponent,
    id: i32,
    count: i32,
) !void {
    for (tag_comp.gameplay_tags) |*entry| {
        if (entry.Id == id) {
            entry.TagCount = count;
            return;
        }
    }

    tag_comp.gameplay_tags = try gpa.realloc(tag_comp.gameplay_tags, tag_comp.gameplay_tags.len + 1);
    tag_comp.gameplay_tags[tag_comp.gameplay_tags.len - 1] = .{ .Id = id, .TagCount = count };
}

fn removeGameplayTag(
    gpa: std.mem.Allocator,
    tag_comp: *Entity.TagComponent,
    id: i32,
) !void {
    for (tag_comp.gameplay_tags, 0..) |entry, i| {
        if (entry.Id != id) continue;

        if (tag_comp.gameplay_tags.len == 1) {
            gpa.free(tag_comp.gameplay_tags);
            tag_comp.gameplay_tags = &.{};
            return;
        }

        if (i + 1 < tag_comp.gameplay_tags.len) {
            std.mem.copyForwards(
                pb.GameplayTagData,
                tag_comp.gameplay_tags[i .. tag_comp.gameplay_tags.len - 1],
                tag_comp.gameplay_tags[i + 1 ..],
            );
        }
        tag_comp.gameplay_tags = try gpa.realloc(tag_comp.gameplay_tags, tag_comp.gameplay_tags.len - 1);
        return;
    }
}

pub fn createSceneBattleEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
) !Entity {
    const entity = try scene.spawn(alloc.gpa, fs, .{
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(390077025, alloc.arena),
            alloc.gpa,
        ),
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .scene_entity,
            .config_type = .template,
            .config_id = 14000169,
        },
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = [_]f32{
                -10000.0,
                -10000.0,
                -10000.0,
            },
            .rotation = [_]f32{ 0.0, 0.0, 0.0 },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.ActorVisibleMarker{},
    });

    return entity;
}
