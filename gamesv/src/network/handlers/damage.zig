const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;

pub fn DamageExecuteRequest(
    txn: *dispatch.CombatRequestTxn(.DamageExecuteRequest),
    assets: *const Assets,
) !void {
    const request: pb.DamageExecuteRequest = txn.payload;
    const damage = assets.tables.damage.getDataById(request.DamageId) orelse {
        txn.respond(.{ .ErrorCode = .ErrConfDamageNotFound });
        return;
    };

    txn.respond(.{
        .ErrorCode = .Success,
        .Damage = 1,
        .ElementType = damage.Element,
    });
}
