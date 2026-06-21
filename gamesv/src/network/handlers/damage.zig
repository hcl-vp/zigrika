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
const damage_helper = @import("../../logic/helpers/damage.zig");

// TODO: make energy regen be based on the damage context as current approach suffers an issue with multi-target.
pub fn DamageExecuteRequest(
    txn: *dispatch.CombatRequestTxn(.DamageExecuteRequest),
    conn: *Connection,
    assets: *const Assets,
    scene: *Scene,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        *Entity.AttributeComponent,
    }),
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const request: pb.DamageExecuteRequest = txn.payload;
    const damage = assets.tables.damage.getDataById(request.DamageId) orelse {
        txn.respond(.{ .ErrorCode = .ErrConfDamageNotFound });
        return;
    };

    var combat_receive_pack: std.ArrayList(pb.CombatReceiveData) = .empty;

    const execute_data = try damage_helper.damageEntity(
        &combat_receive_pack,
        request,
        &damage,
        scene,
        fs,
        io,
        query,
        alloc,
    );
    try conn.push(pb.CombatMessage.CombatReceivePackNotify{ .Data = combat_receive_pack }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .Damage = execute_data.Damage,
        .ElementType = execute_data.ElementType,
    });
}
