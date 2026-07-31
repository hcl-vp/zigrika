const Assets = @This();
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

pub const DataTables = @import("DataTables.zig");
pub const FsmGraphRegistry = @import("FsmGraphRegistry.zig");

tables: DataTables,
fsm_graphs: FsmGraphRegistry,

pub fn init(gpa: Allocator, io: Io) !Assets {
    var tables = try DataTables.load(gpa, io);
    errdefer tables.deinit();
    return .{
        .fsm_graphs = try .init(gpa, &tables),
        .tables = tables,
    };
}

pub fn deinit(assets: *Assets) void {
    assets.fsm_graphs.deinit();
    assets.tables.deinit();
}
