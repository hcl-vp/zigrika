const PlayerGuideComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const GuideInfo = @import("../../../fs/GuideInfo.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: GuideInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerGuideComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    return .{
        .player_id = player_id,
        .info = try file_util.loadOrCreateZon(
            GuideInfo,
            gpa,
            arena,
            fs,
            "player/{}/{s}",
            .{ player_id, GuideInfo.data_path },
        ),
    };
}

pub fn deinit(comp: *PlayerGuideComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}
