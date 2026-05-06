const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Assets = @import("../../data/Assets.zig");
const Entity = Scene.Entity;
const mem = @import("../../mem.zig");
const Connection = @import("../../network/Connection.zig");

pub fn removeBuffFromEntity(
    event: EventQueue.Dequeue(.buff_removal),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, *Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_removal);
    const item = query.byEntityHandle(event.data.entity) orelse return;
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.entity.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (event.data.handle_ids) |handle_id| {
        item[0].removeByHandleId(alloc.gpa, handle_id);
        try notify.Data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = combat_common,
                .Message = .{
                    .RemoveGameplayEffectNotify = .{
                        .EntityId = event.data.entity.net_id,
                        .Handle = handle_id,
                    },
                },
            },
        } });
    }

    try conn.push(notify, alloc.arena);

    try events.enqueue(.buff_change, .{ .entity = event.data.entity });

    log.debug("removed these buffs from {d}: {any}", .{
        event.data.entity.net_id,
        event.data.handle_ids,
    });
}

pub fn addBuffToEntity(
    event: EventQueue.Dequeue(.buff_addition),
    conn: *Connection,
    events: *EventQueue,
    scene: *Scene,
    alloc: mem.Alloc,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, *Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_addition);
    const item = query.byEntityHandle(event.data.target) orelse return;
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.target.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (event.data.buffs) |entry| {
        const existing = item[0].getByBuffId(entry.id);
        if (existing) |buff| { // no dupes
            buff.StackCount = entry.stack_count;
            buff.IsActive = entry.is_active;
        } else {
            scene.*.instance.buff_handle += 1;
            item[0].fight_buff_infos = try alloc.gpa.realloc(item[0].fight_buff_infos, item[0].fight_buff_infos.len + 1);
            item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1] = .{
                .HandleId = scene.instance.buff_handle,
                .BuffId = entry.id,
                .InstigatorId = event.data.instigator.net_id,
                .IsActive = entry.is_active,
            };
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = combat_common,
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = scene.instance.buff_handle,
                            .Id = entry.id,
                            .EntityId = event.data.target.net_id,
                            .InstigatorId = event.data.instigator.net_id,
                            .IsActive = entry.is_active,
                        },
                    },
                },
            } });
        }
    }

    try conn.push(notify, alloc.arena);

    try events.enqueue(.buff_change, .{ .entity = event.data.target });

    log.debug("eid {d}: added these buffs to {d}: {any}", .{
        event.data.instigator.net_id,
        event.data.target.net_id,
        event.data.buffs,
    });
}
