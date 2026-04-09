const std = @import("std");
const pb = @import("proto").pb;
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const comp_util = @import("../component/comp_util.zig");
const EventQueue = @import("../EventQueue.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const Scene = @import("../Scene.zig");

pub fn onRoleInfoModified(
    event: EventQueue.Dequeue(.role_info_modified),
    role_comp: *const PlayerRoleComponent,
    alloc: mem.Alloc,
    fs: *FileSystem,
) !void {
    const role_info = role_comp.role_map.getPtr(event.data.role_id) orelse return;
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/role/{}", .{ role_comp.player_id, event.data.role_id });
    try comp_util.saveStruct(fs, role_info, path, alloc.arena);
}

pub fn onWeaponInfoModified(
    event: EventQueue.Dequeue(.weapon_info_modified),
    weapon_comp: *const PlayerWeaponComponent,
    alloc: mem.Alloc,
    fs: *FileSystem,
) !void {
    const weapon_info = weapon_comp.weapon_map.getPtr(event.data.incr_id) orelse return;
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/weapon/{}", .{ weapon_comp.player_id, event.data.incr_id });
    try comp_util.saveStruct(fs, weapon_info, path, alloc.arena);
}

pub fn onEntityMovement(
    event: EventQueue.Dequeue(.entity_movement),
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
) !void {
    try scene.saveInstance(fs, alloc.gpa);
    try scene.saveComponents(
        fs,
        alloc.gpa,
        event.data.entity,
        &.{Scene.Entity.PositionComponent},
    );
}
