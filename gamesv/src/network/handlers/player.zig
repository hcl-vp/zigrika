const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onHeartbeatRequest(txn: *Transaction(pb.HeartbeatRequest)) !void {
    try txn.respond(.{});
}

pub fn onTimeCheckRequest(txn: *Transaction(pb.TimeCheckRequest)) !void {
    try txn.respond(.{
        .ClientTime = txn.message.ClientTime,
        .ServerTime = txn.message.ClientTime,
        .ServerCombatTime = txn.message.ClientTime,
        .ServerStopTime = txn.message.ClientTime,
        .ServerFlowTimestamp = txn.message.ClientTime,
    });
}

pub fn onAllMsgRequest(txn: *Transaction(pb.AllMsgRequest)) !void {
    try txn.respond(.{});
}

pub fn onBattlePassRequest(txn: *Transaction(pb.BattlePassRequest)) !void {
    try txn.respond(.{ .BattlePass = .{ .InTimeRange = false } });
}

pub fn onGachaInfoRequest(txn: *Transaction(pb.GachaInfoRequest)) !void {
    try txn.respond(.{});
}
