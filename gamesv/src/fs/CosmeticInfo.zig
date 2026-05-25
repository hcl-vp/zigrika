const CosmeticInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../data/Assets.zig");

const Allocator = std.mem.Allocator;

pub const data_path = "cosmetic_info";

pub const NormalItem = struct {
    id: i32,
    count: i32 = 1,
};

normal_items: []NormalItem = &.{},
role_skins: []i32 = &.{},
phantom_skins: []i32 = &.{},
fly_skins: []i32 = &.{},
weapon_skins: []i32 = &.{},
ornaments: []i32 = &.{},
viewed_ornaments: []i32 = &.{},

pub fn normalItemList(info: CosmeticInfo, arena: Allocator) !std.ArrayList(pb.NormalItem) {
    var list: std.ArrayList(pb.NormalItem) = .empty;
    try list.ensureTotalCapacity(arena, info.normal_items.len);
    for (info.normal_items) |item| {
        if (item.id == 0) continue;
        list.appendAssumeCapacity(.{ .Id = item.id, .Count = @max(item.count, 1), .ExpireTime = 0 });
    }
    return list;
}

pub fn intList(items: []const i32, arena: Allocator) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.ensureTotalCapacity(arena, items.len);
    for (items) |id| {
        if (id == 0) continue;
        list.appendAssumeCapacity(id);
    }
    return list;
}

pub fn has(items: []const i32, id: i32) bool {
    if (id == 0) return true;
    for (items) |item| {
        if (item == id) return true;
    }
    return false;
}

pub fn isEmpty(info: CosmeticInfo) bool {
    return info.normal_items.len == 0 and
        info.role_skins.len == 0 and
        info.phantom_skins.len == 0 and
        info.fly_skins.len == 0 and
        info.weapon_skins.len == 0 and
        info.ornaments.len == 0 and
        info.viewed_ornaments.len == 0;
}

pub fn addDefaults(cosmetics: *CosmeticInfo, gpa: Allocator, assets: *const Assets) !void {
    var normal_items: std.ArrayListUnmanaged(NormalItem) = .empty;
    var role_skins: std.ArrayListUnmanaged(i32) = .empty;
    var phantom_skins: std.ArrayListUnmanaged(i32) = .empty;
    var fly_skins: std.ArrayListUnmanaged(i32) = .empty;
    var weapon_skins: std.ArrayListUnmanaged(i32) = .empty;
    var ornaments: std.ArrayListUnmanaged(i32) = .empty;
    var viewed_ornaments: std.ArrayListUnmanaged(i32) = .empty;

    for (assets.tables.fly_skin_config.items) |info| {
        try fly_skins.append(gpa, info.Id);
        try phantom_skins.append(gpa, info.Id);
    }

    for (assets.tables.role_skin.items) |info| {
        try role_skins.append(gpa, info.Id);
        try phantom_skins.append(gpa, info.Id);
    }

    for (assets.tables.weapon_skin.items) |info| {
        if (info.HideInSkinView) continue;
        try weapon_skins.append(gpa, info.Id);
        try phantom_skins.append(gpa, info.Id);
    }

    for (assets.tables.ornament.items) |info| {
        if (info.HideInUi) continue;
        try ornaments.append(gpa, info.Id);
        try phantom_skins.append(gpa, info.Id);
        try viewed_ornaments.append(gpa, info.Id);
        for (info.ItemAccess) |id| {
            try normal_items.append(gpa, .{ .id = id });
            try normal_items.append(gpa, .{ .id = info.Id });
            try phantom_skins.append(gpa, id);
            try viewed_ornaments.append(gpa, id);
        }
    }

    cosmetics.normal_items = try normal_items.toOwnedSlice(gpa);
    cosmetics.role_skins = try role_skins.toOwnedSlice(gpa);
    cosmetics.phantom_skins = try phantom_skins.toOwnedSlice(gpa);
    cosmetics.fly_skins = try fly_skins.toOwnedSlice(gpa);
    cosmetics.weapon_skins = try weapon_skins.toOwnedSlice(gpa);
    cosmetics.ornaments = try ornaments.toOwnedSlice(gpa);
    cosmetics.viewed_ornaments = try viewed_ornaments.toOwnedSlice(gpa);
}

pub fn deinit(info: CosmeticInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
