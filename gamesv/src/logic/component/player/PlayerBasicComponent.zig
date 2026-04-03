const PlayerBasicComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const BasicInfo = @import("../../../fs/BasicInfo.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: BasicInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, player_id: i32) !PlayerBasicComponent {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    return .{
        .player_id = player_id,
        .info = try file_util.loadOrCreateZon(
            BasicInfo,
            gpa,
            arena.allocator(),
            fs,
            "player/{}/basic_info",
            .{player_id},
        ),
    };
}

pub fn deinit(comp: *PlayerBasicComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}
