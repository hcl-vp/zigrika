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
        const log = std.log.scoped(.reset_formation);
        const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene.instance_id) orelse {
            // TODO: fallback to default instance id?
            log.err(
                "player({d}) last scene instance id {d} doesn't exist",
                .{ scene.player_id, scene.instance_id },
            );
            return;
        };

        const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
        var removed_entity_ids: std.ArrayList(i64) = .empty;
        for (formation.*.roles) |maybe_role| {
            const role = maybe_role orelse continue;
            try removed_entity_ids.append(alloc.arena, role.entity_id);
        }

        var remove_notify: pb.EntityRemoveNotify = .{ .IsRemove = true };
        var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;
        defer remove_infos.deinit(alloc.gpa);
        for (removed_entity_ids.items) |entity_id| {
            const entity_index = scene.net_id_map.get(entity_id) orelse continue;
            const storage = scene.entities.get(entity_index);
            if (storage.concomitant) |concomitant| {
                for (concomitant.custom_entity_ids) |concom_id| {
                    try scene.remove(alloc.gpa, fs, concom_id);
                    try remove_infos.append(alloc.gpa, .{ .EntityId = concom_id });
                }
            }

            try scene.remove(alloc.gpa, fs, entity_id);
            try remove_infos.append(alloc.gpa, .{ .EntityId = entity_id });
        }
        remove_notify.RemoveInfos = remove_infos;
        try conn.push(remove_notify, alloc.arena);

        var role_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
        defer role_entity_pbs.deinit(alloc.gpa);
        var concom_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
        defer concom_entity_pbs.deinit(alloc.gpa);

        for (&formation.roles) |*maybe_role| if (maybe_role.*) |*role| {
            const entity = try RoleEntityTemplates.createRoleEntity(
                fs,
                scene,
                alloc,
                scene.player_id,
                assets,
                role_comp,
                weapon_comp,
                instance_dungeon,
                role.role_id,
            );
            role.entity_id = entity.net_id;
            const storage = scene.entities.get(entity.index);
            const entity_pb = try storage.entityToProto(entity.net_id, alloc);
            try role_entity_pbs.append(alloc.gpa, entity_pb);

            if (storage.concomitant) |concomitant| {
                for (concomitant.custom_entity_ids) |concom_id| {
                    const concom_index = scene.net_id_map.get(concom_id) orelse continue;
                    const concom_storage = scene.entities.get(concom_index);
                    const concom_pb = try concom_storage.entityToProto(concom_id, alloc);
                    try concom_entity_pbs.append(alloc.gpa, concom_pb);
                }
            }
        };

        var role_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
        role_entity_add_notify.EntityPbs = role_entity_pbs;
        try conn.push(role_entity_add_notify, alloc.arena);
        var concom_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
        concom_entity_add_notify.EntityPbs = concom_entity_pbs;
        try conn.push(concom_entity_add_notify, alloc.arena);

        var fight_role_infos: std.ArrayList(pb.FightRoleInfo) = .empty;
        defer fight_role_infos.deinit(alloc.gpa);
        for (formation.roles) |maybe_slot| {
            const slot = maybe_slot orelse continue;
            try fight_role_infos.append(alloc.gpa, .{
                .RoleId = slot.role_id,
                .EntityId = slot.entity_id,
                .OnStageWithoutControl = false,
            });
        }

        var fight_role_infos_wrapper: std.ArrayList(pb.FightRoleInfos) = .empty;
        defer fight_role_infos_wrapper.deinit(alloc.gpa);
        try fight_role_infos_wrapper.append(alloc.gpa, .{
            .GroupType = 1,
            .FightRoleInfos = fight_role_infos,
            .CurRole = formation.cur_role,
            .LivingStatus = .Alive,
            .IsFixedLocation = false,
        });

        var group_formations: std.ArrayList(pb.GroupFormation) = .empty;
        defer group_formations.deinit(alloc.gpa);
        try group_formations.append(alloc.gpa, .{
            .PlayerId = scene.player_id,
            .FightRoleInfos = fight_role_infos_wrapper,
            .CurrentGroupType = 1,
        });

        try conn.push(pb.UpdateGroupFormationNotify{
            .GroupFormation = group_formations,
        }, alloc.arena);

        try respond(events, alloc.arena, "reset formation successfully", .{});
    }
};
