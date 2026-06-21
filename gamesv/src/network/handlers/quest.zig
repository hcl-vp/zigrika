const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onQuestReviewDataRequest(txn: *Transaction(pb.QuestReviewDataRequest)) !void {
    txn.respond(.{});
}

pub fn onSetFocusModeDeterConditionRequest(txn: *Transaction(pb.SetFocusModeDeterConditionRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}
