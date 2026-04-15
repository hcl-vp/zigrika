const std = @import("std");
const common = @import("common");
const FileSystem = common.FileSystem;

pub fn next(comptime T: type, fs: *FileSystem, counter_file: []const u8) !T {
    var fmt_buf: [64]u8 = undefined;

    var lock = try fs.lockFile(counter_file) orelse {
        // Create new counter. Write '2' immediately because '1' is going to be occupied right now.
        try fs.writeFile(counter_file, "2\n");
        return 1;
    };

    errdefer lock.unlock(null) catch {};

    var tokens = std.mem.tokenizeAny(u8, lock.content, " \r\n");
    const id = std.fmt.parseInt(T, tokens.next() orelse return error.InvalidCounterFile, 10) catch return error.InvalidCounterFile;

    try lock.unlock(std.fmt.bufPrint(fmt_buf[0..], "{}\n", .{id + 1}) catch unreachable);
    return id;
}
