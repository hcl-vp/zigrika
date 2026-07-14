const BuffTimerScheduler = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const FileSystem = @import("common").FileSystem;
const mem = @import("../../mem.zig");
const buff_helper = @import("../helpers/buff.zig");
const ScheduledJob = @import("ScheduledJob.zig");

const Allocator = std.mem.Allocator;
const Entity = Scene.Entity;

pub const job: ScheduledJob = .{
    .interval = .ms50,
    .event_key = .buff_timer_tick,
};

entries: std.ArrayListUnmanaged(Entry) = .empty,
initialized: bool = false,
dirty: bool = true,

const Kind = enum {
    expiry,
    period,
};

const Entry = struct {
    kind: Kind,
    entity_id: i64,
    handle_id: i32,
    due_ms: i64,
    interval_ms: i64 = 0,
};

pub fn deinit(scheduler: *BuffTimerScheduler, gpa: Allocator) void {
    scheduler.entries.deinit(gpa);
}

pub fn reset(scheduler: *BuffTimerScheduler, gpa: Allocator) void {
    scheduler.entries.deinit(gpa);
    scheduler.* = .{};
}

pub fn markDirty(scheduler: *BuffTimerScheduler) void {
    scheduler.dirty = true;
}

pub fn forgetHandle(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
) void {
    scheduler.removeEntriesForHandle(entity_id, handle_id);
}

pub fn drainDue(
    scheduler: *BuffTimerScheduler,
    event: EventQueue.Dequeue(.buff_timer_tick),
    events: *EventQueue,
    scene: *Scene,
    assets: *const Assets,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    alloc: mem.Alloc,
) !void {
    const now_ms = event.data.now_ms;
    if (!scheduler.initialized or scheduler.dirty) {
        try scheduler.rebuild(alloc.gpa, scene, assets, now_ms);
    }

    var i: usize = 0;
    while (i < scheduler.entries.items.len) {
        const entry = scheduler.entries.items[i];

        switch (entry.kind) {
            .expiry => {
                const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                    _ = scheduler.entries.swapRemove(i);
                    continue;
                };
                syncLeftDuration(lookup[1], entry.due_ms, now_ms);
                if (entry.due_ms > now_ms) {
                    i += 1;
                    continue;
                }

                const entity = lookup[0];
                const handle_ids = try alloc.arena.alloc(i32, 1);
                handle_ids[0] = entry.handle_id;
                scheduler.removeEntriesForHandle(entry.entity_id, entry.handle_id);
                try events.enqueue(.buff_removal, .{
                    .entity = entity,
                    .handle_ids = handle_ids,
                });
                i = 0;
            },
            .period => {
                if (entry.due_ms > now_ms) {
                    i += 1;
                    continue;
                }

                const lookup = scheduler.findEntityBuff(scene, entry.entity_id, entry.handle_id) orelse {
                    _ = scheduler.entries.swapRemove(i);
                    continue;
                };
                const buff_info = lookup[1];
                const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse {
                    _ = scheduler.entries.swapRemove(i);
                    continue;
                };
                try buff_helper.execute_periodic_buff_effects(
                    combat_receive_pack,
                    entry.entity_id,
                    buff_info.InstigatorId,
                    &buff_data,
                    scene,
                    fs,
                    io,
                    query,
                    alloc,
                );
                scheduler.entries.items[i].due_ms = now_ms + @max(entry.interval_ms, 1);
                i += 1;
            },
        }
    }
}

fn rebuild(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    var previous_entries = scheduler.entries;
    defer previous_entries.deinit(gpa);
    scheduler.entries = .empty;
    errdefer {
        scheduler.entries.deinit(gpa);
        scheduler.entries = .empty;
    }

    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.buffs)) |entity_id, maybe_buffs| {
        const buffs = maybe_buffs orelse continue;
        for (buffs.fight_buff_infos) |buff_info| {
            try scheduler.registerBuff(
                gpa,
                assets,
                buff_info,
                entity_id.net_id,
                now_ms,
                previous_entries.items,
            );
        }
    }

    scheduler.initialized = true;
    scheduler.dirty = false;
}

fn registerBuff(
    scheduler: *BuffTimerScheduler,
    gpa: Allocator,
    assets: *const Assets,
    buff_info: pb.FightBuffInformation,
    entity_id: i64,
    now_ms: i64,
    previous_entries: []const Entry,
) !void {
    const buff_data = assets.tables.buff.getDataById(buff_info.BuffId) orelse return;

    if (buff_data.DurationPolicy == .HasDuration and buff_info.LeftDuration > 0) {
        const due_ms = if (findEntry(previous_entries, .expiry, entity_id, buff_info.HandleId)) |entry|
            entry.due_ms
        else
            now_ms + secondsToMs(buff_info.LeftDuration);

        try scheduler.entries.append(gpa, .{
            .kind = .expiry,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = due_ms,
        });
    }

    if (buff_data.Period > 0) {
        const interval_ms = secondsToMs(buff_data.Period);
        const due_ms = if (findEntry(previous_entries, .period, entity_id, buff_info.HandleId)) |entry|
            entry.due_ms
        else
            now_ms + interval_ms;

        try scheduler.entries.append(gpa, .{
            .kind = .period,
            .entity_id = entity_id,
            .handle_id = buff_info.HandleId,
            .due_ms = due_ms,
            .interval_ms = interval_ms,
        });
    }
}

fn findEntityBuff(
    scheduler: *BuffTimerScheduler,
    scene: *Scene,
    entity_id: i64,
    handle_id: i32,
) ?struct { Entity, *pb.FightBuffInformation } {
    _ = scheduler;
    const index = scene.net_id_map.get(entity_id) orelse return null;
    const slice = scene.entities.slice();
    const buffs = if (slice.items(.buffs)[index]) |*component| component else return null;
    const buff = buffs.getByHandleId(handle_id) orelse return null;
    return .{
        .{ .index = index, .net_id = entity_id },
        buff,
    };
}

fn removeEntriesForHandle(
    scheduler: *BuffTimerScheduler,
    entity_id: i64,
    handle_id: i32,
) void {
    var i: usize = 0;
    while (i < scheduler.entries.items.len) {
        const entry = scheduler.entries.items[i];
        if (entry.entity_id == entity_id and entry.handle_id == handle_id) {
            _ = scheduler.entries.swapRemove(i);
        } else {
            i += 1;
        }
    }
}

fn findEntry(
    entries: []const Entry,
    kind: Kind,
    entity_id: i64,
    handle_id: i32,
) ?Entry {
    for (entries) |entry| {
        if (entry.kind == kind and entry.entity_id == entity_id and entry.handle_id == handle_id) {
            return entry;
        }
    }

    return null;
}

fn syncLeftDuration(
    buff_info: *pb.FightBuffInformation,
    due_ms: i64,
    now_ms: i64,
) void {
    const remaining_ms = @max(due_ms - now_ms, 0);
    var remaining_seconds = @as(f32, @floatFromInt(remaining_ms)) / 1000.0;
    if (buff_info.Duration > 0 and remaining_seconds > buff_info.Duration) {
        remaining_seconds = buff_info.Duration;
    }

    buff_info.LeftDuration = remaining_seconds;
}

fn secondsToMs(seconds: f32) i64 {
    return @max(1, @as(i64, @intFromFloat(@ceil(seconds * 1000.0))));
}
