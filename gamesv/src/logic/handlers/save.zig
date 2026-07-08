const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const State = @import("../../network/State.zig");

pub fn onRoleInfoModified(
    event: EventQueue.Dequeue(.role_info_modified),
    alloc: mem.Alloc,
    state: *State,
) !void {
    try state.dirty_saves.markRole(alloc.gpa, event.data.role_id);
}

pub fn onWeaponInfoModified(
    event: EventQueue.Dequeue(.weapon_info_modified),
    alloc: mem.Alloc,
    state: *State,
) !void {
    try state.dirty_saves.markWeapon(alloc.gpa, event.data.incr_id);
}

pub fn onEntityMovement(
    event: EventQueue.Dequeue(.entity_movement),
    alloc: mem.Alloc,
    state: *State,
) !void {
    try state.dirty_saves.markMovement(alloc.gpa, event.data.entity);
}

pub fn onBuffChange(
    event: EventQueue.Dequeue(.buff_change),
    alloc: mem.Alloc,
    state: *State,
) !void {
    state.buff_timers.markDirty();
    try state.dirty_saves.markBuffChange(alloc.gpa, event.data.entity);
}

pub fn onDirtySaveTick(
    _: EventQueue.Dequeue(.dirty_save_tick),
    alloc: mem.Alloc,
    fs: *FileSystem,
    state: *State,
) !void {
    try dirty_save.flush(state, alloc.gpa, fs);
}

const dirty_save = struct {
    fn flush(state: *State, gpa: mem.Allocator, fs: *FileSystem) !void {
        try state.dirty_saves.flush(
            gpa,
            fs,
            &state.player_components.role,
            &state.player_components.weapon,
            if (state.scene) |*scene| scene else null,
        );
    }
};
