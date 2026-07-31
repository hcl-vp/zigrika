const std = @import("std");
const pb = @import("proto").pb;
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const Events = @import("../../logic/events.zig");
const FileSystem = @import("common").FileSystem;
const PlayerSceneComponent = @import("../../logic/component/player/PlayerSceneComponent.zig");
const Connection = @import("../../network/Connection.zig");
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");

pub const flow = struct {
    pub const alias = "flow";
    pub const description = "starts a flow, also sends you to the map containing the flow.\nusage: flow [flow_namespace] [flow_id] [state_id]\nflow_namespace is a string, flow_id is a number, state_id is a number.";
    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        assets: *const Assets,
        fs: *FileSystem,
        scene: *Scene,
        conn: *Connection,
        scene_comp: *PlayerSceneComponent,
        flow_namespace: []const u8,
        flow_id: i32,
        state_id: i32,
    ) !void {
        try events.enqueue(.chat_command_response, .{ .content = "sending to flow..." });

        const flow_inst = assets.tables.flow.getDataById(try std.fmt.allocPrint(alloc.arena, "{s}_{d}", .{ flow_namespace, flow_id })) orelse return;
        try conn.push(pb.LeaveSceneNotify{
            .PlayerId = scene_comp.player_id,
            .SceneId = "",
            .TransitionOption = .{},
        });
        scene_comp.last_scene_info.instance_id = flow_inst.DungeonId;
        try scene.saveLastScene(scene_comp, fs, alloc.gpa);

        // this sucks btw
        try events.enqueue(.initial_scene_join, .{ .pending_flow = .{
            .inc_id = 1,
            .namespace = flow_namespace,
            .id = flow_id,
            .state = state_id,
        } });

        try events.enqueue(.chat_command_response, .{ .content = "probably, sent you to flow successfully!" });
    }
};
