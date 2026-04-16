const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onMailBindInfoRequest(txn: *Transaction(pb.MailBindInfoRequest)) !void {
    txn.respond(.{});
}
