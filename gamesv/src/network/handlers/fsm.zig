const std = @import("std");
const pb = @import("proto").pb;

pub fn FsmConditionPassPush(push: pb.FsmConditionPassPush) !void {
    const log = std.log.scoped(.fsm_condition);

    log.debug("FsmId: {d}, FromState: {d}, ToState: {d}, ConditionIndex: {d}, Value: {}", .{
        push.FsmId,
        push.FromState,
        push.ToState,
        push.ConditionIndex,
        push.Value,
    });

    // TODO
}

pub fn AiHatePush(push: pb.AiHatePush) !void {
    const log = std.log.scoped(.fsm_ai_hate);

    for (push.HateList.items) |ai_hate| {
        log.debug("EntityID: {d}, HatredValue: {d}", .{ ai_hate.EntityId, ai_hate.HatredValue });
    }

    // TODO
}
