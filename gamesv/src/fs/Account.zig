const Account = @This();
const std = @import("std");
const common = @import("common");
const incr = @import("incr.zig");
const file_util = @import("file_util.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,

pub fn loadOrCreate(arena: Allocator, fs: *FileSystem, name: []const u8) !Account {
    const log = std.log.scoped(.account_load);

    const account_file_path = try std.fmt.allocPrint(arena, "account/link/{s}", .{name});
    if (try fs.readFile(arena, account_file_path)) |account_data| {
        const account = file_util.parseZon(Account, arena, account_data, account_file_path) catch {
            log.err("account '{s}': data is corrupted", .{name});
            return error.Corrupted;
        };

        return account;
    } else {
        const player_id = try incr.next(i32, fs, "player/next");
        const account: Account = .{ .player_id = player_id };

        const data = try file_util.serializeZon(arena, account);
        try fs.writeFile(account_file_path, data);

        return account;
    }
}
