const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");

pub fn addDefaultProgressionItems(info: *InventoryInfo, gpa: std.mem.Allocator, assets: *const Assets) !void {
    try addDefaultGachaItems(info, gpa, assets);

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

    try addDefaultEchoMaterials(info, gpa, assets);
}

fn addDefaultEchoMaterials(info: *InventoryInfo, gpa: std.mem.Allocator, assets: *const Assets) !void {
    for (assets.tables.phantom_exp_item.items) |entry| {
        try ensureNormalItem(info, gpa, entry.ItemId, 777);
    }

    for (assets.tables.phantom_quality.items) |entry| {
        var iterator = entry.IdentifyCost.map.iterator();
        while (iterator.next()) |consume| {
            try ensureNormalItem(info, gpa, consume.key_ptr.*, 777);
        }
    }

    for (assets.tables.phantom_rarity.items) |entry| {
        var iterator = entry.PolishCost.map.iterator();
        while (iterator.next()) |consume| {
            try ensureNormalItem(info, gpa, consume.key_ptr.*, 777);
        }
    }

    for (assets.tables.phantom_vice_polish_config.items) |entry| {
        var iterator = entry.Cost.map.iterator();
        while (iterator.next()) |consume| {
            try ensureNormalItem(info, gpa, consume.key_ptr.*, 777);
        }
    }
}

fn addDefaultGachaItems(info: *InventoryInfo, gpa: std.mem.Allocator, assets: *const Assets) !void {
    for (assets.tables.gacha.items) |gacha| {
        const pool_id = firstGachaPoolId(assets, gacha.Id);
        const view = assets.tables.gacha_view_info.getDataById(pool_id) orelse continue;
        try ensureNormalItem(info, gpa, gachaCurrencyItemId(gacha.Id, view.Type), 777);
    }
}

fn firstGachaPoolId(assets: *const Assets, gacha_id: i32) i32 {
    var best_id: i32 = 0;
    var best_sort: i32 = std.math.maxInt(i32);
    for (assets.tables.gacha_pool.items) |pool| {
        if (pool.GachaId != gacha_id) continue;
        if (pool.Sort < best_sort or (pool.Sort == best_sort and (best_id == 0 or pool.Id < best_id))) {
            best_id = pool.Id;
            best_sort = pool.Sort;
        }
    }
    return best_id;
}

pub fn gachaCurrencyItemId(gacha_id: i32, view_type: i32) i32 {
    return switch (view_type) {
        1, 4, 5 => 50001,
        2, 7, 9 => 50002,
        3, 8, 10 => 50005,
        11 => 50007,
        12 => 50008,
        6 => if (gacha_id == 5) 50006 else 50001,
        else => 50001,
    };
}

fn ensureConsumeItems(info: *InventoryInfo, gpa: std.mem.Allocator, consume_map: anytype) !void {
    var iterator = consume_map.map.iterator();
    while (iterator.next()) |consume| {
        try ensureNormalItem(info, gpa, consume.key_ptr.*, 777);
    }
}

fn ensureNormalItem(info: *InventoryInfo, gpa: std.mem.Allocator, id: i32, count: i32) !void {
    if (isPlayerCurrency(id) or count <= 0 or info.normalItemCount(id) >= count) return;

    for (info.normal_items) |*item| {
        if (item.id == id) {
            item.count = count;
            return;
        }
    }

    try InventoryInfo.addNormalItem(info, gpa, id, count);
}

fn isPlayerCurrency(id: i32) bool {
    return id >= 1 and id <= 6;
}
