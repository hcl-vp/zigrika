const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const DirtySaveQueue = @import("../schedulers/DirtySaveQueue.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const BuffTimerScheduler = @import("../schedulers/BuffTimerScheduler.zig");
const Assets = @import("../../data/Assets.zig");
const std = @import("std");

pub fn onRoleInfoModified(
    event: EventQueue.Dequeue(.role_info_modified),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
    io: std.Io,
) !void {
    try dirty_saves.markRole(alloc.gpa, event.data.role_id, nowMs(io));
}

pub fn onWeaponInfoModified(
    event: EventQueue.Dequeue(.weapon_info_modified),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
    io: std.Io,
) !void {
    try dirty_saves.markWeapon(alloc.gpa, event.data.incr_id, nowMs(io));
}

pub fn onEntityMovement(
    event: EventQueue.Dequeue(.entity_movement),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
    io: std.Io,
) !void {
    try dirty_saves.markMovement(alloc.gpa, event.data.entity, nowMs(io));
}

pub fn onBuffChange(
    event: EventQueue.Dequeue(.buff_change),
    alloc: mem.Alloc,
    dirty_saves: *DirtySaveQueue,
    io: std.Io,
) !void {
    try dirty_saves.markBuffChange(alloc.gpa, event.data.entity, nowMs(io));
}

pub fn onDirtySaveTick(
    event: EventQueue.Dequeue(.dirty_save_tick),
    alloc: mem.Alloc,
    fs: *FileSystem,
    dirty_saves: *DirtySaveQueue,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    scene: *?Scene,
    buff_timers: *BuffTimerScheduler,
    assets: *const Assets,
) !void {
    try dirty_saves.flush(
        alloc.gpa,
        fs,
        role_comp,
        weapon_comp,
        if (scene.*) |*active_scene| active_scene else null,
        buff_timers,
        assets,
        event.data.now_ms,
    );
}

fn nowMs(io: std.Io) i64 {
    return (std.Io.Clock.awake).now(io).toMilliseconds();
}
