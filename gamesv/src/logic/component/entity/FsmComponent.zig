const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const Assets = @import("../../../data/Assets.zig");
const AttributeComponent = @import("AttributeComponent.zig");
const LogicStateComponent = @import("LogicStateComponent.zig");
const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

const log = std.log.scoped(.fsm_component);

const NodeEntry = struct {
    key: i32,
    value: AiStateMachineConfig.StateMachineNode,
};

const OverrideEntry = struct {
    key: i32,
    value: i32,
};

pub const FsmNode = struct {
    fsm_id: i32,
    cur_node: i32,
    cur_state: i32,
    parent_state: i32 = 0,
    pending_state: ?i32 = null,
};

pub const ConditionKey = struct {
    fsm_id: i32,
    from: i32,
    to: i32,
    index: i32,
};

pub const LastHit = struct {
    has_be_hit_data: bool,
    fight_state: i32,
    is_trigger_vision_counter_attack: bool,
    skill_id: i64,
};

pub const EvalContext = struct {
    attribute: ?*const AttributeComponent = null,
    logic_state: ?*const LogicStateComponent = null,
    now_ms: i64,
};

pub const Transition = struct {
    fsm_id: i32,
    from: i32,
    to: i32,
};

pub const ConfirmResult = union(enum) {
    machine_not_found,
    invalid_source,
    invalid_target,
    no_pending,
    confirmed,
    accepted,
    mismatch: i32,
};

hash_code: i32 = 0,
common_hash_code: i32 = 0,
state_list: []const i32 = &.{},
node_list: []const NodeEntry = &.{},
override_mapping: []const OverrideEntry = &.{},
runtime_nodes: []FsmNode = &.{},
pass_pool: []ConditionKey = &.{},
tags: []const i64 = &.{},
in_hate: bool = false,
is_paralyze: bool = false,
last_state: i32 = 0,
last_hit_info: ?LastHit = null,
event: ?[]const u8 = null,
start_time_ms: i64 = 0,

pub fn deinit(comp: *Component, gpa: mem.Allocator) void {
    gpa.free(comp.state_list);
    gpa.free(comp.node_list);
    gpa.free(comp.override_mapping);
    gpa.free(comp.runtime_nodes);
    gpa.free(comp.pass_pool);
    gpa.free(comp.tags);
}

pub fn toProto(comp: Component, arena: mem.Allocator, assets: *const Assets) !pb.EntityFsmComponentPb {
    return .{
        .Fsms = try comp.getInitialFsm(arena, assets),
        .HashCode = comp.hash_code,
        .CommonHashCode = comp.common_hash_code,
        .BlackBoard = .empty,
        .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
    };
}

pub fn fromAiBaseId(ai_id: ?i32, assets: *const Assets, gpa: mem.Allocator) !Component {
    const common_fsm = getCommonFsm(assets) orelse {
        log.warn("Common state machine missing", .{});
        return .{};
    };

    const ai_base = assets.tables.ai_base.getDataById(ai_id orelse return .{}) orelse {
        log.warn("Ai base with id {?} not found", .{ai_id});
        return .{};
    };

    const entry = assets.tables.ai_state_machine_config.getDataById(ai_base.StateMachine) orelse {
        log.warn("Requested state machine with id {s} not found in config", .{ai_base.StateMachine});
        return .{};
    };

    return fromConfig(entry.StateMachineJson, common_fsm.StateMachineJson, gpa);
}

pub fn fromStateMachineId(id: []const u8, assets: *const Assets, gpa: mem.Allocator) !Component {
    const common_fsm = getCommonFsm(assets) orelse {
        log.warn("Common state machine missing", .{});
        return .{};
    };

    const entry = assets.tables.ai_state_machine_config.getDataById(id) orelse {
        log.warn("Requested state machine with id {s} not found in config", .{id});
        return .{};
    };

    return fromConfig(entry.StateMachineJson, common_fsm.StateMachineJson, gpa);
}

pub fn initRuntime(comp: *Component, gpa: mem.Allocator, now_ms: i64) !void {
    if (comp.runtime_nodes.len != 0) return;

    var runtime_nodes: std.ArrayList(FsmNode) = .empty;
    defer runtime_nodes.deinit(gpa);

    for (comp.state_list) |fsm_id| {
        const node = comp.findNodeExact(fsm_id) orelse continue;
        const initial = comp.getDeepestChild(node);
        try runtime_nodes.append(gpa, .{
            .fsm_id = fsm_id,
            .cur_node = comp.parentNodeId(initial) orelse 0,
            .cur_state = initial,
            .parent_state = 0,
        });
    }

    comp.runtime_nodes = try runtime_nodes.toOwnedSlice(gpa);
    comp.start_time_ms = now_ms;
}

pub fn recordHit(comp: *Component, hit_info: pb.HitInformation) void {
    comp.last_hit_info = .{
        .has_be_hit_data = hit_info.HasBeHitData,
        .fight_state = hit_info.FightState,
        .is_trigger_vision_counter_attack = hit_info.IsTriggerVisionCounterAttack,
        .skill_id = hit_info.SkillId,
    };
}

pub fn setHateFromList(comp: *Component, hate_list: []const pb.AiHateEntity) bool {
    const old_in_hate = comp.in_hate;
    comp.in_hate = false;
    for (hate_list) |entry| {
        if (entry.HatredValue >= 1) {
            comp.in_hate = true;
            break;
        }
    }

    return old_in_hate != comp.in_hate;
}

pub fn insertPass(comp: *Component, gpa: mem.Allocator, key: ConditionKey, value: bool) !void {
    if (!value) return;

    try comp.appendPass(gpa, key);

    const resolved = comp.resolveOverrideStates(key.from, key.to, false);
    if (resolved.from != key.from or resolved.to != key.to) {
        try comp.appendPass(gpa, .{
            .fsm_id = key.fsm_id,
            .from = resolved.from,
            .to = resolved.to,
            .index = key.index,
        });
    }
}

pub fn confirmPending(comp: *Component, fsm_id: i32, state: i32, gpa: mem.Allocator, now_ms: i64) !ConfirmResult {
    const runtime = comp.runtimeNode(fsm_id) orelse return .machine_not_found;
    if (!comp.stateBelongsToFsm(fsm_id, state)) return .invalid_target;

    const current = runtime.cur_state;
    const resolved = comp.resolveOverrideStates(current, state, true);

    const pending_state = runtime.pending_state orelse return .no_pending;
    if (resolved.to == pending_state) {
        runtime.pending_state = null;
        try comp.changeCurrentState(fsm_id, current, pending_state, gpa, now_ms);
        return .confirmed;
    }

    return .{ .mismatch = pending_state };
}

pub fn confirmStateRequest(
    comp: *Component,
    fsm_id: i32,
    from: i32,
    to: i32,
    gpa: mem.Allocator,
    now_ms: i64,
) !ConfirmResult {
    const runtime = comp.runtimeNode(fsm_id) orelse return .machine_not_found;
    if (!comp.stateBelongsToFsm(fsm_id, from)) return .invalid_source;
    if (!comp.stateBelongsToFsm(fsm_id, to)) return .invalid_target;

    const pending_state = runtime.pending_state orelse {
        if (try comp.acceptPredictedTransition(fsm_id, from, to, gpa, now_ms)) return .accepted;
        return .no_pending;
    };

    const current = runtime.cur_state;
    const resolved = comp.resolveOverrideStates(current, to, true);
    if (resolved.to == pending_state) {
        if (!comp.statesEquivalent(current, from)) return .{ .mismatch = pending_state };

        runtime.pending_state = null;
        try comp.changeCurrentState(fsm_id, current, pending_state, gpa, now_ms);
        return .confirmed;
    }

    if (comp.canFoldPredictedTransition(pending_state, from, to)) {
        runtime.pending_state = null;
        try comp.changeCurrentState(fsm_id, current, pending_state, gpa, now_ms);
        try comp.runTransitionEvents(gpa, from, to);
        try comp.changeCurrentState(fsm_id, from, to, gpa, now_ms);
        return .confirmed;
    }

    return .{ .mismatch = pending_state };
}

pub fn currentState(comp: *const Component, fsm_id: i32) ?i32 {
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id == fsm_id) return runtime.cur_state;
    }

    return null;
}

pub fn checkState(
    comp: *Component,
    entity_id: i64,
    gpa: mem.Allocator,
    ctx: EvalContext,
) !?pb.CombatReceiveData {
    for (comp.runtime_nodes) |runtime| {
        if (try comp.findReadyTransition(runtime.fsm_id, gpa, ctx)) |transition| {
            return transitionNotify(entity_id, transition);
        }
    }

    return null;
}

pub fn checkTransitions(
    comp: *Component,
    entity_id: i64,
    fsm_id: i32,
    gpa: mem.Allocator,
    ctx: EvalContext,
) !?pb.CombatReceiveData {
    if (try comp.findReadyTransition(fsm_id, gpa, ctx)) |transition| {
        return transitionNotify(entity_id, transition);
    }

    return null;
}

pub fn checkAndConfirm(
    comp: *Component,
    entity_id: i64,
    fsm_id: i32,
    gpa: mem.Allocator,
    ctx: EvalContext,
) !?pb.CombatReceiveData {
    const transition = (try comp.findReadyTransition(fsm_id, gpa, ctx)) orelse return null;
    _ = try comp.confirmPending(fsm_id, transition.to, gpa, ctx.now_ms);
    return transitionNotify(entity_id, transition);
}

pub fn transitionNotify(entity_id: i64, transition: Transition) pb.CombatReceiveData {
    return .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .ChangeStateNotify = .{
                .FsmId = transition.fsm_id,
                .FromState = transition.from,
                .ToState = transition.to,
            } },
        },
    } };
}

pub fn getInitialFsm(
    comp: *const Component,
    arena: mem.Allocator,
    assets: *const Assets,
) !std.ArrayList(pb.DFsm) {
    _ = assets;

    var result: std.ArrayList(pb.DFsm) = try .initCapacity(arena, 1);

    if (comp.runtime_nodes.len != 0) {
        for (comp.runtime_nodes) |runtime| {
            const node = comp.findNodeExact(runtime.fsm_id);
            try result.append(arena, .{
                .FsmId = runtime.fsm_id,
                .CurrentState = runtime.cur_state,
                .Flag = if (node) |entry| if (entry.IsAnimStateMachine orelse false) 1 else 0 else 0,
                .StateElapseTime = 0,
            });
        }
        return result;
    }

    for (comp.state_list) |id| {
        const node = comp.findNodeExact(id) orelse continue;
        try result.append(arena, .{
            .FsmId = id,
            .CurrentState = comp.getDeepestChild(node),
            .Flag = if (node.IsAnimStateMachine orelse false) 1 else 0,
            .StateElapseTime = 0,
        });
    }

    return result;
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return assets.tables.ai_state_machine_config.getDataById("SM_Common");
}

fn fromConfig(
    state_machine_config: AiStateMachineConfig.StateMachineJsonData,
    common_state_machine: AiStateMachineConfig.StateMachineJsonData,
    gpa: mem.Allocator,
) !Component {
    var state_list: std.ArrayList(i32) = try .initCapacity(gpa, 1);
    defer state_list.deinit(gpa);
    try state_list.appendSlice(gpa, state_machine_config.StateMachines);

    var fsm_tree: std.ArrayList(NodeEntry) = try .initCapacity(gpa, 1);
    defer fsm_tree.deinit(gpa);

    var override_mapping: std.ArrayList(OverrideEntry) = try .initCapacity(gpa, 1);
    defer override_mapping.deinit(gpa);

    for (state_machine_config.Nodes) |node| {
        switch (node.kind()) {
            .reference => {
                const ref_uuid = node.ReferenceUuid.?;
                const reference = for (common_state_machine.Nodes) |common_node| {
                    if (common_node.kind() == .custom and common_node.Uuid == ref_uuid)
                        break common_node;
                } else null;

                if (reference) |ref_node| {
                    const in_state_list = for (state_list.items) |sid| {
                        if (sid == node.Uuid) break true;
                    } else false;

                    if (in_state_list) try state_list.append(gpa, ref_uuid);
                    try insertWithDescendants(ref_node.Uuid, ref_node, common_state_machine, &fsm_tree, gpa);
                }
            },
            .override => {
                try override_mapping.append(gpa, .{
                    .key = node.Uuid,
                    .value = node.OverrideCommonUuid.?,
                });
                try fsm_tree.append(gpa, .{ .key = node.Uuid, .value = node });
            },
            .custom => try fsm_tree.append(gpa, .{ .key = node.Uuid, .value = node }),
        }
    }

    return .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
        .state_list = try state_list.toOwnedSlice(gpa),
        .node_list = try fsm_tree.toOwnedSlice(gpa),
        .override_mapping = try override_mapping.toOwnedSlice(gpa),
    };
}

fn findReadyTransition(comp: *Component, fsm_id: i32, gpa: mem.Allocator, ctx: EvalContext) !?Transition {
    const runtime = comp.runtimeNode(fsm_id) orelse return null;
    if (runtime.pending_state != null) return null;

    const cur_state = runtime.cur_state;
    const parent_state = runtime.parent_state;

    if (comp.findNodeRecursive(fsm_id, cur_state)) |node| {
        if (node.Children) |children| {
            if (children.len != 0) {
                const last_child = children[children.len - 1];
                if (last_child == cur_state) {
                    if (comp.findNodeRecursive(fsm_id, parent_state)) |parent_node| {
                        if (try comp.checkTransitionsForState(fsm_id, parent_node, parent_state, gpa, ctx)) |transition| {
                            return transition;
                        }
                    }
                } else if (try comp.checkTransitionsForState(fsm_id, node, cur_state, gpa, ctx)) |transition| {
                    return transition;
                }
            }
        }
    }

    if (comp.findNodeRecursive(fsm_id, parent_state)) |node| {
        if (try comp.checkTransitionsForState(fsm_id, node, parent_state, gpa, ctx)) |transition| {
            return transition;
        }
    }

    return null;
}

fn checkTransitionsForState(
    comp: *Component,
    fsm_id: i32,
    node: AiStateMachineConfig.StateMachineNode,
    state_to_check: i32,
    gpa: mem.Allocator,
    ctx: EvalContext,
) !?Transition {
    const runtime = comp.runtimeNode(fsm_id) orelse return null;
    if (runtime.pending_state != null) return null;

    const children = node.Children orelse return null;

    for (children) |target_state| {
        if (state_to_check == target_state) continue;

        for (node.Transitions) |transition| {
            const resolved_transition = comp.resolveOverrideStates(transition.From, transition.To, false);
            if (resolved_transition.from != state_to_check or resolved_transition.to != target_state) continue;

            const top_condition = findCondition(transition.Conditions, 0) orelse continue;
            if (!comp.evalCondition(fsm_id, transition, transition.Conditions, top_condition, ctx, 0)) continue;

            const result = comp.resolveOverrideStates(state_to_check, target_state, true);
            comp.pendingState(fsm_id, result.to);
            try comp.runTransitionEvents(gpa, result.from, result.to);
            return .{ .fsm_id = fsm_id, .from = result.from, .to = result.to };
        }
    }

    return null;
}

fn evalCondition(
    comp: *Component,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    ctx: EvalContext,
    depth: usize,
) bool {
    if (depth > 12) return false;

    var result = comp.evalConditionRaw(fsm_id, transition, conditions, condition, ctx, depth);
    if (condition.Reverse and !(condition.IsClient orelse false)) result = !result;
    return result;
}

fn evalConditionRaw(
    comp: *Component,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    ctx: EvalContext,
    depth: usize,
) bool {
    if (std.mem.eql(u8, condition.Name, "CondTrue")) return true;
    if (std.mem.eql(u8, condition.Name, "CondHate")) return comp.in_hate;

    if (condition.CondAnd) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (!comp.evalCondition(fsm_id, transition, conditions, child, ctx, depth + 1)) return false;
        }
        return true;
    }

    if (condition.CondOr) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (comp.evalCondition(fsm_id, transition, conditions, child, ctx, depth + 1)) return true;
        }
        return false;
    }

    if (condition.CondTimer) |timer| {
        return ctx.now_ms - comp.start_time_ms >= timer.MinTime;
    }

    if (condition.CondCheckState) |state| {
        return comp.currentStateMatches(state.TargetState);
    }

    if (condition.CondCheckStateByName) |state| {
        return comp.currentStateNameMatches(fsm_id, state.TargetStateName);
    }

    if (condition.CondCheckLastState) |state| {
        return comp.lastStateNameMatches(state.TargetStateName);
    }

    if (condition.CondListenBeHit) |hit| {
        return comp.listenBeHitPasses(hit);
    }

    if (condition.CondListenEvent) |listen| {
        return comp.listenEventPasses(listen, std.mem.eql(u8, condition.Name, "CondListenEvent"));
    }

    if (condition.CondCheckPositionState) |position| {
        const logic_state = ctx.logic_state orelse return false;
        return logic_state.position_state == position.PositionState;
    }

    if (condition.CondAttribute) |attribute| {
        return attrInRange(ctx.attribute, attribute.AttributeId, attribute.Min, attribute.Max);
    }

    if (condition.CondAttributeRate) |attribute| {
        return attrRateInRange(ctx.attribute, attribute.AttributeId, attribute.Denominator, attribute.Min, attribute.Max);
    }

    if (condition.CondTag) |tag| {
        if (condition.IsClient orelse false) {
            if (comp.clientPasses(fsm_id, transition, condition.Index)) return true;
        }
        return if (tag.TagId) |tag_id| std.mem.indexOfScalar(i64, comp.tags, @as(i64, tag_id)) != null else false;
    }

    if (condition.CondTaskFinish != null or condition.CondMontageTimeRemaining != null) {
        return (condition.IsClient orelse false) and comp.clientPasses(fsm_id, transition, condition.Index);
    }

    if (condition.CondInstStateChange) |inst| {
        return std.mem.indexOfScalar(i64, comp.tags, @as(i64, inst.TagId)) != null;
    }

    return false;
}

fn runTransitionEvents(comp: *Component, gpa: mem.Allocator, from: i32, to: i32) !void {
    if (comp.findNode(from)) |node| try comp.runActions(gpa, node.OnExitActions);

    if (comp.findNode(to)) |node| {
        try comp.runActions(gpa, node.OnEnterActions);
        try comp.runBindStates(gpa, node.BindStates);
    }
}

fn acceptPredictedTransition(
    comp: *Component,
    fsm_id: i32,
    from: i32,
    to: i32,
    gpa: mem.Allocator,
    now_ms: i64,
) !bool {
    const runtime = comp.runtimeNode(fsm_id) orelse return false;
    if (!comp.statesEquivalent(runtime.cur_state, from)) return false;
    if (!comp.hasPredictedTransition(from, to)) return false;

    try comp.runTransitionEvents(gpa, from, to);
    try comp.changeCurrentState(fsm_id, from, to, gpa, now_ms);
    return true;
}

fn canFoldPredictedTransition(comp: *const Component, pending_state: i32, from: i32, to: i32) bool {
    const pending_node = comp.findNode(pending_state) orelse return false;
    const entry_state = comp.getDeepestChild(pending_node);
    if (!comp.statesEquivalent(entry_state, from)) return false;
    if (!comp.stateContains(pending_state, to, 0)) return false;
    return comp.hasPredictedTransition(from, to);
}

fn hasPredictedTransition(comp: *const Component, from: i32, to: i32) bool {
    const requested = comp.resolveOverrideStates(from, to, false);

    for (comp.node_list) |entry| {
        for (entry.value.Transitions) |transition| {
            const candidate = comp.resolveOverrideStates(transition.From, transition.To, false);
            if (candidate.from != requested.from or candidate.to != requested.to) continue;
            if (transition.TransitionPredictionType == 1) return true;
        }
    }

    return false;
}

fn stateContains(comp: *const Component, ancestor: i32, target: i32, depth: usize) bool {
    if (depth > 32) return false;
    if (comp.statesEquivalent(ancestor, target)) return true;

    const node = comp.findNode(ancestor) orelse return false;
    const children = node.Children orelse return false;
    for (children) |child| {
        if (comp.statesEquivalent(child, target)) return true;
        if (comp.stateContains(child, target, depth + 1)) return true;
    }

    return false;
}

fn statesEquivalent(comp: *const Component, a: i32, b: i32) bool {
    if (a == b) return true;
    const resolved_a = comp.resolvedForAlias(a) orelse a;
    const resolved_b = comp.resolvedForAlias(b) orelse b;
    return resolved_a == resolved_b;
}

fn stateBelongsToFsm(comp: *const Component, fsm_id: i32, state: i32) bool {
    const resolved = comp.resolvedForAlias(state) orelse state;
    return comp.stateContains(fsm_id, resolved, 0);
}

fn runActions(
    comp: *Component,
    gpa: mem.Allocator,
    actions: []const AiStateMachineConfig.StateMachineAction,
) !void {
    for (actions) |action| {
        if (action.ActionDispatchEvent) |event_action| {
            comp.event = event_action.Event;
        }

        if (action.ActionCue) |cue| {
            if (std.mem.indexOfScalar(i64, cue.CueIds, 1020) != null) {
                comp.is_paralyze = true;
            }
        }

        if (action.ActionInstChangeStateTag) |tag| {
            try comp.addTag(gpa, tag.TagId);
        }

        if (action.ActionAddTagCount) |tag| {
            if (tag.Count > 0) try comp.addTag(gpa, tag.TagId);
        }
    }
}

fn runBindStates(
    comp: *Component,
    gpa: mem.Allocator,
    binds: []const AiStateMachineConfig.StateMachineBindState,
) !void {
    for (binds) |bind| {
        if (bind.BindTag) |tag| {
            try comp.addTag(gpa, tag.TagId);
        }
    }
}

fn addTag(comp: *Component, gpa: mem.Allocator, tag_id: i64) !void {
    if (std.mem.indexOfScalar(i64, comp.tags, tag_id) != null) return;

    const old_tags = comp.tags;
    const tags = try gpa.alloc(i64, old_tags.len + 1);
    @memcpy(tags[0..old_tags.len], old_tags);
    tags[old_tags.len] = tag_id;
    gpa.free(old_tags);
    comp.tags = tags;
}

fn pendingState(comp: *Component, fsm_id: i32, to: i32) void {
    const runtime = comp.runtimeNode(fsm_id) orelse return;
    var new_state = to;

    if (comp.aliasForResolved(to)) |alias| {
        new_state = alias;
    }

    runtime.pending_state = new_state;
}

fn changeCurrentState(comp: *Component, fsm_id: i32, from: i32, to: i32, gpa: mem.Allocator, now_ms: i64) !void {
    const runtime = comp.runtimeNode(fsm_id) orelse return;
    var new_state = to;
    const resolved = comp.resolveOverrideStates(from, new_state, false);

    if (comp.findNodeExact(runtime.cur_node)) |root_node| {
        if (root_node.Children) |children| {
            if (std.mem.indexOfScalar(i32, children, resolved.to) != null) {
                runtime.parent_state = resolved.to;
                try comp.removePassesFrom(gpa, runtime.parent_state);
            }
        }
    }

    if (comp.aliasForResolved(to)) |alias| {
        new_state = alias;
    }

    while (comp.findNodeExact(new_state)) |node| {
        const children = node.Children orelse break;
        if (children.len == 0) break;
        new_state = children[0];
    }

    runtime.cur_state = new_state;
    try comp.removePassesFrom(gpa, from);
    comp.start_time_ms = now_ms;
    comp.last_state = from;
}

fn currentStateMatches(comp: *const Component, state: i32) bool {
    for (comp.runtime_nodes) |runtime| {
        if (runtime.cur_state == state) return true;
    }

    return false;
}

fn currentStateNameMatches(comp: *const Component, fsm_id: i32, name: []const u8) bool {
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id != fsm_id) continue;
        const node = comp.findNode(runtime.cur_state) orelse return false;
        if (node.Name) |node_name| return std.mem.eql(u8, node_name, name);
    }

    return false;
}

fn lastStateNameMatches(comp: *const Component, name: []const u8) bool {
    const node = comp.findNode(comp.last_state) orelse return false;
    if (node.Name) |node_name| return std.mem.eql(u8, node_name, name);
    return false;
}

fn listenBeHitPasses(comp: *Component, condition: AiStateMachineConfig.ConditionListenBeHit) bool {
    const hit = comp.last_hit_info orelse return false;
    comp.last_hit_info = null;

    if (condition.NoHitAnimation != hit.has_be_hit_data) return false;

    const state = @divTrunc(hit.fight_state, 256);
    const sub = @rem(hit.fight_state, 256);

    if (state == 2 and sub == 0 and condition.SoftKnock) return true;
    if (state == 2 and sub == 1 and condition.KnockDown) return true;
    if (state == 2 and sub == 2 and condition.KnockUp) return true;
    if ((state == 3 or state == 8) and condition.HeavyKnock) return true;
    if (state == 4 and condition.Parry) {
        if (condition.VisionCounterAttackId == 0) return true;
        return hit.is_trigger_vision_counter_attack and hit.skill_id == condition.VisionCounterAttackId;
    }

    return false;
}

fn listenEventPasses(comp: *Component, condition: AiStateMachineConfig.ConditionListenEvent, _: bool) bool {
    const event = comp.event orelse return false;
    const passed = std.mem.eql(u8, event, condition.Event);
    if (passed) {
        comp.event = null;
    }
    return passed;
}

fn attrInRange(attribute: ?*const AttributeComponent, attribute_id: i32, min: i32, max: i32) bool {
    const attr = attrValue(attribute, attribute_id) orelse return false;
    return attr >= min and attr <= max;
}

fn attrRateInRange(attribute: ?*const AttributeComponent, attribute_id: i32, denominator_id: i32, min: i32, max: i32) bool {
    const numerator = attrValue(attribute, attribute_id) orelse return false;
    const denominator = attrValue(attribute, denominator_id) orelse return false;
    if (denominator == 0) return false;
    const rate = @divTrunc(numerator * 10000, denominator);
    return rate >= min and rate <= max;
}

fn attrValue(attribute: ?*const AttributeComponent, attribute_id: i32) ?i32 {
    if (attribute_id < 0) return null;
    const attr = attribute orelse return null;
    const index: usize = @intCast(attribute_id);
    if (index >= attr.attributes.len) return null;
    return attr.attributes[index].current;
}

fn clientPasses(comp: *const Component, fsm_id: i32, transition: AiStateMachineConfig.StateMachineTransition, index: i32) bool {
    const resolved = comp.resolveOverrideStates(transition.From, transition.To, false);
    return comp.passPoolContains(.{
        .fsm_id = fsm_id,
        .from = resolved.from,
        .to = resolved.to,
        .index = index,
    });
}

fn findCondition(
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    index: i32,
) ?AiStateMachineConfig.StateMachineCondition {
    for (conditions) |condition| {
        if (condition.Index == index) return condition;
    }

    return null;
}

fn runtimeNode(comp: *Component, fsm_id: i32) ?*FsmNode {
    for (comp.runtime_nodes) |*runtime| {
        if (runtime.fsm_id == fsm_id) return runtime;
    }

    return null;
}

fn findNode(comp: *const Component, id: i32) ?AiStateMachineConfig.StateMachineNode {
    if (comp.findNodeExact(id)) |node| return node;
    if (comp.resolvedForAlias(id)) |mapped| return comp.findNodeExact(mapped);
    return null;
}

fn findNodeExact(comp: *const Component, id: i32) ?AiStateMachineConfig.StateMachineNode {
    for (comp.node_list) |entry| {
        if (entry.key == id or entry.value.Uuid == id) return entry.value;
    }

    return null;
}

fn parentNodeId(comp: *const Component, state: i32) ?i32 {
    for (comp.node_list) |entry| {
        if (entry.value.Children) |children| {
            if (std.mem.indexOfScalar(i32, children, state) != null) return entry.key;
        }
    }

    return null;
}

fn findNodeRecursive(comp: *const Component, fsm_id: i32, target_state: i32) ?AiStateMachineConfig.StateMachineNode {
    const root = comp.findNodeExact(fsm_id) orelse return null;
    const children = root.Children orelse return null;

    if (std.mem.indexOfScalar(i32, children, target_state) != null) return root;

    for (comp.node_list) |entry| {
        if (entry.value.Children) |node_children| {
            if (std.mem.indexOfScalar(i32, node_children, target_state) != null) return entry.value;
        }
    }

    for (children) |child| {
        if (comp.findNodeRecursive(child, target_state)) |found| return found;
    }

    return null;
}

fn getDeepestChild(
    comp: *const Component,
    node: AiStateMachineConfig.StateMachineNode,
) i32 {
    if (node.Children) |children| {
        if (children.len > 0) {
            const first_child_id = children[0];
            if (comp.findNode(first_child_id)) |child| {
                return comp.getDeepestChild(child);
            }
        }
    }

    return node.Uuid;
}

const ResolvedStates = struct {
    from: i32,
    to: i32,
};

fn resolveOverrideStates(comp: *const Component, from: i32, to: i32, reverse: bool) ResolvedStates {
    if (reverse) {
        return .{
            .from = comp.aliasForResolved(from) orelse from,
            .to = comp.aliasForResolved(to) orelse to,
        };
    }

    return .{
        .from = comp.resolvedForAlias(from) orelse from,
        .to = comp.resolvedForAlias(to) orelse to,
    };
}

fn resolvedForAlias(comp: *const Component, key: i32) ?i32 {
    for (comp.override_mapping) |entry| {
        if (entry.key == key) return entry.value;
    }

    return null;
}

fn aliasForResolved(comp: *const Component, value: i32) ?i32 {
    for (comp.override_mapping) |entry| {
        if (entry.value == value) return entry.key;
    }

    return null;
}

fn appendPass(comp: *Component, gpa: mem.Allocator, key: ConditionKey) !void {
    if (comp.passPoolContains(key)) return;

    const old_pass_pool = comp.pass_pool;
    const pass_pool = try gpa.alloc(ConditionKey, old_pass_pool.len + 1);
    @memcpy(pass_pool[0..old_pass_pool.len], old_pass_pool);
    pass_pool[old_pass_pool.len] = key;
    gpa.free(old_pass_pool);
    comp.pass_pool = pass_pool;
}

fn removePassesFrom(comp: *Component, gpa: mem.Allocator, from: i32) !void {
    var pass_pool: std.ArrayList(ConditionKey) = .empty;
    defer pass_pool.deinit(gpa);

    for (comp.pass_pool) |entry| {
        if (entry.from == from) continue;
        try pass_pool.append(gpa, entry);
    }

    gpa.free(comp.pass_pool);
    comp.pass_pool = try pass_pool.toOwnedSlice(gpa);
}

fn passPoolContains(comp: *const Component, key: ConditionKey) bool {
    for (comp.pass_pool) |entry| {
        if (conditionKeyEql(entry, key)) return true;
    }

    return false;
}

fn conditionKeyEql(a: ConditionKey, b: ConditionKey) bool {
    return a.fsm_id == b.fsm_id and
        a.from == b.from and
        a.to == b.to and
        a.index == b.index;
}

fn insertWithDescendants(
    node_id: i32,
    node: AiStateMachineConfig.StateMachineNode,
    source: AiStateMachineConfig.StateMachineJsonData,
    target: *std.ArrayList(NodeEntry),
    gpa: mem.Allocator,
) !void {
    const already_exists = for (target.items) |entry| {
        if (entry.key == node_id) break true;
    } else false;

    if (already_exists) return;

    try target.append(gpa, .{ .key = node_id, .value = node });

    if (node.Children) |children| {
        for (children) |child_id| {
            const child_node = for (source.Nodes) |source_node| {
                if (source_node.Uuid == child_id) break source_node;
            } else null;

            if (child_node) |child| {
                try insertWithDescendants(child_id, child, source, target, gpa);
            } else {
                log.warn("Child node {} of parent {} not found in source_nodes", .{ child_id, node_id });
            }
        }
    }
}
