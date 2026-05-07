const std = @import("std");
const pb = @import("proto").pb;
const Scene = @import("../../logic/Scene.zig");
const Io = std.Io;
const EventQueue = @import("../EventQueue.zig");

pub fn handleTimeTick(
    _: EventQueue.Dequeue(.tick_time),
    scene: *Scene,
    io: Io,
) !void {
    if (scene.scene_time.last_packet_time == 0) {
        return;
    }
    const rtc: Io.Clock = .real;
    const now_ms = rtc.now(io).toMilliseconds();
    const delta_ms: f64 = @floatFromInt(now_ms - scene.scene_time.last_packet_time);
    const flow_delta: i64 = @trunc(delta_ms * scene.scene_time.dilation);
    scene.scene_time.timestamp += flow_delta;
    scene.scene_time.last_packet_time = now_ms;
}
