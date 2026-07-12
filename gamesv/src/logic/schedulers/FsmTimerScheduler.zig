const FsmTimerScheduler = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const mem = @import("../../mem.zig");
const ScheduledJob = @import("ScheduledJob.zig");

const Allocator = std.mem.Allocator;
const Entity = Scene.Entity;
const FsmComponent = Entity.FsmComponent;
const StateMachineCondition = Assets.DataTables.AiStateMachineConfig.StateMachineCondition;
const StateMachineTransition = Assets.DataTables.AiStateMachineConfig.StateMachineTransition;

pub const job: ScheduledJob = .{
    .lane = .ms50,
    .event_key = .fsm_timer_tick,
};

entries: std.ArrayListUnmanaged(TimerEntry) = .empty,
states: std.ArrayListUnmanaged(FsmState) = .empty,
client_passes: std.ArrayListUnmanaged(ConditionKey) = .empty,
initialized: bool = false,
dirty: bool = true,

const FsmState = struct {
    entity_id: i64,
    fsm_id: i32,
    current_state: i32,
    pending_state: ?i32 = null,
    last_state: i32 = 0,
    state_started_ms: i64,
};

const TimerEntry = struct {
    entity_id: i64,
    fsm_id: i32,
    from_state: i32,
    to_state: i32,
    due_ms: i64,
};

const ConditionKey = struct {
    entity_id: i64,
    fsm_id: i32,
    from_state: i32,
    to_state: i32,
    condition_index: i32,
};

const TransitionStates = struct {
    from: i32,
    to: i32,
};

const ConditionEval = union(enum) {
    passed,
    failed,
    wait_until: i64,
};

pub fn deinit(scheduler: *FsmTimerScheduler, gpa: Allocator) void {
    scheduler.entries.deinit(gpa);
    scheduler.states.deinit(gpa);
    scheduler.client_passes.deinit(gpa);
}

pub fn reset(scheduler: *FsmTimerScheduler, gpa: Allocator) void {
    scheduler.deinit(gpa);
    scheduler.* = .{};
}

pub fn markDirty(scheduler: *FsmTimerScheduler) void {
    scheduler.dirty = true;
}

pub fn drainDue(
    scheduler: *FsmTimerScheduler,
    event: EventQueue.Dequeue(.fsm_timer_tick),
    scene: *Scene,
    assets: *const Assets,
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    alloc: mem.Alloc,
) !void {
    const now_ms = event.data.now_ms;
    try scheduler.ensureLoaded(alloc.gpa, scene, assets, now_ms);

    var i: usize = 0;
    while (i < scheduler.entries.items.len) {
        const entry = scheduler.entries.items[i];
        if (entry.due_ms > now_ms) {
            i += 1;
            continue;
        }

        const state_index = scheduler.findStateIndex(entry.entity_id, entry.fsm_id) orelse {
            _ = scheduler.entries.swapRemove(i);
            continue;
        };
        const state = scheduler.states.items[state_index];
        if (state.pending_state != null or state.current_state != entry.from_state) {
            _ = scheduler.entries.swapRemove(i);
            continue;
        }

        scheduler.states.items[state_index].pending_state = entry.to_state;
        scheduler.removeEntriesForFsm(entry.entity_id, entry.fsm_id);
        try combat_receive_pack.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entry.entity_id },
                .Message = .{
                    .ChangeStateNotify = .{
                        .FsmId = entry.fsm_id,
                        .FromState = entry.from_state,
                        .ToState = entry.to_state,
                    },
                },
            },
        } });
        i = 0;
    }
}

pub fn recordClientPass(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    entity_id: i64,
    fsm_id: i32,
    from_state: i32,
    to_state: i32,
    condition_index: i32,
    value: bool,
    now_ms: i64,
) !void {
    try scheduler.ensureLoaded(gpa, scene, assets, now_ms);

    const raw_key: ConditionKey = .{
        .entity_id = entity_id,
        .fsm_id = fsm_id,
        .from_state = from_state,
        .to_state = to_state,
        .condition_index = condition_index,
    };

    if (value) {
        try scheduler.addClientPass(gpa, raw_key);
    } else {
        scheduler.removeClientPass(raw_key);
    }

    if (findFsmComponent(scene, entity_id)) |fsm_component| {
        const resolved = resolveOverride(fsm_component, from_state, to_state, false);
        const resolved_key: ConditionKey = .{
            .entity_id = entity_id,
            .fsm_id = fsm_id,
            .from_state = resolved.from,
            .to_state = resolved.to,
            .condition_index = condition_index,
        };

        if (value) {
            try scheduler.addClientPass(gpa, resolved_key);
        } else {
            scheduler.removeClientPass(resolved_key);
        }
    }

    try scheduler.rescheduleAll(gpa, scene, assets, now_ms);
}

pub fn setCurrentState(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    entity_id: i64,
    fsm_id: i32,
    current_state: i32,
    now_ms: i64,
) !i32 {
    try scheduler.ensureLoaded(gpa, scene, assets, now_ms);

    const state_index = scheduler.findStateIndex(entity_id, fsm_id) orelse return current_state;
    const fsm_component = findFsmComponent(scene, entity_id) orelse return current_state;
    const new_state = deepestChild(fsm_component, current_state);

    scheduler.states.items[state_index].last_state = scheduler.states.items[state_index].current_state;
    scheduler.states.items[state_index].current_state = new_state;
    scheduler.states.items[state_index].pending_state = null;
    scheduler.states.items[state_index].state_started_ms = now_ms;
    scheduler.removeEntriesForFsm(entity_id, fsm_id);
    try scheduler.scheduleForState(gpa, scene, assets, state_index, now_ms);

    return new_state;
}

fn ensureLoaded(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    if (!scheduler.initialized or scheduler.dirty) {
        try scheduler.rebuild(gpa, scene, assets, now_ms);
    }
}

fn rebuild(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    scheduler.entries.clearRetainingCapacity();
    scheduler.states.clearRetainingCapacity();

    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.fsm)) |entity_id, maybe_fsm| {
        const fsm_component = maybe_fsm orelse continue;
        var fsms = try fsm_component.getInitialFsm(gpa, assets);
        defer fsms.deinit(gpa);

        for (fsms.items) |fsm| {
            try scheduler.states.append(gpa, .{
                .entity_id = entity_id.net_id,
                .fsm_id = fsm.FsmId,
                .current_state = fsm.CurrentState,
                .state_started_ms = now_ms,
            });
        }
    }

    scheduler.initialized = true;
    scheduler.dirty = false;
    try scheduler.rescheduleAll(gpa, scene, assets, now_ms);
}

fn rescheduleAll(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    now_ms: i64,
) !void {
    scheduler.entries.clearRetainingCapacity();
    for (0..scheduler.states.items.len) |i| {
        try scheduler.scheduleForState(gpa, scene, assets, i, now_ms);
    }
}

fn scheduleForState(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    scene: *Scene,
    assets: *const Assets,
    state_index: usize,
    now_ms: i64,
) !void {
    _ = assets;
    const state = scheduler.states.items[state_index];
    if (state.pending_state != null) return;

    const fsm_component = findFsmComponent(scene, state.entity_id) orelse return;

    for (fsm_component.node_list) |entry| {
        for (entry.value.Transitions) |transition| {
            if (transition.From != state.current_state) continue;

            const due_ms = scheduler.transitionDueMs(
                fsm_component,
                state,
                transition,
                now_ms,
            ) orelse continue;

            try scheduler.entries.append(gpa, .{
                .entity_id = state.entity_id,
                .fsm_id = state.fsm_id,
                .from_state = transition.From,
                .to_state = transition.To,
                .due_ms = @max(due_ms, now_ms),
            });
        }
    }
}

fn transitionDueMs(
    scheduler: *FsmTimerScheduler,
    fsm_component: *const FsmComponent,
    state: FsmState,
    transition: StateMachineTransition,
    now_ms: i64,
) ?i64 {
    const top_condition = findCondition(transition.Conditions, 0) orelse return null;
    return switch (scheduler.evaluateCondition(
        fsm_component,
        state,
        transition,
        top_condition.*,
        now_ms,
    )) {
        .passed => now_ms,
        .failed => null,
        .wait_until => |due_ms| due_ms,
    };
}

fn evaluateCondition(
    scheduler: *FsmTimerScheduler,
    fsm_component: *const FsmComponent,
    state: FsmState,
    transition: StateMachineTransition,
    condition: StateMachineCondition,
    now_ms: i64,
) ConditionEval {
    var result = scheduler.evaluateConditionBase(fsm_component, state, transition, condition, now_ms);
    if (condition.Reverse and !(condition.IsClient orelse false)) {
        result = switch (result) {
            .passed => .failed,
            .failed => .passed,
            .wait_until => .passed,
        };
    }
    return result;
}

fn evaluateConditionBase(
    scheduler: *FsmTimerScheduler,
    fsm_component: *const FsmComponent,
    state: FsmState,
    transition: StateMachineTransition,
    condition: StateMachineCondition,
    now_ms: i64,
) ConditionEval {
    if (condition.CondAnd) |cond_and| {
        var due_ms: ?i64 = null;
        for (cond_and.Conditions) |condition_index| {
            const sub_condition = findCondition(transition.Conditions, condition_index) orelse return .failed;
            switch (scheduler.evaluateCondition(fsm_component, state, transition, sub_condition.*, now_ms)) {
                .failed => return .failed,
                .passed => {},
                .wait_until => |due| due_ms = if (due_ms) |current| @max(current, due) else due,
            }
        }

        return if (due_ms) |due| .{ .wait_until = due } else .passed;
    }

    if (condition.CondOr) |cond_or| {
        var due_ms: ?i64 = null;
        for (cond_or.Conditions) |condition_index| {
            const sub_condition = findCondition(transition.Conditions, condition_index) orelse continue;
            switch (scheduler.evaluateCondition(fsm_component, state, transition, sub_condition.*, now_ms)) {
                .passed => return .passed,
                .failed => {},
                .wait_until => |due| due_ms = if (due_ms) |current| @min(current, due) else due,
            }
        }

        return if (due_ms) |due| .{ .wait_until = due } else .failed;
    }

    if (condition.CondTimer) |timer| {
        const due_ms = state.state_started_ms + timer.MinTime;
        return if (now_ms >= due_ms) .passed else .{ .wait_until = due_ms };
    }

    if (std.mem.eql(u8, condition.Name, "CondTrue")) {
        return .passed;
    }

    if (condition.IsClient orelse false) {
        return if (scheduler.hasClientPass(
            fsm_component,
            state.entity_id,
            state.fsm_id,
            transition.From,
            transition.To,
            condition.Index,
        )) .passed else .failed;
    }

    return .failed;
}

fn findCondition(
    conditions: []const StateMachineCondition,
    condition_index: i32,
) ?*const StateMachineCondition {
    for (conditions) |*condition| {
        if (condition.Index == condition_index) return condition;
    }
    return null;
}

fn findStateIndex(
    scheduler: *const FsmTimerScheduler,
    entity_id: i64,
    fsm_id: i32,
) ?usize {
    for (scheduler.states.items, 0..) |state, i| {
        if (state.entity_id == entity_id and state.fsm_id == fsm_id) return i;
    }
    return null;
}

fn removeEntriesForFsm(
    scheduler: *FsmTimerScheduler,
    entity_id: i64,
    fsm_id: i32,
) void {
    var i: usize = 0;
    while (i < scheduler.entries.items.len) {
        const entry = scheduler.entries.items[i];
        if (entry.entity_id == entity_id and entry.fsm_id == fsm_id) {
            _ = scheduler.entries.swapRemove(i);
        } else {
            i += 1;
        }
    }
}

fn addClientPass(
    scheduler: *FsmTimerScheduler,
    gpa: Allocator,
    key: ConditionKey,
) !void {
    if (scheduler.hasExactClientPass(key)) return;
    try scheduler.client_passes.append(gpa, key);
}

fn removeClientPass(
    scheduler: *FsmTimerScheduler,
    key: ConditionKey,
) void {
    var i: usize = 0;
    while (i < scheduler.client_passes.items.len) {
        if (conditionKeyEql(scheduler.client_passes.items[i], key)) {
            _ = scheduler.client_passes.swapRemove(i);
        } else {
            i += 1;
        }
    }
}

fn hasClientPass(
    scheduler: *const FsmTimerScheduler,
    fsm_component: *const FsmComponent,
    entity_id: i64,
    fsm_id: i32,
    from_state: i32,
    to_state: i32,
    condition_index: i32,
) bool {
    const raw_key: ConditionKey = .{
        .entity_id = entity_id,
        .fsm_id = fsm_id,
        .from_state = from_state,
        .to_state = to_state,
        .condition_index = condition_index,
    };
    if (scheduler.hasExactClientPass(raw_key)) return true;

    const resolved = resolveOverride(fsm_component, from_state, to_state, false);
    return scheduler.hasExactClientPass(.{
        .entity_id = entity_id,
        .fsm_id = fsm_id,
        .from_state = resolved.from,
        .to_state = resolved.to,
        .condition_index = condition_index,
    });
}

fn hasExactClientPass(
    scheduler: *const FsmTimerScheduler,
    key: ConditionKey,
) bool {
    for (scheduler.client_passes.items) |pass| {
        if (conditionKeyEql(pass, key)) return true;
    }
    return false;
}

fn conditionKeyEql(a: ConditionKey, b: ConditionKey) bool {
    return a.entity_id == b.entity_id and
        a.fsm_id == b.fsm_id and
        a.from_state == b.from_state and
        a.to_state == b.to_state and
        a.condition_index == b.condition_index;
}

fn findFsmComponent(scene: *Scene, entity_id: i64) ?*Entity.FsmComponent {
    const index = scene.net_id_map.get(entity_id) orelse return null;
    const slice = scene.entities.slice();
    return if (slice.items(.fsm)[index]) |*component| component else null;
}

fn resolveOverride(
    fsm_component: *const FsmComponent,
    from_state: i32,
    to_state: i32,
    reverse: bool,
) TransitionStates {
    return .{
        .from = resolveOverrideState(fsm_component, from_state, reverse),
        .to = resolveOverrideState(fsm_component, to_state, reverse),
    };
}

fn resolveOverrideState(
    fsm_component: *const FsmComponent,
    state: i32,
    reverse: bool,
) i32 {
    for (fsm_component.override_mapping) |entry| {
        if (reverse) {
            if (entry.value == state) return entry.key;
        } else if (entry.key == state) {
            return entry.value;
        }
    }
    return state;
}

fn deepestChild(fsm_component: *const FsmComponent, state: i32) i32 {
    const node = findNode(fsm_component, state) orelse return state;
    if (node.Children) |children| {
        if (children.len > 0) return deepestChild(fsm_component, children[0]);
    }
    return state;
}

fn findNode(
    fsm_component: *const FsmComponent,
    node_id: i32,
) ?Assets.DataTables.AiStateMachineConfig.StateMachineNode {
    for (fsm_component.node_list) |entry| {
        if (entry.key == node_id) return entry.value;
    }
    return null;
}
