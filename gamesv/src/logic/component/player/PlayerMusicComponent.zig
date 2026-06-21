const PlayerMusicComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const MusicInfo = @import("../../../fs/MusicInfo.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: MusicInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerMusicComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    return .{
        .player_id = player_id,
        .info = try file_util.loadOrCreateZon(
            MusicInfo,
            gpa,
            arena,
            fs,
            "player/{}/{s}",
            .{ player_id, MusicInfo.data_path },
        ),
    };
}

pub fn deinit(comp: *PlayerMusicComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}

pub fn save(comp: *PlayerMusicComponent, fs: *FileSystem, arena: Allocator) !void {
    const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ comp.player_id, MusicInfo.data_path });
    const serialized = try file_util.serializeZon(arena, comp.info);
    try fs.writeFile(path, serialized);
}
