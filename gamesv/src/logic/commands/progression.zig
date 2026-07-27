const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PlayerInventoryComponent = @import("../../logic/component/player/PlayerInventoryComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const WeaponItem = @import("../../fs/WeaponItem.zig");
const special_item_incr = @import("../../fs/special_item_incr.zig");
const FileSystem = @import("common").FileSystem;
const Connection = @import("../../network/Connection.zig");
const Scene = @import("../../logic/Scene.zig");
const comp_util = @import("../component/comp_util.zig");
const mem = @import("../../mem.zig");
const respond = @import("../commands.zig").respond;
const Events = @import("../../logic/events.zig");
const RoleStats = @import("../../logic/helpers/role_stats.zig");

pub const resonance_item = struct {
    pub const alias = "waveband";
    pub const description = "grants or clears resonance chain items.\nusage: waveband [current|full_role_id] [count|clear?]\ncount defaults to 6.";

    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        assets: *const Assets,
        fs: *FileSystem,
        conn: *Connection,
        scene: *Scene,
        inventory_comp: *PlayerInventoryComponent,
        role_comp: *PlayerRoleComponent,
        weapon_comp: *PlayerWeaponComponent,
        echo_comp: *PlayerEchoComponent,
        query: Scene.Query(&.{
            Scene.Entity,
            *Scene.Entity.FightBuffComponent,
            *Scene.Entity.ConfigComponent,
        }),
        subject: ?[]const u8,
        action: ?[]const u8,
    ) !void {
        const token = subject orelse {
            try respond(events, alloc.arena, "no character specified", .{});
            return;
        };
        if (std.ascii.eqlIgnoreCase(token, "all")) {
            try respond(events, alloc.arena, "no character specified", .{});
            return;
        }

        if (action) |value| {
            if (std.ascii.eqlIgnoreCase(value, "clear")) {
                try clearWavebands(events, alloc, assets, fs, conn, scene, inventory_comp, role_comp, weapon_comp, echo_comp, query, token);
                return;
            }
        }

        const item_count = parseCount(action, 6) catch {
            try respond(events, alloc.arena, "count must be a number or clear", .{});
            return;
        };
        const resolved = try resolveItemId(events, alloc, assets, scene, token) orelse return;
        const old_count = inventory_comp.info.normalItemCount(resolved.item_id);
        try InventoryInfo.addNormalItem(&inventory_comp.info, alloc.gpa, resolved.item_id, item_count);

        try saveInventoryInfo(alloc, fs, inventory_comp);

        var updated_items: std.ArrayList(pb.NormalItem) = .empty;
        try updated_items.append(alloc.arena, .{
            .Id = resolved.item_id,
            .Count = inventory_comp.info.normalItemCount(resolved.item_id),
            .ExpireTime = 0,
        });
        if (old_count == 0) {
            try conn.push(pb.NormalItemAddNotify{
                .NormalItemList = updated_items,
                .NoTips = true,
            });
        } else {
            try conn.push(pb.NormalItemUpdateNotify{
                .NormalItemList = updated_items,
                .NoTips = true,
            });
        }

        try respond(events, alloc.arena, "granted {d} wavebands for {s} ({d}, total {d})", .{
            item_count,
            token,
            resolved.item_id,
            inventory_comp.info.normalItemCount(resolved.item_id),
        });
    }
};

pub const weapon_item = struct {
    pub const alias = "weapon";
    pub const description = "grants or clears weapon copies.\nusage: weapon [current|weapon_id] [count|clear?]\ncount defaults to 4.";

    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        assets: *const Assets,
        fs: *FileSystem,
        conn: *Connection,
        weapon_comp: *PlayerWeaponComponent,
        role_comp: *PlayerRoleComponent,
        scene: *Scene,
        query: Scene.Query(&.{
            Scene.Entity,
            *Scene.Entity.ConfigComponent,
            *Scene.Entity.FightBuffComponent,
        }),
        subject: ?[]const u8,
        action: ?[]const u8,
    ) !void {
        const token = subject orelse {
            try respond(events, alloc.arena, "weapon must be specified", .{});
            return;
        };
        if (std.ascii.eqlIgnoreCase(token, "all")) {
            try respond(events, alloc.arena, "weapon must be specified", .{});
            return;
        }
        const weapon_id = try resolveWeaponId(events, alloc, assets, scene, role_comp, weapon_comp, token) orelse return;
        if (action) |value| {
            if (std.ascii.eqlIgnoreCase(value, "clear")) {
                try clearWeaponCopies(events, alloc, assets, fs, conn, query, weapon_comp, weapon_id);
                return;
            }
        }

        const count = parseCount(action, 4) catch {
            try respond(events, alloc.arena, "count must be a number or clear", .{});
            return;
        };

        var added: std.ArrayList(pb.WeaponItem) = .empty;
        try addWeaponCopies(alloc, fs, assets, weapon_comp, weapon_id, count, &added);
        try pushWeaponAdds(conn, added);
        try respond(events, alloc.arena, "granted {d} copies of weapon {d}", .{ count, weapon_id });
    }
};

fn parseCount(action: ?[]const u8, default: i32) !i32 {
    const value = action orelse return default;
    return @max(try std.fmt.parseInt(i32, value, 10), 1);
}

fn saveInventoryInfo(
    alloc: mem.Alloc,
    fs: *FileSystem,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}", .{ inventory_comp.player_id, InventoryInfo.data_path });
    try comp_util.saveStruct(fs, inventory_comp.info, path, alloc.arena);
}

fn saveWeaponInfo(
    alloc: mem.Alloc,
    fs: *FileSystem,
    weapon_comp: *PlayerWeaponComponent,
    incr_id: i32,
    weapon: WeaponItem,
) !void {
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}/{}", .{ weapon_comp.player_id, WeaponItem.data_dir, incr_id });
    try comp_util.saveStruct(fs, weapon, path, alloc.arena);
}

fn addWeaponCopies(
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    weapon_comp: *PlayerWeaponComponent,
    weapon_id: i32,
    count: i32,
    added: *std.ArrayList(pb.WeaponItem),
) !void {
    for (0..@intCast(count)) |_| {
        const incr_id = try special_item_incr.next(alloc.gpa, fs, weapon_comp.player_id);
        const weapon: WeaponItem = .{
            .id = weapon_id,
            .func_value = WeaponItem.defaultFuncValue(assets, weapon_id),
        };
        try weapon_comp.weapon_map.put(alloc.gpa, incr_id, weapon);
        try saveWeaponInfo(alloc, fs, weapon_comp, incr_id, weapon);
        try added.append(alloc.arena, weapon.toProto(incr_id));
    }
}

fn pushWeaponAdds(
    conn: *Connection,
    added: std.ArrayList(pb.WeaponItem),
) !void {
    if (added.items.len == 0) return;
    try conn.push(pb.WeaponItemAddNotify{
        .WeaponItemList = added,
        .AddFromRole = false,
        .Reason = 0,
    });
}

fn currentWeaponId(
    events: *EventQueue,
    alloc: mem.Alloc,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
) !?i32 {
    const formation_index: usize = @intCast(scene.formation_info.cur_formation);
    if (formation_index >= scene.formation_info.formations.len) {
        try respond(events, alloc.arena, "no current formation", .{});
        return null;
    }
    const role_id = scene.formation_info.formations[formation_index].cur_role;
    const role = role_comp.role_map.getPtr(role_id) orelse {
        try respond(events, alloc.arena, "current role has no saved data", .{});
        return null;
    };
    const weapon = weapon_comp.weapon_map.getPtr(role.weapon) orelse {
        try respond(events, alloc.arena, "weapon must be specified", .{});
        return null;
    };
    return weapon.id;
}

fn resolveWeaponId(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    token: []const u8,
) !?i32 {
    if (std.ascii.eqlIgnoreCase(token, "current")) return currentWeaponId(events, alloc, scene, role_comp, weapon_comp);
    const weapon_id = std.fmt.parseInt(i32, token, 10) catch {
        try respond(events, alloc.arena, "weapon id must be a number or current", .{});
        return null;
    };
    if (assets.tables.weapon_conf.getDataById(weapon_id) == null) {
        try respond(events, alloc.arena, "unknown weapon id: {d}", .{weapon_id});
        return null;
    }
    return weapon_id;
}

fn clearWeaponCopies(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    conn: *Connection,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.FightBuffComponent,
    }),
    weapon_comp: *PlayerWeaponComponent,
    weapon_id: i32,
) !void {
    var removed_ids: std.ArrayList(i32) = .empty;
    var updated_items: std.ArrayList(pb.WeaponItem) = .empty;
    var iterator = weapon_comp.weapon_map.iterator();
    while (iterator.next()) |entry| {
        if (entry.value_ptr.id != weapon_id) continue;
        if (entry.value_ptr.role_id == null) {
            try removed_ids.append(alloc.arena, entry.key_ptr.*);
            continue;
        }
        if (entry.value_ptr.reson_level != 1) {
            const config = assets.tables.weapon_conf.getDataById(weapon_id) orelse continue;
            const old_reson = assets.tables.getWeaponReson(config.ResonId, entry.value_ptr.reson_level);
            const new_reson = assets.tables.getWeaponReson(config.ResonId, 1);
            if (entry.value_ptr.role_id) |role_id| {
                var it = query.iterator;
                while (it.next()) |item| {
                    const entity, const config_item, const buffs = item;
                    if (config_item.config_id != role_id) continue;

                    if (old_reson) |old| {
                        var handles_to_remove: std.ArrayList(i32) = .empty;
                        for (old.Effect) |buff_id| {
                            const buff = buffs.getByBuffId(buff_id) orelse continue;
                            try handles_to_remove.append(alloc.arena, buff.HandleId);
                        }
                        try events.enqueue(.buff_removal, .{ .entity = entity, .handle_ids = handles_to_remove.items });
                    }

                    if (new_reson) |new| {
                        var buffs_to_add: std.ArrayList(Events.BuffAdditionEntry) = .empty;
                        for (new.Effect) |buff_id| {
                            try buffs_to_add.append(alloc.arena, .{ .id = buff_id, .is_active = true, .stack_count = 1 });
                        }
                        try events.enqueue(.buff_addition, .{ .target = entity, .instigator = entity, .buffs = buffs_to_add.items });
                    }
                    break;
                }
            }
            entry.value_ptr.reson_level = 1;
            try saveWeaponInfo(alloc, fs, weapon_comp, entry.key_ptr.*, entry.value_ptr.*);
            try events.enqueue(.weapon_info_modified, .{ .incr_id = entry.key_ptr.* });
            try updated_items.append(alloc.arena, entry.value_ptr.toProto(entry.key_ptr.*));
        }
    }

    for (removed_ids.items) |incr_id| {
        _ = weapon_comp.weapon_map.orderedRemove(incr_id);
        try fs.deleteFile(try std.fmt.allocPrint(alloc.arena, "player/{}/{s}/{}", .{ weapon_comp.player_id, WeaponItem.data_dir, incr_id }));
    }

    if (removed_ids.items.len != 0) {
        try conn.push(pb.WeaponItemRemoveNotify{ .WeaponItemIncrIdList = removed_ids });
    }
    try pushWeaponAdds(conn, updated_items);
    try respond(events, alloc.arena, "cleared weapon {d}", .{weapon_id});
}

fn clearWavebands(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    fs: *FileSystem,
    conn: *Connection,
    scene: *Scene,
    inventory_comp: *PlayerInventoryComponent,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.FightBuffComponent,
        *Scene.Entity.ConfigComponent,
    }),
    token: []const u8,
) !void {
    if (std.ascii.eqlIgnoreCase(token, "all")) {
        try respond(events, alloc.arena, "no character specified", .{});
        return;
    }

    const resolved = try resolveItemId(events, alloc, assets, scene, token) orelse return;
    _ = try InventoryInfo.removeNormalItem(&inventory_comp.info, alloc.gpa, resolved.item_id);
    var updated_items: std.ArrayList(pb.NormalItem) = .empty;
    try updated_items.append(alloc.arena, .{ .Id = resolved.item_id, .Count = 0, .ExpireTime = 0 });

    if (resolved.role_id) |role_id| {
        if (role_comp.role_map.getPtr(role_id)) |role| {
            if (role.resonant_chain_group_index != 0) {
                var it = query.iterator;
                while (it.next()) |item| {
                    const entity, const buffs, const config_item = item;
                    if (config_item.config_id != role_id) continue;

                    var handles_to_remove: std.ArrayList(i32) = .empty;
                    for (assets.tables.resonant_chain.items) |chain| {
                        if (chain.GroupId != role_id) continue;
                        if (chain.GroupIndex > role.resonant_chain_group_index) continue;
                        for (chain.BuffIds) |buff_id| {
                            const buff = buffs.getByBuffId(buff_id) orelse continue;
                            try handles_to_remove.append(alloc.arena, buff.HandleId);
                        }
                    }

                    if (handles_to_remove.items.len > 0) {
                        try events.enqueue(.buff_removal, .{ .entity = entity, .handle_ids = handles_to_remove.items });
                    }
                    break;
                }
                role.resonant_chain_group_index = 0;
                try events.enqueue(.role_info_modified, .{ .role_id = role_id });
            }
            var role_list: std.ArrayList(pb.RoleInfo) = .empty;
            try role_list.append(alloc.arena, try RoleStats.toClientRoleInfo(
                alloc.gpa,
                alloc.arena,
                assets,
                role_comp,
                role_id,
                role,
                weapon_comp,
                echo_comp,
            ));
            try conn.push(pb.PbGetRoleListNotify{ .RoleList = role_list });
        }
    }

    try saveInventoryInfo(alloc, fs, inventory_comp);
    try conn.push(pb.NormalItemUpdateNotify{
        .NormalItemList = updated_items,
        .NoTips = true,
    });
    try respond(events, alloc.arena, "cleared wavebands for {s}", .{token});
}

const ResolvedItem = struct {
    item_id: i32,
    role_id: ?i32 = null,
};

fn resolveItemId(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    scene: *Scene,
    subject: []const u8,
) !?ResolvedItem {
    const token = subject;
    if (std.ascii.eqlIgnoreCase(token, "current")) {
        const formation_index: usize = @intCast(scene.formation_info.cur_formation);
        if (formation_index >= scene.formation_info.formations.len) {
            try respond(events, alloc.arena, "no current formation", .{});
            return null;
        }
        return roleToItem(events, alloc, assets, scene.formation_info.formations[formation_index].cur_role);
    }

    if (std.fmt.parseInt(i32, token, 10)) |id| {
        if (id < 10000000) {
            try respond(events, alloc.arena, "use the full character id: {d}", .{id});
            return null;
        }
        return roleToItem(events, alloc, assets, id - 10000000);
    } else |_| {}

    try respond(events, alloc.arena, "character id must be current or a full id", .{});
    return null;
}

fn roleToItem(events: *EventQueue, alloc: mem.Alloc, assets: *const Assets, role_id: i32) !?ResolvedItem {
    const role = assets.tables.role_info.getDataById(role_id) orelse {
        try respond(events, alloc.arena, "unknown role id: {d}", .{role_id});
        return null;
    };
    if (role.ResonantChainGroupId == 0) {
        try respond(events, alloc.arena, "role {d} has no resonance chain group", .{role_id});
        return null;
    }
    const item_id = firstActivateItem(assets, role.ResonantChainGroupId) orelse {
        try respond(events, alloc.arena, "role {d} has no resonance chain item", .{role_id});
        return null;
    };
    return .{ .item_id = item_id, .role_id = role_id };
}

fn firstActivateItem(assets: *const Assets, group_id: i32) ?i32 {
    for (assets.tables.resonant_chain.items) |chain| {
        if (chain.GroupId != group_id or chain.GroupIndex != 1) continue;
        var iterator = chain.ActivateConsume.map.iterator();
        if (iterator.next()) |entry| return entry.key_ptr.*;
        return null;
    }
    return null;
}
