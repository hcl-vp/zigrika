const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const comp_util = @import("../../logic/component/comp_util.zig");
const GuideInfo = @import("../../fs/GuideInfo.zig");
const PlayerGuideComponent = @import("../../logic/component/player/PlayerGuideComponent.zig");

const finished_by_default = [_]i32{
    10116, 10193, 10194,
    10120, 10175, 10270,
    10285,
};

pub fn onGuideInfoRequest(
    txn: *Transaction(pb.GuideInfoRequest),
    guide_comp: *PlayerGuideComponent,
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var finished: std.ArrayList(i32) = .empty;
    if (Assets.DataTables.Config.autocomplete_guides) {
        for (assets.tables.guide_group.items) |group| {
            try finished.append(alloc.arena, group.Id);
        }
    } else {
        for (finished_by_default) |group_id| {
            if (!guide_comp.info.hasFinished(group_id)) try finished.append(alloc.arena, group_id);
        }
        try finished.appendSlice(alloc.arena, guide_comp.info.finished_groups);
    }
    txn.respond(.{ .GuideGroupFinishList = finished });
}

pub fn onGuideTriggerRequest(txn: *Transaction(pb.GuideTriggerRequest)) !void {
    txn.respond(.{});
}

pub fn onGuideFinishRequest(
    txn: *Transaction(pb.GuideFinishRequest),
    guide_comp: *PlayerGuideComponent,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    try guide_comp.info.addFinished(alloc.gpa, txn.message.GroupId);
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}", .{ guide_comp.player_id, GuideInfo.data_path });
    try comp_util.saveStruct(fs, guide_comp.info, path, alloc.arena);
    txn.respond(.{});
}

pub fn onIllustratedInfoRequest(
    txn: *Transaction(pb.IllustratedInfoRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
) !void {
    var classes: std.ArrayList(pb.IllustratedClass) = .empty;

    for (txn.message.TypeList.items) |illustrated_type| {
        var entries: std.ArrayList(pb.IllustratedEntry) = .empty;

        if (illustrated_type == .VocalCorpse) {
            for (assets.tables.calabash_develop_reward.items) |reward| {
                if (!reward.IsShow) continue;
                try entries.append(alloc.arena, .{
                    .Id = reward.MonsterId,
                    .CreateTime = 1,
                    .Num = @intCast(reward.DevelopCondition.len),
                    .IsRead = true,
                });
            }
        }

        try classes.append(alloc.arena, .{
            .Type = illustrated_type,
            .IllustratedEntryList = entries,
        });
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .IllustratedClassList = classes,
    });
}
