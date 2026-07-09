const Account = @This();
const std = @import("std");
const common = @import("common");
const DataTables = @import("../data/DataTables.zig");
const incr = @import("incr.zig");
const file_util = @import("file_util.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,

const LoginAccount = struct {
    user_id: []const u8,
    user_name: []const u8,
    token: []const u8,
    sex: i32 = 0,
};

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
        const player_id = try incr.nextStartingAt(i32, fs, "player/next", DataTables.Config.default_uid);
        const account: Account = .{ .player_id = player_id };

        const data = try file_util.serializeZon(arena, account);
        try fs.writeFile(account_file_path, data);

        return account;
    }
}

pub fn syncLoginSexForPlayer(arena: Allocator, fs: *FileSystem, player_id: i32, sex: i32) !void {
    const link_dir = try fs.readDir("account/link") orelse return;
    defer link_dir.deinit();

    for (link_dir.entries) |entry| {
        if (entry.kind != .file) continue;

        const link = (try file_util.loadZon(Account, arena, arena, fs, "{s}", .{entry.path})) orelse continue;
        if (link.player_id != player_id) continue;

        const account_path = try std.fmt.allocPrint(arena, "account/{s}", .{entry.basename()});
        var login_account = (try file_util.loadZon(LoginAccount, arena, arena, fs, "{s}", .{account_path})) orelse return;
        login_account.sex = sex;

        try fs.writeFile(account_path, try file_util.serializeZon(arena, login_account));
        return;
    }
}
