const PlayerWeaponComponent = @This();
const std = @import("std");
const common = @import("common");
const comp_util = @import("../comp_util.zig");
const file_util = @import("../../../fs/file_util.zig");

const Assets = @import("../../../data/Assets.zig");
const WeaponItem = @import("../../../fs/WeaponItem.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
weapon_map: std.AutoArrayHashMapUnmanaged(i32, WeaponItem),

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerWeaponComponent {
    return .{
        .player_id = player_id,
        .weapon_map = try comp_util.loadItems(WeaponItem, gpa, fs, assets, player_id, .by_incr_id),
    };
}

pub fn deinit(comp: *PlayerWeaponComponent, gpa: Allocator) void {
    comp_util.freeMap(gpa, &comp.weapon_map);
}
