const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onHeartbeatRequest(txn: *Transaction(pb.HeartbeatRequest)) !void {
    txn.respond(.{});
}

pub fn onAllMsgRequest(txn: *Transaction(pb.AllMsgRequest)) !void {
    txn.respond(.{});
}

pub fn onBattlePassRequest(txn: *Transaction(pb.BattlePassRequest)) !void {
    txn.respond(.{ .BattlePass = .{ .InTimeRange = false } });
}
