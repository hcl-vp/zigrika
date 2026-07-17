const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const FsmLifecycle = @import("../../logic/FsmLifecycle.zig");
const Scene = @import("../../logic/Scene.zig");
const Entity = Scene.Entity;

const FsmQuery = Scene.Query(&.{
    Entity,
    *Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.FightBuffComponent,
    ?*Entity.LogicStateComponent,
    ?*Entity.TagComponent,
    ?*Entity.PartComponent,
});

const AiHateQuery = Scene.Query(&.{
    Entity,
    *Entity.MonsterAiComponent,
    ?*Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.FightBuffComponent,
    ?*Entity.LogicStateComponent,
    ?*Entity.TagComponent,
    ?*Entity.PartComponent,
});

const LogicStateQuery = Scene.Query(&.{
    Entity,
    *Entity.LogicStateComponent,
});

const GameplayTagQuery = Scene.Query(&.{
    Entity,
    ?*Entity.TagComponent,
    ?*Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.FightBuffComponent,
    ?*Entity.LogicStateComponent,
    ?*Entity.PartComponent,
});

pub fn HitRequest(txn: *dispatch.CombatRequestTxn(.HitRequest)) !void {
    txn.respond(.{
        .HitInfo = txn.payload.HitInfo,
        .ErrorCode = .Success,
    });
}

pub fn HitEndRequest(txn: *dispatch.CombatRequestTxn(.HitEndRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn AnimationGameplayTagRequest(
    txn: *dispatch.CombatRequestTxn(.AnimationGameplayTagRequest),
    query: GameplayTagQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const entity_id = commonEntityId(txn.common) orelse {
        txn.respond(.{ .ErrorCode = .ErrEntityNotFound });
        return;
    };
    const item = query.byNetId(entity_id) orelse {
        txn.respond(.{ .ErrorCode = .ErrEntityNotFound });
        return;
    };

    const entity, const optional_tags, const fsm, const attribute, const buffs, const logic_state, const parts = item;
    const tags = optional_tags orelse {
        txn.respond(.{ .ErrorCode = .ErrMonsterNotGameplayTagComp });
        return;
    };
    try applyGameplayTagChange(
        entity,
        tags,
        fsm,
        attribute,
        buffs,
        logic_state,
        parts,
        txn.payload.AddTagIds,
        txn.payload.RemoveTagIds,
        events,
        io,
        alloc,
        txn.receive_data_pack,
    );
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn AnimationGameplayTagPush(
    push: pb.AnimationGameplayTagPush,
    common: ?pb.CombatCommon,
    query: GameplayTagQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    const item = query.byNetId(entity_id) orelse return;
    const entity, const optional_tags, const fsm, const attribute, const buffs, const logic_state, const parts = item;
    const tags = optional_tags orelse return;

    try applyGameplayTagChange(
        entity,
        tags,
        fsm,
        attribute,
        buffs,
        logic_state,
        parts,
        push.AddTagIds,
        push.RemoveTagIds,
        events,
        io,
        alloc,
        receive_data_pack,
    );
}

pub fn ChangeStateRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateRequest),
    query: FsmQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const entity_id = commonEntityId(txn.common) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
            .CurrentState = 0,
        });
        return;
    };
    const item = query.byNetId(entity_id) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
            .CurrentState = 0,
        });
        return;
    };

    const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
    const now_ms = queryNow(io);
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);

    var current_state = fsm.currentState(txn.payload.FsmId) orelse 0;
    var response_error: pb.DErrorResult = successResult();

    switch (try fsm.confirmStateRequest(
        txn.payload.FsmId,
        txn.payload.FromState,
        txn.payload.ToState,
        alloc.gpa,
        now_ms,
    )) {
        .confirmed => {
            current_state = fsm.currentState(txn.payload.FsmId) orelse current_state;
            if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
                try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, txn.receive_data_pack);
                try appendFollowupTransition(entity, fsm, txn.payload.FsmId, attribute, buffs, logic_state, tags, parts, now_ms, alloc, txn.receive_data_pack);
            }
        },
        .accepted => {
            current_state = fsm.currentState(txn.payload.FsmId) orelse current_state;
            if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
                try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, txn.receive_data_pack);
                try appendFollowupTransition(entity, fsm, txn.payload.FsmId, attribute, buffs, logic_state, tags, parts, now_ms, alloc, txn.receive_data_pack);
            }
        },
        .mismatch => |pending_state| {
            current_state = pending_state;
            response_error = try errorResult(alloc.arena, .ErrIEntityFsmActionNotMatchState, &.{
                txn.payload.FsmId,
                txn.payload.ToState,
                pending_state,
            });
        },
        .machine_not_found => response_error = try errorResult(alloc.arena, .ErrEntityFsmMachineNotExist, &.{txn.payload.FsmId}),
        .invalid_source => response_error = try errorResult(alloc.arena, .ErrEntityFsmStateIncorrect, &.{
            txn.payload.FsmId,
            txn.payload.FromState,
            current_state,
        }),
        .invalid_target => response_error = try errorResult(alloc.arena, .ErrIEntityFsmTransitToState, &.{
            txn.payload.FsmId,
            txn.payload.ToState,
        }),
        .no_pending => {
            if (try fsm.checkAndConfirm(entity.net_id, txn.payload.FsmId, alloc.gpa, .{
                .attribute = attribute,
                .buffs = buffs,
                .logic_state = logic_state,
                .tags = tags,
                .parts = if (parts) |part| part.states() else null,
                .now_ms = now_ms,
            })) |notify| {
                try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, txn.receive_data_pack);
                try txn.receive_data_pack.append(alloc.arena, notify);
                _ = try FsmLifecycle.enqueueEffectsWithoutRecheck(entity, fsm, events, alloc, now_ms);
                const transition = notify.Message.?.CombatNotifyData.?.Message.?.ChangeStateNotify.?;
                current_state = transition.ToState;
                response_error = try errorResult(alloc.arena, .ErrIEntityFsmConfirmNotWait, &.{
                    transition.FsmId,
                    transition.FromState,
                    transition.ToState,
                });
            } else {
                current_state = fsm.currentState(txn.payload.FsmId) orelse current_state;
                response_error = try errorResult(alloc.arena, .ErrIEntityFsmConfirmNotExist, &.{
                    txn.payload.FsmId,
                    current_state,
                });
            }
        },
    }
    _ = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);

    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .Error = response_error,
        .CurrentState = current_state,
    });
}

pub fn ChangeStateConfirmRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateConfirmRequest),
    query: FsmQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const entity_id = commonEntityId(txn.common) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .State = 0,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
        });
        return;
    };
    const item = query.byNetId(entity_id) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .State = 0,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
        });
        return;
    };

    const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
    const now_ms = queryNow(io);
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);

    var response_state = fsm.currentState(txn.payload.FsmId) orelse 0;
    var response_error: pb.DErrorResult = successResult();

    switch (try fsm.confirmPending(txn.payload.FsmId, txn.payload.State, alloc.gpa)) {
        .confirmed => {
            response_state = fsm.currentState(txn.payload.FsmId) orelse response_state;
            if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
                try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, txn.receive_data_pack);
                try appendFollowupTransition(entity, fsm, txn.payload.FsmId, attribute, buffs, logic_state, tags, parts, now_ms, alloc, txn.receive_data_pack);
            }
        },
        .mismatch => |pending_state| {
            response_state = pending_state;
            response_error = try errorResult(alloc.arena, .ErrIEntityFsmActionNotMatchState, &.{
                txn.payload.FsmId,
                txn.payload.State,
                pending_state,
            });
        },
        .machine_not_found => response_error = try errorResult(alloc.arena, .ErrEntityFsmMachineNotExist, &.{txn.payload.FsmId}),
        .invalid_target => response_error = try errorResult(alloc.arena, .ErrIEntityFsmTransitToState, &.{
            txn.payload.FsmId,
            txn.payload.State,
        }),
        .no_pending => response_error = try errorResult(alloc.arena, .ErrIEntityFsmConfirmNotExist, &.{
            txn.payload.FsmId,
            response_state,
        }),
        .accepted => response_state = fsm.currentState(txn.payload.FsmId) orelse response_state,
        .invalid_source => response_error = try errorResult(alloc.arena, .ErrEntityFsmStateIncorrect, &.{
            txn.payload.FsmId,
            response_state,
        }),
    }
    _ = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);

    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .State = response_state,
        .Error = response_error,
    });
}

pub fn FsmConditionPassRequest(
    txn: *dispatch.CombatRequestTxn(.FsmConditionPassRequest),
    query: FsmQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const entity_id = commonEntityId(txn.common) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
        });
        return;
    };
    const item = query.byNetId(entity_id) orelse {
        txn.respond(.{
            .FsmId = txn.payload.FsmId,
            .Error = try errorResult(alloc.arena, .ErrEntityNotFound, &.{}),
        });
        return;
    };

    const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
    const now_ms = queryNow(io);
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);
    const pass_result = try fsm.recordClientPass(alloc.gpa, .{
        .fsm_id = txn.payload.FsmId,
        .from = txn.payload.FromState,
        .to = txn.payload.ToState,
        .index = txn.payload.ConditionIndex,
    }, txn.payload.Value);
    const response_error = try clientPassError(alloc.arena, pass_result, txn.payload);
    const lifecycle_deferred = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);

    if (pass_result == .updated and !lifecycle_deferred) {
        if (try fsm.checkTransitions(entity.net_id, txn.payload.FsmId, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
            .now_ms = now_ms,
        })) |notify| {
            try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, txn.receive_data_pack);
            try txn.receive_data_pack.append(alloc.arena, notify);
        }
    }

    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .Error = response_error,
    });
}

pub fn FsmStateBehaviorRequest(
    txn: *dispatch.CombatRequestTxn(.FsmStateBehaviorRequest),
) !void {
    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .State = txn.payload.State,
        .ErrorCode = .Success,
    });
}

pub fn FsmPlayMontageRequest(txn: *dispatch.CombatRequestTxn(.FsmPlayMontageRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn FsmPlayMontagePush(_: pb.FsmPlayMontagePush) !void {}

pub fn AiHateRequest(
    txn: *dispatch.CombatRequestTxn(.AiHateRequest),
    scene: *Scene,
    query: AiHateQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    if (commonEntityId(txn.common)) |entity_id| {
        if (query.byNetId(entity_id)) |item| {
            try applyAiHate(scene, item, txn.payload.HateList.items, events, queryNow(io), alloc, txn.receive_data_pack);
        }
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn LogicStateInitRequest(
    txn: *dispatch.CombatRequestTxn(.LogicStateInitRequest),
    query: LogicStateQuery,
) !void {
    updateLogicState(query, txn.payload.EntityId, txn.payload.CombatCommon, txn.payload.InitData);
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn SwitchLogicStateRequest(
    txn: *dispatch.CombatRequestTxn(.SwitchLogicStateRequest),
    query: LogicStateQuery,
) !void {
    updateLogicState(query, 0, txn.common, txn.payload.States);
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn FsmConditionPassPush(
    push: pb.FsmConditionPassPush,
    common: ?pb.CombatCommon,
    query: FsmQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
        const now_ms = queryNow(io);
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        const pass_result = try fsm.recordClientPass(alloc.gpa, .{
            .fsm_id = push.FsmId,
            .from = push.FromState,
            .to = push.ToState,
            .index = push.ConditionIndex,
        }, push.Value);
        const lifecycle_deferred = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);
        if (pass_result != .updated) return;
        if (lifecycle_deferred) return;
        if (try fsm.checkTransitions(entity.net_id, push.FsmId, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
            .now_ms = now_ms,
        })) |notify| {
            try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, receive_data_pack);
            try receive_data_pack.append(alloc.arena, notify);
        }
    }
}

pub fn AiHatePush(
    push: pb.AiHatePush,
    common: ?pb.CombatCommon,
    scene: *Scene,
    query: AiHateQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        try applyAiHate(scene, item, push.HateList.items, events, queryNow(io), alloc, receive_data_pack);
    }
}

pub fn ChangeStateConfirmPush(
    push: pb.ChangeStateConfirmPush,
    common: ?pb.CombatCommon,
    query: FsmQuery,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        const entity, const fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;
        const now_ms = queryNow(io);
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        switch (try fsm.confirmPending(push.FsmId, push.State, alloc.gpa)) {
            .confirmed => {
                if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
                    try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, receive_data_pack);
                    try appendFollowupTransition(entity, fsm, push.FsmId, attribute, buffs, logic_state, tags, parts, now_ms, alloc, receive_data_pack);
                }
            },
            .accepted, .machine_not_found, .invalid_source, .invalid_target, .mismatch, .no_pending => {},
        }
        _ = try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms);
    }
}

pub fn LogicStateInitPush(
    push: pb.LogicStateInitPush,
    common: ?pb.CombatCommon,
    query: LogicStateQuery,
) !void {
    updateLogicState(query, push.EntityId, push.CombatCommon orelse common, push.InitData);
}

pub fn SwitchLogicStatePush(
    push: pb.SwitchLogicStatePush,
    common: ?pb.CombatCommon,
    query: LogicStateQuery,
) !void {
    updateLogicState(query, 0, common, push.States);
}

fn updateLogicState(
    query: LogicStateQuery,
    entity_id: i64,
    common: ?pb.CombatCommon,
    state_data: ?pb.LogicStateComponentPb,
) void {
    const target_id = if (entity_id != 0) entity_id else commonEntityId(common) orelse return;
    const data = state_data orelse return;
    if (query.byNetId(target_id)) |item| {
        _, const logic_state = item;
        logic_state.position_state = data.PositionState;
        logic_state.move_state = data.MoveState;
        logic_state.direction_state = data.DirectionState;
        logic_state.position_sub_state = data.PositionSubState;
    }
}

fn appendFollowupTransition(
    entity: Entity,
    fsm: *Entity.FsmComponent,
    fsm_id: i32,
    attribute: ?*Entity.AttributeComponent,
    buffs: ?*Entity.FightBuffComponent,
    logic_state: ?*Entity.LogicStateComponent,
    tags: ?*Entity.TagComponent,
    parts: ?*Entity.PartComponent,
    now_ms: i64,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    if (try fsm.checkTransitions(entity.net_id, fsm_id, .{
        .attribute = attribute,
        .buffs = buffs,
        .logic_state = logic_state,
        .tags = tags,
        .parts = if (parts) |part| part.states() else null,
        .now_ms = now_ms,
    })) |notify| {
        try fsm.appendBlackboardNotify(entity.net_id, alloc.arena, receive_data_pack);
        try receive_data_pack.append(alloc.arena, notify);
    }
}

fn applyAiHate(
    scene: *Scene,
    item: AiHateQuery.Item,
    hate_list: []const pb.AiHateEntity,
    events: *EventQueue,
    now_ms: i64,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity, _, const optional_fsm, const attribute, const buffs, const logic_state, const tags, const parts = item;

    try scene.updateBattleEntityFromHate(alloc.gpa, entity.net_id, hate_list);
    _ = try scene.appendBattleStateNotify(alloc.arena, receive_data_pack);

    const fsm = optional_fsm orelse return;
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);
    _ = fsm.setHateFromList(hate_list);
    if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, receive_data_pack, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
            .now_ms = now_ms,
        });
    }
}

fn applyGameplayTagChange(
    entity: Entity,
    tags: *Entity.TagComponent,
    optional_fsm: ?*Entity.FsmComponent,
    attribute: ?*Entity.AttributeComponent,
    buffs: ?*Entity.FightBuffComponent,
    logic_state: ?*Entity.LogicStateComponent,
    parts: ?*Entity.PartComponent,
    tag_id: i32,
    add: bool,
    events: *EventQueue,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    if (tag_id == 0) return;
    const changed = try tags.adjustGameplayTagCount(alloc.gpa, tag_id, if (add) 1 else -1);
    if (!changed) return;

    const fsm = optional_fsm orelse return;
    const now_ms = queryNow(io);
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);

    if (!try FsmLifecycle.enqueueEffects(entity, fsm, events, alloc, now_ms)) {
        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, receive_data_pack, .{
            .attribute = attribute,
            .buffs = buffs,
            .logic_state = logic_state,
            .tags = tags,
            .parts = if (parts) |part| part.states() else null,
            .now_ms = now_ms,
        });
    }
}

fn queryNow(io: std.Io) i64 {
    const rtc: std.Io.Clock = .awake;
    return rtc.now(io).toMilliseconds();
}

fn commonEntityId(common: ?pb.CombatCommon) ?i64 {
    const value = common orelse return null;
    if (value.EntityId == 0) return null;
    return value.EntityId;
}

fn successResult() pb.DErrorResult {
    return .{ .ErrorCode = .Success };
}

fn clientPassError(
    arena: std.mem.Allocator,
    result: Entity.FsmComponent.ClientPassResult,
    payload: pb.FsmConditionPassRequest,
) !pb.DErrorResult {
    return switch (result) {
        .updated => successResult(),
        .machine_not_found => try errorResult(arena, .ErrEntityFsmMachineNotExist, &.{payload.FsmId}),
        .invalid_source => try errorResult(arena, .ErrEntityFsmStateIncorrect, &.{
            payload.FsmId,
            payload.FromState,
        }),
        .invalid_target => try errorResult(arena, .ErrIEntityFsmTransitToState, &.{
            payload.FsmId,
            payload.ToState,
        }),
        .inactive_source, .transition_not_found, .condition_not_found, .condition_not_client => try errorResult(
            arena,
            .ErrIEntityFsmActionNotMatchState,
            &.{ payload.FsmId, payload.FromState, payload.ToState, payload.ConditionIndex },
        ),
    };
}

fn errorResult(arena: std.mem.Allocator, code: pb.ErrorCode, params: []const i32) !pb.DErrorResult {
    var error_params: std.ArrayList([]const u8) = .empty;
    for (params) |param| {
        try error_params.append(arena, try std.fmt.allocPrint(arena, "{d}", .{param}));
    }

    return .{
        .ErrorCode = code,
        .ErrorParams = error_params,
    };
}

test "ai hate handling does not require an fsm component" {
    const FormationInfo = @import("../../fs/FormationInfo.zig");
    const Role = FormationInfo.Formation.Role;
    var formations = [_]FormationInfo.Formation{.{
        .cur_role = 1001,
        .roles = .{
            Role{ .role_id = 1001, .entity_id = 11 },
            null,
            null,
        },
    }};
    var scene: Scene = undefined;
    scene.player_id = 1;
    scene.formation_info = .{ .cur_formation = 0, .formations = &formations };
    scene.active_battle_entities = .empty;
    scene.player_in_battle = false;
    scene.battle_state_notified = false;
    scene.battle_state_dirty = false;
    defer scene.active_battle_entities.deinit(std.testing.allocator);

    var monster_ai: Entity.MonsterAiComponent = .{};
    const item: AiHateQuery.Item = .{
        .{ .index = 0, .net_id = 101 },
        &monster_ai,
        null,
        null,
        null,
        null,
        null,
        null,
    };
    var events: EventQueue = .{ .arena = std.testing.allocator };
    defer events.deque.deinit(std.testing.allocator);
    var output: std.ArrayList(pb.CombatReceiveData) = .empty;
    defer output.deinit(std.testing.allocator);
    const alloc: mem.Alloc = .{ .gpa = std.testing.allocator, .arena = std.testing.allocator };

    const formation_hate = [_]pb.AiHateEntity{.{ .EntityId = 11, .HatredValue = 1 }};
    try applyAiHate(&scene, item, &formation_hate, &events, 100, alloc, &output);
    try std.testing.expect(scene.player_in_battle);
    try std.testing.expectEqual(@as(usize, 1), scene.active_battle_entities.count());
    try std.testing.expectEqual(@as(usize, 1), output.items.len);
    try std.testing.expect(output.items[0].Message.?.CombatNotifyData.?.Message.?.PlayerBattleStateChangeNotify.?.InBattle);
    try std.testing.expect(events.deque.popFront() == null);

    const empty_hate: [0]pb.AiHateEntity = .{};
    try applyAiHate(&scene, item, &empty_hate, &events, 200, alloc, &output);
    try std.testing.expect(!scene.player_in_battle);
    try std.testing.expectEqual(@as(usize, 0), scene.active_battle_entities.count());
    try std.testing.expectEqual(@as(usize, 2), output.items.len);
    try std.testing.expect(!output.items[1].Message.?.CombatNotifyData.?.Message.?.PlayerBattleStateChangeNotify.?.InBattle);

    const TestAssets = @import("../../data/Assets.zig");
    const AiStateMachineConfig = TestAssets.DataTables.AiStateMachineConfig;
    const hate_conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondHate" },
    };
    const hate_transitions = [_]AiStateMachineConfig.StateMachineTransition{
        .{ .From = 2, .To = 3, .Conditions = &hate_conditions },
    };
    const fsm_children = [_]i32{ 2, 3 };
    const fsm_nodes = [_]AiStateMachineConfig.StateMachineNode{
        .{ .Uuid = 1, .Children = &fsm_children, .Transitions = &hate_transitions },
        .{ .Uuid = 2 },
        .{ .Uuid = 3 },
    };
    var graph_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer graph_arena.deinit();
    const graph = (try TestAssets.FsmGraphRegistry.buildGraph(
        graph_arena.allocator(),
        .{ .Version = 1, .StateMachines = &.{1}, .Nodes = &fsm_nodes },
        .{ .Version = 2, .StateMachines = &.{}, .Nodes = &.{} },
    )) orelse return error.InvalidTestFsmGraph;
    var fsm: Entity.FsmComponent = .{
        .graph = &graph,
    };
    defer fsm.deinit(std.testing.allocator);
    const fsm_item: AiHateQuery.Item = .{
        .{ .index = 0, .net_id = 101 },
        &monster_ai,
        &fsm,
        null,
        null,
        null,
        null,
        null,
    };
    const non_formation_hate = [_]pb.AiHateEntity{.{ .EntityId = 33, .HatredValue = 1 }};
    try applyAiHate(&scene, fsm_item, &non_formation_hate, &events, 300, alloc, &output);
    try std.testing.expect(fsm.in_hate);
    try std.testing.expect(!scene.player_in_battle);
    try std.testing.expectEqual(@as(usize, 3), output.items.len);
    const transition = output.items[2].Message.?.CombatNotifyData.?.Message.?.ChangeStateNotify.?;
    try std.testing.expectEqual(@as(i32, 2), transition.FromState);
    try std.testing.expectEqual(@as(i32, 3), transition.ToState);
}

test "ai hate query requires ai and keeps fsm optional" {
    const fields = @typeInfo(AiHateQuery.Item).@"struct".fields;
    try std.testing.expect(fields[1].type == *Entity.MonsterAiComponent);
    try std.testing.expect(fields[2].type == ?*Entity.FsmComponent);
}
