const PlayerMotorComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");

const MotorInfo = @import("../../../fs/MotorInfo.zig");
const Assets = @import("../../../data/Assets.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: MotorInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerMotorComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var info = try file_util.loadZon(
        MotorInfo,
        gpa,
        arena,
        fs,
        "player/{}/{s}",
        .{ player_id, MotorInfo.data_path },
    ) orelse MotorInfo{};

    if (info.isEmpty()) {
        try info.addDefaults(gpa, assets);
        const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, MotorInfo.data_path });
        const serialized = try file_util.serializeZon(arena, info);
        try fs.writeFile(path, serialized);
    }

    return .{
        .player_id = player_id,
        .info = info,
    };
}

pub fn deinit(comp: *PlayerMotorComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}

pub fn save(comp: *PlayerMotorComponent, fs: *FileSystem, arena: Allocator) !void {
    const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ comp.player_id, MotorInfo.data_path });
    const serialized = try file_util.serializeZon(arena, comp.info);
    try fs.writeFile(path, serialized);
}
