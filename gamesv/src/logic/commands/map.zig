const pb = @import("proto").pb;
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const PlayerSceneComponent = @import("../../logic/component/player/PlayerSceneComponent.zig");
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");

pub const map = struct {
    pub const alias = "m";
    pub const description = "sends you to the map id in the first parameter.\nusage: map [map_id]\nmap_id is a number.";
    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        fs: *FileSystem,
        scene: *Scene,
        conn: *Connection,
        scene_comp: *PlayerSceneComponent,
        map_id: i32,
    ) !void {
        try events.enqueue(.chat_command_response, .{ .content = "sending to map..." });

        try conn.push(pb.LeaveSceneNotify{
            .PlayerId = scene_comp.player_id,
            .SceneId = "",
            .TransitionOption = .{},
        });
        scene_comp.last_scene_info.instance_id = map_id;
        try scene.saveLastScene(scene_comp, fs, alloc.gpa);
        try events.enqueue(.initial_scene_join, .{});

        try events.enqueue(.chat_command_response, .{ .content = "probably, sent you to map successfully!" });
    }
};
