const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");

pub const Attribute = struct {
    base: i32,
    increment: i32,
    current: i32,
};
attributes: []Attribute = &.{},

pub fn toProto(comp: Component, alloc: mem.Alloc) !pb.AttributeComponentPb {
    var comp_pb: pb.AttributeComponentPb = .{};

    inline for (comptime std.meta.fields(pb.EAttributeType), 0..) |field, i| {
        try comp_pb.AttrData.append(alloc.arena, .{
            .AttributeType = @field(pb.EAttributeType, field.name),
            .CurrentValue = if (i < comp.attributes.len) comp.attributes[i].current else 0,
            .ValueIncrement = if (i < comp.attributes.len) comp.attributes[i].increment else 0,
        });
    }

    return comp_pb;
}

pub fn create(base_prop: []i32, gpa: std.mem.Allocator) !Component {
    return Component{
        .attributes = blk: {
            var s = try gpa.alloc(Attribute, base_prop.len);
            for (base_prop, 0..) |prop, i| {
                s[i] = Attribute{
                    .base = prop,
                    .increment = 0,
                    .current = prop,
                };
            }
            break :blk s;
        },
    };
}
