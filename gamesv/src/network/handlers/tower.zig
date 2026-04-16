const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onTowerRequest(txn: *Transaction(pb.TowerRequest)) !void {
    txn.respond(.{ .TowerInfo = .{} });
}

pub fn onTowerSeasonUpdateRequest(txn: *Transaction(pb.TowerSeasonUpdateRequest)) !void {
    txn.respond(.{
        .Towers = .{ .TowerInfo = .{} },
        .MaxUnlockDifficulty = 0,
    });
}
