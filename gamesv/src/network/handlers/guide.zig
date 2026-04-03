const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onGuideInfoRequest(txn: *Transaction(pb.GuideInfoRequest)) !void {
    try txn.respond(.{});
}
