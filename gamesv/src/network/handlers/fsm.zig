const std = @import("std");
const pb = @import("proto").pb;
const dispatch = @import("combat.zig");
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const FsmTimerScheduler = @import("../../logic/schedulers/FsmTimerScheduler.zig");
const mem = @import("../../mem.zig");

pub fn ChangeStateRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateRequest),
    fsm_timers: *FsmTimerScheduler,
    scene: *Scene,
    assets: *const Assets,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    const request = txn.payload;
    const entity_id = if (txn.common) |common| common.EntityId else 0;
    const current_state = try fsm_timers.setCurrentState(
        alloc.gpa,
        scene,
        assets,
        entity_id,
        request.FsmId,
        request.ToState,
        nowMs(io),
    );

    txn.respond(.{
        .FsmId = request.FsmId,
        .CurrentState = current_state,
        .Error = pb.DErrorResult{ .ErrorCode = .Success },
    });
}

pub fn ChangeStateConfirmPush(
    push: pb.ChangeStateConfirmPush,
    common: ?pb.CombatCommon,
    fsm_timers: *FsmTimerScheduler,
    scene: *Scene,
    assets: *const Assets,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    const entity_id = if (common) |combat_common| combat_common.EntityId else return;
    _ = try fsm_timers.setCurrentState(
        alloc.gpa,
        scene,
        assets,
        entity_id,
        push.FsmId,
        push.State,
        nowMs(io),
    );
}

pub fn FsmConditionPassPush(
    push: pb.FsmConditionPassPush,
    common: ?pb.CombatCommon,
    fsm_timers: *FsmTimerScheduler,
    scene: *Scene,
    assets: *const Assets,
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    const log = std.log.scoped(.fsm_condition);
    const entity_id = if (common) |combat_common| combat_common.EntityId else return;

    try fsm_timers.recordClientPass(
        alloc.gpa,
        scene,
        assets,
        entity_id,
        push.FsmId,
        push.FromState,
        push.ToState,
        push.ConditionIndex,
        push.Value,
        nowMs(io),
    );

    log.debug("FsmId: {d}, FromState: {d}, ToState: {d}, ConditionIndex: {d}, Value: {}", .{
        push.FsmId,
        push.FromState,
        push.ToState,
        push.ConditionIndex,
        push.Value,
    });
}

pub fn AiHatePush(push: pb.AiHatePush) !void {
    const log = std.log.scoped(.fsm_ai_hate);

    for (push.HateList.items) |ai_hate| {
        log.debug("EntityID: {d}, HatredValue: {d}", .{ ai_hate.EntityId, ai_hate.HatredValue });
    }

    // TODO
}

pub fn FsmStateBehaviorRequest(
    txn: *dispatch.CombatRequestTxn(.FsmStateBehaviorRequest),
) !void {
    const request = txn.payload;
    txn.respond(.{
        .FsmId = request.FsmId,
        .State = request.State,
        .ErrorCode = .Success,
    });
}

fn nowMs(io: std.Io) i64 {
    const clock: std.Io.Clock = .awake;
    return clock.now(io).toMilliseconds();
}
