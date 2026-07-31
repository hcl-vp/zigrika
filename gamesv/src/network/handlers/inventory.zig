const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const PlayerBasicComponent = @import("../../logic/component/player/PlayerBasicComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const PlayerInventoryComponent = @import("../../logic/component/player/PlayerInventoryComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");

pub fn onNormalItemRequest(
    txn: *Transaction(pb.NormalItemRequest),
    alloc: mem.Alloc,
    basic_comp: *const PlayerBasicComponent,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    var normal_items = try inventory_comp.info.normalItemList(alloc.arena);
    try appendNormalItem(&normal_items, alloc.arena, 2, basic_comp.info.attributes.coin);
    txn.respond(.{ .NormalItemList = normal_items });
}

fn appendNormalItem(list: *std.ArrayList(pb.NormalItem), arena: std.mem.Allocator, id: i32, count: i32) !void {
    if (count <= 0) return;

    for (list.items) |*item| {
        if (item.Id != id) continue;
        item.Count = count;
        return;
    }

    try list.append(arena, .{ .Id = id, .Count = count, .ExpireTime = 0 });
}

pub fn onItemLockRequest(
    txn: *Transaction(pb.ItemLockRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const func_value: i32 = if (txn.message.ItemId == 1) 1 else 0;

    if (weapon_comp.weapon_map.getPtr(txn.message.IncrId)) |item| {
        item.func_value = func_value;
        try PlayerWeaponComponent.saveAll(alloc.gpa, fs, weapon_comp.player_id, weapon_comp.weapon_map);
        try txn.conn.push(pb.ItemFuncValueUpdateNotify{
            .IncrId = txn.message.IncrId,
            .FuncValue = item.func_value,
        });
        txn.respond(.{ .ErrorCode = .Success });
        return;
    }

    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };

    item.func_value = func_value;
    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    try txn.conn.push(pb.ItemFuncValueUpdateNotify{
        .IncrId = txn.message.IncrId,
        .FuncValue = item.func_value,
    });

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onItemDeprecateRequest(
    txn: *Transaction(pb.ItemDeprecateRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    echo_comp: *PlayerEchoComponent,
) !void {
    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };

    item.func_value = if (txn.message.ItemId == 1) 2 else 0;
    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    txn.respond(.{ .ErrorCode = .Success });
}
