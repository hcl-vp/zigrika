const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Io = std.Io;

pub fn RTimeStopPush(
    push: pb.RTimeStopPush,
    scene: *Scene,
    io: Io,
) !void {
    const clock: Io.Clock = .awake;
    scene.scene_time.setDilation(clock.now(io).toMilliseconds(), push.Dilation);
}

pub fn onTimeStopPush(
    txn: *Transaction(pb.TimeStopPush),
    scene: *Scene,
    io: Io,
) !void {
    const clock: Io.Clock = .awake;
    scene.scene_time.setDilation(clock.now(io).toMilliseconds(), txn.message.TimeDilation);
}

pub fn onTimeCheckRequest(
    txn: *Transaction(pb.TimeCheckRequest),
    io: Io,
    scene: *Scene,
) !void {
    const rtc: Io.Clock = .real;
    const monotonic_clock: Io.Clock = .awake;
    const now_ms = rtc.now(io).toMilliseconds();
    const monotonic_now = monotonic_clock.now(io).toMilliseconds();
    txn.respond(.{
        .ClientTime = txn.message.ClientTime,
        .ServerTime = now_ms,
        .ServerCombatTime = now_ms,
        .ServerStopTime = now_ms,
        .ServerFlowTimestamp = scene.scene_time.currentFlowTimestamp(monotonic_now),
    });
}
