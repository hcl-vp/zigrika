const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Connection = @import("../../network/Connection.zig");
const Entity = @import("../../logic/Scene.zig").Entity;
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const buff_helper = @import("../../logic/helpers/buff.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Events = @import("../../logic/events.zig");

pub fn OrderApplyBuffRequest(
    txn: *dispatch.CombatRequestTxn(.OrderApplyBuffRequest),
    events: *EventQueue,
    assets: *const Assets,
    scene: *Scene,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const request: pb.OrderApplyBuffRequest = txn.payload;
    const buff_data = assets.tables.buff.getDataById(request.Id) orelse {
        txn.respond(.{ .ErrorCode = .ErrOrderApplyBuffFailed });
        return;
    };

    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;

    switch (buff_data.DurationPolicy) {
        .Instant => {
            try combat_receive_pack.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = .{ .EntityId = txn.common.?.EntityId },
                    .Message = .{
                        .ApplyGameplayEffectNotify = .{
                            .Handle = -2,
                            .Id = buff_data.Id,
                            .EntityId = txn.common.?.EntityId,
                            .InstigatorId = request.InstigatorId,
                            .IsActive = true,
                        },
                    },
                },
            } });
            try buff_helper.execute_buff_effects(
                &combat_receive_pack,
                txn.common.?.EntityId,
                request.InstigatorId,
                &buff_data,
                scene,
                fs,
                io,
                query,
                alloc,
            );
        },
        else => {
            const target, _, _ = query.byNetId(txn.common.?.EntityId) orelse {
                txn.respond(.{ .ErrorCode = .ErrOrderApplyBuffFailed });
                return;
            };
            const instigator = if (request.InstigatorId != 0)
                if (query.byNetId(request.InstigatorId)) |item| item[0] else target
            else
                target;

            const buff_entries = try alloc.arena.alloc(Events.BuffAdditionEntry, 1);
            buff_entries[0] = .{
                .id = request.Id,
                .stack_count = request.StackCount,
                .is_active = true,
                .duration_seconds = requestDuration(request.Time),
            };
            try events.enqueue(.buff_addition, .{
                .target = target,
                .instigator = instigator,
                .buffs = buff_entries,
            });
        },
    }

    try txn.receive_data_pack.appendSlice(alloc.arena, combat_receive_pack.items);

    txn.respond(.{
        .ErrorCode = .Success,
    });
}

fn requestDuration(time: @FieldType(pb.OrderApplyBuffRequest, "Time")) ?f32 {
    return if (time) |value| switch (value) {
        .Duration => |duration| duration,
    } else null;
}

pub fn ApplyGameplayEffectPush(
    push: pb.ApplyGameplayEffectPush,
    common: ?pb.CombatCommon,
    conn: *Connection,
    assets: *const Assets,
    scene: *Scene,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const buff_data = assets.tables.buff.getDataById(push.Id) orelse {
        return;
    };

    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;

    try buff_helper.execute_buff_effects(
        &combat_receive_pack,
        common.?.EntityId,
        push.InstigatorId,
        &buff_data,
        scene,
        fs,
        io,
        query,
        alloc,
    );
    try conn.push(pb.CombatReceivePackNotify{ .Data = combat_receive_pack }, alloc.arena);
}
