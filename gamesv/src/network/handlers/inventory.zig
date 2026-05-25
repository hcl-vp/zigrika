const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const PlayerCosmeticComponent = @import("../../logic/component/player/PlayerCosmeticComponent.zig");

pub fn onNormalItemRequest(
    txn: *Transaction(pb.NormalItemRequest),
    alloc: mem.Alloc,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    txn.respond(.{ .NormalItemList = try cosmetic_comp.info.normalItemList(alloc.arena) });
}
