const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const mem = @import("../../mem.zig");
const State = @import("../State.zig");

pub const bot_details: pb.PlayerDetails = .{
    .PlayerId = 1337,
    .Name = "Zigrika",
    .Level = 90,
    .OriginWorldLevel = 8,
    .CurWorldLevel = 8,
    .HeadId = 82001412,
    .HeadFrameId = 0,
    .Signature = "here to help!",
    .IsOnline = true,
    .IsCanLobbyOnline = false,
    .LastOfflineTime = 0,
    .TeamMemberCount = 0,
    .LevelGap = 0,
    .Birthday = 0,
    .RoleShowList = .empty,
    .CardShowList = .empty,
    .CurCard = 0,
    .DisplayBirthday = false,
    .LastEnterMultiWillTime = 0,
    .SdkUserId = "Zig",
    .SdkOnlineId = "Zig",
    .SdkAccountId = "Zig",
    .CrossPlayEnabled = true,
    .LimitState = 0,
    .PlayerTitleId = 0,
    .CurPlayerTitleId = 0,
    .Sex = 0,
    .Deactivation = false,
};

pub fn onFriendAllRequest(
    txn: *Transaction(pb.FriendAllRequest),
    alloc: mem.Alloc,
) !void {
    var friends: std.ArrayList(pb.FriendInfo) = .empty;

    try friends.append(alloc.arena, .{
        .Info = bot_details,
        .Remark = "",
    });

    txn.respond(.{
        .FriendInfoList = friends,
        .ErrorCode = .Success,
    });
}

pub fn onPlayerBasicInfoGetRequest(
    txn: *Transaction(pb.PlayerBasicInfoGetRequest),
    _: mem.Alloc,
) !void {
    if (txn.message.Id == bot_details.PlayerId) {
        txn.respond(.{
            .Info = bot_details,
            .ErrorCode = .Success,
        });
    }
}
