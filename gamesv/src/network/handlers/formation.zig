const std = @import("std");
const mem = @import("../../mem.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const pb = @import("proto").pb;
const SceneInstance = @import("../../fs/SceneInstance.zig");
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Transaction = @import("../handlers.zig").Transaction;
const FormationInfo = @import("../../fs/FormationInfo.zig");
const FileSystem = @import("common").FileSystem;
const RoleEntityHelpers = @import("../../logic/entity/RoleEntityHelpers.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const EntityComponentStorage = @import("../../logic/component/entity/EntityComponentStorage.zig");

fn build_fight_formations(
    alloc: mem.Alloc,
    scene: *Scene,
) !std.ArrayList(pb.FightFormation) {
    var fight_formations: std.ArrayList(pb.FightFormation) = .empty;

    for (scene.formation_info.formations, 0..) |fight_formation, i| {
        var role_ids: std.ArrayList(i32) = .empty;

        for (fight_formation.roles) |maybe_role| {
            if (maybe_role) |role| {
                try role_ids.append(alloc.arena, role.role_id);
            }
        }

        try fight_formations.append(alloc.arena, .{
            .FormationId = @intCast(i),
            .CurRole = fight_formation.cur_role,
            .RoleIds = role_ids,
            .IsCurrent = (i == scene.formation_info.cur_formation),
        });
    }

    return fight_formations;
}

// pub fn onFormationAttrRequest(
//     txn: *Transaction(pb.FormationAttrRequest),
//     alloc: mem.Alloc,
//     scene: *Scene,
// ) !void {
//     for (scene.instance.players) |scene_player| {
//         if (scene_player.id == scene.player_id) {
//             for (scene.formation_info.formations) |formation| {
//                 for (formation.roles) |_| {
//                     const formation_attr_notify: pb.FormationAttrNotify = .{
//                         .Duration = txn.message.Duration,
//                         .FormationAttrs = txn.message.FormationAttrs,
//                     };
//                     try txn.conn.push(formation_attr_notify, alloc.arena);
//                 }
//             }
//             break;
//         }
//     } else {
//         return error.PlayerNotFoundInScene;
//     }
//     txn.respond(.{});
// }

pub fn onUpdateFormationRequest(
    txn: *Transaction(pb.UpdateFormationRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    const log = std.log.scoped(.formation_update);

    for (txn.message.Formations.items) |fight_formation| {
        const formation_id = fight_formation.FormationId - 1;
        const idx: usize = @intCast(formation_id);
        const is_current = fight_formation.IsCurrent;

        if (idx + 1 > scene.formation_info.formations.len) {
            const old_len = scene.formation_info.formations.len;
            const new_formations = try alloc.gpa.realloc(scene.formation_info.formations, idx + 1);
            scene.formation_info.formations = new_formations;
            for (new_formations[old_len..]) |*f| {
                f.* = .{ .cur_role = 0, .roles = .{ null, null, null } };
            }
        }

        if (is_current) {
            const old_formation_copy = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
            const old_formation = &old_formation_copy;
            scene.formation_info.cur_formation = formation_id;

            const current_formation = &scene.formation_info.formations[idx];
            var roles: [3]?FormationInfo.Formation.Role = .{ null, null, null };
            for (fight_formation.RoleIds.items, 0..) |role_id, i| {
                if (i >= 3) break;
                const existing_entity_id: i64 = blk: {
                    for (old_formation.roles) |maybe_existing| {
                        if (maybe_existing) |existing| {
                            if (existing.role_id == role_id) break :blk existing.entity_id;
                        }
                    }
                    break :blk -1;
                };
                roles[i] = .{
                    .role_id = role_id,
                    .entity_id = existing_entity_id,
                    .on_stage_without_control = false,
                };
            }
            current_formation.* = .{
                .cur_role = fight_formation.CurRole,
                .roles = roles,
            };

            var added_roles: std.ArrayList(i32) = .empty;
            for (current_formation.*.roles) |maybe_role| {
                const role = maybe_role orelse continue;
                const contained_in_old = blk: {
                    for (old_formation.roles) |maybe_old_role| {
                        const old_role = maybe_old_role orelse continue;
                        if (old_role.role_id == role.role_id) break :blk true;
                    }
                    break :blk false;
                };
                if (!contained_in_old) {
                    try added_roles.append(alloc.arena, role.role_id);
                }
            }

            var removed_entity_ids: std.ArrayList(i64) = .empty;
            for (old_formation.*.roles) |maybe_role| {
                const role = maybe_role orelse continue;
                const contained_in_current = blk: {
                    for (current_formation.roles) |maybe_cf_role| {
                        const cf_role = maybe_cf_role orelse continue;
                        if (cf_role.role_id == role.role_id) break :blk true;
                    }
                    break :blk false;
                };
                if (!contained_in_current) {
                    try removed_entity_ids.append(alloc.arena, role.entity_id);
                }
            }

            log.debug("added: {any}, removed: {any}", .{ added_roles.items, removed_entity_ids.items });

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
            try txn.conn.push(remove_notify, alloc.arena);

            const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene.instance_id) orelse
                return error.InstanceDungeonNotFound;

            var role_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
            defer role_entity_pbs.deinit(alloc.gpa);
            var concom_entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
            defer concom_entity_pbs.deinit(alloc.gpa);

            for (added_roles.items) |role_id| {
                const entity = try RoleEntityHelpers.createRoleEntity(
                    fs,
                    scene,
                    alloc,
                    scene.player_id,
                    assets,
                    role_comp,
                    weapon_comp,
                    instance_dungeon,
                    role_id,
                );
                for (&current_formation.roles) |*maybe_slot| {
                    const slot = &(maybe_slot.* orelse continue);
                    if (slot.role_id == role_id) {
                        slot.entity_id = entity.net_id;
                        break;
                    }
                }
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
            }

            var role_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
            role_entity_add_notify.EntityPbs = role_entity_pbs;
            try txn.conn.push(role_entity_add_notify, alloc.arena);
            var concom_entity_add_notify: pb.EntityAddNotify = .{ .RemoveTagIds = false };
            concom_entity_add_notify.EntityPbs = concom_entity_pbs;
            try txn.conn.push(concom_entity_add_notify, alloc.arena);

            current_formation.*.cur_role = blk: {
                for (current_formation.roles) |maybe_cf_role| {
                    const cf_role = maybe_cf_role orelse continue;
                    if (cf_role.role_id == old_formation.cur_role) break :blk old_formation.cur_role;
                }
                const slot = slot_blk: {
                    for (old_formation.roles, 0..) |maybe_role, i| {
                        const role = maybe_role orelse continue;
                        if (role.role_id == old_formation.cur_role) break :slot_blk i;
                    }
                    break :slot_blk 0;
                };

                var i: usize = slot;
                while (true) {
                    if (current_formation.roles[i] != null) break :blk current_formation.roles[i].?.role_id;
                    if (i == 0) break;
                    i -= 1;
                }

                break :blk current_formation.*.roles[0].?.role_id;
            };

            var fight_role_infos: std.ArrayList(pb.FightRoleInfo) = .empty;
            defer fight_role_infos.deinit(alloc.gpa);
            for (current_formation.roles) |maybe_slot| {
                const slot = maybe_slot orelse continue;
                try fight_role_infos.append(alloc.gpa, .{
                    .RoleId = slot.role_id,
                    .EntityId = slot.entity_id,
                    .OnStageWithoutControl = false,
                });
            }
            log.debug("fight_role_infos: {any}", .{fight_role_infos});

            var fight_role_infos_wrapper: std.ArrayList(pb.FightRoleInfos) = .empty;
            defer fight_role_infos_wrapper.deinit(alloc.gpa);
            try fight_role_infos_wrapper.append(alloc.gpa, .{
                .GroupType = 1,
                .FightRoleInfos = fight_role_infos,
                .CurRole = current_formation.cur_role,
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

            try txn.conn.push(pb.UpdateGroupFormationNotify{
                .GroupFormation = group_formations,
            }, alloc.arena);
        } else {
            var roles: [3]?FormationInfo.Formation.Role = .{ null, null, null };
            for (fight_formation.RoleIds.items, 0..) |role_id, i| {
                roles[i] = .{
                    .role_id = role_id,
                    .entity_id = -1,
                    .on_stage_without_control = false,
                };
            }
            scene.formation_info.formations[idx] = .{
                .cur_role = fight_formation.CurRole,
                .roles = roles,
            };
        }
    }

    try scene.save(fs, alloc.gpa);
    try events.enqueue(.update_formations, .{});
    txn.respond(.{});
}

pub fn onFormationDataRequest(
    txn: *Transaction(pb.GetFormationDataRequest),
    alloc: mem.Alloc,
    scene: *Scene,
) !void {
    const fight_formations: std.ArrayList(pb.FightFormation) = try build_fight_formations(alloc, scene);

    const log = std.log.scoped(.formation);
    log.debug("{any}\n", .{fight_formations});

    txn.respond(.{ .Formations = fight_formations });
}
