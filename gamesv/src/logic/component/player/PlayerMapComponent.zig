const PlayerMapComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const MapInfo = @import("../../../fs/MapInfo.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: MapInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerMapComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    return .{
        .player_id = player_id,
        .info = try file_util.loadOrCreateZon(
            MapInfo,
            gpa,
            arena,
            fs,
            "player/{}/{s}",
            .{ player_id, MapInfo.data_path },
        ),
    };
}

pub fn deinit(comp: *PlayerMapComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}

pub fn save(comp: *PlayerMapComponent, fs: *FileSystem, arena: Allocator) !void {
    const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ comp.player_id, MapInfo.data_path });
    const serialized = try file_util.serializeZon(arena, comp.info);
    try fs.writeFile(path, serialized);
}
