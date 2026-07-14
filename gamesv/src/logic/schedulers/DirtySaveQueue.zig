const DirtySaveQueue = @This();
const std = @import("std");
const FileSystem = @import("common").FileSystem;
const comp_util = @import("../component/comp_util.zig");
const Scene = @import("../Scene.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const ScheduledJob = @import("ScheduledJob.zig");

const Allocator = std.mem.Allocator;

pub const job: ScheduledJob = .{
    .interval = .s30,
    .event_key = .dirty_save_tick,
};

role_ids: std.ArrayListUnmanaged(i32) = .empty,
weapon_ids: std.ArrayListUnmanaged(i32) = .empty,
position_entity_ids: std.ArrayListUnmanaged(i64) = .empty,
buff_entity_ids: std.ArrayListUnmanaged(i64) = .empty,
scene_instance_dirty: bool = false,

pub fn deinit(queue: *DirtySaveQueue, gpa: Allocator) void {
    queue.role_ids.deinit(gpa);
    queue.weapon_ids.deinit(gpa);
    queue.position_entity_ids.deinit(gpa);
    queue.buff_entity_ids.deinit(gpa);
}

pub fn markRole(queue: *DirtySaveQueue, gpa: Allocator, role_id: i32) !void {
    try appendUnique(i32, gpa, &queue.role_ids, role_id);
}

pub fn markWeapon(queue: *DirtySaveQueue, gpa: Allocator, weapon_id: i32) !void {
    try appendUnique(i32, gpa, &queue.weapon_ids, weapon_id);
}

pub fn markMovement(queue: *DirtySaveQueue, gpa: Allocator, entity: Scene.Entity) !void {
    queue.scene_instance_dirty = true;
    try appendUnique(i64, gpa, &queue.position_entity_ids, entity.net_id);
}

pub fn markBuffChange(queue: *DirtySaveQueue, gpa: Allocator, entity: Scene.Entity) !void {
    queue.scene_instance_dirty = true;
    try appendUnique(i64, gpa, &queue.buff_entity_ids, entity.net_id);
}

pub fn flush(
    queue: *DirtySaveQueue,
    gpa: Allocator,
    fs: *FileSystem,
    role_comp: *const PlayerRoleComponent,
    weapon_comp: *const PlayerWeaponComponent,
    scene: ?*Scene,
) !void {
    if (!queue.hasPending()) return;

    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    for (queue.role_ids.items) |role_id| {
        const role_info = role_comp.role_map.getPtr(role_id) orelse continue;
        const path = try std.fmt.allocPrint(arena, "player/{}/role/{}", .{ role_comp.player_id, role_id });
        try comp_util.saveStruct(fs, role_info, path, arena);
    }

    for (queue.weapon_ids.items) |weapon_id| {
        const weapon_info = weapon_comp.weapon_map.getPtr(weapon_id) orelse continue;
        const path = try std.fmt.allocPrint(arena, "player/{}/weapon/{}", .{ weapon_comp.player_id, weapon_id });
        try comp_util.saveStruct(fs, weapon_info, path, arena);
    }

    if (scene) |scene_ref| {
        if (queue.scene_instance_dirty) {
            try scene_ref.saveInstance(fs, gpa);
        }

        for (queue.position_entity_ids.items) |entity_id| {
            const entity = entityByNetId(scene_ref, entity_id) orelse continue;
            try scene_ref.saveComponents(
                fs,
                gpa,
                entity,
                &.{Scene.Entity.PositionComponent},
            );
        }

        for (queue.buff_entity_ids.items) |entity_id| {
            const entity = entityByNetId(scene_ref, entity_id) orelse continue;
            try scene_ref.saveComponents(
                fs,
                gpa,
                entity,
                &.{Scene.Entity.FightBuffComponent},
            );
        }
    }

    queue.clearRetainingCapacity();
}

fn hasPending(queue: *const DirtySaveQueue) bool {
    return queue.scene_instance_dirty or
        queue.role_ids.items.len != 0 or
        queue.weapon_ids.items.len != 0 or
        queue.position_entity_ids.items.len != 0 or
        queue.buff_entity_ids.items.len != 0;
}

fn clearRetainingCapacity(queue: *DirtySaveQueue) void {
    queue.role_ids.clearRetainingCapacity();
    queue.weapon_ids.clearRetainingCapacity();
    queue.position_entity_ids.clearRetainingCapacity();
    queue.buff_entity_ids.clearRetainingCapacity();
    queue.scene_instance_dirty = false;
}

fn entityByNetId(scene: *Scene, entity_id: i64) ?Scene.Entity {
    const index = scene.net_id_map.get(entity_id) orelse return null;
    return .{ .index = index, .net_id = entity_id };
}

fn appendUnique(
    comptime T: type,
    gpa: Allocator,
    list: *std.ArrayListUnmanaged(T),
    value: T,
) !void {
    if (std.mem.indexOfScalar(T, list.items, value) != null) return;
    try list.append(gpa, value);
}
