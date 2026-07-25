pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    for (args[1..]) |path|
        try std.Io.Dir.cwd().deleteTree(init.io, path);
}

const std = @import("std");
