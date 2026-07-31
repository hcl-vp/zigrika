const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;

pub fn onLanguageSettingUpdateRequest(txn: *Transaction(pb.LanguageSettingUpdateRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onInputSettingRequest(txn: *Transaction(pb.InputSettingRequest)) !void {
    txn.respond(.{});
}

pub fn onInputSettingUpdateRequest(txn: *Transaction(pb.InputSettingUpdateRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}
