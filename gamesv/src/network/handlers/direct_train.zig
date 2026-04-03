const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onDirectTrainGetPlayerIdRequest(txn: *Transaction(pb.DirectTrainGetPlayerIdRequest)) !void {
    try txn.respond(.{});
}