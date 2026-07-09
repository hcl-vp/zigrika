const std = @import("std");
const common = @import("common");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");
const PlayerMapComponent = @import("../../logic/component/player/PlayerMapComponent.zig");

const FileSystem = common.FileSystem;
const lahai_roi_dungeon_id = 906;
const full_explore_percent = 100;

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

fn appendExploreProgressRewardIds(arena: std.mem.Allocator, assets: *const Assets) !std.ArrayList(i32) {
    var reward_ids: std.ArrayList(i32) = .empty;
    for (assets.tables.explore_progress_reward.items) |reward| {
        try reward_ids.append(arena, reward.Id);
    }
    return reward_ids;
}

const CountryExploreScoreData = struct {
    score: i32,
    received: std.ArrayList(pb.CountryExploreScoreReceived),
};

fn appendMaxExploreLevelEntries(
    arena: std.mem.Allocator,
    assets: *const Assets,
    country_filter: ?i32,
) !std.ArrayList(pb.CountryExploreLevel) {
    var levels: std.ArrayList(pb.CountryExploreLevel) = .empty;

    for (assets.tables.explore_reward.items) |reward| {
        if (country_filter) |country_id| {
            if (reward.Country != country_id) continue;
        }

        for (levels.items) |*entry| {
            if (entry.CountryId == reward.Country) {
                entry.ExploreLevel = @max(entry.ExploreLevel, reward.ExploreLevel);
                break;
            }
        } else {
            try levels.append(arena, .{
                .CountryId = reward.Country,
                .ExploreLevel = reward.ExploreLevel,
            });
        }
    }

    return levels;
}

fn buildCountryExploreScoreData(
    arena: std.mem.Allocator,
    assets: *const Assets,
    country_id: i32,
) !CountryExploreScoreData {
    var received: std.ArrayList(pb.CountryExploreScoreReceived) = .empty;
    var total_score: i32 = 0;

    for (assets.tables.explore_score.items) |score_cfg| {
        const area = assets.tables.area.getDataById(score_cfg.Area) orelse continue;
        if (area.CountryId != country_id) continue;

        var thresholds: std.ArrayList(i32) = .empty;
        var it = score_cfg.Score.map.iterator();
        while (it.next()) |entry| {
            try thresholds.append(arena, entry.key_ptr.*);
            total_score += entry.value_ptr.*;
        }
        if (thresholds.items.len == 0) continue;

        try received.append(arena, .{
            .AreaId = score_cfg.Area,
            .ExploreProgress = thresholds,
        });
    }

    return .{
        .score = total_score,
        .received = received,
    };
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

pub fn onExploreProgressRequest(
    txn: *Transaction(pb.ExploreProgressRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    try txn.conn.push(pb.ExploreLevelNotify{
        .CountryExploreLevel = try appendMaxExploreLevelEntries(alloc.arena, assets, null),
    }, alloc.arena);

    try txn.conn.push(pb.ExploreProgressRewardIdsNotify{
        .AreaStageRewardDataList = try appendExploreProgressRewardIds(alloc.arena, assets),
    }, alloc.arena);

    var area_progress: std.ArrayList(pb.AreaExploreInfo) = .empty;

    for (txn.message.AreaIds.items) |area_id| {
        try area_progress.append(alloc.arena, .{
            .AreaId = area_id,
            .ExplorePercent = full_explore_percent,
        });
    }

    txn.respond(.{
        .AreaProgress = area_progress,
    });
}

pub fn onReceiveAreaStageRewardAsyncRequest(
    txn: *Transaction(pb.ReceiveAreaStageRewardAsyncRequest),
    alloc: mem.Alloc,
) !void {
    _ = alloc;
    txn.respond(.{
        .AreaStageRewardDataList = txn.message.AreaStageRewardDataList,
    });
}

pub fn onCountryExploreScoreInfoRequest(
    txn: *Transaction(pb.CountryExploreScoreInfoRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    const country_id = txn.message.CountryId;
    const score_data = try buildCountryExploreScoreData(alloc.arena, assets, country_id);
    const levels = try appendMaxExploreLevelEntries(alloc.arena, assets, country_id);

    try txn.conn.push(pb.ExploreLevelNotify{ .CountryExploreLevel = levels }, alloc.arena);
    txn.respond(.{
        .ExploreScore = score_data.score,
        .CountryExploreScoreReceived = score_data.received,
    });
}

pub fn onMultiExploreScoreRewardRequest(
    txn: *Transaction(pb.MultiExploreScoreRewardRequest),
    alloc: mem.Alloc,
) !void {
    _ = txn.message;
    _ = alloc;
    txn.respond(.{
        .ErrorCode = .Success,
    });
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
