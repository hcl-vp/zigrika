const Account = @This();
const std = @import("std");
const common = @import("common");
const zon = std.zon;

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

user_id: []const u8,
user_name: []const u8,
token: []const u8,
sex: i32 = 0,

pub fn loadOrCreate(
    arena: Allocator,
    fs: *FileSystem,
    user_id: []const u8,
    user_name: []const u8,
    token: []const u8,
) !Account {
    const log = std.log.scoped(.account);

    const path = try std.fmt.allocPrint(arena, "account/{s}", .{user_id});
    if (try fs.readFile(arena, path)) |account_data| {
        var diagnostics: zon.parse.Diagnostics = .{};

        const account = zon.parse.fromSliceAlloc(Account, arena, account_data, &diagnostics, .{}) catch {
            log.err("failed to parse account file:\n{s}:{f}", .{ path, diagnostics });
            return error.ParseFailed;
        };

        if (!std.mem.eql(u8, account.token, token)) return error.TokenMismatch;
        return account;
    } else {
        const account: Account = .{
            .user_id = user_id,
            .user_name = user_name,
            .token = token,
        };

        var allocating = std.Io.Writer.Allocating.init(arena);
        try zon.stringify.serialize(account, .{}, &allocating.writer);
        try fs.writeFile(path, allocating.written());

        return account;
    }
}
