const std = @import("std");
const common = @import("common");
const FileSystem = common.FileSystem;

pub fn next(comptime T: type, fs: *FileSystem, counter_file: []const u8) !T {
    // Create new counter. Write '2' immediately because '1' is going to be occupied right now.
    return try nextStartingAt(T, fs, counter_file, 1);
}

pub fn nextStartingAt(comptime T: type, fs: *FileSystem, counter_file: []const u8, start_id: T) !T {
    var fmt_buf: [64]u8 = undefined;

    var lock = try fs.lockFile(counter_file) orelse {
        try fs.writeFile(counter_file, std.fmt.bufPrint(fmt_buf[0..], "{}\n", .{start_id + 1}) catch unreachable);
        return start_id;
    };

    errdefer lock.unlock(null) catch {};

    var tokens = std.mem.tokenizeAny(u8, lock.content, " \r\n");
    const id = std.fmt.parseInt(T, tokens.next() orelse return error.InvalidCounterFile, 10) catch return error.InvalidCounterFile;

    try lock.unlock(std.fmt.bufPrint(fmt_buf[0..], "{}\n", .{id + 1}) catch unreachable);
    return id;
}
