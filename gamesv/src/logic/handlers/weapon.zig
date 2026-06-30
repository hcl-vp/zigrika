const std = @import("std");
const pb = @import("proto").pb;
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const comp_util = @import("../component/comp_util.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const WeaponItem = @import("../../fs/WeaponItem.zig");
const special_item_incr = @import("../../fs/special_item_incr.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");

pub fn ensureRoleWeapons(
    _: EventQueue.Dequeue(.enter_game),
    events: *EventQueue,
    fs: *FileSystem,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    // Make sure all the roles have weapons for them
    var roles = role_comp.role_map.iterator();
    outer: while (roles.next()) |role_kv| {
        var weapons = weapon_comp.weapon_map.iterator();
        while (weapons.next()) |weapon_kv| {
            if (weapon_kv.value_ptr.role_id == role_kv.key_ptr.*) continue :outer;
        }

        const role_info = assets.tables.role_info.getDataById(role_kv.key_ptr.*) orelse continue;
        const weapon: WeaponItem = .{
            .id = role_info.InitWeaponItemId,
            .func_value = WeaponItem.defaultFuncValue(assets, role_info.InitWeaponItemId),
            .role_id = role_kv.key_ptr.*,
        };

        const incr_id = try special_item_incr.next(alloc.gpa, fs, role_comp.player_id);

        const path = try std.fmt.allocPrint(alloc.gpa, "player/{d}/weapon/{d}", .{ role_comp.player_id, incr_id });
        defer alloc.gpa.free(path);
        try comp_util.saveStruct(fs, weapon, path, alloc.arena);

        role_kv.value_ptr.weapon = incr_id;
        try events.enqueue(.role_info_modified, .{ .role_id = role_kv.key_ptr.* });
        try weapon_comp.weapon_map.put(alloc.gpa, incr_id, weapon);
    }
}
