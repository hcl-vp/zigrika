const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onLordGymInfoRequest(txn: *Transaction(pb.LordGymInfoRequest)) !void {
    txn.respond(.{});
}
