const Component = @This();
const pb = @import("proto").pb;
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

gameplay_tags: []pb.GameplayTagData = &.{},
entity_common_tags: []i32 = &.{},
init_gameplay_tag: bool = false,

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.gameplay_tags);
    gpa.free(comp.entity_common_tags);
}

pub fn toProto(comp: Component) pb.TagComponentPb {
    return .{
        .GameplayTags = sliceToArrayList(pb.GameplayTagData, comp.gameplay_tags),
        .EntityCommonTags = sliceToArrayList(i32, comp.entity_common_tags),
        .InitGameplayTag = comp.init_gameplay_tag,
    };
}

pub fn hasTag(comp: *const Component, tag_id: i64) bool {
    const id = std.math.cast(i32, tag_id) orelse return false;
    for (comp.gameplay_tags) |tag| {
        if (tag.Id == id and tag.TagCount > 0) return true;
    }
    return std.mem.indexOfScalar(i32, comp.entity_common_tags, id) != null;
}
