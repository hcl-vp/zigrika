const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const FileSystem = @import("common").FileSystem;
const Connection = @import("../../network/Connection.zig");
const mem = @import("../../mem.zig");
const Io = std.Io;

pub fn onFlowEndRequest(
    txn: *Transaction(pb.FlowEndRequest),
    fs: *FileSystem,
    conn: *Connection,
    alloc: mem.Alloc,
) !void {
    const js = try Io.Dir.readFileAlloc(Io.Dir.cwd(), fs.io, "assets/scripts/misc_patches/flow_ender.js", alloc.gpa, Io.Limit.unlimited);
    defer alloc.gpa.free(js);
    try conn.push(pb.JSPatchNotify{
        .Content = js,
    });

    txn.respond(.{});
}
