const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onMapTraceInfoRequest(txn: *Transaction(pb.MapTraceInfoRequest)) !void {
    try txn.respond(.{});
}

pub fn onMapUnlockFieldInfoRequest(txn: *Transaction(pb.MapUnlockFieldInfoRequest)) !void {
    try txn.respond(.{});
}