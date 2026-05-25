const CosmeticInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;

const Allocator = std.mem.Allocator;

pub const data_path = "cosmetic_info";

pub const NormalItem = struct {
    id: i32,
    count: i32 = 1,
};

const default_normal_items = [_]NormalItem{
    .{ .id = 851002 },   .{ .id = 852003 },   .{ .id = 852006 },   .{ .id = 852007 },
    .{ .id = 852008 },   .{ .id = 852009 },   .{ .id = 852010 },   .{ .id = 853001 },
    .{ .id = 853002 },   .{ .id = 853003 },   .{ .id = 853004 },   .{ .id = 853999 },
    .{ .id = 859307 },   .{ .id = 871001 },   .{ .id = 871002 },   .{ .id = 871003 },
    .{ .id = 871004 },   .{ .id = 871005 },   .{ .id = 871006 },   .{ .id = 80080001 },
    .{ .id = 80080002 }, .{ .id = 80080003 }, .{ .id = 80080004 }, .{ .id = 80080005 },
    .{ .id = 80080006 }, .{ .id = 80080007 }, .{ .id = 80080008 }, .{ .id = 80870001 },
    .{ .id = 80870004 }, .{ .id = 80870005 }, .{ .id = 80871001 }, .{ .id = 80871002 },
    .{ .id = 80871003 }, .{ .id = 80871004 },
};

const default_role_skins = [_]i32{
    81001102, 81001103, 81001104, 81001105, 81001106, 81001107, 81001108, 81001109,
    81001202, 81001203, 81001204, 81001205, 81001206, 81001207, 81001208, 81001209,
    81001210, 81001211, 81001301, 81001302, 81001303, 81001304, 81001305, 81001306,
    81001307, 81001308, 81001402, 81001403, 81001404, 81001405, 81001406, 81001407,
    81001408, 81001409, 81001410, 81001411, 81001412, 81001501, 81001502, 81001503,
    81001504, 81001505, 81001506, 81001507, 81001508, 81001509, 81001510, 81001511,
    81001601, 81001602, 81001603, 81001604, 81001605, 81001606, 81001607, 81001608,
    81011102, 81011107, 81011205, 81011209, 81011304, 81011406, 81011408, 81011501,
    81011502, 81011507, 81011604, 81011605,
};

const default_phantom_skins = [_]i32{
    851002,   852003,   852006,   852007,   852008,   852009,   852010,   853001,
    853002,   853003,   853004,   853999,   859307,   871001,   871002,   871003,
    871004,   871005,   871006,   80080001, 80080002, 80080003, 80080004, 80080005,
    80080006, 80080007, 80080008, 80870001, 80870004, 80870005, 80871001, 80871002,
    80871003, 80871004, 81001102, 81001103, 81001104, 81001105, 81001106, 81001107,
    81001108, 81001109, 81001202, 81001203, 81001204, 81001205, 81001206, 81001207,
    81001208, 81001209, 81001210, 81001211, 81001301, 81001302, 81001303, 81001304,
    81001305, 81001306, 81001307, 81001308, 81001402, 81001403, 81001404, 81001405,
    81001406, 81001407, 81001408, 81001409, 81001410, 81001411, 81001412, 81001501,
    81001502, 81001503, 81001504, 81001505, 81001506, 81001507, 81001508, 81001509,
    81001510, 81001511, 81001601, 81001602, 81001603, 81001604, 81001605, 81001606,
    81001607, 81001608, 81011102, 81011107, 81011205, 81011209, 81011304, 81011406,
    81011408, 81011501, 81011502, 81011507, 81011604, 81011605, 84000001, 84000002,
    84000003, 84100001, 84100002, 84100003, 84100004,
};

const default_fly_skins = [_]i32{ 84000001, 84000002, 84000003, 84100001, 84100002, 84100003, 84100004 };
const default_weapon_skins = [_]i32{ 80080001, 80080002, 80080003, 80080004, 80080005, 80080006, 80080007, 80080008 };
const default_ornaments = [_]i32{ 80870001, 80870004, 80870005, 80871001, 80871002, 80871003, 80871004 };
const default_viewed_ornaments = [_]i32{
    871001,   871002,   871003,   871004,   871005,   871006,   80870001,
    80870004, 80870005, 80871001, 80871002, 80871003, 80871004,
};

pub const default: CosmeticInfo = .{
    .normal_items = &default_normal_items,
    .role_skins = &default_role_skins,
    .phantom_skins = &default_phantom_skins,
    .fly_skins = &default_fly_skins,
    .weapon_skins = &default_weapon_skins,
    .ornaments = &default_ornaments,
    .viewed_ornaments = &default_viewed_ornaments,
};

normal_items: []const NormalItem = &.{},
role_skins: []const i32 = &.{},
phantom_skins: []const i32 = &.{},
fly_skins: []const i32 = &.{},
weapon_skins: []const i32 = &.{},
ornaments: []const i32 = &.{},
viewed_ornaments: []const i32 = &.{},

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

pub fn deinit(info: CosmeticInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
