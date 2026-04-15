const WeaponItem = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../data/Assets.zig");

const Allocator = std.mem.Allocator;

pub const data_dir = "weapon";

id: i32,
func_value: i32 = 0,
level: i32 = 1,
exp: i32 = 0,
breach: i32 = 0,
reson_level: i32 = 1,
role_id: ?i32 = null,

pub fn toProto(item: WeaponItem, incr_id: i32) pb.WeaponItem {
    return .{
        .Id = item.id,
        .IncrId = incr_id,
        .FuncValue = item.func_value,
        .WeaponLevel = item.level,
        .WeaponExp = item.exp,
        .WeaponBreach = item.breach,
        .WeaponResonLevel = item.reson_level,
        .RoleId = item.role_id orelse 0,
    };
}

pub fn addDefaults(gpa: Allocator, assets: *const Assets, map: *std.array_hash_map.Auto(i32, WeaponItem)) !void {
    for (assets.tables.weapon_conf.items) |info| {
        try map.put(gpa, @intCast(map.entries.len + 1), .{
            .id = info.ItemId,
            .func_value = 0,
            .level = 1,
            .exp = 0,
            .breach = 0,
            .reson_level = 1,
        });
    }
}

pub fn deinit(item: WeaponItem, gpa: Allocator) void {
    std.zon.parse.free(gpa, item);
}
