const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Entity = Scene.Entity;

const FsmQuery = Scene.Query(&.{
    Entity,
    *Entity.FsmComponent,
    ?*Entity.AttributeComponent,
    ?*Entity.LogicStateComponent,
});

const LogicStateQuery = Scene.Query(&.{
    Entity,
    *Entity.LogicStateComponent,
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

pub fn ChangeStateRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateRequest),
    query: FsmQuery,
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

    const entity, const fsm, const attribute, const logic_state = item;
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
            try appendFollowupTransition(entity, fsm, txn.payload.FsmId, attribute, logic_state, now_ms, alloc, txn.receive_data_pack);
        },
        .accepted => current_state = fsm.currentState(txn.payload.FsmId) orelse current_state,
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
                .logic_state = logic_state,
                .now_ms = now_ms,
            })) |notify| {
                try txn.receive_data_pack.append(alloc.arena, notify);
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

    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .Error = response_error,
        .CurrentState = current_state,
    });
}

pub fn ChangeStateConfirmRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateConfirmRequest),
    query: FsmQuery,
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

    const entity, const fsm, const attribute, const logic_state = item;
    const now_ms = queryNow(io);
    try fsm.initRuntime(alloc.gpa, now_ms);
    defer fsm.finishTick(now_ms);

    var response_state = fsm.currentState(txn.payload.FsmId) orelse 0;
    var response_error: pb.DErrorResult = successResult();

    switch (try fsm.confirmPending(txn.payload.FsmId, txn.payload.State, alloc.gpa)) {
        .confirmed => {
            response_state = fsm.currentState(txn.payload.FsmId) orelse response_state;
            try appendFollowupTransition(entity, fsm, txn.payload.FsmId, attribute, logic_state, now_ms, alloc, txn.receive_data_pack);
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

    txn.respond(.{
        .FsmId = txn.payload.FsmId,
        .State = response_state,
        .Error = response_error,
    });
}

pub fn FsmConditionPassRequest(
    txn: *dispatch.CombatRequestTxn(.FsmConditionPassRequest),
    query: FsmQuery,
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

    const entity, const fsm, const attribute, const logic_state = item;
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

    if (pass_result == .updated) {
        if (try fsm.checkTransitions(entity.net_id, txn.payload.FsmId, .{
            .attribute = attribute,
            .logic_state = logic_state,
            .now_ms = now_ms,
        })) |notify| {
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

pub fn AiHateRequest(
    txn: *dispatch.CombatRequestTxn(.AiHateRequest),
    query: FsmQuery,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    if (commonEntityId(txn.common)) |entity_id| {
        if (query.byNetId(entity_id)) |item| {
            const entity, const fsm, const attribute, const logic_state = item;
            const now_ms = queryNow(io);
            try fsm.initRuntime(alloc.gpa, now_ms);
            defer fsm.finishTick(now_ms);
            _ = fsm.setHateFromList(txn.payload.HateList.items);
            try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, txn.receive_data_pack, .{
                .attribute = attribute,
                .logic_state = logic_state,
                .now_ms = now_ms,
            });
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
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        const entity, const fsm, const attribute, const logic_state = item;
        const now_ms = queryNow(io);
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        const pass_result = try fsm.recordClientPass(alloc.gpa, .{
            .fsm_id = push.FsmId,
            .from = push.FromState,
            .to = push.ToState,
            .index = push.ConditionIndex,
        }, push.Value);
        if (pass_result != .updated) return;
        if (try fsm.checkTransitions(entity.net_id, push.FsmId, .{
            .attribute = attribute,
            .logic_state = logic_state,
            .now_ms = now_ms,
        })) |notify| {
            try receive_data_pack.append(alloc.arena, notify);
        }
    }
}

pub fn AiHatePush(
    push: pb.AiHatePush,
    common: ?pb.CombatCommon,
    query: FsmQuery,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        const entity, const fsm, const attribute, const logic_state = item;
        const now_ms = queryNow(io);
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        _ = fsm.setHateFromList(push.HateList.items);
        try fsm.appendReadyStateTransitions(entity.net_id, alloc.arena, receive_data_pack, .{
            .attribute = attribute,
            .logic_state = logic_state,
            .now_ms = now_ms,
        });
    }
}

pub fn ChangeStateConfirmPush(
    push: pb.ChangeStateConfirmPush,
    common: ?pb.CombatCommon,
    query: FsmQuery,
    io: std.Io,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const entity_id = commonEntityId(common) orelse return;
    if (query.byNetId(entity_id)) |item| {
        const entity, const fsm, const attribute, const logic_state = item;
        const now_ms = queryNow(io);
        try fsm.initRuntime(alloc.gpa, now_ms);
        defer fsm.finishTick(now_ms);
        switch (try fsm.confirmPending(push.FsmId, push.State, alloc.gpa)) {
            .confirmed => try appendFollowupTransition(entity, fsm, push.FsmId, attribute, logic_state, now_ms, alloc, receive_data_pack),
            .accepted, .machine_not_found, .invalid_source, .invalid_target, .mismatch, .no_pending => {},
        }
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
    logic_state: ?*Entity.LogicStateComponent,
    now_ms: i64,
    alloc: mem.Alloc,
    receive_data_pack: *std.ArrayList(pb.CombatReceiveData),
) !void {
    if (try fsm.checkTransitions(entity.net_id, fsm_id, .{
        .attribute = attribute,
        .logic_state = logic_state,
        .now_ms = now_ms,
    })) |notify| {
        try receive_data_pack.append(alloc.arena, notify);
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
