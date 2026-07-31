const Component = @This();
const pb = @import("proto").pb;
const std = @import("std");
const DataTables = @import("../../../data/DataTables.zig");
const gameplay_tag_hierarchy = @import("../../helpers/gameplay_tags.zig");
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

pub fn hasTag(
    comp: *const Component,
    parents: *const DataTables.GameplayTagParentTable,
    tag_id: i64,
) bool {
    const id = std.math.cast(i32, tag_id) orelse return false;
    for (comp.gameplay_tags) |tag| {
        if (tag.TagCount > 0 and gameplay_tag_hierarchy.contains(parents, tag.Id, id)) return true;
    }
    return std.mem.indexOfScalar(i32, comp.entity_common_tags, id) != null;
}

pub fn gameplayTagCount(comp: *const Component, id: i32) i32 {
    for (comp.gameplay_tags) |entry| {
        if (entry.Id == id) return entry.TagCount;
    }
    return 0;
}

pub fn setGameplayTagCount(comp: *Component, gpa: std.mem.Allocator, id: i32, count: i32) !void {
    if (count <= 0) return comp.removeGameplayTag(gpa, id);
    for (comp.gameplay_tags) |*entry| {
        if (entry.Id == id) {
            entry.TagCount = count;
            return;
        }
    }

    comp.gameplay_tags = try gpa.realloc(comp.gameplay_tags, comp.gameplay_tags.len + 1);
    comp.gameplay_tags[comp.gameplay_tags.len - 1] = .{ .Id = id, .TagCount = count };
}

pub fn adjustGameplayTagCount(comp: *Component, gpa: std.mem.Allocator, id: i32, delta: i32) !bool {
    if (delta == 0) return false;

    for (comp.gameplay_tags) |entry| {
        if (entry.Id != id) continue;

        const count = std.math.add(i32, entry.TagCount, delta) catch return error.GameplayTagCountOverflow;
        try comp.setGameplayTagCount(gpa, id, count);
        return true;
    }

    if (delta < 0) return false;
    try comp.setGameplayTagCount(gpa, id, delta);
    return true;
}

pub fn removeGameplayTag(comp: *Component, gpa: std.mem.Allocator, id: i32) !void {
    for (comp.gameplay_tags, 0..) |entry, index| {
        if (entry.Id != id) continue;

        if (comp.gameplay_tags.len == 1) {
            gpa.free(comp.gameplay_tags);
            comp.gameplay_tags = &.{};
            return;
        }
        if (index + 1 < comp.gameplay_tags.len) {
            std.mem.copyForwards(
                pb.GameplayTagData,
                comp.gameplay_tags[index .. comp.gameplay_tags.len - 1],
                comp.gameplay_tags[index + 1 ..],
            );
        }
        comp.gameplay_tags = try gpa.realloc(comp.gameplay_tags, comp.gameplay_tags.len - 1);
        return;
    }
}
