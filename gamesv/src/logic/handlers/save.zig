const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const BuffTimerScheduler = @import("../schedulers/BuffTimerScheduler.zig");
const DirtySaveQueue = @import("../schedulers/DirtySaveQueue.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");

pub fn onRoleInfoModified(
    event: EventQueue.Dequeue(.role_info_modified),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
) !void {
    try dirty_saves.markRole(alloc.gpa, event.data.role_id);
}

pub fn onWeaponInfoModified(
    event: EventQueue.Dequeue(.weapon_info_modified),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
) !void {
    try dirty_saves.markWeapon(alloc.gpa, event.data.incr_id);
}

pub fn onEntityMovement(
    event: EventQueue.Dequeue(.entity_movement),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
) !void {
    try dirty_saves.markMovement(alloc.gpa, event.data.entity);
}

pub fn onBuffChange(
    event: EventQueue.Dequeue(.buff_change),
    alloc: mem.Alloc,
    buff_timers: *BuffTimerScheduler,
    dirty_saves: *DirtySaveQueue,
) !void {
    buff_timers.markDirty();
    try dirty_saves.markBuffChange(alloc.gpa, event.data.entity);
}

pub fn onDirtySaveTick(
    _: EventQueue.Dequeue(.dirty_save_tick),
    alloc: mem.Alloc,
    fs: *FileSystem,
    dirty_saves: *DirtySaveQueue,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    scene: *Scene,
) !void {
    try dirty_saves.flush(alloc.gpa, fs, role_comp, weapon_comp, scene);
}
