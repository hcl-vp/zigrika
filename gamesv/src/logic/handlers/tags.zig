const std = @import("std");
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
    var notify: pb.CombatReceivePackNotify = .{};

    try appendGameplayTagNotifies(
        &notify,
        alloc,
        combat_common,
        event.data.add_tag_ids,
        event.data.remove_tag_ids,
        event.data.remove_before_add,
    );

    if (notify.Data.items.len != 0) {
        try conn.push(notify, alloc.arena);
    }
}

fn appendGameplayTagNotifies(
    notify: *pb.CombatReceivePackNotify,
    alloc: mem.Alloc,
    combat_common: pb.CombatCommon,
    add_tag_ids: []const i32,
    remove_tag_ids: []const i32,
    remove_before_add: bool,
) !void {
    if (remove_before_add) {
        for (remove_tag_ids) |tag_id| try appendTagNotify(notify, alloc, combat_common, tag_id, false);
        for (add_tag_ids) |tag_id| try appendTagNotify(notify, alloc, combat_common, tag_id, true);
    } else {
        for (add_tag_ids) |tag_id| try appendTagNotify(notify, alloc, combat_common, tag_id, true);
        for (remove_tag_ids) |tag_id| try appendTagNotify(notify, alloc, combat_common, tag_id, false);
    }
}

fn appendTagNotify(
    notify: *pb.CombatReceivePackNotify,
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

test "gameplay tag notify ordering is event specific" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = arena.allocator() };
    const combat_common: pb.CombatCommon = .{ .EntityId = 1001 };

    var replacement: pb.CombatReceivePackNotify = .{};
    try appendGameplayTagNotifies(&replacement, alloc, combat_common, &.{22}, &.{11}, true);
    try expectTagNotify(replacement.Data.items[0], 11, false);
    try expectTagNotify(replacement.Data.items[1], 22, true);

    var general: pb.CombatReceivePackNotify = .{};
    try appendGameplayTagNotifies(&general, alloc, combat_common, &.{44}, &.{33}, false);
    try expectTagNotify(general.Data.items[0], 44, true);
    try expectTagNotify(general.Data.items[1], 33, false);
}

fn expectTagNotify(data: pb.CombatReceiveData, tag_id: i32, add: bool) !void {
    const message = data.Message orelse return error.MissingCombatMessage;
    const combat = switch (message) {
        .CombatNotifyData => |value| value orelse return error.MissingCombatNotify,
        else => return error.UnexpectedCombatMessage,
    };
    const notify_message = combat.Message orelse return error.MissingNotifyMessage;
    const tag_notify = switch (notify_message) {
        .AnimationGameplayTagNotify => |value| value orelse return error.MissingTagNotify,
        else => return error.UnexpectedNotifyMessage,
    };
    try std.testing.expectEqual(tag_id, tag_notify.AddTagIds);
    try std.testing.expectEqual(add, tag_notify.RemoveTagIds);
}
