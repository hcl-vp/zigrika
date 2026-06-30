const std = @import("std");
const common = @import("common");
const incr = @import("incr.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

pub fn current(gpa: Allocator, fs: *FileSystem, player_id: i32) !i32 {
    const path = try counterPath(gpa, player_id);
    defer gpa.free(path);

    if (try fs.lockFile(path)) |lock_value| {
        var lock = lock_value;
        var tokens = std.mem.tokenizeAny(u8, lock.content, " \r\n");
        const id = std.fmt.parseInt(i32, tokens.next() orelse {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        }, 10) catch {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        };
        try lock.unlock(null);
        return id;
    }

    return 1;
}

pub fn next(gpa: Allocator, fs: *FileSystem, player_id: i32) !i32 {
    const path = try counterPath(gpa, player_id);
    defer gpa.free(path);
    return try incr.next(i32, fs, path);
}

pub fn ensureAtLeast(gpa: Allocator, fs: *FileSystem, player_id: i32, next_id: i32) !void {
    if (next_id <= 1) return;

    const path = try counterPath(gpa, player_id);
    defer gpa.free(path);

    var buf: [32]u8 = undefined;
    if (try fs.lockFile(path)) |lock_value| {
        var lock = lock_value;
        var tokens = std.mem.tokenizeAny(u8, lock.content, " \r\n");
        const current_id = std.fmt.parseInt(i32, tokens.next() orelse {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        }, 10) catch {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        };

        if (current_id < next_id) {
            try lock.unlock(try std.fmt.bufPrint(&buf, "{}\n", .{next_id}));
        } else {
            try lock.unlock(null);
        }
        return;
    }

    try fs.writeFile(path, try std.fmt.bufPrint(&buf, "{}\n", .{next_id}));
}

pub fn nextAfterMap(map: anytype) i32 {
    var next_id: i32 = 1;
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        next_id = @max(next_id, entry.key_ptr.* + 1);
    }
    return next_id;
}

pub fn nextAfterMaps(maps: anytype) i32 {
    var next_id: i32 = 1;
    inline for (maps) |map| {
        next_id = @max(next_id, nextAfterMap(map.*));
    }
    return next_id;
}

fn counterPath(gpa: Allocator, player_id: i32) ![]u8 {
    return try std.fmt.allocPrint(gpa, "player/{}/special_item/next", .{player_id});
}
