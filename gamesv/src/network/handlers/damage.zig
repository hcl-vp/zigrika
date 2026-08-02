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
    assets: *const Assets,
    scene: *Scene,
    fs: *FileSystem,
    conn: *Connection,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
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
    try txn.receive_data_pack.appendSlice(alloc.arena, combat_receive_pack.items);

    // --- monster death removal: when a monster's HP reaches zero, remove it from the scene ---
    if (request.TargetEntityId != request.AttackerEntityId) {
        if (query.byNetId(request.TargetEntityId)) |target| {
            const target_entity, _, const target_attr = target;
            const life_idx = @intFromEnum(pb.EAttributeType.Life);
            const is_dead = if (target_attr) |attr|
                life_idx < attr.attributes.len and attr.attributes[life_idx].current <= 0
            else
                false;
            const is_monster = scene.entities.items(.config)[target_entity.index].entity_type == .monster;
            if (is_dead and is_monster) {
                try scene.remove(alloc.gpa, fs, request.TargetEntityId);
                var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;
                try remove_infos.append(alloc.arena, .{ .EntityId = request.TargetEntityId });
                try conn.push(pb.EntityRemoveNotify{
                    .IsRemove = true,
                    .RemoveInfos = remove_infos,
                });
            }
        }
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .Damage = execute_data.Damage,
        .ElementType = execute_data.ElementType,
        .TargetEntityId = request.TargetEntityId,
        .ChangeLife = execute_data.ChangeLife,
    });
}

pub fn HitEndPush(_: pb.HitEndPush) !void {}
