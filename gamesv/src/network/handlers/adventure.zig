const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;

pub fn onAdventureManualRequest(txn: *Transaction(pb.AdventureManualRequest)) !void {
    txn.respond(.{ .AdventureManualData = .{} });
}
pub fn onAdventureManualDataRequest(txn: *Transaction(pb.AdventureManualDataRequest)) !void {
    txn.respond(.{ .AdventureManualData = .{} });
}
pub fn onWeeklyFrameworkInfoRequest(
    txn: *Transaction(pb.WeeklyFrameworkInfoRequest),
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const rtc: std.Io.Clock = .real;
    const now_ms = rtc.now(io).toMilliseconds();
    var score_tasks: std.ArrayList(i32) = .empty;
    try score_tasks.appendSlice(alloc.arena, &.{ 1000, 2000, 3000, 4000, 5000, 6000 });
    txn.respond(.{
        .FrameworkInfo = .{
            .ConfigId = 1,
            .BeginTime = now_ms,
            .EndTime = now_ms + 604800000,
            .ScoreTasks = score_tasks,
            .WorldLevel = 1,
        },
    });
}
