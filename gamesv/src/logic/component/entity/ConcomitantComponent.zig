const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

vision_entity_id: []i64 = &.{},
custom_entity_ids: []i64 = &.{},
phantom_role_id: i64 = 0,
boss_rush_id: i64 = 0,

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.custom_entity_ids);
    gpa.free(comp.vision_entity_id);
}

pub fn toProto(comp: Component) !pb.ConcomitantsComponentPb {
    return .{
        .VisionEntityId = sliceToArrayList(i64, comp.vision_entity_id),
        .CustomEntityIds = sliceToArrayList(i64, comp.custom_entity_ids),
        .PhantomRoleId = comp.phantom_role_id,
        .BossRushId = comp.boss_rush_id,
    };
}
