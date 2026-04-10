const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

list: []i32 = &.{},

pub fn toProto(comp: Component, alloc: mem.Alloc) !pb.FollowerComponentPb {
    var follower_list = std.ArrayList(pb.FollowerList).empty;
    for (comp.list) |item| {
        try follower_list.append(alloc.arena, .{
            .Type = @enumFromInt(item),
            .EntityId = 0,
        });
    }
    return .{
        .FollowerList = follower_list,
    };
}
