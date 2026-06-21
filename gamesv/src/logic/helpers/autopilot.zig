const std = @import("std");
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Io = std.Io;

const AutoPilotCircle = struct {
    MapId: i32 = 0,
    WaySplines: []const i32 = &.{},
};

fn appendUniqueI32(items: *std.ArrayList(i32), arena: std.mem.Allocator, value: i32) !void {
    for (items.items) |existing| {
        if (existing == value) return;
    }

    try items.append(arena, value);
}

pub fn roadIdsForMap(fs: *FileSystem, alloc: mem.Alloc, map_id: i32) !std.ArrayList(i32) {
    var roads: std.ArrayList(i32) = .empty;
    const content = try Io.Dir.readFileAlloc(Io.Dir.cwd(), fs.io, "assets/BinData/AutoPilotCircles.json", alloc.gpa, Io.Limit.unlimited);
    defer alloc.gpa.free(content);

    const circles = try std.json.parseFromSliceLeaky(
        []AutoPilotCircle,
        alloc.arena,
        content,
        .{ .ignore_unknown_fields = true, .allocate = .alloc_always },
    );

    for (circles) |circle| {
        if (circle.MapId != map_id) continue;

        for (circle.WaySplines) |road_id| {
            try appendUniqueI32(&roads, alloc.arena, road_id);
        }
    }

    return roads;
}
