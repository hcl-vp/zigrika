const std = @import("std");
const common = @import("common");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");
const PlayerMapComponent = @import("../../logic/component/player/PlayerMapComponent.zig");

const FileSystem = common.FileSystem;
const lahai_roi_dungeon_id = 906;

fn appendTrackedIds(arena: std.mem.Allocator, map_comp: *const PlayerMapComponent) !std.ArrayList(i32) {
    var ids: std.ArrayList(i32) = .empty;
    try ids.appendSlice(arena, map_comp.info.tracked_mark_ids);
    return ids;
}

fn appendCustomMarks(arena: std.mem.Allocator, map_comp: *const PlayerMapComponent) !std.ArrayList(pb.MarkPointInfo) {
    var marks: std.ArrayList(pb.MarkPointInfo) = .empty;
    for (map_comp.info.custom_marks) |saved_mark| {
        try marks.append(arena, saved_mark.toPb());
    }
    return marks;
}

pub fn onMapTraceRequest(
    txn: *Transaction(pb.MapTraceRequest),
    map_comp: *PlayerMapComponent,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    try map_comp.info.trackMark(alloc.gpa, txn.message.MarkId);
    try map_comp.save(fs, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .MarkId = txn.message.MarkId,
    });
}

pub fn onMapCancelTraceRequest(
    txn: *Transaction(pb.MapCancelTraceRequest),
    map_comp: *PlayerMapComponent,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    try map_comp.info.untrackMark(alloc.gpa, txn.message.MarkId);
    try map_comp.save(fs, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .MarkId = txn.message.MarkId,
    });
}

pub fn onMapTraceInfoRequest(
    txn: *Transaction(pb.MapTraceInfoRequest),
    map_comp: *PlayerMapComponent,
    alloc: mem.Alloc,
) !void {
    const marks = try appendCustomMarks(alloc.arena, map_comp);
    if (marks.items.len != 0) {
        try txn.conn.push(pb.MapMarkInfoNotify{ .InfoList = marks }, alloc.arena);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .MarkIdList = try appendTrackedIds(alloc.arena, map_comp),
    });
}

pub fn onMapMarkRequest(
    txn: *Transaction(pb.MapMarkRequest),
    map_comp: *PlayerMapComponent,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    const request_mark = txn.message.MarkPointRequestInfo orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const saved_mark = try map_comp.info.addCustomMark(alloc.gpa, request_mark);
    try map_comp.save(fs, alloc.arena);

    const mark = saved_mark.toPb();

    try txn.conn.push(pb.MapMarkAddNotify{ .Info = mark }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .Info = mark,
    });
}

pub fn onRemoveMapMarkRequest(
    txn: *Transaction(pb.RemoveMapMarkRequest),
    map_comp: *PlayerMapComponent,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    try map_comp.info.deleteCustomMarks(alloc.gpa, txn.message.MarkList.items);
    try map_comp.save(fs, alloc.arena);

    try txn.conn.push(pb.MapMarkInfoNotify{
        .InfoList = try appendCustomMarks(alloc.arena, map_comp),
    }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .MarkList = txn.message.MarkList,
    });
}

pub fn onMapUnlockFieldInfoRequest(
    txn: *Transaction(pb.MapUnlockFieldInfoRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var fields: std.ArrayList(i32) = .empty;

    for (assets.tables.map_fog.items) |fog| {
        try fields.append(alloc.arena, fog.Fog);
    }

    var multi_maps: std.ArrayList(i32) = .empty;
    var map_blocks: std.ArrayList(i32) = .empty;

    for (assets.tables.multi_map.items) |multi| {
        try multi_maps.append(alloc.arena, multi.Id);
    }
    for (assets.tables.map_block_info.items) |block| {
        try map_blocks.append(alloc.arena, block.BlockId);
    }

    try txn.conn.push(pb.MapUnlockDataNotify{
        .UnlockMultiMapIds = multi_maps,
        .UnlockMapBlockIds = map_blocks,
    }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .FieldId = fields,
    });
}

pub fn onExploreProgressRequest(txn: *Transaction(pb.ExploreProgressRequest)) !void {
    txn.respond(.{});
}

pub fn onDarkCoastDeliveryRequest(txn: *Transaction(pb.DarkCoastDeliveryRequest)) !void {
    const drop_items = pb.DragonPoolDropItems{
        .DragonPoolId = txn.message.DragonPoolId,
        .DropIds = .empty,
        .DropItems = .empty,
    };

    txn.respond(.{
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

    txn.respond(.{
        .ErrorCode = .Success,
        .EntityId = txn.message.EntityId,
        .Info = access_info,
    });
}

pub fn onSimpleTrackReportAsyncRequest(
    txn: *Transaction(pb.SimpleTrackReportAsyncRequest),
) !void {
    txn.respond(.{
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

    txn.respond(.{
        .ErrorCode = .Success,
        .InfrInfo = infr_data,
    });
}

pub fn onInfrInfoRequest(
    txn: *Transaction(pb.InfrInfoRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var roads: std.ArrayList(pb.InfrOneRoad) = .empty;
    for (assets.tables.infr_road_build.items) |cfg| {
        if (cfg.DungeonId != lahai_roi_dungeon_id) continue;

        try roads.append(alloc.arena, .{
            .RoadId = cfg.Id,
            .status = .InfrStatusComplete,
            .CompleteTime = 0,
            .TotalGiftCount = 0,
            .LastGiftTime = 0,
        });
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .InfrInfo = .{
            .RoadInfo = .{ .Roads = roads },
        },
    });
}
