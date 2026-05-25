const std = @import("std");
const pb = @import("proto").pb;
const Scene = @import("../../logic/Scene.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const RoleEntityTemplates = @import("../../logic/templates/RoleEntityTemplates.zig");

pub fn resetRoles(
    scene: *Scene,
    fs: *FileSystem,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    conn: *Connection,
    alloc: mem.Alloc,
    role_ids: ?[]const i32,
) !void {
    const log = std.log.scoped(.reset_formation);
    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene.instance_id) orelse {
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
        if (role_ids) |ids| {
            const should_reset = for (ids) |id| {
                if (id == role.role_id) break true;
            } else false;
            if (!should_reset) continue;
        }
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
        if (role_ids) |ids| {
            const should_reset = for (ids) |id| {
                if (id == role.role_id) break true;
            } else false;
            if (!should_reset) continue;
        }
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
}
