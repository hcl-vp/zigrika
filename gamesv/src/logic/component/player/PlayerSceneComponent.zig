const PlayerSceneComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const LastSceneInfo = @import("../../../fs/LastSceneInfo.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
last_scene_info: LastSceneInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerSceneComponent {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    return .{
        .player_id = player_id,
        .last_scene_info = try file_util.loadOrCreateZon(
            LastSceneInfo,
            gpa,
            arena.allocator(),
            fs,
            "player/{}/last_scene",
            .{player_id},
        ),
    };
}

pub fn deinit(comp: *PlayerSceneComponent, gpa: Allocator) void {
    comp.last_scene_info.deinit(gpa);
}
