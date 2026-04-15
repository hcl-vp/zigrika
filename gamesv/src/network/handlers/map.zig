const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");

pub fn onMapTraceInfoRequest(txn: *Transaction(pb.MapTraceInfoRequest)) !void {
    try txn.respond(.{});
}

pub fn onMapUnlockFieldInfoRequest(
    txn: *Transaction(pb.MapUnlockFieldInfoRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var fields: std.ArrayList(i32) = .empty;

    for (assets.tables.area.items) |area| {
        try fields.append(alloc.arena, area.AreaId);
    }

    try txn.respond(.{
        .ErrorCode = .Success,
        .FieldId = fields,
    });
}

pub fn onDarkCoastDeliveryRequest(txn: *Transaction(pb.DarkCoastDeliveryRequest)) !void {
    const drop_items = pb.DragonPoolDropItems{
        .DragonPoolId = txn.message.DragonPoolId,
        .DropIds = .empty,
        .DropItems = .empty,
    };

    try txn.respond(.{
        .ErrorCode = .Success,
        .DragonPoolDropItems = drop_items,
        .DefeatedGuard = .empty,
        .ReceivedGuardReward = .empty,
        .LevelGain = 0,
    });
}

pub fn onPlayerAccessEffectAreaRequest(txn: *Transaction(pb.PlayerAccessEffectAreaRequest)) !void {
    const access_info = pb.EntityAccessInfo{
        .EntityId = txn.message.EntityId,
        .RangeType = txn.message.RangeType,
        .AcessRangeResults = .empty,
    };

    try txn.respond(.{
        .ErrorCode = .Success,
        .EntityId = txn.message.EntityId,
        .Info = access_info,
    });
}

pub fn onSimpleTrackReportAsyncRequest(
    txn: *Transaction(pb.SimpleTrackReportAsyncRequest),
) !void {
    try txn.respond(.{
        .ErrorCode = .Success,
        .SimpleTrackReportMsgs = .empty,
    });
}

pub fn onInfrV2InfoRequest(
    txn: *Transaction(pb.InfrV2InfoRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var tree_list: std.ArrayList(pb.InfrV2OneTree) = .empty;

    for (assets.tables.infr_v2_tree_build.items) |cfg| {
        try tree_list.append(alloc.arena, .{
            .TreeId = cfg.Id,
            .status = 2, // Proto_InfrV2StatusComplete
            .CompleteTime = 0,
        });
    }

    const village_data = pb.InfrV2FirePb{
        .FireExp = 0,
        .FireLevel = 1,
        .FireLevelReachTime = 0,
        .FireStatus = 2, // Proto_InfrV2StatusComplete
    };

    const infr_data = pb.InfrV2Pb{
        .FireInfo = village_data,
        .TreeInfo = .{
            .Trees = tree_list,
            .ManualTraceTree = 0,
        },
    };

    try txn.respond(.{
        .ErrorCode = .Success,
        .InfrInfo = infr_data,
    });
}
