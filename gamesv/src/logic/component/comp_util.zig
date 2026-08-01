const std = @import("std");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const file_util = @import("../../fs/file_util.zig");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

pub fn freeMap(gpa: Allocator, map: anytype) void {
    var iterator = map.iterator();
    while (iterator.next()) |kv| {
        kv.value_ptr.deinit(gpa);
    }

    map.deinit(gpa);
}

pub fn saveStruct(
    fs: *FileSystem,
    data: anytype,
    path: []const u8,
    arena: Allocator,
) !void {
    const serialized = try file_util.serializeZon(arena, data);
    try fs.writeFile(path, serialized);
}

pub fn loadItems(
    comptime Item: type,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
    player_id: i32,
    comptime store_type: enum {
        by_data_id,
        by_incr_id,
    },
) !std.AutoArrayHashMapUnmanaged(i32, Item) {
    var map: std.AutoArrayHashMapUnmanaged(i32, Item) = .empty;
    errdefer freeMap(gpa, &map);

    var temp_allocator = ArenaAllocator.init(gpa);
    defer temp_allocator.deinit();
    const arena = temp_allocator.allocator();

    const data_dir_path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, Item.data_dir });
    if (try fs.readDir(data_dir_path)) |dir| {
        defer dir.deinit();

        for (dir.entries) |entry| if (entry.kind == .file) {
            const unique_id = std.fmt.parseInt(i32, entry.basename(), 10) catch continue;
            const item = file_util.loadZon(Item, gpa, arena, fs, "player/{}/{s}/{}", .{ player_id, Item.data_dir, unique_id }) catch {
                std.log.err("failed to load {s} with id {}", .{ @typeName(Item), unique_id });
                continue;
            } orelse continue;

            try map.put(gpa, unique_id, item);
        };
    } else {
        try Item.addDefaults(gpa, assets, &map);

        var iterator = map.iterator();
        var highest_id: i32 = 0;
        while (iterator.next()) |kv| {
            highest_id = @max(kv.key_ptr.*, highest_id);

            try fs.writeFile(
                try std.fmt.allocPrint(arena, "player/{}/{s}/{}", .{ player_id, Item.data_dir, kv.key_ptr.* }),
                try file_util.serializeZon(arena, kv.value_ptr.*),
            );
        }

        if (store_type == .by_incr_id and !@hasDecl(Item, "shared_incr_id")) {
            const counter_path = try std.fmt.allocPrint(arena, "player/{}/{s}/next", .{ player_id, Item.data_dir });

            var print_buf: [32]u8 = undefined;
            try fs.writeFile(counter_path, try std.fmt.bufPrint(print_buf[0..], "{}", .{highest_id + 1}));
        }
    }

    return map;
}
