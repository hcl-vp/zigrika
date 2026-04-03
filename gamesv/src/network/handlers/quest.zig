const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onQuestReviewDataRequest(txn: *Transaction(pb.QuestReviewDataRequest)) !void {
    try txn.respond(.{});
}
