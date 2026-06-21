const MotorInfo = @This();
const std = @import("std");
const Assets = @import("../data/Assets.zig");

const Allocator = std.mem.Allocator;

pub const data_path = "motor_info";

pub const TechNode = struct {
    id: i32,
    tree_type: i32,
    level: i32,
    unlocked: bool,
    current: i32,
    target: i32,
};

pub const TaskNode = struct {
    id: i32,
    tree_type: i32,
    type: i32,
    current: i32,
    target: i32,
    rewarded: i32,
    wait_reward: i32,
    max_reward: i32,
};

pub const Preset = struct {
    id: i32,
    name: []const u8,
    skin: i32,
    stickers: []i32,
    decorations: []i32,
    frame: i32,
};

level: i32 = 1,
exp: i32 = 0,
rewarded_max_level: i32 = 0,
tree_in_use: i32 = 0,
daily_exp_gain: i32 = 0,
daily_exp_limit: i32 = 0,
tech_nodes: []TechNode = &.{},
task_nodes: []TaskNode = &.{},
owned_skins: []i32 = &.{},
owned_stickers: []i32 = &.{},
owned_decorations: []i32 = &.{},
owned_frames: []i32 = &.{},
equipped_skin: i32 = 0,
equipped_frame: i32 = 0,
equipped_stickers: []i32 = &.{},
equipped_decorations: []i32 = &.{},
presets: []Preset = &.{},
next_preset_id: i32 = 1,

pub fn isEmpty(info: MotorInfo) bool {
    return info.tech_nodes.len == 0 and
        info.task_nodes.len == 0 and
        info.owned_skins.len == 0 and
        info.owned_stickers.len == 0 and
        info.owned_decorations.len == 0 and
        info.owned_frames.len == 0;
}

fn appendId(list: *std.ArrayListUnmanaged(i32), gpa: Allocator, id: i32) !void {
    if (id == 0) return;
    for (list.items) |item| {
        if (item == id) return;
    }
    try list.append(gpa, id);
}

fn zeroList(gpa: Allocator, count: usize) ![]i32 {
    const items = try gpa.alloc(i32, count);
    @memset(items, 0);
    return items;
}

pub fn addDefaults(info: *MotorInfo, gpa: Allocator, assets: *const Assets) !void {
    var tech_nodes: std.ArrayListUnmanaged(TechNode) = .empty;
    var task_nodes: std.ArrayListUnmanaged(TaskNode) = .empty;
    var owned_skins: std.ArrayListUnmanaged(i32) = .empty;
    var owned_stickers: std.ArrayListUnmanaged(i32) = .empty;
    var owned_decorations: std.ArrayListUnmanaged(i32) = .empty;
    var owned_frames: std.ArrayListUnmanaged(i32) = .empty;

    for (assets.tables.motor_lvl.items) |lvl| {
        if (lvl.Level > info.level) {
            info.level = lvl.Level;
            info.exp = lvl.Exp;
        }
    }

    info.tree_in_use = if (assets.tables.motor_tech_tree.items.len == 0)
        0
    else
        assets.tables.motor_tech_tree.items[0].Id;

    for (assets.tables.motor_tech.items) |tech| {
        const level: i32 = @intCast(@min(@as(usize, @intCast(@max(tech.InitLevel, 0))), tech.TechLv.len));
        try tech_nodes.append(gpa, .{
            .id = tech.Id,
            .tree_type = tech.TreeType,
            .level = level,
            .unlocked = true,
            .current = level,
            .target = @intCast(tech.TechLv.len),
        });
    }

    for (assets.tables.motor_task.items) |task| {
        try task_nodes.append(gpa, .{
            .id = task.Id,
            .tree_type = task.TreeType,
            .type = 1,
            .current = 1,
            .target = 1,
            .rewarded = @max(task.RewardTpCount, 1),
            .wait_reward = 0,
            .max_reward = @max(task.RewardTpCount, 1),
        });
    }

    for (assets.tables.motor_skin.items) |skin| {
        try appendId(&owned_skins, gpa, skin.Id);
        if (skin.DefaultFlag) info.equipped_skin = skin.Id;
    }

    for (assets.tables.motor_load_project.items) |preset| {
        for (preset.Sticker) |id| {
            try appendId(&owned_stickers, gpa, id);
        }
    }

    for (assets.tables.motor_general_preview.items) |preview| {
        for (preview.Sticker) |id| {
            try appendId(&owned_stickers, gpa, id);
        }
    }

    for (assets.tables.motor_decal_ip.items) |ip| {
        for (ip.IpStickerList) |id| {
            try appendId(&owned_stickers, gpa, id);
        }
    }

    for (assets.tables.motor_linkage_ip.items) |ip| {
        for (ip.IpStickerList) |id| {
            try appendId(&owned_stickers, gpa, id);
        }
    }

    for (assets.tables.motor_decorations.items) |decoration| {
        try appendId(&owned_decorations, gpa, decoration.Id);
    }

    for (assets.tables.motor_frame.items) |frame| {
        try appendId(&owned_frames, gpa, frame.Id);
        if (frame.DefaultFlag) info.equipped_frame = frame.Id;
    }

    if (info.equipped_skin == 0 and owned_skins.items.len != 0) info.equipped_skin = owned_skins.items[0];
    if (info.equipped_frame == 0 and owned_frames.items.len != 0) info.equipped_frame = owned_frames.items[0];

    info.tech_nodes = try tech_nodes.toOwnedSlice(gpa);
    info.task_nodes = try task_nodes.toOwnedSlice(gpa);
    info.owned_skins = try owned_skins.toOwnedSlice(gpa);
    info.owned_stickers = try owned_stickers.toOwnedSlice(gpa);
    info.owned_decorations = try owned_decorations.toOwnedSlice(gpa);
    info.owned_frames = try owned_frames.toOwnedSlice(gpa);
    info.equipped_stickers = try zeroList(gpa, assets.tables.motor_sticker_part.items.len);
    info.equipped_decorations = try zeroList(gpa, assets.tables.motor_decorations_part.items.len);
}

pub fn deinit(info: MotorInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
