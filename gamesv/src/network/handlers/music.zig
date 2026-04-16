const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onGetMusicInfoRequest(txn: *Transaction(pb.GetMusicInfoRequest)) !void {
    txn.respond(.{});
}
