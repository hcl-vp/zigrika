const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onTeleportDataRequest(txn: *Transaction(pb.TeleportDataRequest)) !void {
    try txn.respond(.{});
}