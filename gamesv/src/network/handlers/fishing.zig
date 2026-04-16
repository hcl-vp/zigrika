const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onFishingDataRequest(txn: *Transaction(pb.FishingDataRequest)) !void {
    txn.respond(.{ .FishingData = .default });
}
