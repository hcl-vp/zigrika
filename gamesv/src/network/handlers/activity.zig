const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");

const EXCLUDED_ACTIVITY = [_]i32{
    100100001, // Gifts of Thawing Frost
    100100002, // Gifts of Celestial Light
    100100003, // Gifts of Lunar Radiance
    100100004, // Gifts of Sea Breeze
    100100005, // Gifts of Fleeting Dreams
    100100006, // Gifts of Joyous Tunes
    100100007, // Gifts of Blue Water
    100100008, // Gifts of the Still Tides
    100100009, // Gifts of Grand Reunion
    100100010, // Gifts of Melodic Verses
    100100011, // Gifts of Applause
    100100012, // Gifts of Grand Symphony
    100100013, // Gifts of the Hunt
    100100014, // Gifts of Approaching Dawn
    100100015, // Gifts of Amber
    100100016, // Gifts of Ink Song
    100100017, // Gifts of Freshers Week
    100100018, // Gifts of Soft Snow
    100100019, // Gifts of Solsworn
    100100020,
    100400001, // Awakening Journey

    105800001, // Tidal Defense Simulator

    100700001, // Intensive Training
    100700002, // Bountiful Crescendo
    100700003, // Chord Cleansing
    100700004,
    100700005,
    100700006,
    100700007,
    100700008,
    100700009,
    100700010,
    100700011,
    100700012,
    100700013,
    100700014,
    100700015,
    100700016,
    100700017,
    100700018,
    100700019,
    100700020,
    100700021,
    100700022,
    100700023,
    100700024,
    100700025,
    100700026,
    100700027,
    100700028,
    100700029,
    100700030,
    100700031,
    100700032,
    100700033,
    100700034,
    100700035,
    100700036,
    100800001, // Alloy Smelt
    100800002, // Alloy Smelt II

    100805001, // Tactical Simulacra: Off Tune
    100805002, // Tactical Simulacra: Off Tune
    100805003, // Tactical Simulacra III
    100805004, // Tactical Simulacra: Off Tune

    108600001, // Knights of the Wild

    102300013, // Infinite Battle Simulation
    102300020, // Infinite Battle Simulation II

    102400001, // Solaris Weather Forecast
    102400002, // Ragunna Weather Forecast
    102400003, // Septimont Weather Forecast

    103000001, // Pincer Maneuver Warriors I
    103000002, // Pincer Maneuver Warriors II
    102900001, // Pincer Maneuver Warriors III
    102900002, // Pincer Maneuver Warriors IV

    103300001, // John Wicktorio: No Debts for Old Men
    103300002, // Test Server Training Ground
    103300003, // Blade Hunter: Wilderness

    103200001, // Tales of the Isles

    103500001, // Glamour Couture
    103500002, // Glamour Couture
    103500003, // Glamour Couture

    104000001, // Virtual Crisis: Prototype Trials
    104000002, // Virtual Crisis: Frontier Trials

    104400001, // Cube, Cubic n Cubie

    105100001, // Gilded Nightmarket

    105300002, // Solaris New Voyage Celebration

    107100001, // Whispers Between Stars

    100770001, // Doubled Pawns Matrix: Pilot
    100770002, // Doubled Pawns Matrix: Pilot

    107500002, // Startorch for You

    107200001, // Peaks of Prestige: Rekindled Duel

    100300001, // Hazard Revisited

    101700001, // By Moon's Grace
    101700002, // By Moon's Grace: Summary

    101100001, // Echo Hunters

    100, // Overdash Club

};

pub fn onActivityRequest(
    txn: *Transaction(pb.ActivityRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    const log = std.log.scoped(.activity_handler);

    const ActivityConfig = @import("../../data/tables/Activity.zig");
    var highest_id_map: std.AutoArrayHashMapUnmanaged(i32, *const ActivityConfig) = .empty;

    defer highest_id_map.deinit(alloc.gpa);

    for (assets.tables.activity.items) |*cfg| {
        if (std.mem.indexOfScalar(i32, &EXCLUDED_ACTIVITY, cfg.Id) != null) {
            continue;
        }

        const gop = try highest_id_map.getOrPut(alloc.gpa, cfg.Type);

        if (!gop.found_existing) {
            gop.value_ptr.* = cfg;
        } else {
            if (cfg.Id > gop.value_ptr.*.Id) {
                gop.value_ptr.* = cfg;
            }
        }
    }

    var activity_list: std.ArrayList(pb.ActivityData) = .empty;
    var it = highest_id_map.iterator();
    while (it.next()) |entry| {
        const winner = entry.value_ptr.*;

        try activity_list.append(alloc.arena, .{
            .Id = winner.Id,
            .Type = @enumFromInt(winner.Type),
            .BeginShowTime = 0,
            .EndShowTime = 0,
            .BeginOpenTime = 0,
            .EndOpenTime = 0,
            .IsUnlock = true,
            .IsFirstOpen = false,
            .ActivityOpenType = @enumFromInt(winner.OpenType),
            .IsPreOpen = false,
            .StartTime = 0,
            .EndTime = 0,
            .BeginRewardTimeInternal = 0,
            .EndRewardTimeInternal = 0,
            .Data = null,
        });
    }

    log.debug("Pushed {d} unique activities for preview ({d} excluded).", .{
        activity_list.items.len,
        EXCLUDED_ACTIVITY.len,
    });

    try txn.respond(.{
        .Activities = activity_list,
        .ErrorCode = .Success,
    });
}
