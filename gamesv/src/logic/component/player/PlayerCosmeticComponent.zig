const PlayerCosmeticComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");

const CosmeticInfo = @import("../../../fs/CosmeticInfo.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: CosmeticInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerCosmeticComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var info = try file_util.loadOrCreateZon(
        CosmeticInfo,
        gpa,
        arena,
        fs,
        "player/{}/{s}",
        .{ player_id, CosmeticInfo.data_path },
    );
    if (info.isEmpty()) {
        info.deinit(gpa);
        const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, CosmeticInfo.data_path });
        const serialized = try file_util.serializeZon(arena, CosmeticInfo.default);
        try fs.writeFile(path, serialized);
        info = try file_util.parseZon(CosmeticInfo, gpa, serialized, null);
    }

    return .{
        .player_id = player_id,
        .info = info,
    };
}

pub fn deinit(comp: *PlayerCosmeticComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}
