const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");

pub fn addDefaultProgressionItems(info: *InventoryInfo, gpa: std.mem.Allocator, assets: *const Assets) !void {
    for (assets.tables.skill_tree.items) |entry| {
        var iterator = entry.Consume.map.iterator();
        while (iterator.next()) |consume| {
            try ensureNormalItem(info, gpa, consume.key_ptr.*, 9999);
        }
    }

    for (assets.tables.weapon_exp_item.items) |entry| {
        try ensureNormalItem(info, gpa, entry.Id, 9999);
    }

    for (assets.tables.weapon_breach.items) |entry| {
        var iterator = entry.Consume.map.iterator();
        while (iterator.next()) |consume| {
            try ensureNormalItem(info, gpa, consume.key_ptr.*, 9999);
        }
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
