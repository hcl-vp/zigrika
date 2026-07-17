const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const Blackboard = @import("Blackboard.zig");
const ConditionEvaluator = @import("ConditionEvaluator.zig");
const StateHierarchy = @import("StateHierarchy.zig");
const Types = @import("Types.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;
const FsmGraph = Assets.FsmGraphRegistry.Graph;
const pending_transition_timeout_ms = 3000;

pub fn needsServerTick(comp: anytype) bool {
    if (comp.blackboard_dirty != 0) return true;
    if (comp.lifecycle_effects_pending) return true;
    if (comp.lifecycle_effects.items.len != 0) return true;
    if (comp.paralysis_active) return true;
    if (comp.in_hate) return true;

    for (comp.runtime_nodes) |runtime| {
        if (runtime.pending_to != null) return true;
        const active_path = runtime.active();
        if (active_path.len < 2) continue;

        for (active_path[1..], 1..) |active_state, index| {
            const parent = StateHierarchy.findNode(comp, active_path[index - 1]) orelse continue;
            for (parent.Transitions) |transition| {
                const resolved = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
                if (!StateHierarchy.statesEquivalent(comp, resolved.from, active_state)) continue;
                const condition = ConditionEvaluator.findCondition(transition.Conditions, 0) orelse continue;
                if (!(condition.IsClient orelse false) and !std.mem.eql(u8, condition.Name, "CondHate")) return true;
            }
        }
    }

    return false;
}

pub fn recoverExpiredPending(comp: anytype, gpa: mem.Allocator, now_ms: i64) !bool {
    if (comp.lifecycle_effects_pending) return false;
    const expired = for (comp.runtime_nodes) |runtime| {
        if (runtime.pending_to == null or runtime.pending_started_ms <= 0) continue;
        if (now_ms < runtime.pending_started_ms) continue;
        if (now_ms - runtime.pending_started_ms < pending_transition_timeout_ms) continue;
        break true;
    } else false;
    if (!expired) return false;

    for (comp.runtime_nodes) |*runtime| {
        if (runtime.pending_to == null) continue;
        try commitPending(comp, runtime, gpa);
    }
    return true;
}

pub fn recordClientPass(
    comp: anytype,
    gpa: mem.Allocator,
    key: Types.ConditionKey,
    value: bool,
) !Types.ClientPassResult {
    const fsm_id = StateHierarchy.canonicalState(comp, key.fsm_id);
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return .machine_not_found;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, key.from)) return .invalid_source;
    const source_is_active = StateHierarchy.pathContains(comp, runtime.active(), key.from);
    const source_is_pending = runtime.pending_from != null and
        runtime.pending_to != null and
        StateHierarchy.pathContains(comp, runtime.pending(), key.from);
    if (!source_is_active and !source_is_pending) return .inactive_source;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, key.to)) return .invalid_target;

    const resolved = StateHierarchy.resolveOverrideStates(comp, key.from, key.to, false);
    switch (clientConditionLookup(comp, fsm_id, resolved.from, resolved.to, key.index)) {
        .valid => {},
        .transition_not_found => return .transition_not_found,
        .condition_not_found => return .condition_not_found,
        .condition_not_client => return .condition_not_client,
    }

    const resolved_key: Types.ConditionKey = .{
        .fsm_id = fsm_id,
        .from = resolved.from,
        .to = resolved.to,
        .index = key.index,
    };

    if (!value) {
        try removePass(comp, gpa, resolved_key);
        return .updated;
    }

    try appendPass(comp, gpa, resolved_key);
    return .updated;
}

pub fn confirmPending(comp: anytype, fsm_id: i32, state: i32, gpa: mem.Allocator) !Types.ConfirmResult {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return .machine_not_found;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, state)) return .invalid_target;

    const pending_state = runtime.pending_to orelse return .no_pending;
    if (StateHierarchy.statesEquivalent(comp, state, pending_state)) {
        try commitPending(comp, runtime, gpa);
        return .confirmed;
    }

    return .{ .mismatch = StateHierarchy.clientState(comp, pending_state) };
}

pub fn confirmStateRequest(
    comp: anytype,
    fsm_id: i32,
    from: i32,
    to: i32,
    gpa: mem.Allocator,
    now_ms: i64,
) !Types.ConfirmResult {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return .machine_not_found;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, from)) return .invalid_source;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, to)) return .invalid_target;

    const pending_state = runtime.pending_to orelse {
        if (try acceptPredictedTransition(comp, fsm_id, from, to, gpa, now_ms)) return .accepted;
        return .no_pending;
    };

    if (StateHierarchy.statesEquivalent(comp, to, pending_state)) {
        const pending_from = runtime.pending_from orelse
            return .{ .mismatch = StateHierarchy.clientState(comp, pending_state) };
        if (!StateHierarchy.statesEquivalent(comp, pending_from, from))
            return .{ .mismatch = StateHierarchy.clientState(comp, pending_state) };

        try commitPending(comp, runtime, gpa);
        return .confirmed;
    }

    if (canFoldPredictedTransition(comp, runtime, from, to)) {
        try commitPending(comp, runtime, gpa);
        try changeCurrentState(comp, fsm_id, to, gpa, now_ms);
        return .confirmed;
    }

    return .{ .mismatch = StateHierarchy.clientState(comp, pending_state) };
}

pub fn currentState(comp: anytype, fsm_id: i32) ?i32 {
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id == StateHierarchy.canonicalState(comp, fsm_id)) {
            return if (runtime.leaf()) |leaf| StateHierarchy.clientState(comp, leaf) else null;
        }
    }

    return null;
}

pub fn findReadyTransition(comp: anytype, fsm_id: i32, ctx: Types.EvalContext) !?Types.Transition {
    if (comp.lifecycle_effects_pending) return null;
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return null;
    if (runtime.pending_to != null) return null;

    const active_path = runtime.active();
    if (active_path.len < 2) return null;

    for (active_path[1..], 1..) |active_state, index| {
        const parent_node = StateHierarchy.findNode(comp, active_path[index - 1]) orelse continue;
        if (try checkTransitionsForState(comp, runtime.fsm_id, parent_node, active_state, ctx)) |transition| {
            return transition;
        }
    }

    return null;
}

pub fn enterPath(comp: anytype, gpa: mem.Allocator, path: []const i32) !void {
    for (path) |state| try enterNode(comp, gpa, state);
}

fn checkTransitionsForState(
    comp: anytype,
    fsm_id: i32,
    node: *const AiStateMachineConfig.StateMachineNode,
    state_to_check: i32,
    ctx: Types.EvalContext,
) !?Types.Transition {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return null;
    if (runtime.pending_to != null) return null;

    const children = node.Children orelse return null;
    const canonical_source = StateHierarchy.canonicalState(comp, state_to_check);

    for (node.Transitions) |transition| {
        const resolved_transition = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
        if (resolved_transition.from != canonical_source) continue;

        const target_state = resolved_transition.to;
        if (canonical_source == target_state) continue;

        const target_is_child = for (children) |child| {
            if (StateHierarchy.statesEquivalent(comp, child, target_state)) break true;
        } else false;
        if (!target_is_child) continue;

        const top_condition = ConditionEvaluator.findCondition(transition.Conditions, 0) orelse continue;
        if (!ConditionEvaluator.evaluate(comp, fsm_id, transition, transition.Conditions, top_condition, ctx, 0)) continue;

        try setPendingTransition(comp, runtime, canonical_source, target_state, ctx.now_ms);
        return .{
            .fsm_id = StateHierarchy.clientState(comp, runtime.fsm_id),
            .from = StateHierarchy.clientState(comp, canonical_source),
            .to = StateHierarchy.clientState(comp, target_state),
        };
    }

    return null;
}

fn acceptPredictedTransition(
    comp: anytype,
    fsm_id: i32,
    from: i32,
    to: i32,
    gpa: mem.Allocator,
    now_ms: i64,
) !bool {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return false;
    if (!StateHierarchy.pathContains(comp, runtime.active(), from)) return false;
    if (!hasPredictedTransition(comp, runtime.fsm_id, from, to)) return false;

    try changeCurrentState(comp, fsm_id, to, gpa, now_ms);
    return true;
}

fn canFoldPredictedTransition(comp: anytype, runtime: *const Types.FsmNode, from: i32, to: i32) bool {
    if (!StateHierarchy.pathContains(comp, runtime.pending(), from)) return false;
    if (!StateHierarchy.stateBelongsToFsm(comp, runtime.fsm_id, to)) return false;
    return hasPredictedTransition(comp, runtime.fsm_id, from, to);
}

fn hasPredictedTransition(comp: anytype, fsm_id: i32, from: i32, to: i32) bool {
    const requested = StateHierarchy.resolveOverrideStates(comp, from, to, false);
    const root = StateHierarchy.findNode(comp, fsm_id) orelse return false;
    const client_owns_animation = root.IsAnimStateMachine orelse false;
    const flags = comp.graph.transitionFlags(requested.from, requested.to);
    if (client_owns_animation) return flags & Assets.FsmGraphRegistry.transition_present != 0;
    return flags & Assets.FsmGraphRegistry.transition_predicted != 0;
}

fn clientConditionLookup(comp: anytype, fsm_id: i32, from: i32, to: i32, index: i32) Types.ClientConditionLookup {
    var found_transition = false;
    var found_condition = false;
    if (findClientConditionRecursive(
        comp,
        StateHierarchy.canonicalState(comp, fsm_id),
        StateHierarchy.canonicalState(comp, from),
        StateHierarchy.canonicalState(comp, to),
        index,
        &found_transition,
        &found_condition,
        0,
    )) return .valid;

    if (!found_transition) return .transition_not_found;
    if (!found_condition) return .condition_not_found;
    return .condition_not_client;
}

fn findClientConditionRecursive(
    comp: anytype,
    node_id: i32,
    from: i32,
    to: i32,
    index: i32,
    found_transition: *bool,
    found_condition: *bool,
    depth: usize,
) bool {
    if (depth >= Types.max_state_depth) return false;
    const node = StateHierarchy.findNode(comp, node_id) orelse return false;

    for (node.Transitions) |transition| {
        const resolved = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
        if (resolved.from != from or resolved.to != to) continue;

        found_transition.* = true;
        const condition = ConditionEvaluator.findCondition(transition.Conditions, index) orelse continue;
        found_condition.* = true;
        if (condition.IsClient orelse false) return true;
    }

    if (node.Children) |children| {
        for (children) |child| {
            if (findClientConditionRecursive(
                comp,
                child,
                from,
                to,
                index,
                found_transition,
                found_condition,
                depth + 1,
            )) return true;
        }
    }

    return false;
}

fn runActions(
    comp: anytype,
    gpa: mem.Allocator,
    actions: []const AiStateMachineConfig.StateMachineAction,
) !void {
    for (actions) |action| {
        if (action.ActionDispatchEvent) |event_action| {
            comp.event = event_action.Event;
        }

        if (action.ActionAddBuff) |buff| try appendLifecycleEffect(comp, gpa, .{ .add_buff = buff.BuffId });
        if (action.ActionRemoveBuff) |buff| try appendLifecycleEffect(comp, gpa, .{ .remove_buff = buff.BuffId });
        if (action.ActionCue) |cue| {
            if (std.mem.indexOfScalar(i64, cue.CueIds, 1020) != null) {
                try appendLifecycleEffect(comp, gpa, .cue_paralysis);
            }
        }
        if (action.ActionResetStatus != null) try appendLifecycleEffect(comp, gpa, .reset_status);
        if (action.ActionSetRageFullAttribute != null) try appendLifecycleEffect(comp, gpa, .set_rage_full);
        if (action.ActionInstChangeStateTag) |state| {
            if (std.math.cast(i32, state.TagId)) |tag_id| {
                try appendLifecycleEffect(comp, gpa, .{ .set_instance_state = tag_id });
            }
        }
        if (action.ActionActivatePart) |part| {
            try appendLifecycleEffect(comp, gpa, .{ .activate_part = .{
                .name = part.PartName,
                .activate = part.Activate,
            } });
        }
        if (action.ActionResetPart) |part| {
            try appendLifecycleEffect(comp, gpa, .{ .reset_part = .{
                .name = part.PartName,
                .reset_activate = part.ResetActivate,
                .reset_life = part.ResetLife,
            } });
        }

        if (action.ActionAddTagCount) |tag| {
            if (tag.Count > 0) try updateTagCount(comp, gpa, tag.TagId, tag.Count);
        }

        if (action.ActionRemoveTagCount) |tag| {
            if (tag.Count == -1) {
                clearTag(comp, tag.TagId);
            } else if (tag.Count > 0) {
                try updateTagCount(comp, gpa, tag.TagId, -tag.Count);
            }
        }
    }
}

fn updateBindStates(
    comp: anytype,
    gpa: mem.Allocator,
    binds: []const AiStateMachineConfig.StateMachineBindState,
    delta: i32,
) !void {
    for (binds) |bind| {
        if (bind.BindBuff) |buff| {
            if (delta > 0) {
                try appendLifecycleEffect(comp, gpa, .{ .add_buff = buff.BuffId });
            }
        }

        if (bind.BindTag) |tag| {
            try updateTagCount(comp, gpa, tag.TagId, delta);
        }
    }
}

fn appendLifecycleEffect(comp: anytype, gpa: mem.Allocator, effect: Types.LifecycleEffect) !void {
    try comp.lifecycle_effects.append(gpa, effect);
}

fn updateTagCount(comp: anytype, gpa: mem.Allocator, tag_id: i64, delta: i32) !void {
    for (comp.tags) |*tag| {
        if (tag.id != tag_id) continue;
        const count = @as(i64, tag.count) + delta;
        if (count > std.math.maxInt(i32)) return error.FsmTagCountOverflow;
        tag.count = if (count > 0) @intCast(count) else 0;
        return;
    }

    if (delta <= 0) return;

    const old_tags = comp.tags;
    const tags = try gpa.alloc(Types.TagCount, old_tags.len + 1);
    @memcpy(tags[0..old_tags.len], old_tags);
    tags[old_tags.len] = .{ .id = tag_id, .count = delta };
    gpa.free(old_tags);
    comp.tags = tags;
}

fn clearTag(comp: anytype, tag_id: i64) void {
    for (comp.tags) |*tag| {
        if (tag.id == tag_id) {
            tag.count = 0;
            return;
        }
    }
}

fn applyPathLifecycle(comp: anytype, gpa: mem.Allocator, active_path: []const i32, target_path: []const i32) !void {
    const common_len = StateHierarchy.commonPathPrefixLen(active_path, target_path);

    comp.event = null;

    var exit_index = active_path.len;
    while (exit_index > common_len) {
        exit_index -= 1;
        try exitNode(comp, gpa, active_path[exit_index]);
    }

    for (target_path[common_len..]) |state| try enterNode(comp, gpa, state);
}

fn enterNode(comp: anytype, gpa: mem.Allocator, state: i32) !void {
    const node = StateHierarchy.findNode(comp, state) orelse return;
    try runActions(comp, gpa, node.OnEnterActions);
    try updateBindStates(comp, gpa, node.BindStates, 1);
}

fn exitNode(comp: anytype, gpa: mem.Allocator, state: i32) !void {
    const node = StateHierarchy.findNode(comp, state) orelse return;
    try runActions(comp, gpa, node.OnExitActions);
    try updateBindStates(comp, gpa, node.BindStates, -1);
}

fn setPendingTransition(comp: anytype, runtime: *Types.FsmNode, from: i32, to: i32, now_ms: i64) !void {
    const pending_len = StateHierarchy.buildActivePath(comp, runtime.fsm_id, to, &runtime.pending_path) orelse
        return error.InvalidFsmTransitionTarget;

    for (runtime.pending_path[0..pending_len], 0..) |state, index| {
        runtime.pending_since_ms[index] = if (index < runtime.active_len and runtime.active_path[index] == state)
            runtime.active_since_ms[index]
        else
            now_ms;
    }

    runtime.pending_len = @intCast(pending_len);
    runtime.pending_from = StateHierarchy.canonicalState(comp, from);
    runtime.pending_to = StateHierarchy.canonicalState(comp, to);
    runtime.pending_started_ms = now_ms;
    Blackboard.preparePath(comp, runtime.pending(), runtime.pending_since_ms[0..runtime.pending_len], true);
}

fn commitPending(comp: anytype, runtime: *Types.FsmNode, gpa: mem.Allocator) !void {
    if (runtime.pending_from == null) return;
    const pending_path = runtime.pending();
    if (pending_path.len == 0) return;

    try applyPathLifecycle(comp, gpa, runtime.active(), pending_path);
    try removePassesForExitedPath(comp, gpa, runtime.fsm_id, runtime.active(), pending_path);
    @memcpy(runtime.active_path[0..pending_path.len], pending_path);
    @memcpy(runtime.active_since_ms[0..pending_path.len], runtime.pending_since_ms[0..pending_path.len]);
    runtime.active_len = runtime.pending_len;
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
}

fn changeCurrentState(comp: anytype, fsm_id: i32, to: i32, gpa: mem.Allocator, now_ms: i64) !void {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return;
    var target_path: [Types.max_state_depth]i32 = @splat(0);
    var target_since_ms: [Types.max_state_depth]i64 = @splat(0);
    const active_len = StateHierarchy.buildActivePath(comp, runtime.fsm_id, to, &target_path) orelse return;
    for (target_path[0..active_len], 0..) |state, index| {
        target_since_ms[index] = if (index < runtime.active_len and runtime.active_path[index] == state)
            runtime.active_since_ms[index]
        else
            now_ms;
    }

    Blackboard.preparePath(comp, target_path[0..active_len], target_since_ms[0..active_len], true);
    try applyPathLifecycle(comp, gpa, runtime.active(), target_path[0..active_len]);
    try removePassesForExitedPath(comp, gpa, runtime.fsm_id, runtime.active(), target_path[0..active_len]);
    @memcpy(runtime.active_path[0..active_len], target_path[0..active_len]);
    @memcpy(runtime.active_since_ms[0..active_len], target_since_ms[0..active_len]);
    runtime.active_len = @intCast(active_len);
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
}

fn appendPass(comp: anytype, gpa: mem.Allocator, key: Types.ConditionKey) !void {
    if (passPoolContains(comp, key)) return;

    const old_pass_pool = comp.pass_pool;
    const pass_pool = try gpa.alloc(Types.ConditionKey, old_pass_pool.len + 1);
    @memcpy(pass_pool[0..old_pass_pool.len], old_pass_pool);
    pass_pool[old_pass_pool.len] = key;
    gpa.free(old_pass_pool);
    comp.pass_pool = pass_pool;
}

fn removePass(comp: anytype, gpa: mem.Allocator, key: Types.ConditionKey) !void {
    var pass_pool: std.ArrayList(Types.ConditionKey) = .empty;
    defer pass_pool.deinit(gpa);

    for (comp.pass_pool) |entry| {
        if (entry.fsm_id == key.fsm_id and
            entry.index == key.index and
            StateHierarchy.statesEquivalent(comp, entry.from, key.from) and
            StateHierarchy.statesEquivalent(comp, entry.to, key.to)) continue;
        try pass_pool.append(gpa, entry);
    }

    gpa.free(comp.pass_pool);
    comp.pass_pool = try pass_pool.toOwnedSlice(gpa);
}

fn removePassesForExitedPath(
    comp: anytype,
    gpa: mem.Allocator,
    fsm_id: i32,
    active_path: []const i32,
    target_path: []const i32,
) !void {
    const exited_path = active_path[StateHierarchy.commonPathPrefixLen(active_path, target_path)..];
    if (exited_path.len == 0 or comp.pass_pool.len == 0) return;

    const canonical_fsm = StateHierarchy.canonicalState(comp, fsm_id);
    var retained: usize = 0;
    for (comp.pass_pool) |entry| {
        const remove = entry.fsm_id == canonical_fsm and StateHierarchy.pathContains(comp, exited_path, entry.from);
        if (remove) continue;
        comp.pass_pool[retained] = entry;
        retained += 1;
    }

    if (retained == comp.pass_pool.len) return;
    if (retained == 0) {
        gpa.free(comp.pass_pool);
        comp.pass_pool = &.{};
    } else {
        comp.pass_pool = try gpa.realloc(comp.pass_pool, retained);
    }
}

test "pending fsm transition defers lifecycle effects until confirmation" {
    const TestComponent = struct {
        graph: *const FsmGraph = &FsmGraph.empty,
        runtime_nodes: []Types.FsmNode = &.{},
        pass_pool: []Types.ConditionKey = &.{},
        tags: []Types.TagCount = &.{},
        lifecycle_effects: std.ArrayList(Types.LifecycleEffect) = .empty,
        lifecycle_effects_pending: bool = false,
        in_hate: bool = false,
        paralysis_active: bool = false,
        instance_state_tag: ?i32 = null,
        event: ?[]const u8 = null,
        last_tick_ms: i64 = 0,
        blackboard: [3]?i32 = .{ null, null, null },
        blackboard_dirty: u8 = 0,
    };

    const conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondTrue" },
    };
    const transitions = [_]AiStateMachineConfig.StateMachineTransition{
        .{ .From = 2, .To = 3, .Conditions = &conditions },
    };
    const exit_actions = [_]AiStateMachineConfig.StateMachineAction{
        .{ .ActionSetRageFullAttribute = .{} },
    };
    const enter_actions = [_]AiStateMachineConfig.StateMachineAction{
        .{ .ActionResetStatus = .{} },
        .{ .ActionActivatePart = .{ .PartName = "shield", .Activate = true } },
    };
    const children = [_]i32{ 2, 3 };
    const nodes = [_]AiStateMachineConfig.StateMachineNode{
        .{ .Uuid = 1, .Children = &children, .Transitions = &transitions },
        .{ .Uuid = 2, .OnExitActions = &exit_actions },
        .{ .Uuid = 3, .OnEnterActions = &enter_actions },
    };
    var graph_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer graph_arena.deinit();
    const graph = try buildTestGraph(graph_arena.allocator(), &.{1}, &nodes);
    var runtime_nodes = [_]Types.FsmNode{.{
        .fsm_id = 1,
        .active_path = .{ 1, 2 } ++ @as([Types.max_state_depth - 2]i32, @splat(0)),
        .active_since_ms = @splat(10),
        .active_len = 2,
    }};
    var component: TestComponent = .{
        .graph = &graph,
        .runtime_nodes = &runtime_nodes,
    };
    defer component.lifecycle_effects.deinit(std.testing.allocator);

    const transition = (try findReadyTransition(&component, 1, .{ .now_ms = 100 })) orelse
        return error.ExpectedFsmTransition;
    try std.testing.expectEqual(@as(i32, 2), transition.from);
    try std.testing.expectEqual(@as(i32, 3), transition.to);
    try std.testing.expectEqual(@as(usize, 0), component.lifecycle_effects.items.len);
    try std.testing.expectEqual(@as(?i32, 3), runtime_nodes[0].pending_to);

    try std.testing.expectEqual(Types.ConfirmResult.confirmed, try confirmPending(
        &component,
        1,
        3,
        std.testing.allocator,
    ));
    try std.testing.expectEqual(@as(?i32, null), runtime_nodes[0].pending_to);
    try std.testing.expectEqual(@as(?i32, 3), runtime_nodes[0].leaf());
    try std.testing.expectEqual(@as(usize, 3), component.lifecycle_effects.items.len);
    try std.testing.expectEqual(Types.LifecycleEffect.set_rage_full, component.lifecycle_effects.items[0]);
    try std.testing.expectEqual(Types.LifecycleEffect.reset_status, component.lifecycle_effects.items[1]);
    try std.testing.expectEqualStrings("shield", component.lifecycle_effects.items[2].activate_part.name);
    try std.testing.expect(component.lifecycle_effects.items[2].activate_part.activate);
}

test "client pass from pending path drives followup after confirmation" {
    const TestComponent = struct {
        graph: *const FsmGraph = &FsmGraph.empty,
        runtime_nodes: []Types.FsmNode = &.{},
        pass_pool: []Types.ConditionKey = &.{},
        tags: []Types.TagCount = &.{},
        lifecycle_effects: std.ArrayList(Types.LifecycleEffect) = .empty,
        lifecycle_effects_pending: bool = false,
        in_hate: bool = false,
        paralysis_active: bool = false,
        instance_state_tag: ?i32 = null,
        event: ?[]const u8 = null,
        last_tick_ms: i64 = 0,
        blackboard: [3]?i32 = .{ null, null, null },
        blackboard_dirty: u8 = 0,
    };

    const root_conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondTrue" },
    };
    const client_conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondTaskFinish", .IsClient = true },
    };
    const root_transitions = [_]AiStateMachineConfig.StateMachineTransition{
        .{ .From = 2, .To = 3, .Conditions = &root_conditions },
    };
    const nested_transitions = [_]AiStateMachineConfig.StateMachineTransition{
        .{ .From = 5, .To = 6, .Conditions = &client_conditions, .TransitionPredictionType = 2 },
    };
    const root_children = [_]i32{ 2, 3 };
    const pending_children = [_]i32{ 5, 6 };
    const nodes = [_]AiStateMachineConfig.StateMachineNode{
        .{ .Uuid = 1, .Children = &root_children, .Transitions = &root_transitions },
        .{ .Uuid = 2 },
        .{ .Uuid = 3, .Children = &pending_children, .Transitions = &nested_transitions },
        .{ .Uuid = 5 },
        .{ .Uuid = 6 },
    };
    var graph_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer graph_arena.deinit();
    const graph = try buildTestGraph(graph_arena.allocator(), &.{1}, &nodes);
    var runtime_nodes = [_]Types.FsmNode{.{
        .fsm_id = 1,
        .active_path = .{ 1, 2 } ++ @as([Types.max_state_depth - 2]i32, @splat(0)),
        .active_since_ms = @splat(10),
        .active_len = 2,
        .pending_path = .{ 1, 3, 5 } ++ @as([Types.max_state_depth - 3]i32, @splat(0)),
        .pending_since_ms = @splat(20),
        .pending_len = 3,
        .pending_from = 2,
        .pending_to = 3,
        .pending_started_ms = 20,
    }};
    var component: TestComponent = .{
        .graph = &graph,
        .runtime_nodes = &runtime_nodes,
    };
    defer {
        std.testing.allocator.free(component.pass_pool);
        component.lifecycle_effects.deinit(std.testing.allocator);
    }

    const key: Types.ConditionKey = .{ .fsm_id = 1, .from = 5, .to = 6, .index = 0 };
    try std.testing.expectEqual(
        Types.ClientPassResult.updated,
        try recordClientPass(&component, std.testing.allocator, key, true),
    );
    try std.testing.expect(passPoolContains(&component, key));
    try std.testing.expect((try findReadyTransition(&component, 1, .{ .now_ms = 25 })) == null);

    try std.testing.expectEqual(
        Types.ConfirmResult.confirmed,
        try confirmPending(&component, 1, 3, std.testing.allocator),
    );
    const followup = (try findReadyTransition(&component, 1, .{ .now_ms = 30 })) orelse
        return error.ExpectedFsmTransition;
    try std.testing.expectEqual(@as(i32, 5), followup.from);
    try std.testing.expectEqual(@as(i32, 6), followup.to);

    try std.testing.expectEqual(
        Types.ClientPassResult.updated,
        try recordClientPass(&component, std.testing.allocator, key, false),
    );
    try std.testing.expect(!passPoolContains(&component, key));
}

test "client pass validation preserves active pending and override boundaries" {
    const TestComponent = struct {
        graph: *const FsmGraph = &FsmGraph.empty,
        runtime_nodes: []Types.FsmNode = &.{},
        pass_pool: []Types.ConditionKey = &.{},
    };

    const client_conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondTaskFinish", .Index = 7, .IsClient = true },
    };
    const server_conditions = [_]AiStateMachineConfig.StateMachineCondition{
        .{ .Name = "CondTrue", .Index = 8 },
    };
    const transitions = [_]AiStateMachineConfig.StateMachineTransition{
        .{ .From = 20, .To = 30, .Conditions = &client_conditions },
        .{ .From = 20, .To = 40, .Conditions = &server_conditions },
    };
    const children = [_]i32{ 20, 30, 40, 50 };
    const other_children = [_]i32{ 70, 80 };
    const nodes = [_]AiStateMachineConfig.StateMachineNode{
        .{ .Uuid = 10, .Children = &children, .Transitions = &transitions },
        .{ .Uuid = 20 },
        .{ .Uuid = 30 },
        .{ .Uuid = 40 },
        .{ .Uuid = 50 },
        .{ .Uuid = 60, .Children = &other_children },
        .{ .Uuid = 70 },
        .{ .Uuid = 80 },
        .{ .Uuid = 120, .OverrideCommonUuid = 20 },
        .{ .Uuid = 130, .OverrideCommonUuid = 30 },
    };
    var graph_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer graph_arena.deinit();
    const graph = try buildTestGraph(graph_arena.allocator(), &.{ 10, 60 }, &nodes);
    var runtime_nodes = [_]Types.FsmNode{
        .{
            .fsm_id = 10,
            .active_path = .{ 10, 20 } ++ @as([Types.max_state_depth - 2]i32, @splat(0)),
            .active_len = 2,
        },
        .{
            .fsm_id = 60,
            .active_path = .{ 60, 70 } ++ @as([Types.max_state_depth - 2]i32, @splat(0)),
            .active_len = 2,
            .pending_path = .{ 60, 80 } ++ @as([Types.max_state_depth - 2]i32, @splat(0)),
            .pending_len = 2,
            .pending_from = 70,
            .pending_to = 80,
        },
    };
    var component: TestComponent = .{
        .graph = &graph,
        .runtime_nodes = &runtime_nodes,
    };
    defer std.testing.allocator.free(component.pass_pool);

    const alias_key: Types.ConditionKey = .{ .fsm_id = 10, .from = 120, .to = 130, .index = 7 };
    try std.testing.expectEqual(
        Types.ClientPassResult.updated,
        try recordClientPass(&component, std.testing.allocator, alias_key, true),
    );
    try std.testing.expect(passPoolContains(&component, .{ .fsm_id = 10, .from = 20, .to = 30, .index = 7 }));
    const original_pool_len = component.pass_pool.len;

    try std.testing.expectEqual(
        Types.ClientPassResult.inactive_source,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 50, .to = 30, .index = 7 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.inactive_source,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 50, .to = 30, .index = 7 }, false),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.invalid_source,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 80, .to = 70, .index = 7 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.invalid_target,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 20, .to = 999, .index = 7 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.transition_not_found,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 20, .to = 50, .index = 7 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.condition_not_found,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 20, .to = 30, .index = 99 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.condition_not_client,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 10, .from = 20, .to = 40, .index = 8 }, true),
    );
    try std.testing.expectEqual(
        Types.ClientPassResult.machine_not_found,
        try recordClientPass(&component, std.testing.allocator, .{ .fsm_id = 999, .from = 20, .to = 30, .index = 7 }, true),
    );
    try std.testing.expectEqual(original_pool_len, component.pass_pool.len);
}

fn buildTestGraph(
    arena: mem.Allocator,
    roots: []const i32,
    nodes: []const AiStateMachineConfig.StateMachineNode,
) !FsmGraph {
    return (try Assets.FsmGraphRegistry.buildGraph(
        arena,
        .{ .Version = 1, .StateMachines = roots, .Nodes = nodes },
        .{ .Version = 2, .StateMachines = &.{}, .Nodes = &.{} },
    )) orelse error.InvalidTestFsmGraph;
}

fn passPoolContains(comp: anytype, key: Types.ConditionKey) bool {
    for (comp.pass_pool) |entry| {
        if (conditionKeyEql(entry, key)) return true;
    }

    return false;
}

fn conditionKeyEql(a: Types.ConditionKey, b: Types.ConditionKey) bool {
    return a.fsm_id == b.fsm_id and
        a.from == b.from and
        a.to == b.to and
        a.index == b.index;
}
