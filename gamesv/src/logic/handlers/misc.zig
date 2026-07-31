const pb = @import("proto").pb;
const std = @import("std");
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");
const PlayerCosmeticComponent = @import("../component/player/PlayerCosmeticComponent.zig");
const phantom_projector = @import("../helpers/phantom_projector.zig");

pub fn pushData(
    _: EventQueue.Dequeue(.push_data),
    conn: *Connection,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    var role_notify: pb.RoleConfigInfoNotify = .default;
    var iterator = role_comp.role_map.iterator();

    while (iterator.next()) |role| {
        try role_notify.RoleConfigs.append(alloc.arena, pb.RoleConfigInfo{ .RoleId = role.key_ptr.*, .SkillBranch = 0 });
    }

    try conn.push(role_notify);
    var notify: pb.FuncOpenNotify = .default;

    for (assets.tables.function_condition.items) |config| {
        try notify.Func.append(alloc.arena, .{
            .Id = config.FunctionId,
            .Flag = 2,
        });
    }

    try conn.push(notify);

    try conn.push(pb.AdviceSettingNotify{ .IsShow = false });
    try conn.push(pb.ControlInfoNotify{});
    try conn.push(pb.InstDataNotify{});
    try conn.push(try buildCalabashMsgNotify(alloc, assets));
    try conn.push(try phantom_projector.buildUnlockNotify(alloc, assets, echo_comp.calabash_info, cosmetic_comp.info));
    try conn.push(pb.CalabashLevelsRewardNotify{
        .RewardedLevels = try intList(echo_comp.calabash_info.rewarded_levels, alloc.arena),
    });

    var open_pkg: std.ArrayList(i32) = .empty;
    defer open_pkg.deinit(alloc.gpa);
    for (0..8) |i| {
        try open_pkg.append(alloc.gpa, @intCast(i));
    }
    try conn.push(pb.ItemPkgOpenNotify{
        .OpenPkg = open_pkg,
    });

    try conn.push(pb.BuffItemNotify{});

    var update_info: std.ArrayList(pb.EnergyInfo) = .empty;
    defer update_info.deinit(alloc.gpa);
    try update_info.append(alloc.gpa, .{
        .EnergyCount = 240,
        .LastRenewEnergyTime = 0,
        .EnergyType = 5,
    });
    try update_info.append(alloc.gpa, .{
        .EnergyCount = 480,
        .LastRenewEnergyTime = 0,
        .EnergyType = 6,
    });
    try conn.push(pb.EnergyUpdateNotify{
        .UpdateInfo = update_info,
    });
    try conn.push(pb.LevelPlayInfoNotify{});
    try conn.push(pb.PlayerVarNotify{});
    try conn.push(pb.RoguelikeCurrencyNotify{});
    try conn.push(pb.PassiveSkillNotify{});
    try conn.push(pb.MailInfosNotify{});
    try conn.push(pb.SettingNotify{});
    try conn.push(pb.MoonChasingTrackMoonHandbookRewardNotify{});
    try conn.push(pb.MoonChasingTargetGetCountNotify{});
    try conn.push(pb.SilenceNpcNotify{});
}

fn buildCalabashMsgNotify(alloc: mem.Alloc, assets: *const Assets) !pb.CalabashMsgNotify {
    var max_level: i32 = 0;
    var max_exp: i32 = 0;
    var level_condition: i32 = 0;
    var levels: std.ArrayList(i32) = .empty;
    var catch_gain: std.ArrayList(pb.MapEntry(i32, i32)) = .empty;

    for (assets.tables.calabash_level.items) |level| {
        try levels.append(alloc.arena, level.Level);
        try catch_gain.append(alloc.arena, .{ .key = level.Level, .value = level.TempCatchGain });
        if (level.Level > max_level) {
            max_level = level.Level;
            max_exp = level.LevelUpExp;
            level_condition = level.LevelUpCondition;
        }
    }

    var develop_infos: std.ArrayList(pb.CalabashDevelopInfo) = .empty;
    for (assets.tables.calabash_develop_reward.items) |reward| {
        if (!reward.IsShow) continue;
        var conditions: std.ArrayList(pb.CalabashDevelopConditionState) = .empty;
        for (reward.DevelopCondition) |condition_id| {
            try conditions.append(alloc.arena, .{ .ConditionId = condition_id, .Rewarded = true });
        }
        try develop_infos.append(alloc.arena, .{
            .MonsterId = reward.MonsterId,
            .UnlockConditions = conditions,
        });
    }

    return .{
        .CalabashMsg = .{
            .Level = max_level,
            .Exp = max_exp,
            .UnlockedLevels = levels,
            .UnlockedDevelopRewards = develop_infos,
        },
        .CalabashCfg = .{
            .LevelUpExp = max_exp,
            .LevelUpCondition = level_condition,
            .CatchGain = catch_gain,
        },
    };
}

fn intList(values: []const i32, arena: std.mem.Allocator) !std.ArrayList(i32) {
    var list: std.ArrayList(i32) = .empty;
    try list.appendSlice(arena, values);
    return list;
}
