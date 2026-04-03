const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onTowerRequest(txn: *Transaction(pb.TowerRequest)) !void {
    try txn.respond(.{ .TowerInfo = .{} });
}