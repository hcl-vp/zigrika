const PlayerRoleComponent = @This();
const std = @import("std");
const common = @import("common");
const comp_util = @import("../comp_util.zig");
const file_util = @import("../../../fs/file_util.zig");

const Assets = @import("../../../data/Assets.zig");
const RoleInfo = @import("../../../fs/RoleInfo.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
role_map: std.AutoArrayHashMapUnmanaged(i32, RoleInfo),

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerRoleComponent {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    return .{
        .player_id = player_id,
        .role_map = try comp_util.loadItems(RoleInfo, gpa, fs, assets, player_id, .by_data_id),
    };
}

pub fn deinit(comp: *PlayerRoleComponent, gpa: Allocator) void {
    comp_util.freeMap(gpa, &comp.role_map);
}
