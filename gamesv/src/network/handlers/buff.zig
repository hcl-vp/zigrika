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

pub fn OrderApplyBuffRequest(
    txn: *dispatch.CombatRequestTxn(.OrderApplyBuffRequest),
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
        },
        else => {},
    }

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
    try conn.push(pb.CombatReceivePackNotify{ .Data = combat_receive_pack }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
    });
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
