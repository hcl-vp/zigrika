const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const Blackboard = @import("Blackboard.zig");
const ConditionEvaluator = @import("ConditionEvaluator.zig");
const StateHierarchy = @import("StateHierarchy.zig");
const Types = @import("Types.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;
const pending_transition_timeout_ms = 3000;

pub fn refreshWakeRequirements(comp: anytype, now_ms: i64) void {
    for (comp.runtime_nodes) |*runtime| refreshRootWakeRequirements(comp, runtime, now_ms, true);
}

pub fn refreshRootTimer(comp: anytype, fsm_id: i32, now_ms: i64) void {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return;
    refreshRootWakeRequirements(comp, runtime, now_ms, false);
}

pub fn markDirty(comp: anytype, reason: Types.WakeMask) bool {
    var marked = false;
    for (comp.runtime_nodes) |*runtime| {
        if (!serverEvaluatesRoot(comp, runtime.fsm_id)) continue;
        const relevant = if (reason & Types.WakeReason.initial != 0)
            reason
        else
            reason & runtime.wake_dependencies;
        if (relevant == 0) continue;
        runtime.dirty_reasons |= relevant;
        marked = true;
    }
    return marked;
}

pub fn markRootDirty(comp: anytype, fsm_id: i32, reason: Types.WakeMask) bool {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return false;
    if (!serverEvaluatesRoot(comp, runtime.fsm_id)) return false;
    const relevant = if (reason & Types.WakeReason.initial != 0)
        reason
    else
        reason & runtime.wake_dependencies;
    if (relevant == 0) return false;
    runtime.dirty_reasons |= relevant;
    return true;
}

pub fn pendingDeadline(comp: anytype) ?i64 {
    var deadline: ?i64 = null;
    for (comp.runtime_nodes) |runtime| {
        if (runtime.pending_to == null or runtime.pending_started_ms <= 0) continue;
        const candidate = runtime.pending_started_ms + pending_transition_timeout_ms;
        deadline = if (deadline) |current| @min(current, candidate) else candidate;
    }
    return deadline;
}

fn refreshRootWakeRequirements(
    comp: anytype,
    runtime: *Types.FsmNode,
    now_ms: i64,
    refresh_dependencies: bool,
) void {
    if (refresh_dependencies) runtime.wake_dependencies = 0;
    runtime.next_timer_due_ms = null;
    if (!serverEvaluatesRoot(comp, runtime.fsm_id)) {
        runtime.dirty_reasons = 0;
        return;
    }

    const active_path = runtime.active();
    if (active_path.len < 2) return;

    for (active_path[1..], 1..) |active_state, index| {
        const parent_state = active_path[index - 1];
        const parent_node = StateHierarchy.findNode(comp, parent_state) orelse continue;
        if (anyStateChild(comp, parent_node)) |any_state| {
            refreshSourceWakeRequirements(
                comp,
                runtime,
                parent_node,
                any_state,
                parent_state,
                now_ms,
                refresh_dependencies,
            );
        }
        refreshSourceWakeRequirements(
            comp,
            runtime,
            parent_node,
            active_state,
            active_state,
            now_ms,
            refresh_dependencies,
        );
    }
}

fn refreshSourceWakeRequirements(
    comp: anytype,
    runtime: *Types.FsmNode,
    parent_node: *const AiStateMachineConfig.StateMachineNode,
    configured_source: i32,
    activation_state: i32,
    now_ms: i64,
    refresh_dependencies: bool,
) void {
    const children = parent_node.Children orelse return;
    const canonical_source = StateHierarchy.canonicalState(comp, configured_source);

    for (parent_node.Transitions) |transition| {
        const resolved = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
        if (resolved.from != canonical_source or resolved.from == resolved.to) continue;
        if (!targetIsChild(comp, children, resolved.to)) continue;

        const top_condition = ConditionEvaluator.findCondition(transition.Conditions, 0) orelse continue;
        if (refresh_dependencies) {
            runtime.wake_dependencies |= ConditionEvaluator.dependencyMask(
                transition.Conditions,
                top_condition,
                0,
            );
        }
        if (runtime.pending_to != null) continue;
        if (ConditionEvaluator.nextTimerDeadline(
            comp,
            runtime.fsm_id,
            transition,
            transition.Conditions,
            top_condition,
            now_ms,
            activation_state,
            0,
        )) |candidate| {
            runtime.next_timer_due_ms = if (runtime.next_timer_due_ms) |current|
                @min(current, candidate)
            else
                candidate;
        }
    }
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
        if (runtime.pending_to == null or runtime.pending_started_ms <= 0) continue;
        if (now_ms < runtime.pending_started_ms) continue;
        if (now_ms - runtime.pending_started_ms < pending_transition_timeout_ms) continue;
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
    const source_is_active = StateHierarchy.pathContains(comp, runtime.active(), key.from) or
        pathContainsEligibleAnyState(comp, runtime.active(), key.from);
    const source_is_pending = runtime.pending_from != null and
        runtime.pending_to != null and
        (StateHierarchy.pathContains(comp, runtime.pending(), key.from) or
            pathContainsEligibleAnyState(comp, runtime.pending(), key.from));
    if (!source_is_active and !source_is_pending) return .inactive_source;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, key.to)) return .invalid_target;

    const resolved = StateHierarchy.resolveOverrideStates(comp, key.from, key.to, false);
    switch (clientConditionLookup(comp, fsm_id, resolved.from, resolved.to, key.index)) {
        .valid => |requirement| {
            const path = if (source_is_pending) runtime.pending() else runtime.active();
            if (!StateHierarchy.clientTaskRequirementSatisfied(
                comp,
                path,
                resolved.from,
                resolved.to,
                requirement,
            ))
                return .condition_context_invalid;
        },
        .transition_not_found => return .transition_not_found,
        .condition_not_found => return .condition_not_found,
        .condition_not_client => return .condition_not_client,
        .condition_invalid => return .condition_context_invalid,
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
    ctx: Types.EvalContext,
) !Types.ConfirmResult {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return .machine_not_found;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, from)) return .invalid_source;
    if (!StateHierarchy.stateBelongsToFsm(comp, fsm_id, to)) return .invalid_target;

    const pending_state = runtime.pending_to orelse {
        if (try acceptPredictedTransition(comp, fsm_id, from, to, gpa, ctx)) return .accepted;
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

    if (canApplyNestedTransition(comp, runtime, from, to)) {
        try commitPending(comp, runtime, gpa);
        try changeCurrentState(comp, fsm_id, to, gpa, ctx.now_ms);
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
    if (!serverEvaluatesRoot(comp, runtime.fsm_id)) return null;
    if (runtime.pending_to != null) return null;

    const active_path = runtime.active();
    if (active_path.len < 2) return null;

    for (active_path[1..], 1..) |active_state, index| {
        const parent_state = active_path[index - 1];
        const parent_node = StateHierarchy.findNode(comp, parent_state) orelse continue;
        if (anyStateChild(comp, parent_node)) |any_state| {
            if (try checkTransitionsForState(
                comp,
                runtime.fsm_id,
                parent_node,
                any_state,
                active_state,
                parent_state,
                null,
                false,
                ctx,
            )) |transition| {
                return transition;
            }
        }
        if (try checkTransitionsForState(
            comp,
            runtime.fsm_id,
            parent_node,
            active_state,
            active_state,
            active_state,
            null,
            false,
            ctx,
        )) |transition| {
            return transition;
        }
    }

    return null;
}

pub fn enterPath(
    comp: anytype,
    gpa: mem.Allocator,
    fsm_id: i32,
    path: []const i32,
    active_since_ms: []const i64,
) !void {
    for (path, 0..) |state, index| {
        try enterNode(comp, gpa, fsm_id, state, active_since_ms[index]);
    }
}

fn checkTransitionsForState(
    comp: anytype,
    fsm_id: i32,
    node: *const AiStateMachineConfig.StateMachineNode,
    configured_source: i32,
    runtime_source: i32,
    activation_state: i32,
    requested_target: ?i32,
    client_request: bool,
    ctx: Types.EvalContext,
) !?Types.Transition {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return null;
    if (runtime.pending_to != null) return null;

    const children = node.Children orelse return null;
    const canonical_source = StateHierarchy.canonicalState(comp, configured_source);
    const canonical_runtime_source = StateHierarchy.canonicalState(comp, runtime_source);

    for (node.Transitions) |transition| {
        const resolved_transition = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
        if (resolved_transition.from != canonical_source) continue;

        const target_state = resolved_transition.to;
        if (canonical_source == target_state) continue;
        if (requested_target) |target| {
            if (!StateHierarchy.statesEquivalent(comp, target_state, target)) continue;
        }

        if (!targetIsChild(comp, children, target_state)) continue;
        if (client_request and !clientMayTakeTransition(comp, runtime.fsm_id, canonical_source, transition)) continue;

        const top_condition = ConditionEvaluator.findCondition(transition.Conditions, 0) orelse continue;
        if (!ConditionEvaluator.evaluate(
            comp,
            fsm_id,
            transition,
            transition.Conditions,
            top_condition,
            ctx,
            activation_state,
            0,
        )) continue;

        if (comp.dissolve_combine_signal and ConditionEvaluator.transitionUsesDissolveCombine(transition.Conditions)) {
            comp.dissolve_combine_signal = false;
        }
        try setPendingTransition(comp, runtime, canonical_runtime_source, target_state, ctx.now_ms);
        return .{
            .fsm_id = StateHierarchy.clientState(comp, runtime.fsm_id),
            .from = StateHierarchy.clientState(comp, canonical_runtime_source),
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
    ctx: Types.EvalContext,
) !bool {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return false;
    if (!StateHierarchy.pathContains(comp, runtime.active(), from)) return false;
    if (!serverEvaluatesRoot(comp, runtime.fsm_id)) {
        if (!canClientTransition(comp, runtime.fsm_id, from, to) and
            !canClientAnyStateTransition(comp, runtime.fsm_id, runtime.active(), from, to)) return false;
        try changeCurrentState(comp, fsm_id, to, gpa, ctx.now_ms);
        return true;
    }

    const active_path = runtime.active();
    if (active_path.len < 2) return false;
    for (active_path[1..], 1..) |active_state, index| {
        if (!StateHierarchy.statesEquivalent(comp, active_state, from)) continue;
        const parent_state = active_path[index - 1];
        const parent_node = StateHierarchy.findNode(comp, parent_state) orelse return false;
        const accepted = if (anyStateChild(comp, parent_node)) |any_state|
            try checkTransitionsForState(
                comp,
                runtime.fsm_id,
                parent_node,
                any_state,
                active_state,
                parent_state,
                to,
                true,
                ctx,
            )
        else
            null;
        _ = accepted orelse (try checkTransitionsForState(
            comp,
            runtime.fsm_id,
            parent_node,
            active_state,
            active_state,
            active_state,
            to,
            true,
            ctx,
        )) orelse return false;
        try commitPending(comp, runtime, gpa);
        return true;
    }
    return false;
}

fn canApplyNestedTransition(comp: anytype, runtime: *const Types.FsmNode, from: i32, to: i32) bool {
    if (!StateHierarchy.pathContains(comp, runtime.pending(), from)) return false;
    if (!StateHierarchy.stateBelongsToFsm(comp, runtime.fsm_id, to)) return false;
    const any_state = anyStateSourceForActiveState(comp, runtime.pending(), from);
    if (!allowsNestedTransition(comp, runtime.fsm_id, from) and
        (any_state == null or !allowsNestedTransition(comp, runtime.fsm_id, any_state.?))) return false;
    return canClientTransition(comp, runtime.fsm_id, from, to) or
        canClientAnyStateTransition(comp, runtime.fsm_id, runtime.pending(), from, to);
}

const AnyStateContext = struct {
    source: i32,
    parent_node: *const AiStateMachineConfig.StateMachineNode,
};

fn anyStateContextForActiveState(comp: anytype, path: []const i32, active_source: i32) ?AnyStateContext {
    if (path.len < 2) return null;
    for (path[1..], 1..) |active_state, index| {
        if (!StateHierarchy.statesEquivalent(comp, active_state, active_source)) continue;
        const parent_node = StateHierarchy.findNode(comp, path[index - 1]) orelse return null;
        const source = anyStateChild(comp, parent_node) orelse return null;
        return .{ .source = source, .parent_node = parent_node };
    }
    return null;
}

fn anyStateSourceForActiveState(comp: anytype, path: []const i32, active_source: i32) ?i32 {
    const context = anyStateContextForActiveState(comp, path, active_source) orelse return null;
    return context.source;
}

fn pathContainsEligibleAnyState(comp: anytype, path: []const i32, source: i32) bool {
    if (path.len < 2) return false;
    for (path[1..], 1..) |_, index| {
        const parent_node = StateHierarchy.findNode(comp, path[index - 1]) orelse continue;
        const any_state = anyStateChild(comp, parent_node) orelse continue;
        if (StateHierarchy.statesEquivalent(comp, any_state, source)) return true;
    }
    return false;
}

fn anyStateChild(comp: anytype, parent_node: *const AiStateMachineConfig.StateMachineNode) ?i32 {
    const children = parent_node.Children orelse return null;
    var any_state: ?i32 = null;
    for (children) |child| {
        const child_node = StateHierarchy.findNode(comp, child) orelse continue;
        if (child_node.IsAnyState) any_state = StateHierarchy.canonicalState(comp, child);
    }
    return any_state;
}

fn targetIsChild(comp: anytype, children: []const i32, target: i32) bool {
    for (children) |child| {
        if (StateHierarchy.statesEquivalent(comp, child, target)) return true;
    }
    return false;
}

fn canClientAnyStateTransition(comp: anytype, fsm_id: i32, path: []const i32, from: i32, to: i32) bool {
    const context = anyStateContextForActiveState(comp, path, from) orelse return false;
    const children = context.parent_node.Children orelse return false;
    if (!targetIsChild(comp, children, to)) return false;
    return canClientTransition(comp, fsm_id, context.source, to);
}

fn canClientTransition(comp: anytype, fsm_id: i32, from: i32, to: i32) bool {
    const requested = StateHierarchy.resolveOverrideStates(comp, from, to, false);
    const root = StateHierarchy.findNode(comp, fsm_id) orelse return false;
    const client_owns_animation = root.IsAnimStateMachine orelse false;
    const flags = comp.graph.transitionFlags(requested.from, requested.to);
    if (flags & Assets.FsmGraphRegistry.transition_present == 0) return false;
    if (client_owns_animation or StateHierarchy.isConduitState(comp, requested.from)) return true;
    return flags & Assets.FsmGraphRegistry.transition_predicted != 0;
}

fn clientMayTakeTransition(
    comp: anytype,
    fsm_id: i32,
    from: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
) bool {
    const root = StateHierarchy.findNode(comp, fsm_id) orelse return false;
    if ((root.IsAnimStateMachine orelse false) or StateHierarchy.isConduitState(comp, from)) return true;
    const prediction_type = transition.TransitionPredictionType orelse return false;
    return prediction_type == 1 or prediction_type == 2;
}

fn allowsNestedTransition(comp: anytype, fsm_id: i32, from: i32) bool {
    const root = StateHierarchy.findNode(comp, fsm_id) orelse return false;
    return (root.IsAnimStateMachine orelse false) or StateHierarchy.isConduitState(comp, from);
}

fn serverEvaluatesRoot(comp: anytype, fsm_id: i32) bool {
    const root = StateHierarchy.findNode(comp, fsm_id) orelse return false;
    return !(root.IsAnimStateMachine orelse false);
}

fn clientConditionLookup(comp: anytype, fsm_id: i32, from: i32, to: i32, index: i32) Types.ClientConditionLookup {
    var found_transition = false;
    var found_condition = false;
    var invalid_condition = false;
    var requirement: Types.ClientConditionRequirement = .none;
    if (findClientConditionRecursive(
        comp,
        StateHierarchy.canonicalState(comp, fsm_id),
        StateHierarchy.canonicalState(comp, from),
        StateHierarchy.canonicalState(comp, to),
        index,
        &found_transition,
        &found_condition,
        &invalid_condition,
        &requirement,
        0,
    )) return .{ .valid = requirement };

    if (!found_transition) return .transition_not_found;
    if (!found_condition) return .condition_not_found;
    if (invalid_condition) return .condition_invalid;
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
    invalid_condition: *bool,
    requirement: *Types.ClientConditionRequirement,
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
        if (!(condition.IsClient orelse false)) continue;
        if (!Assets.FsmGraphRegistry.conditionPayloadMatches(condition)) {
            invalid_condition.* = true;
            continue;
        }
        requirement.* = clientConditionRequirement(condition);
        return true;
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
                invalid_condition,
                requirement,
                depth + 1,
            )) return true;
        }
    }

    return false;
}

fn clientConditionRequirement(
    condition: AiStateMachineConfig.StateMachineCondition,
) Types.ClientConditionRequirement {
    if (condition.CondTaskFinish != null) return .task;
    if (condition.CondMontageTimeRemaining != null or condition.CondMontageTimeElapsing != null) return .montage;
    if (condition.CondCheckGroupPatrol != null) return .group_patrol;
    if (condition.CondCheckGroupPerform != null) return .group_perform;
    return .none;
}

fn runActions(
    comp: anytype,
    gpa: mem.Allocator,
    actions: []const AiStateMachineConfig.StateMachineAction,
    state_entry: bool,
) !void {
    for (actions) |action| {
        if (action.ActionDispatchEvent) |event_action| {
            comp.event = event_action.Event;
        }

        if (state_entry and action.ActionEnterFight != null) try appendLifecycleEffect(comp, gpa, .enter_fight);
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

fn updateActivationBindStates(
    comp: anytype,
    gpa: mem.Allocator,
    binds: []const AiStateMachineConfig.StateMachineBindState,
    delta: i32,
) !void {
    for (binds) |bind| {
        if (bind.BindTag) |tag| {
            try updateTagCount(comp, gpa, tag.TagId, delta);
        }
    }
}

fn enterBindStates(
    comp: anytype,
    gpa: mem.Allocator,
    fsm_id: i32,
    state: i32,
    activation_ms: i64,
    binds: []const AiStateMachineConfig.StateMachineBindState,
) !void {
    var delayed_suicide: ?AiStateMachineConfig.BindDelaySuicide = null;
    for (binds, 0..) |bind, index| {
        if (bind.BindBuff) |buff| {
            try appendLifecycleEffect(comp, gpa, .{ .bind_buff_add = .{
                .source = try bindBuffSource(comp, fsm_id, state, index),
                .buff_id = buff.BuffId,
            } });
        }
        if (bind.BindDelaySuicide) |delayed| delayed_suicide = delayed;
    }

    if (delayed_suicide) |delayed| {
        scheduleDelayedSuicide(comp, fsm_id, state, activation_ms, delayed);
    }
}

fn exitBindStates(
    comp: anytype,
    gpa: mem.Allocator,
    fsm_id: i32,
    state: i32,
    binds: []const AiStateMachineConfig.StateMachineBindState,
) !void {
    for (binds, 0..) |bind, index| {
        if (bind.BindBuff == null) continue;
        try appendLifecycleEffect(comp, gpa, .{
            .bind_buff_remove = try bindBuffSource(comp, fsm_id, state, index),
        });
    }
}

fn bindBuffSource(
    comp: anytype,
    fsm_id: i32,
    state: i32,
    index: usize,
) !Types.FsmBindBuffSource {
    return .{
        .fsm_id = StateHierarchy.canonicalState(comp, fsm_id),
        .state = StateHierarchy.canonicalState(comp, state),
        .bind_index = std.math.cast(i32, index) orelse return error.FsmBindIndexOverflow,
    };
}

fn scheduleDelayedSuicide(
    comp: anytype,
    fsm_id: i32,
    state: i32,
    activation_ms: i64,
    delayed: AiStateMachineConfig.BindDelaySuicide,
) void {
    if (!std.math.isFinite(delayed.SuicideDelay) or
        !std.math.isFinite(delayed.DestroyDelay) or
        delayed.SuicideDelay < 0 or
        delayed.DestroyDelay < delayed.SuicideDelay) return;

    const suicide_due_ms = delayedDeadline(activation_ms, delayed.SuicideDelay) orelse return;
    const destroy_due_ms = delayedDeadline(activation_ms, delayed.DestroyDelay) orelse return;
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return;
    if (runtime.delayed_suicide_fired and runtime.delayed_destroy_due_ms != null) return;

    runtime.delayed_suicide_state = StateHierarchy.canonicalState(comp, state);
    runtime.delayed_suicide_due_ms = suicide_due_ms;
    runtime.delayed_destroy_due_ms = destroy_due_ms;
    runtime.delayed_suicide_fired = false;
}

fn delayedDeadline(activation_ms: i64, delay_ms: f32) ?i64 {
    const wide_delay: f64 = delay_ms;
    const max_i64: f64 = @floatFromInt(std.math.maxInt(i64));
    if (wide_delay >= max_i64) return null;
    const rounded_delay: i64 = @intFromFloat(@ceil(wide_delay));
    return std.math.add(i64, activation_ms, rounded_delay) catch null;
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

fn applyPathLifecycle(
    comp: anytype,
    gpa: mem.Allocator,
    fsm_id: i32,
    active_path: []const i32,
    target_path: []const i32,
    target_since_ms: []const i64,
) !void {
    const common_len = StateHierarchy.commonPathPrefixLen(active_path, target_path);

    comp.event = null;
    try removePassesForExitedPath(comp, gpa, fsm_id, active_path, target_path);

    var exit_index = active_path.len;
    while (exit_index > common_len) {
        exit_index -= 1;
        try exitNode(comp, gpa, fsm_id, active_path[exit_index]);
    }

    for (target_path[common_len..], common_len..) |state, index| {
        try enterNode(comp, gpa, fsm_id, state, target_since_ms[index]);
    }
}

fn enterNode(comp: anytype, gpa: mem.Allocator, fsm_id: i32, state: i32, activation_ms: i64) !void {
    const node = StateHierarchy.findNode(comp, state) orelse return;
    try updateActivationBindStates(comp, gpa, node.BindStates, 1);
    try runActions(comp, gpa, node.OnEnterActions, true);
    try enterBindStates(comp, gpa, fsm_id, state, activation_ms, node.BindStates);
}

fn exitNode(comp: anytype, gpa: mem.Allocator, fsm_id: i32, state: i32) !void {
    const node = StateHierarchy.findNode(comp, state) orelse return;
    try updateActivationBindStates(comp, gpa, node.BindStates, -1);
    try runActions(comp, gpa, node.OnExitActions, false);
    try exitBindStates(comp, gpa, fsm_id, state, node.BindStates);
    exitDelayedSuicideBind(comp, fsm_id, state);
}

fn exitDelayedSuicideBind(comp: anytype, fsm_id: i32, state: i32) void {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return;
    const bound_state = runtime.delayed_suicide_state orelse return;
    if (!StateHierarchy.statesEquivalent(comp, bound_state, state)) return;

    runtime.delayed_suicide_due_ms = null;
    if (runtime.delayed_suicide_fired) return;
    runtime.delayed_suicide_state = null;
    runtime.delayed_destroy_due_ms = null;
}

fn setPendingTransition(comp: anytype, runtime: *Types.FsmNode, from: i32, to: i32, now_ms: i64) !void {
    const pending_len = StateHierarchy.buildActivePath(comp, runtime.fsm_id, to, &runtime.pending_path) orelse
        return error.InvalidFsmTransitionTarget;
    const preserves_skill = runtime.active_len != 0 and pending_len != 0 and
        runtime.active_path[runtime.active_len - 1] == runtime.pending_path[pending_len - 1];

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
    runtime.pending_skill_id = if (preserves_skill) runtime.active_skill_id else null;
    runtime.pending_skill_ended = preserves_skill and runtime.active_skill_ended;
    runtime.next_timer_due_ms = null;
    Blackboard.preparePath(comp, runtime.pending(), runtime.pending_since_ms[0..runtime.pending_len], true);
}

fn commitPending(comp: anytype, runtime: *Types.FsmNode, gpa: mem.Allocator) !void {
    if (runtime.pending_from == null) return;
    const pending_path = runtime.pending();
    if (pending_path.len == 0) return;

    try applyPathLifecycle(
        comp,
        gpa,
        runtime.fsm_id,
        runtime.active(),
        pending_path,
        runtime.pending_since_ms[0..runtime.pending_len],
    );
    @memcpy(runtime.active_path[0..pending_path.len], pending_path);
    @memcpy(runtime.active_since_ms[0..pending_path.len], runtime.pending_since_ms[0..pending_path.len]);
    runtime.active_len = runtime.pending_len;
    runtime.active_skill_id = runtime.pending_skill_id;
    runtime.active_skill_ended = runtime.pending_skill_ended;
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
    runtime.pending_skill_id = null;
    runtime.pending_skill_ended = false;
}

fn changeCurrentState(comp: anytype, fsm_id: i32, to: i32, gpa: mem.Allocator, now_ms: i64) !void {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id) orelse return;
    var target_path: [Types.max_state_depth]i32 = @splat(0);
    var target_since_ms: [Types.max_state_depth]i64 = @splat(0);
    const active_len = StateHierarchy.buildActivePath(comp, runtime.fsm_id, to, &target_path) orelse return;
    const preserves_skill = runtime.active_len != 0 and active_len != 0 and
        runtime.active_path[runtime.active_len - 1] == target_path[active_len - 1];
    for (target_path[0..active_len], 0..) |state, index| {
        target_since_ms[index] = if (index < runtime.active_len and runtime.active_path[index] == state)
            runtime.active_since_ms[index]
        else
            now_ms;
    }

    Blackboard.preparePath(comp, target_path[0..active_len], target_since_ms[0..active_len], true);
    try applyPathLifecycle(
        comp,
        gpa,
        runtime.fsm_id,
        runtime.active(),
        target_path[0..active_len],
        target_since_ms[0..active_len],
    );
    @memcpy(runtime.active_path[0..active_len], target_path[0..active_len]);
    @memcpy(runtime.active_since_ms[0..active_len], target_since_ms[0..active_len]);
    runtime.active_len = @intCast(active_len);
    if (!preserves_skill) {
        runtime.active_skill_id = null;
        runtime.active_skill_ended = false;
    }
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
    runtime.pending_skill_id = null;
    runtime.pending_skill_ended = false;
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
