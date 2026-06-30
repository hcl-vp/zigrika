const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EchoInfo = @import("../../fs/EchoInfo.zig");
const CosmeticInfo = @import("../../fs/CosmeticInfo.zig");

pub const slot_count = 8;

pub fn buildUnlockNotify(
    alloc: mem.Alloc,
    assets: *const Assets,
    calabash_info: EchoInfo.CalabashInfo,
    cosmetic_info: CosmeticInfo,
) !pb.PhantomInteractionUnlockNotify {
    return .{
        .UnlockIllustratedPhantoms = try unlockList(alloc, assets, calabash_info, cosmetic_info),
        .EquipedMonsterIds = try equippedMonsterList(alloc.arena, assets, calabash_info),
    };
}

pub fn equippedMonsterList(
    arena: std.mem.Allocator,
    assets: *const Assets,
    calabash_info: EchoInfo.CalabashInfo,
) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.ensureTotalCapacity(arena, slot_count);

    for (0..slot_count) |index| {
        const monster_id = if (index < calabash_info.projector_monster_ids.len)
            calabash_info.projector_monster_ids[index]
        else
            0;
        list.appendAssumeCapacity(if (monster_id == 0 or isUnlockedMonster(assets, monster_id)) monster_id else 0);
    }

    return list;
}

pub fn replaceEquippedMonsters(
    gpa: std.mem.Allocator,
    calabash_info: *EchoInfo.CalabashInfo,
    monster_ids: []const i32,
) !void {
    var ids = try gpa.alloc(i32, slot_count);
    errdefer gpa.free(ids);

    for (0..slot_count) |index| {
        ids[index] = if (index < monster_ids.len) monster_ids[index] else 0;
    }

    if (calabash_info.projector_monster_ids.len != 0) gpa.free(calabash_info.projector_monster_ids);
    calabash_info.projector_monster_ids = ids;
}

pub fn setEquippedSkin(
    gpa: std.mem.Allocator,
    calabash_info: *EchoInfo.CalabashInfo,
    monster_id: i32,
    skin_id: i32,
) !void {
    var count: usize = 0;
    for (calabash_info.projector_skins) |entry| {
        if (entry.monster_id != monster_id) count += 1;
    }
    if (skin_id != 0) count += 1;

    const skins = try gpa.alloc(EchoInfo.ProjectorSkin, count);
    errdefer gpa.free(skins);

    var index: usize = 0;
    for (calabash_info.projector_skins) |entry| {
        if (entry.monster_id == monster_id) continue;
        skins[index] = entry;
        index += 1;
    }
    if (skin_id != 0) {
        skins[index] = .{ .monster_id = monster_id, .skin_id = skin_id };
    }

    if (calabash_info.projector_skins.len != 0) gpa.free(calabash_info.projector_skins);
    calabash_info.projector_skins = skins;
}

pub fn isUnlockedMonster(assets: *const Assets, monster_id: i32) bool {
    const reward = assets.tables.calabash_develop_reward.getDataById(monster_id) orelse return false;
    return reward.IsShow and reward.AllowVision and phantomItemByMonsterId(assets, monster_id) != null;
}

pub fn isValidSkin(assets: *const Assets, cosmetic_info: CosmeticInfo, monster_id: i32, skin_id: i32) bool {
    if (skin_id == 0) return true;
    const skin = assets.tables.phantom_item.getDataById(skin_id) orelse return false;
    return skin.ParentMonsterId == monster_id and CosmeticInfo.has(cosmetic_info.phantom_skins, skin_id);
}

pub fn displayedPhantomItem(
    assets: *const Assets,
    calabash_info: EchoInfo.CalabashInfo,
    monster_id: i32,
) ?Assets.DataTables.PhantomItem {
    const base_item = phantomItemByMonsterId(assets, monster_id) orelse return null;
    for (calabash_info.projector_skins) |entry| {
        if (entry.monster_id != monster_id or entry.skin_id == 0) continue;
        const skin_item = assets.tables.phantom_item.getDataById(entry.skin_id) orelse return base_item;
        if (skin_item.ParentMonsterId == monster_id) return skin_item;
    }
    return base_item;
}

fn unlockList(
    alloc: mem.Alloc,
    assets: *const Assets,
    calabash_info: EchoInfo.CalabashInfo,
    cosmetic_info: CosmeticInfo,
) !std.ArrayList(pb.UnlockIllustratedPhantom) {
    var list: std.ArrayList(pb.UnlockIllustratedPhantom) = .empty;
    try list.ensureTotalCapacity(alloc.arena, assets.tables.calabash_develop_reward.items.len);

    for (assets.tables.calabash_develop_reward.items) |reward| {
        if (!reward.IsShow or !reward.AllowVision or phantomItemByMonsterId(assets, reward.MonsterId) == null) continue;
        list.appendAssumeCapacity(.{
            .MonsterId = reward.MonsterId,
            .SkinIds = try skinIdList(alloc, assets, cosmetic_info, reward.MonsterId),
            .EqupiedSkin = equippedSkin(calabash_info, cosmetic_info, assets, reward.MonsterId),
            .IsSpecial = reward.IsWorldInteractable,
        });
    }

    return list;
}

fn skinIdList(
    alloc: mem.Alloc,
    assets: *const Assets,
    cosmetic_info: CosmeticInfo,
    monster_id: i32,
) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    for (cosmetic_info.phantom_skins) |skin_id| {
        const skin = assets.tables.phantom_item.getDataById(skin_id) orelse continue;
        if (skin.ParentMonsterId == monster_id) try list.append(alloc.arena, skin_id);
    }
    return list;
}

fn equippedSkin(
    calabash_info: EchoInfo.CalabashInfo,
    cosmetic_info: CosmeticInfo,
    assets: *const Assets,
    monster_id: i32,
) i32 {
    for (calabash_info.projector_skins) |entry| {
        if (entry.monster_id == monster_id and isValidSkin(assets, cosmetic_info, monster_id, entry.skin_id)) {
            return entry.skin_id;
        }
    }
    return 0;
}

fn phantomItemByMonsterId(assets: *const Assets, monster_id: i32) ?Assets.DataTables.PhantomItem {
    for (assets.tables.phantom_item.items) |item| {
        if (item.MonsterId == monster_id) return item;
    }
    return null;
}
