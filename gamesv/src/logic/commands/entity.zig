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
const RoleHelper = @import("../../logic/helpers/role.zig");
const RoleEntityTemplates = @import("../../logic/templates/RoleEntityTemplates.zig");
const respond = @import("../commands.zig").respond;

const EntitySpawnBase = struct {
    config_type: ConfigComponent.ConfigType,
    entity_type: ConfigComponent.EntityType,
    entity_state: ConfigComponent.EntityState,
};

const FROZEN_BUFFS: *const [1]i64 = &.{10010001};
const TUNE_BROKEN_BUFFS: *const [5]i64 = &.{ 3161, 3162, 3163, 3164, 9000000000 };
const buffListFromIds = @import("../../data/tables/Buff.zig").buffListFromIds;

pub const spawn = struct {
    pub const alias = "s";
    pub const description = "spawns an entity.\nusage: spawn [entity_id] [freeze?] [tune_break?]";
    pub fn call(
        events: *EventQueue,
        scene: *Scene,
        fs: *FileSystem,
        assets: *const Assets,
        conn: *Connection,
        alloc: mem.Alloc,
        entity_id: i64,
        is_frozen: ?bool,
        is_tune_broken: ?bool,
    ) !void {
        var entity_config = (assets.tables.level_entity_config.getDataById(entity_id) orelse {
            try respond(events, alloc.arena, "{d} couldn't be spawned, couldn't find it in LevelEntityConfig", .{entity_id});
            return;
        });
        const blueprint_config = blk: {
            for (assets.tables.blueprint_config.items) |bp_cfg| {
                if (std.mem.eql(u8, bp_cfg.BlueprintType, entity_config.BlueprintType)) {
                    break :blk bp_cfg;
                }
            }
            try respond(events, alloc.arena, "{d} couldn't be spawned, no blueprint config found", .{entity_id});
            return;
        };
        var template_config = blk: {
            for (assets.tables.template_config.items) |tp_cfg| {
                if (std.mem.eql(u8, tp_cfg.BlueprintType, entity_config.BlueprintType)) {
                    break :blk tp_cfg;
                }
            }
            try respond(events, alloc.arena, "{d} couldn't be spawned, no blueprint config found", .{entity_id});
            return;
        };

        template_config.ComponentsData.mergeInto(&entity_config.ComponentsData);

        const spawn_base: EntitySpawnBase = switch (blueprint_config.EntityLogic) {
            .Item => .{ .config_type = .level, .entity_type = .scene_item, .entity_state = .default },
            .Animal => .{ .config_type = .level, .entity_type = .animal, .entity_state = .default },
            .Monster => .{ .config_type = .level, .entity_type = .monster, .entity_state = .born },
            .Vehicle => .{ .config_type = .level, .entity_type = .vehicle, .entity_state = .default },
            .Npc => .{ .config_type = .level, .entity_type = .npc, .entity_state = .default },
            .Vision => .{ .config_type = .level, .entity_type = .vision, .entity_state = .default },
            .ClientOnly => .{ .config_type = .level, .entity_type = .client_only, .entity_state = .default },
            .Custom => .{ .config_type = .level, .entity_type = .custom, .entity_state = .default },
            .ServerOnly, .SimpleCombat => {
                try respond(events, alloc.arena, "{d} couldn't be spawned, unhandled entity logic: {s}", .{ entity_id, @tagName(blueprint_config.EntityLogic) });
                return;
            },
        };

        const base_info = template_config.ComponentsData.BaseInfoComponent orelse {
            try respond(events, alloc.arena, "{d} couldn't be spawned, it had no baseinfo comp and we dont support that :)", .{entity_id});
            return;
        };

        const entity = try scene.spawn(alloc.gpa, fs, .{
            Entity.ConfigComponent{
                .camp = base_info.Camp orelse 0,
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

        var buff_ids: std.ArrayList(i64) = .empty;
        defer buff_ids.deinit(alloc.gpa);

        if (is_frozen orelse false) try buff_ids.appendSlice(alloc.gpa, FROZEN_BUFFS);
        if (is_tune_broken orelse false) try buff_ids.appendSlice(alloc.gpa, TUNE_BROKEN_BUFFS);
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
        const entity_pb = try storage.entityToProto(entity.net_id, alloc);
        entity_pbs.appendAssumeCapacity(entity_pb);
        try conn.push(pb.EntityAddNotify{ .EntityPbs = entity_pbs }, alloc.arena);

        try respond(events, alloc.arena, "spawned {d}, frozen: {any}, tune broken: {any}", .{ entity_id, is_frozen, is_tune_broken });
    }
};

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
        conn: *Connection,
        alloc: mem.Alloc,
    ) !void {
        try RoleHelper.resetRoles(
            scene,
            fs,
            assets,
            role_comp,
            weapon_comp,
            conn,
            alloc,
            null,
        );
        try respond(events, alloc.arena, "reset formation successfully", .{});
    }
};
