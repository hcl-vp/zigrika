const std = @import("std");
const Io = std.Io;
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onHeartbeatRequest(txn: *Transaction(pb.HeartbeatRequest)) !void {
    txn.respond(.{});
}

pub fn onTimeCheckRequest(txn: *Transaction(pb.TimeCheckRequest), io: Io) !void {
    const rtc: Io.Clock = .real;
    const now_ms = rtc.now(io).toMilliseconds();
    txn.respond(.{
        .ClientTime = txn.message.ClientTime,
        .ServerTime = now_ms,
        .ServerCombatTime = now_ms,
        .ServerStopTime = now_ms,
        .ServerFlowTimestamp = now_ms,
    });
}

pub fn onAllMsgRequest(txn: *Transaction(pb.AllMsgRequest)) !void {
    txn.respond(.{});
}

pub fn onBattlePassRequest(txn: *Transaction(pb.BattlePassRequest)) !void {
    txn.respond(.{ .BattlePass = .{ .InTimeRange = false } });
}

pub fn onGachaInfoRequest(txn: *Transaction(pb.GachaInfoRequest)) !void {
    txn.respond(.{});
}
