const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const Assets = @import("../../../data/Assets.zig");
const AttributeComponent = @import("AttributeComponent.zig");
const LogicStateComponent = @import("LogicStateComponent.zig");
const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

const log = std.log.scoped(.fsm_component);
const max_state_depth = 32;

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
    active_path: [max_state_depth]i32 = @splat(0),
    active_len: u8 = 0,
    pending_path: [max_state_depth]i32 = @splat(0),
    pending_len: u8 = 0,
    pending_from: ?i32 = null,
    pending_to: ?i32 = null,
    pending_since_ms: i64 = 0,

    fn active(node: *const FsmNode) []const i32 {
        return node.active_path[0..node.active_len];
    }

    fn pending(node: *const FsmNode) []const i32 {
        return node.pending_path[0..node.pending_len];
    }

    fn leaf(node: *const FsmNode) ?i32 {
        const path = node.active();
        return if (path.len == 0) null else path[path.len - 1];
    }
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

    for (comp.state_list) |raw_fsm_id| {
        const fsm_id = comp.canonicalState(raw_fsm_id);
        const already_added = for (runtime_nodes.items) |runtime| {
            if (runtime.fsm_id == fsm_id) break true;
        } else false;
        if (already_added) continue;

        var runtime: FsmNode = .{ .fsm_id = fsm_id };
        const active_len = comp.buildInitialPath(fsm_id, &runtime.active_path) orelse continue;
        runtime.active_len = @intCast(active_len);
        try runtime_nodes.append(gpa, runtime);
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
    const resolved = comp.resolveOverrideStates(key.from, key.to, false);
    const resolved_key: ConditionKey = .{
        .fsm_id = key.fsm_id,
        .from = resolved.from,
        .to = resolved.to,
        .index = key.index,
    };

    if (!value) {
        try comp.removePass(gpa, resolved_key);
        return;
    }

    try comp.appendPass(gpa, resolved_key);
}

pub fn confirmPending(comp: *Component, fsm_id: i32, state: i32, gpa: mem.Allocator, now_ms: i64) !ConfirmResult {
    const runtime = comp.runtimeNode(fsm_id) orelse return .machine_not_found;
    if (!comp.stateBelongsToFsm(fsm_id, state)) return .invalid_target;

    const pending_state = runtime.pending_to orelse return .no_pending;
    if (comp.statesEquivalent(state, pending_state)) {
        try comp.commitPending(runtime, gpa, now_ms);
        return .confirmed;
    }

    return .{ .mismatch = comp.clientState(pending_state) };
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

    const pending_state = runtime.pending_to orelse {
        if (try comp.acceptPredictedTransition(fsm_id, from, to, gpa, now_ms)) return .accepted;
        return .no_pending;
    };

    if (comp.statesEquivalent(to, pending_state)) {
        const pending_from = runtime.pending_from orelse return .{ .mismatch = comp.clientState(pending_state) };
        if (!comp.statesEquivalent(pending_from, from)) return .{ .mismatch = comp.clientState(pending_state) };

        try comp.commitPending(runtime, gpa, now_ms);
        return .confirmed;
    }

    if (comp.canFoldPredictedTransition(runtime, from, to)) {
        try comp.commitPending(runtime, gpa, now_ms);
        try comp.runTransitionEvents(gpa, from, to);
        try comp.changeCurrentState(fsm_id, from, to, gpa, now_ms);
        return .confirmed;
    }

    return .{ .mismatch = comp.clientState(pending_state) };
}

pub fn currentState(comp: *const Component, fsm_id: i32) ?i32 {
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id == comp.canonicalState(fsm_id)) {
            return if (runtime.leaf()) |leaf| comp.clientState(leaf) else null;
        }
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
            const node = comp.findNode(runtime.fsm_id);
            const current_state = runtime.leaf() orelse continue;
            try result.append(arena, .{
                .FsmId = comp.clientState(runtime.fsm_id),
                .CurrentState = comp.clientState(current_state),
                .Flag = if (node) |entry| if (entry.IsAnimStateMachine orelse false) 1 else 0 else 0,
                .StateElapseTime = 0,
            });
        }
        return result;
    }

    var seen_roots: [max_state_depth]i32 = @splat(0);
    var seen_len: usize = 0;
    for (comp.state_list) |raw_id| {
        const id = comp.canonicalState(raw_id);
        if (std.mem.indexOfScalar(i32, seen_roots[0..seen_len], id) != null) continue;
        if (seen_len >= seen_roots.len) return error.FsmRootLimitExceeded;
        seen_roots[seen_len] = id;
        seen_len += 1;

        const node = comp.findNode(id) orelse continue;
        var active_path: [max_state_depth]i32 = @splat(0);
        const active_len = comp.buildInitialPath(id, &active_path) orelse continue;
        try result.append(arena, .{
            .FsmId = comp.clientState(id),
            .CurrentState = comp.clientState(active_path[active_len - 1]),
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
    if (runtime.pending_to != null) return null;

    const active_path = runtime.active();
    if (active_path.len < 2) return null;

    for (active_path[1..], 1..) |active_state, index| {
        const parent_node = comp.findNode(active_path[index - 1]) orelse continue;
        if (try comp.checkTransitionsForState(runtime.fsm_id, parent_node, active_state, gpa, ctx)) |transition| {
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
    if (runtime.pending_to != null) return null;

    const children = node.Children orelse return null;
    const canonical_source = comp.canonicalState(state_to_check);

    for (children) |raw_target_state| {
        const target_state = comp.canonicalState(raw_target_state);
        if (canonical_source == target_state) continue;

        for (node.Transitions) |transition| {
            const resolved_transition = comp.resolveOverrideStates(transition.From, transition.To, false);
            if (resolved_transition.from != canonical_source or resolved_transition.to != target_state) continue;

            const top_condition = findCondition(transition.Conditions, 0) orelse continue;
            if (!comp.evalCondition(fsm_id, transition, transition.Conditions, top_condition, ctx, 0)) continue;

            try comp.setPendingTransition(runtime, canonical_source, target_state, ctx.now_ms);
            try comp.runTransitionEvents(gpa, canonical_source, target_state);
            return .{
                .fsm_id = comp.clientState(runtime.fsm_id),
                .from = comp.clientState(canonical_source),
                .to = comp.clientState(target_state),
            };
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
    if (!comp.pathContains(runtime.active(), from)) return false;
    if (!comp.hasPredictedTransition(from, to)) return false;

    try comp.runTransitionEvents(gpa, from, to);
    try comp.changeCurrentState(fsm_id, from, to, gpa, now_ms);
    return true;
}

fn canFoldPredictedTransition(comp: *const Component, runtime: *const FsmNode, from: i32, to: i32) bool {
    if (!comp.pathContains(runtime.pending(), from)) return false;
    if (!comp.stateBelongsToFsm(runtime.fsm_id, to)) return false;
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
    return comp.canonicalState(a) == comp.canonicalState(b);
}

fn stateBelongsToFsm(comp: *const Component, fsm_id: i32, state: i32) bool {
    return comp.stateContains(comp.canonicalState(fsm_id), comp.canonicalState(state), 0);
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

fn setPendingTransition(comp: *const Component, runtime: *FsmNode, from: i32, to: i32, now_ms: i64) !void {
    const pending_len = comp.buildActivePath(runtime.fsm_id, to, &runtime.pending_path) orelse
        return error.InvalidFsmTransitionTarget;

    runtime.pending_len = @intCast(pending_len);
    runtime.pending_from = comp.canonicalState(from);
    runtime.pending_to = comp.canonicalState(to);
    runtime.pending_since_ms = now_ms;
}

fn commitPending(comp: *Component, runtime: *FsmNode, gpa: mem.Allocator, now_ms: i64) !void {
    const from = runtime.pending_from orelse return;
    const pending_path = runtime.pending();
    if (pending_path.len == 0) return;

    @memcpy(runtime.active_path[0..pending_path.len], pending_path);
    runtime.active_len = runtime.pending_len;
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_since_ms = 0;

    try comp.removePassesFrom(gpa, runtime.fsm_id, from);
    comp.start_time_ms = now_ms;
    comp.last_state = from;
}

fn changeCurrentState(comp: *Component, fsm_id: i32, from: i32, to: i32, gpa: mem.Allocator, now_ms: i64) !void {
    const runtime = comp.runtimeNode(fsm_id) orelse return;
    const active_len = comp.buildActivePath(runtime.fsm_id, to, &runtime.active_path) orelse return;

    runtime.active_len = @intCast(active_len);
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_since_ms = 0;
    try comp.removePassesFrom(gpa, runtime.fsm_id, from);
    comp.start_time_ms = now_ms;
    comp.last_state = comp.canonicalState(from);
}

fn currentStateMatches(comp: *const Component, state: i32) bool {
    for (comp.runtime_nodes) |runtime| {
        if (comp.pathContains(runtime.active(), state)) return true;
    }

    return false;
}

fn currentStateNameMatches(comp: *const Component, _: i32, name: []const u8) bool {
    for (comp.runtime_nodes) |runtime| {
        for (runtime.active()) |state| {
            const node = comp.findNode(state) orelse continue;
            if (node.Name) |node_name| {
                if (std.mem.eql(u8, node_name, name)) return true;
            }
        }
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
    const canonical_fsm_id = comp.canonicalState(fsm_id);
    for (comp.runtime_nodes) |*runtime| {
        if (runtime.fsm_id == canonical_fsm_id) return runtime;
    }

    return null;
}

fn findNode(comp: *const Component, id: i32) ?AiStateMachineConfig.StateMachineNode {
    const canonical_id = comp.canonicalState(id);
    if (comp.aliasForResolved(canonical_id)) |alias| {
        if (comp.findNodeExact(alias)) |node| return node;
    }
    return comp.findNodeExact(canonical_id);
}

fn findNodeExact(comp: *const Component, id: i32) ?AiStateMachineConfig.StateMachineNode {
    for (comp.node_list) |entry| {
        if (entry.key == id or entry.value.Uuid == id) return entry.value;
    }

    return null;
}

fn canonicalState(comp: *const Component, state: i32) i32 {
    return comp.resolvedForAlias(state) orelse state;
}

fn clientState(comp: *const Component, state: i32) i32 {
    const canonical_state = comp.canonicalState(state);
    return comp.aliasForResolved(canonical_state) orelse canonical_state;
}

fn pathContains(comp: *const Component, path: []const i32, state: i32) bool {
    const canonical_state = comp.canonicalState(state);
    for (path) |active_state| {
        if (active_state == canonical_state) return true;
    }
    return false;
}

fn buildInitialPath(comp: *const Component, fsm_id: i32, path: *[max_state_depth]i32) ?usize {
    var len: usize = 0;
    var current = comp.canonicalState(fsm_id);

    while (true) {
        if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], current) != null) return null;
        path[len] = current;
        len += 1;

        const node = comp.findNode(current) orelse return null;
        const children = node.Children orelse break;
        if (children.len == 0) break;
        current = comp.canonicalState(children[0]);
    }

    return len;
}

fn buildActivePath(comp: *const Component, fsm_id: i32, target_state: i32, path: *[max_state_depth]i32) ?usize {
    var len: usize = 0;
    if (!comp.findPathToState(comp.canonicalState(fsm_id), comp.canonicalState(target_state), path, &len, 0)) return null;

    var current = path[len - 1];
    while (true) {
        const node = comp.findNode(current) orelse return null;
        const children = node.Children orelse break;
        if (children.len == 0) break;

        current = comp.canonicalState(children[0]);
        if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], current) != null) return null;
        path[len] = current;
        len += 1;
    }

    return len;
}

fn findPathToState(
    comp: *const Component,
    current_state: i32,
    target_state: i32,
    path: *[max_state_depth]i32,
    len: *usize,
    depth: usize,
) bool {
    if (depth >= max_state_depth or len.* >= path.len) return false;

    const canonical_current = comp.canonicalState(current_state);
    if (std.mem.indexOfScalar(i32, path[0..len.*], canonical_current) != null) return false;
    path[len.*] = canonical_current;
    len.* += 1;

    if (canonical_current == comp.canonicalState(target_state)) return true;

    if (comp.findNode(canonical_current)) |node| {
        if (node.Children) |children| {
            for (children) |child| {
                if (comp.findPathToState(child, target_state, path, len, depth + 1)) return true;
            }
        }
    }

    len.* -= 1;
    return false;
}

const ResolvedStates = struct {
    from: i32,
    to: i32,
};

fn resolveOverrideStates(comp: *const Component, from: i32, to: i32, reverse: bool) ResolvedStates {
    if (reverse) {
        return .{
            .from = comp.clientState(from),
            .to = comp.clientState(to),
        };
    }

    return .{
        .from = comp.canonicalState(from),
        .to = comp.canonicalState(to),
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

fn removePass(comp: *Component, gpa: mem.Allocator, key: ConditionKey) !void {
    var pass_pool: std.ArrayList(ConditionKey) = .empty;
    defer pass_pool.deinit(gpa);

    for (comp.pass_pool) |entry| {
        if (entry.fsm_id == key.fsm_id and
            entry.index == key.index and
            comp.statesEquivalent(entry.from, key.from) and
            comp.statesEquivalent(entry.to, key.to)) continue;
        try pass_pool.append(gpa, entry);
    }

    gpa.free(comp.pass_pool);
    comp.pass_pool = try pass_pool.toOwnedSlice(gpa);
}

fn removePassesFrom(comp: *Component, gpa: mem.Allocator, fsm_id: i32, from: i32) !void {
    var pass_pool: std.ArrayList(ConditionKey) = .empty;
    defer pass_pool.deinit(gpa);

    for (comp.pass_pool) |entry| {
        if (entry.fsm_id == fsm_id and comp.statesEquivalent(entry.from, from)) continue;
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
