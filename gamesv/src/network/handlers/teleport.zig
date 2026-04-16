const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");

pub fn onTeleportDataRequest(
    txn: *Transaction(pb.TeleportDataRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var ids: std.ArrayList(i32) = .empty;
    for (assets.tables.teleporter.items) |tp| {
        try ids.append(alloc.arena, tp.Id);
    }
    txn.respond(.{ .ErrorCode = .Success, .Ids = ids });
}
