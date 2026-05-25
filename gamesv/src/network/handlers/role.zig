const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");

pub fn onRoleFavorListRequest(
    txn: *Transaction(pb.RoleFavorListRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var favor_list: std.ArrayList(pb.RoleFavor) = .empty;

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |role_entry| {
        const role_id = role_entry.key_ptr.*;

        var role_favor: pb.RoleFavor = .{
            .RoleId = role_id,
            .Level = 5,
            .Exp = 0,
        };

        for (assets.tables.favor_word.items) |word| {
            if (word.RoleId == role_id) {
                try role_favor.WordIds.append(alloc.arena, .{
                    .Id = word.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_story.items) |story| {
            if (story.RoleId == role_id) {
                try role_favor.StoryIds.append(alloc.arena, .{
                    .Id = story.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_goods.items) |goods| {
            if (goods.RoleId == role_id) {
                try role_favor.GoodsIds.append(alloc.arena, .{
                    .Id = goods.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        try favor_list.append(alloc.arena, role_favor);
    }

    txn.respond(.{ .FavorList = favor_list });
}

pub fn SwitchRoleRequest(
    txn: *dispatch.CombatRequestTxn(.SwitchRoleRequest),
    scene: *Scene,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    const request: pb.SwitchRoleRequest = txn.payload;
    const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
    const previous_role = formation.cur_role;
    formation.cur_role = request.RoleId;

    const slice = scene.entities.slice();
    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id == previous_role) {
            slice.items(.visible)[i] = null;
        } else if (config.config_id == request.RoleId) {
            slice.items(.visible)[i] = .{};
        }
    }

    try scene.save(fs, alloc.gpa);
    txn.respond(.{ .ErrorCode = .Success, .RoleId = request.RoleId });
}
