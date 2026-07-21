const FsmWakeScheduler = @This();
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const Kind = enum(u8) {
    root_timer,
    pending_timeout,
    paralysis,
};

pub const Entry = struct {
    entity_id: i64,
    fsm_id: i32 = 0,
    kind: Kind,
    due_ms: i64,
};

heap: std.ArrayListUnmanaged(Entry) = .empty,
positions: std.AutoHashMapUnmanaged(u128, usize) = .empty,
dirty_entities: std.ArrayListUnmanaged(i64) = .empty,
dirty_set: std.AutoHashMapUnmanaged(i64, void) = .empty,
dirty_head: usize = 0,

pub fn deinit(scheduler: *FsmWakeScheduler, gpa: Allocator) void {
    scheduler.heap.deinit(gpa);
    scheduler.positions.deinit(gpa);
    scheduler.dirty_entities.deinit(gpa);
    scheduler.dirty_set.deinit(gpa);
}

pub fn reset(scheduler: *FsmWakeScheduler, gpa: Allocator) void {
    scheduler.deinit(gpa);
    scheduler.* = .{};
}

pub fn markDirty(scheduler: *FsmWakeScheduler, gpa: Allocator, entity_id: i64) !void {
    if (scheduler.dirty_set.contains(entity_id)) return;
    try scheduler.dirty_set.put(gpa, entity_id, {});
    errdefer _ = scheduler.dirty_set.remove(entity_id);
    try scheduler.dirty_entities.append(gpa, entity_id);
}

pub fn popDirty(scheduler: *FsmWakeScheduler) ?i64 {
    while (scheduler.dirty_head < scheduler.dirty_entities.items.len) {
        const entity_id = scheduler.dirty_entities.items[scheduler.dirty_head];
        scheduler.dirty_head += 1;
        if (scheduler.dirty_set.remove(entity_id)) return entity_id;
    }

    scheduler.dirty_entities.clearRetainingCapacity();
    scheduler.dirty_head = 0;
    return null;
}

pub fn upsert(scheduler: *FsmWakeScheduler, gpa: Allocator, entry: Entry) !void {
    const entry_key = key(entry.entity_id, entry.fsm_id, entry.kind);
    if (scheduler.positions.get(entry_key)) |index| {
        const previous_due = scheduler.heap.items[index].due_ms;
        scheduler.heap.items[index] = entry;
        if (entry.due_ms < previous_due) {
            scheduler.siftUp(index);
        } else if (entry.due_ms > previous_due) {
            scheduler.siftDown(index);
        }
        return;
    }

    const index = scheduler.heap.items.len;
    try scheduler.heap.append(gpa, entry);
    errdefer _ = scheduler.heap.pop();
    try scheduler.positions.put(gpa, entry_key, index);
    scheduler.siftUp(index);
}

pub fn cancel(scheduler: *FsmWakeScheduler, entity_id: i64, fsm_id: i32, kind: Kind) void {
    const entry_key = key(entity_id, fsm_id, kind);
    const index = scheduler.positions.get(entry_key) orelse return;
    _ = scheduler.removeAt(index);
}

pub fn cancelEntity(scheduler: *FsmWakeScheduler, entity_id: i64) void {
    _ = scheduler.dirty_set.remove(entity_id);
    var index: usize = 0;
    while (index < scheduler.heap.items.len) {
        if (scheduler.heap.items[index].entity_id == entity_id) {
            _ = scheduler.removeAt(index);
        } else {
            index += 1;
        }
    }
}

pub fn popDue(scheduler: *FsmWakeScheduler, now_ms: i64) ?Entry {
    if (scheduler.heap.items.len == 0 or scheduler.heap.items[0].due_ms > now_ms) return null;
    return scheduler.removeAt(0);
}

fn removeAt(scheduler: *FsmWakeScheduler, index: usize) Entry {
    const removed = scheduler.heap.items[index];
    _ = scheduler.positions.remove(key(removed.entity_id, removed.fsm_id, removed.kind));

    const last_index = scheduler.heap.items.len - 1;
    if (index == last_index) {
        _ = scheduler.heap.pop();
        return removed;
    }

    scheduler.heap.items[index] = scheduler.heap.items[last_index];
    _ = scheduler.heap.pop();
    scheduler.positions.getPtr(key(
        scheduler.heap.items[index].entity_id,
        scheduler.heap.items[index].fsm_id,
        scheduler.heap.items[index].kind,
    )).?.* = index;

    if (index > 0 and lessThan(scheduler.heap.items[index], scheduler.heap.items[(index - 1) / 2])) {
        scheduler.siftUp(index);
    } else {
        scheduler.siftDown(index);
    }
    return removed;
}

fn siftUp(scheduler: *FsmWakeScheduler, start_index: usize) void {
    var index = start_index;
    while (index > 0) {
        const parent = (index - 1) / 2;
        if (!lessThan(scheduler.heap.items[index], scheduler.heap.items[parent])) break;
        scheduler.swapEntries(index, parent);
        index = parent;
    }
}

fn siftDown(scheduler: *FsmWakeScheduler, start_index: usize) void {
    var index = start_index;
    while (true) {
        const left = index * 2 + 1;
        if (left >= scheduler.heap.items.len) return;
        const right = left + 1;
        const child = if (right < scheduler.heap.items.len and
            lessThan(scheduler.heap.items[right], scheduler.heap.items[left])) right else left;
        if (!lessThan(scheduler.heap.items[child], scheduler.heap.items[index])) return;
        scheduler.swapEntries(index, child);
        index = child;
    }
}

fn swapEntries(scheduler: *FsmWakeScheduler, a: usize, b: usize) void {
    std.mem.swap(Entry, &scheduler.heap.items[a], &scheduler.heap.items[b]);
    scheduler.positions.getPtr(key(
        scheduler.heap.items[a].entity_id,
        scheduler.heap.items[a].fsm_id,
        scheduler.heap.items[a].kind,
    )).?.* = a;
    scheduler.positions.getPtr(key(
        scheduler.heap.items[b].entity_id,
        scheduler.heap.items[b].fsm_id,
        scheduler.heap.items[b].kind,
    )).?.* = b;
}

fn lessThan(a: Entry, b: Entry) bool {
    if (a.due_ms != b.due_ms) return a.due_ms < b.due_ms;
    if (a.entity_id != b.entity_id) return a.entity_id < b.entity_id;
    if (a.fsm_id != b.fsm_id) return a.fsm_id < b.fsm_id;
    return @intFromEnum(a.kind) < @intFromEnum(b.kind);
}

fn key(entity_id: i64, fsm_id: i32, kind: Kind) u128 {
    const entity_bits: u64 = @bitCast(entity_id);
    const fsm_bits: u32 = @bitCast(fsm_id);
    return (@as(u128, entity_bits) << 40) |
        (@as(u128, fsm_bits) << 8) |
        @intFromEnum(kind);
}
