const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const Io = std.Io;

pub fn RTimeStopPush(
    push: pb.RTimeStopPush,
    scene: *Scene,
) !void {
    scene.scene_time.dilation = push.Dilation;
}

pub fn onTimeStopPush(
    txn: *Transaction(pb.TimeStopPush),
    scene: *Scene,
) !void {
    scene.scene_time.dilation = txn.message.TimeDilation;
}

pub fn onTimeCheckRequest(
    txn: *Transaction(pb.TimeCheckRequest),
    io: Io,
    scene: *Scene,
) !void {
    const rtc: Io.Clock = .real;
    const now_ms = rtc.now(io).toMilliseconds();
    txn.respond(.{
        .ClientTime = txn.message.ClientTime,
        .ServerTime = now_ms,
        .ServerCombatTime = now_ms,
        .ServerStopTime = now_ms,
        .ServerFlowTimestamp = scene.scene_time.timestamp,
    });
}
