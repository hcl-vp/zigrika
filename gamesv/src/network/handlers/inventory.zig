const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const PlayerInventoryComponent = @import("../../logic/component/player/PlayerInventoryComponent.zig");

pub fn onNormalItemRequest(
    txn: *Transaction(pb.NormalItemRequest),
    alloc: mem.Alloc,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    txn.respond(.{ .NormalItemList = try inventory_comp.info.normalItemList(alloc.arena) });
}
