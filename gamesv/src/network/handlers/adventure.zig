const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onAdventureManualRequest(txn: *Transaction(pb.AdventureManualRequest)) !void {
    txn.respond(.{ .AdventureManualData = .{} });
}
pub fn onAdventureManualDataRequest(txn: *Transaction(pb.AdventureManualDataRequest)) !void {
    txn.respond(.{ .AdventureManualData = .{} });
}
