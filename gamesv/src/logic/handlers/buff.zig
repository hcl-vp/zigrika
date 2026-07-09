const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const mem = @import("../../mem.zig");
const Connection = @import("../../network/Connection.zig");
const State = @import("../../network/State.zig");

pub fn removeBuffFromEntity(
    event: EventQueue.Dequeue(.buff_removal),
    conn: *Connection,
    events: *EventQueue,
    alloc: mem.Alloc,
    state: *State,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, ?*Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_removal);
    const item = query.byEntityHandle(event.data.entity) orelse return;
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.entity.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (event.data.handle_ids) |handle_id| {
        item[0].removeByHandleId(alloc.gpa, handle_id);
        state.buff_timers.markDirty();
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
    state: *State,
    assets: *const Assets,
    alloc: mem.Alloc,
    query: Scene.Query(&.{ *Entity.FightBuffComponent, ?*Entity.AttributeComponent }),
) !void {
    const log = std.log.scoped(.buff_addition);
    const item = query.byEntityHandle(event.data.target) orelse return;
    const combat_common: pb.CombatCommon = .{ .EntityId = event.data.target.net_id };
    var notify: pb.CombatReceivePackNotify = .{};

    for (event.data.buffs) |entry| {
        const buff_data = assets.tables.buff.getDataById(entry.id) orelse continue;
        const existing = item[0].getByBuffId(entry.id);
        const stack_count = if (entry.stack_count > 0) entry.stack_count else 1;
        if (existing) |buff| { // no dupes
            state.buff_timers.forgetHandle(event.data.target.net_id, buff.HandleId);
            buff.Level = 1;
            buff.StackCount = stack_count;
            buff.InstigatorId = event.data.instigator.net_id;
            buff.EntityId = event.data.target.net_id;
            applyBuffDuration(buff, &buff_data, entry.duration_seconds);
            buff.ApplyType = .Common;
            buff.IsActive = entry.is_active;
            buff.MessageId = -1;
            state.buff_timers.markDirty();
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
            applyBuffDuration(&item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1], &buff_data, entry.duration_seconds);
            const buff = item[0].fight_buff_infos[item[0].fight_buff_infos.len - 1];
            state.buff_timers.markDirty();
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

pub fn handleBuffTimerTick(
    event: EventQueue.Dequeue(.buff_timer_tick),
    conn: *Connection,
    events: *EventQueue,
    state: *State,
    scene: *Scene,
    assets: *const Assets,
    fs: *FileSystem,
    io: std.Io,
    alloc: mem.Alloc,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
) !void {
    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;
    try state.buff_timers.drainDue(
        event,
        events,
        scene,
        assets,
        fs,
        io,
        query,
        &combat_receive_pack,
        alloc,
    );

    if (combat_receive_pack.items.len != 0) {
        try conn.push(pb.CombatReceivePackNotify{ .Data = combat_receive_pack }, alloc.arena);
    }
}

fn applyBuffDuration(
    buff: *pb.FightBuffInformation,
    buff_data: *const Assets.DataTables.Buff,
    requested_duration: ?f32,
) void {
    switch (buff_data.DurationPolicy) {
        .Instant => {
            buff.Duration = 0;
            buff.LeftDuration = 0;
        },
        .Infinite => {
            buff.Duration = -1;
            buff.LeftDuration = -1;
        },
        .HasDuration => {
            const duration = requested_duration orelse dataDuration(buff_data);
            if (duration > 0) {
                buff.Duration = duration;
                buff.LeftDuration = duration;
            } else {
                buff.Duration = -1;
                buff.LeftDuration = -1;
            }
        },
    }
}

fn dataDuration(buff_data: *const Assets.DataTables.Buff) f32 {
    return if (buff_data.DurationMagnitude.len > 0) buff_data.DurationMagnitude[0] else 0;
}
