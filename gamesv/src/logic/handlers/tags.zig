const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const mem = @import("../../mem.zig");
const Connection = @import("../../network/Connection.zig");

pub fn updateGameplayTags(
    event: EventQueue.Dequeue(.gameplay_tag_change),
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.entity.net_id };
    var notify: pb.CombatMessage.CombatReceivePackNotify = .{};

    for (event.data.add_tag_ids) |tag_id| {
        try appendTagNotify(&notify, alloc, combat_common, tag_id, true);
    }
    for (event.data.remove_tag_ids) |tag_id| {
        try appendTagNotify(&notify, alloc, combat_common, tag_id, false);
    }

    if (notify.Data.items.len != 0) {
        try conn.push(notify, alloc.arena);
    }
}

fn appendTagNotify(
    notify: *pb.CombatMessage.CombatReceivePackNotify,
    alloc: mem.Alloc,
    combat_common: pb.CombatCommon,
    tag_id: i32,
    add: bool,
) !void {
    // Generated names are stale: AddTagIds is the tag id, RemoveTagIds is the add/remove flag.
    try notify.Data.append(alloc.arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = combat_common,
            .Message = .{
                .AnimationGameplayTagNotify = .{
                    .AddTagIds = tag_id,
                    .RemoveTagIds = add,
                },
            },
        },
    } });
}
