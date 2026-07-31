const std = @import("std");
const pb = @import("proto").pb;
const dispatch = @import("combat.zig");

pub fn ChangeStateRequest(
    txn: *dispatch.CombatRequestTxn(.ChangeStateRequest),
) !void {
    const request = txn.payload;

    txn.respond(.{
        .FsmId = request.FsmId,
        .CurrentState = request.ToState,
        .Error = pb.DErrorResult{ .ErrorCode = .Success },
    });
}

pub fn ChangeStateConfirmPush(_: pb.ChangeStateConfirmPush) !void {}

pub fn FsmConditionPassPush(
    push: pb.FsmConditionPassPush,
) !void {
    const log = std.log.scoped(.fsm_condition);

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
