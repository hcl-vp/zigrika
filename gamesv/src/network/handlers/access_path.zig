const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onAccessPathTimeServerConfigRequest(txn: *Transaction(pb.AccessPathTimeServerConfigRequest)) !void {
    txn.respond(.{});
}
