const PlayerInventoryComponent = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");

const InventoryInfo = @import("../../../fs/InventoryInfo.zig");
const Assets = @import("../../../data/Assets.zig");
const InventoryHelper = @import("../../helpers/inventory.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
info: InventoryInfo,

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerInventoryComponent {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var info = try file_util.loadZon(
        InventoryInfo,
        gpa,
        arena,
        fs,
        "player/{}/{s}",
        .{ player_id, InventoryInfo.data_path },
    ) orelse InventoryInfo{};

    if (info.isEmpty()) {
        try InventoryHelper.addDefaultProgressionItems(&info, gpa, assets);
        const path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, InventoryInfo.data_path });
        const serialized = try file_util.serializeZon(arena, info);
        try fs.writeFile(path, serialized);
    }

    return .{
        .player_id = player_id,
        .info = info,
    };
}

pub fn deinit(comp: *PlayerInventoryComponent, gpa: Allocator) void {
    comp.info.deinit(gpa);
}
