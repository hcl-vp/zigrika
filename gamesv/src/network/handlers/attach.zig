const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Entity = Scene.Entity;

const AttachQuery = Scene.Query(&.{
    Entity,
    ?*Entity.CharacterAttachComponent,
    ?*Entity.PartComponent,
});

pub fn CharacterAttachRequest(
    txn: *dispatch.CombatRequestTxn(.CharacterAttachRequest),
    scene: *Scene,
    query: AttachQuery,
    alloc: mem.Alloc,
) !void {
    if (attachEnvelopeError(commonEntityId(txn.common), txn.payload.CharacterAttachInfo, txn.payload.TargetEntity)) |code| {
        txn.respond(.{ .ErrorCode = code });
        return;
    }

    const info = txn.payload.CharacterAttachInfo.?;
    const position = info.Pos.?;
    const rotation = info.Rot.?;
    const combine_item = query.byNetId(info.EntityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrCombinerEntityNotExists });
        return;
    };
    if (combine_item[1] == null) {
        txn.respond(.{ .ErrorCode = .ErrCombineComponentNotExists });
        return;
    }

    const target_item = query.byNetId(txn.payload.TargetEntity) orelse {
        txn.respond(.{ .ErrorCode = .ErrTargetEntityNotExists });
        return;
    };
    if (target_item[1] == null) {
        txn.respond(.{ .ErrorCode = .ErrCombineComponentNotExists });
        return;
    }
    const target_parts = target_item[2] orelse {
        txn.respond(.{ .ErrorCode = .ErrTargetPartNotExists });
        return;
    };
    if (!target_parts.supportsCombinePart(info.PartIndex)) {
        txn.respond(.{ .ErrorCode = .ErrTargetPartNotExists });
        return;
    }

    try txn.receive_data_pack.ensureUnusedCapacity(alloc.arena, 1);
    _ = scene.registerCombineRelation(alloc.gpa, info.EntityId, .{
        .target_entity_id = txn.payload.TargetEntity,
        .part_index = info.PartIndex,
        .position = position,
        .rotation = rotation,
    }) catch |err| switch (err) {
        error.CombineRelationConflict => {
            txn.respond(.{ .ErrorCode = .ErrAlreadyCombineToOtherEntity });
            return;
        },
        else => return err,
    };

    txn.receive_data_pack.appendAssumeCapacity(attachNotify(info, txn.payload.TargetEntity));
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn CharacterDetachRequest(
    txn: *dispatch.CombatRequestTxn(.CharacterDetachRequest),
    scene: *Scene,
    query: AttachQuery,
    alloc: mem.Alloc,
) !void {
    const combine_entity_id = commonEntityId(txn.common) orelse {
        txn.respond(.{ .ErrorCode = .ErrCombineEntityNotFound });
        return;
    };
    if (txn.payload.EntityA == 0 or txn.payload.EntityB == 0 or txn.payload.EntityA != combine_entity_id) {
        txn.respond(.{ .ErrorCode = .ErrCombineEntityNotFound });
        return;
    }

    const combine_item = query.byNetId(combine_entity_id) orelse {
        txn.respond(.{ .ErrorCode = .ErrCombineEntityNotFound });
        return;
    };
    if (combine_item[1] == null) {
        txn.respond(.{ .ErrorCode = .ErrCombineComponentNotExists });
        return;
    }
    const target_item = query.byNetId(txn.payload.EntityB) orelse {
        txn.respond(.{ .ErrorCode = .ErrTargetEntityNotExists });
        return;
    };
    if (target_item[1] == null) {
        txn.respond(.{ .ErrorCode = .ErrCombineComponentNotExists });
        return;
    }

    try txn.receive_data_pack.ensureUnusedCapacity(alloc.arena, 1);
    _ = scene.detachCombineRelation(combine_entity_id, txn.payload.EntityB) orelse {
        txn.respond(.{ .ErrorCode = .ErrCombineEntityNotFound });
        return;
    };
    const detach: Scene.CombineDetach = .{
        .combine_entity_id = combine_entity_id,
        .target_entity_id = txn.payload.EntityB,
    };
    txn.receive_data_pack.appendAssumeCapacity(Scene.removeCombineNotify(detach));
    try scene.signalFsmDissolveCombine(alloc.gpa, combine_entity_id);
    txn.respond(.{ .ErrorCode = .Success });
}

fn attachEnvelopeError(
    common_entity_id: ?i64,
    maybe_info: ?pb.CharacterAttachInfo,
    target_entity_id: i64,
) ?pb.ErrorCode {
    const info = maybe_info orelse return .ErrLackCombinePartInfoParam;
    const common_id = common_entity_id orelse return .ErrCombinerEntityNotExists;
    if (info.EntityId == 0 or info.EntityId != common_id) return .ErrCombinerEntityNotExists;
    if (target_entity_id == 0 or target_entity_id == info.EntityId) return .ErrTargetEntityNotExists;
    if (info.Pos == null) return .ErrLackCombinerOffsetPos;
    if (info.Rot == null) return .ErrLackCombinerOffsetRotate;
    return null;
}

fn attachNotify(info: pb.CharacterAttachInfo, target_entity_id: i64) pb.CombatReceiveData {
    return .{ .Message = .{ .CombatNotifyData = .{
        .CombatCommon = .{ .EntityId = info.EntityId },
        .Message = .{ .AddCombineEntitiesRelationNotify = .{
            .CharacterAttachInfo = info,
            .TargetEntity = target_entity_id,
        } },
    } } };
}

fn commonEntityId(common: ?pb.CombatCommon) ?i64 {
    const value = common orelse return null;
    if (value.EntityId == 0) return null;
    return value.EntityId;
}
