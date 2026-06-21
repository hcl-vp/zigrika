const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

pub const Entry = struct {
    Type: i32,
    EntityId: i64 = 0,
};

list: []Entry = &.{},

pub fn toProto(comp: Component, alloc: mem.Alloc) !pb.Summon.FollowerComponentPb {
    var follower_list = std.ArrayList(pb.Summon.FollowerList).empty;
    for (comp.list) |item| {
        try follower_list.append(alloc.arena, .{
            .Type = @enumFromInt(item.Type),
            .EntityId = item.EntityId,
        });
    }
    return .{
        .FollowerList = follower_list,
    };
}
