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
        const stack_count = if (entry.stack_count > 0) entry.stack_count else 1;
        if (existing) |buff| { // no dupes
            buff.Level = 1;
            buff.StackCount = stack_count;
            buff.InstigatorId = event.data.instigator.net_id;
            buff.EntityId = event.data.target.net_id;
            buff.Duration = -1.0;
            buff.LeftDuration = -1.0;
            buff.ApplyType = .Common;
            buff.IsActive = entry.is_active;
            buff.MessageId = -1;
        } else {
            scene.*.instance.buff_handle += 1;
            item[0].fight_buff_infos = try alloc.gpa.realloc(item[0].fight_buff_infos, item[0].fight_buff_infos.len + 1);
            item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1] = Assets.DataTables.createBuffInformation(
                scene.instance.buff_handle,
                entry.id,
                event.data.instigator.net_id,
                event.data.target.net_id,
                entry.is_active,
            );
            item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1].StackCount = stack_count;
            const buff = item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1];
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = combat_common,
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = buff.HandleId,
                            .Id = buff.BuffId,
                            .Level = buff.Level,
                            .EntityId = buff.EntityId,
                            .InstigatorId = buff.InstigatorId,
                            .ApplyType = if (buff.ApplyType) |apply_type| @intFromEnum(apply_type) else 0,
                            .IsActive = buff.IsActive,
                            .ServerId = buff.ServerId,
                            .StackCount = buff.StackCount,
                            .CRoundAction = .{ .Duration = buff.Duration },
                            .Time = .{ .LeftDuration = buff.LeftDuration },
                            .ConfBuffId = buff.ConfBuffId,
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
