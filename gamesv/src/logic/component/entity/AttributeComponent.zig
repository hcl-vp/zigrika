const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");

base_prop: []i32 = &.{},

pub fn toProto(comp: Component, alloc: mem.Alloc) !pb.AttributeComponentPb {
    var comp_pb: pb.AttributeComponentPb = .{};

    inline for (comptime std.meta.fields(pb.EAttributeType), 0..) |field, i| {
        try comp_pb.AttrData.append(alloc.arena, .{
            .AttributeType = @field(pb.EAttributeType, field.name),
            .CurrentValue = if (i < comp.base_prop.len) comp.base_prop[i] else 0,
        });
    }

    return comp_pb;
}
