const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onUpdateVoxelEnvRequest(txn: *Transaction(pb.UpdateVoxelEnvRequest)) !void {
    try txn.respond(.{ .ServerCaveMode = txn.message.ServerCaveMode });
}
