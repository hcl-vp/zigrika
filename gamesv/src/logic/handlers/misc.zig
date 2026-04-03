const pb = @import("proto").pb;
const std = @import("std");
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");

pub fn pushData(_: EventQueue.Dequeue(.push_data), conn: *Connection, alloc: mem.Alloc, assets: *const Assets, role_comp: *PlayerRoleComponent) !void {
    var role_notify: pb.RoleConfigInfoNotify = .default;
    var iterator = role_comp.role_map.iterator();

    while (iterator.next()) |role| {
        try role_notify.RoleConfigs.append(alloc.arena, pb.RoleConfigInfo{ .RoleId = role.key_ptr.*, .SkillBranch = 0 });
    }

    try conn.push(role_notify, alloc.arena);
    var notify: pb.FuncOpenNotify = .default;

    for (assets.tables.function_condition.items) |config| {
        try notify.Func.append(alloc.arena, .{
            .Id = config.FunctionId,
            .Flag = 2,
        });
    }

    try conn.push(notify, alloc.arena);

    var open_pkg: std.ArrayList(i32) = .empty;
    defer open_pkg.deinit(alloc.gpa);
    for (0..8) |i| {
        try open_pkg.append(alloc.gpa, @intCast(i));
    }
    try conn.push(pb.ItemPkgOpenNotify{
        .OpenPkg = open_pkg,
    }, alloc.arena);

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
    }, alloc.arena);

    try conn.push(pb.AdviceSettingNotify{ .IsShow = false }, alloc.arena);
    try conn.push(pb.ControlInfoNotify{}, alloc.arena);
    try conn.push(pb.LevelPlayInfoNotify{}, alloc.arena);
    try conn.push(pb.PlayerVarNotify{}, alloc.arena);
    try conn.push(pb.RoguelikeCurrencyNotify{}, alloc.arena);
    try conn.push(pb.PassiveSkillNotify{}, alloc.arena);
    try conn.push(pb.MailInfosNotify{}, alloc.arena);
    try conn.push(pb.SettingNotify{}, alloc.arena);
    try conn.push(pb.MoonChasingTrackMoonHandbookRewardNotify{}, alloc.arena);
    try conn.push(pb.MoonChasingTargetGetCountNotify{}, alloc.arena);
    try conn.push(pb.InstDataNotify{}, alloc.arena);
    try conn.push(pb.SilenceNpcNotify{}, alloc.arena);
}
