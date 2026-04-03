const Assets = @This();
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub const DataTables = @import("DataTables.zig");

tables: DataTables,

pub fn init(gpa: Allocator, io: Io) !Assets {
    return .{ .tables = try DataTables.load(gpa, io) };
}

pub fn deinit(assets: *Assets) void {
    assets.tables.deinit();
}
