const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onLoadingConfigRequest(txn: *Transaction(pb.LoadingConfigRequest)) !void {
    txn.respond(.{});
}
