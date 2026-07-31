const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const PlayerID = @import("../PlayerID.zig");
const Connection = @import("../../network/Connection.zig");
const Assets = @import("../../data/Assets.zig");
const PlayerBasicComponent = @import("../component/player/PlayerBasicComponent.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");

pub fn pushData(
    _: EventQueue.Dequeue(.push_data),
    conn: *Connection,
    alloc: mem.Alloc,
    player_id: PlayerID,
    assets: *const Assets,
    basic_comp: *const PlayerBasicComponent,
    role_comp: *const PlayerRoleComponent,
) !void {
    var notify: pb.BasicInfoNotify = .{ .Id = player_id.id };

    const attrs = basic_comp.info.attributes.toProto();
    (try notify.Attributes.addManyAsArray(alloc.arena, attrs.len)).* = attrs;
    try appendRoleShowList(&notify.RoleShowList, alloc.arena, basic_comp.info.role_show_list, role_comp);
    try appendCardUnlockList(&notify.CardUnlockList, alloc.arena, assets);
    notify.CurCardId = basic_comp.info.cur_card_id;
    notify.Birthday = basic_comp.info.birthday;
    notify.DisplayBirthDay = basic_comp.info.display_birthday;
    notify.LastModifyNameTime = basic_comp.info.last_modify_name_time;
    notify.ModifyNameTime = "";

    try conn.push(notify);
    if (basic_comp.info.cur_player_title_id > 0) {
        try conn.push(pb.SetDressedPlayerTitleNotify{
            .PlayerTitleId = basic_comp.info.cur_player_title_id,
            .CurPlayerTitleId = 1, // PlayerTitleExtraParam
        });
    }
}

fn appendRoleShowList(
    list: *std.ArrayList(pb.RoleShowEntry),
    arena: std.mem.Allocator,
    role_ids: []const i32,
    role_comp: *const PlayerRoleComponent,
) !void {
    try list.ensureTotalCapacity(arena, role_ids.len);
    for (role_ids) |role_id| {
        const role = role_comp.role_map.get(role_id) orelse continue;
        list.appendAssumeCapacity(.{
            .RoleId = role_id,
            .Level = role.level,
        });
    }
}

fn appendCardUnlockList(
    list: *std.ArrayList(pb.CardShowEntry),
    arena: std.mem.Allocator,
    assets: *const Assets,
) !void {
    try list.ensureTotalCapacity(arena, assets.tables.background_card.items.len);
    for (assets.tables.background_card.items) |card| {
        list.appendAssumeCapacity(.{
            .CardId = card.Id,
            .IsRead = true,
        });
    }
}
