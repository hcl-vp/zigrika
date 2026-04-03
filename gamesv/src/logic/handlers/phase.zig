const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");

pub fn runEnterGamePhase(
    _: EventQueue.Dequeue(.enter_game),
    events: *EventQueue,
) !void {
    // events will be consumed sequentially, extend as needed
    try events.enqueue(.push_data, .{});
    try events.enqueue(.push_data_complete, .{});
    try events.enqueue(.initial_scene_join, .{});
}

pub fn notifyPushDataComplete(
    _: EventQueue.Dequeue(.push_data_complete),
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    try conn.push(pb.PushContextIdNotify{ .Id = 0 }, alloc.arena);
    try conn.push(pb.PushDataCompleteNotify{}, alloc.arena);
}

pub fn notifyAfterJoinScene(
    _: EventQueue.Dequeue(.after_scene_join),
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    try conn.push(pb.AfterJoinSceneNotify{}, alloc.arena);
}
