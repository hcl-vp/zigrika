const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../../handlers.zig").Transaction;
const mem = @import("../../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../../data/Assets.zig");
const PlayerEchoComponent = @import("../../../logic/component/player/PlayerEchoComponent.zig");

pub fn onCalabashLevelRewardRequest(
    txn: *Transaction(pb.CalabashLevelRewardRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
) !void {
    const level = txn.message.Level;
    _ = assets.tables.calabash_level.getDataById(level) orelse {
        txn.respond(.{ .ErrorCode = .ErrCalabashLevelConfig });
        return;
    };
    if (level > 0 and !containsInt(echo_comp.calabash_info.rewarded_levels, level)) {
        try appendRewardedLevel(alloc.gpa, echo_comp, level);
    }

    try PlayerEchoComponent.saveCalabash(alloc.gpa, fs, echo_comp.player_id, echo_comp.calabash_info);

    const rewarded_levels = try intList(echo_comp.calabash_info.rewarded_levels, alloc.arena);
    try txn.conn.push(pb.CalabashLevelsRewardNotify{ .RewardedLevels = rewarded_levels }, alloc.arena);
    txn.respond(.{ .ErrorCode = .Success });
}

fn appendRewardedLevel(
    gpa: std.mem.Allocator,
    echo_comp: *PlayerEchoComponent,
    level: i32,
) !void {
    const levels = try gpa.alloc(i32, echo_comp.calabash_info.rewarded_levels.len + 1);
    @memcpy(levels[0..echo_comp.calabash_info.rewarded_levels.len], echo_comp.calabash_info.rewarded_levels);
    levels[echo_comp.calabash_info.rewarded_levels.len] = level;

    if (echo_comp.calabash_info.rewarded_levels.len != 0) {
        gpa.free(echo_comp.calabash_info.rewarded_levels);
    }
    echo_comp.calabash_info.rewarded_levels = levels;
}

fn containsInt(values: []const i32, needle: i32) bool {
    for (values) |value| {
        if (value == needle) return true;
    }
    return false;
}

fn intList(values: []const i32, arena: std.mem.Allocator) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.ensureTotalCapacity(arena, values.len);
    for (values) |value| list.appendAssumeCapacity(value);
    return list;
}
