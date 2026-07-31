const std = @import("std");
const common = @import("common");
const Io = std.Io;
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const mem = @import("../../mem.zig");
const file_util = @import("../../fs/file_util.zig");
const Assets = @import("../../data/Assets.zig");
const PlayerBasicComponent = @import("../../logic/component/player/PlayerBasicComponent.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const FileSystem = common.FileSystem;

pub fn onPlayerHeadDataRequest(txn: *Transaction(pb.PlayerHeadDataRequest), assets: *const Assets, alloc: mem.Alloc) !void {
    var ids: std.ArrayList(i32) = .empty;
    try ids.ensureTotalCapacity(alloc.arena, assets.tables.player_head_re.items.len);

    for (assets.tables.player_head_re.items) |head| {
        ids.appendAssumeCapacity(head.Id);
    }

    txn.respond(.{
        .PlayerHeadDataIds = ids,
    });
}

pub fn onPlayerTitleDataRequest(txn: *Transaction(pb.PlayerTitleDataRequest), assets: *const Assets, alloc: mem.Alloc) !void {
    var title_data: std.ArrayList(pb.PlayerTitleData) = .empty;
    try title_data.ensureTotalCapacity(alloc.arena, assets.tables.player_title.items.len);

    for (assets.tables.player_title.items) |title| {
        title_data.appendAssumeCapacity(.{
            .PlayerTitleId = title.Id,
            .IsUnlock = true,
            .StarLevel = 1,
        });
    }

    txn.respond(.{
        .PlayerTitleData = title_data,
        .ErrorCode = .Success,
    });
}

pub fn onRoleShowListUpdateRequest(
    txn: *Transaction(pb.RoleShowListUpdateRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    basic_comp: *PlayerBasicComponent,
    role_comp: *const PlayerRoleComponent,
) !void {
    var role_ids: std.ArrayList(i32) = .empty;
    defer role_ids.deinit(alloc.gpa);

    for (txn.message.RoleList.items) |role_id| {
        if (role_ids.items.len == 3) break;
        if (role_comp.role_map.get(role_id) == null) continue;
        if (std.mem.indexOfScalar(i32, role_ids.items, role_id) != null) continue;
        try role_ids.append(alloc.gpa, role_id);
    }

    const owned = try role_ids.toOwnedSlice(alloc.gpa);
    if (basic_comp.info.role_show_list.len != 0) alloc.gpa.free(basic_comp.info.role_show_list);
    basic_comp.info.role_show_list = owned;
    try saveBasicInfo(fs, alloc.arena, basic_comp);

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onChangeCardRequest(
    txn: *Transaction(pb.ChangeCardRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    assets: *const Assets,
    basic_comp: *PlayerBasicComponent,
) !void {
    if (assets.tables.background_card.getDataById(txn.message.CardId) != null) {
        basic_comp.info.cur_card_id = txn.message.CardId;
        try saveBasicInfo(fs, alloc.arena, basic_comp);
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onReadCardRequest(txn: *Transaction(pb.ReadCardRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onChangePlayerTitleRequest(
    txn: *Transaction(pb.ChangePlayerTitleRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    assets: *const Assets,
    basic_comp: *PlayerBasicComponent,
) !void {
    if (txn.message.PlayerTitleId == 0 or assets.tables.player_title.getDataById(txn.message.PlayerTitleId) != null) {
        basic_comp.info.cur_player_title_id = txn.message.PlayerTitleId;
        try saveBasicInfo(fs, alloc.arena, basic_comp);
        try txn.conn.push(pb.SetDressedPlayerTitleNotify{
            .PlayerTitleId = txn.message.PlayerTitleId,
            .CurPlayerTitleId = if (txn.message.PlayerTitleId == 0) 0 else 1, // PlayerTitleExtraParam
        });
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onModifyNameRequest(
    txn: *Transaction(pb.ModifyNameRequest),
    io: Io,
    fs: *FileSystem,
    alloc: mem.Alloc,
    basic_comp: *PlayerBasicComponent,
) !void {
    const last_modify_name_time = adjustedModifyNameTime(io);
    const name = try alloc.gpa.dupe(u8, txn.message.Name);

    if (basic_comp.info.attributes.name.len != 0) alloc.gpa.free(basic_comp.info.attributes.name);
    basic_comp.info.attributes.name = name;
    basic_comp.info.last_modify_name_time = last_modify_name_time;
    try saveBasicInfo(fs, alloc.arena, basic_comp);

    try txn.conn.push(pb.PlayerNameUpdateNotify{
        .Name = basic_comp.info.attributes.name,
        .LastModifyNameTime = last_modify_name_time,
    });

    txn.respond(.{
        .Name = basic_comp.info.attributes.name,
        .ErrorCode = .Success,
        .LastModifyNameTime = last_modify_name_time,
        .ModifyNameTime = "",
    });
}

pub fn onChangeHeadPhotoRequest(
    txn: *Transaction(pb.ChangeHeadPhotoRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    assets: *const Assets,
    basic_comp: *PlayerBasicComponent,
) !void {
    if (assets.tables.player_head_re.getDataById(txn.message.HeadPhotoId) != null) {
        basic_comp.info.attributes.head_photo = txn.message.HeadPhotoId;
        try saveBasicInfo(fs, alloc.arena, basic_comp);
    }

    txn.respond(.{
        .HeadPhotoId = basic_comp.info.attributes.head_photo,
        .ErrorCode = .Success,
    });
}

pub fn onModifySignatureRequest(
    txn: *Transaction(pb.ModifySignatureRequest),
    basic_comp: *const PlayerBasicComponent,
) !void {
    txn.respond(.{
        .Signature = basic_comp.info.attributes.sign,
        .ErrorCode = .ContainsDirtyWord,
    });
}

pub fn onBirthdayInitRequest(
    txn: *Transaction(pb.BirthdayInitRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    basic_comp: *PlayerBasicComponent,
) !void {
    if (txn.message.Birthday > 0) {
        basic_comp.info.birthday = txn.message.Birthday;
        basic_comp.info.display_birthday = true;
        try saveBasicInfo(fs, alloc.arena, basic_comp);
        try txn.conn.push(pb.BirthdayInfoUpdateNotify{
            .BirthDayReset = true,
            .RecentRewardTime = @divTrunc(basic_comp.info.birthday, 10000),
        });
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onBirthdayShowSetRequest(
    txn: *Transaction(pb.BirthdayShowSetRequest),
    fs: *FileSystem,
    alloc: mem.Alloc,
    basic_comp: *PlayerBasicComponent,
) !void {
    basic_comp.info.display_birthday = txn.message.DisPlay;
    try saveBasicInfo(fs, alloc.arena, basic_comp);

    txn.respond(.{ .ErrorCode = .Success });
}

fn saveBasicInfo(fs: *FileSystem, arena: std.mem.Allocator, basic_comp: *const PlayerBasicComponent) !void {
    const path = try std.fmt.allocPrint(arena, "player/{}/basic_info", .{basic_comp.player_id});
    const serialized = try file_util.serializeZon(arena, basic_comp.info);
    try fs.writeFile(path, serialized);
}

fn adjustedModifyNameTime(io: Io) i64 {
    const client_name_modify_cd = 72 * 60 * 60;
    const testing_name_modify_cd = 5;
    const realtime_clock: Io.Clock = .real;
    const now = realtime_clock.now(io).toSeconds();
    return @max(0, now - client_name_modify_cd + testing_name_modify_cd);
}
