const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onLanguageSettingUpdateRequest(txn: *Transaction(pb.LanguageSettingUpdateRequest)) !void {
    try txn.respond(.{});
}