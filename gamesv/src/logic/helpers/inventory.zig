const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");

pub fn addDefaultProgressionItems(info: *InventoryInfo, gpa: std.mem.Allocator, assets: *const Assets) !void {
    for (assets.tables.skill_tree.items) |entry| {
        try ensureConsumeItems(info, gpa, entry.Consume);
    }

    for (assets.tables.weapon_exp_item.items) |entry| {
        try ensureNormalItem(info, gpa, entry.Id, 777);
    }

    for (assets.tables.weapon_breach.items) |entry| {
        try ensureConsumeItems(info, gpa, entry.Consume);
    }

    for (assets.tables.role_breach.items) |entry| {
        try ensureConsumeItems(info, gpa, entry.BreachConsume);
    }

    for (assets.tables.skill_level.items) |entry| {
        try ensureConsumeItems(info, gpa, entry.Consume);
    }

    for (assets.tables.motor_tech_tree.items) |entry| {
        try ensureNormalItem(info, gpa, entry.TpItemId, 777);
    }
}

fn ensureConsumeItems(info: *InventoryInfo, gpa: std.mem.Allocator, consume_map: anytype) !void {
    var iterator = consume_map.map.iterator();
    while (iterator.next()) |consume| {
        try ensureNormalItem(info, gpa, consume.key_ptr.*, 777);
    }
}

fn ensureNormalItem(info: *InventoryInfo, gpa: std.mem.Allocator, id: i32, count: i32) !void {
    if (id == 0 or count <= 0 or info.normalItemCount(id) >= count) return;

    for (info.normal_items) |*item| {
        if (item.id == id) {
            item.count = count;
            return;
        }
    }

    try InventoryInfo.addNormalItem(info, gpa, id, count);
}
