const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const Assets = @import("../../../data/Assets.zig");
const AttributeComponent = @import("AttributeComponent.zig");
const FightBuffComponent = @import("FightBuffComponent.zig");
const LogicStateComponent = @import("LogicStateComponent.zig");
const TagComponent = @import("TagComponent.zig");
const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

const log = std.log.scoped(.fsm_component);
const max_state_depth = 32;
const montage_blackboard_key = 1;
const encounter_target_blackboard_key = 2;
const pending_transition_timeout_ms = 3000;

pub const transient = true;

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
    active_since_ms: [max_state_depth]i64 = @splat(0),
    active_len: u8 = 0,
    previous_path: [max_state_depth]i32 = @splat(0),
    previous_len: u8 = 0,
    pending_path: [max_state_depth]i32 = @splat(0),
    pending_since_ms: [max_state_depth]i64 = @splat(0),
    pending_len: u8 = 0,
    pending_from: ?i32 = null,
    pending_to: ?i32 = null,
    pending_started_ms: i64 = 0,

    fn active(node: *const FsmNode) []const i32 {
        return node.active_path[0..node.active_len];
    }

    fn pending(node: *const FsmNode) []const i32 {
        return node.pending_path[0..node.pending_len];
    }

    fn previous(node: *const FsmNode) []const i32 {
        return node.previous_path[0..node.previous_len];
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

const TagCount = struct {
    id: i64,
    count: i32,
};

pub const EvalContext = struct {
    attribute: ?*const AttributeComponent = null,
    buffs: ?*const FightBuffComponent = null,
    logic_state: ?*const LogicStateComponent = null,
    tags: ?*const TagComponent = null,
    parts: ?[]const PartState = null,
    dissolve_combined: ?bool = null,
    now_ms: i64,
};

pub const PartState = struct {
    name: []const u8,
    life: f32,
    max_life: f32,
    activated: bool,
};

pub const Transition = struct {
    fsm_id: i32,
    from: i32,
    to: i32,
};

pub const LifecycleEffect = union(enum) {
    add_buff: i64,
    remove_buff: i64,
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

pub const ClientPassResult = enum {
    updated,
    machine_not_found,
    invalid_source,
    inactive_source,
    invalid_target,
    transition_not_found,
    condition_not_found,
    condition_not_client,
};

hash_code: i32 = 0,
common_hash_code: i32 = 0,
state_list: []const i32 = &.{},
node_list: []const NodeEntry = &.{},
override_mapping: []const OverrideEntry = &.{},
runtime_nodes: []FsmNode = &.{},
pass_pool: []ConditionKey = &.{},
tags: []TagCount = &.{},
lifecycle_effects: std.ArrayList(LifecycleEffect) = .empty,
lifecycle_effects_pending: bool = false,
in_hate: bool = false,
event: ?[]const u8 = null,
last_tick_ms: i64 = 0,
blackboard: [3]?i32 = .{ null, null, null },
blackboard_dirty: u8 = 0,

pub fn deinit(comp: *Component, gpa: mem.Allocator) void {
    gpa.free(comp.state_list);
    gpa.free(comp.node_list);
    gpa.free(comp.override_mapping);
    gpa.free(comp.runtime_nodes);
    gpa.free(comp.pass_pool);
    gpa.free(comp.tags);
    comp.lifecycle_effects.deinit(gpa);
}

pub fn toProto(comp: Component, arena: mem.Allocator, assets: *const Assets) !pb.EntityFsmComponentPb {
    return .{
        .Fsms = try comp.getInitialFsm(arena, assets),
        .HashCode = comp.hash_code,
        .CommonHashCode = comp.common_hash_code,
        .BlackBoard = try comp.blackboardToProto(arena, null),
        .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
    };
}

pub fn fromAiBaseId(ai_id: ?i32, assets: *const Assets, gpa: mem.Allocator) !?Component {
    const configs = findAiStateMachineConfigs(ai_id, assets) orelse return null;
    return fromConfig(configs.entity, configs.common, gpa);
}

pub fn hasUsableAiBaseId(ai_id: ?i32, assets: *const Assets) bool {
    return findAiStateMachineConfigs(ai_id, assets) != null;
}

pub fn fromStateMachineId(id: []const u8, assets: *const Assets, gpa: mem.Allocator) !Component {
    const configs = findStateMachineConfigs(id, assets) orelse return error.InvalidFsmConfiguration;
    return (try fromConfig(configs.entity, configs.common, gpa)) orelse error.InvalidFsmConfiguration;
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
        @memset(runtime.active_since_ms[0..active_len], now_ms);
        try runtime_nodes.append(gpa, runtime);
    }

    comp.runtime_nodes = try runtime_nodes.toOwnedSlice(gpa);
    errdefer {
        gpa.free(comp.runtime_nodes);
        comp.runtime_nodes = &.{};
        gpa.free(comp.tags);
        comp.tags = &.{};
        comp.lifecycle_effects.deinit(gpa);
        comp.lifecycle_effects = .empty;
        comp.event = null;
    }

    comp.event = null;
    comp.prepareInitialBlackboard(now_ms);
    for (comp.runtime_nodes) |runtime| {
        comp.preparePathBlackboard(runtime.active(), runtime.active_since_ms[0..runtime.active_len], false);
        try comp.enterPath(gpa, runtime.active());
    }
    comp.blackboard_dirty = 0;
    comp.finishTick(now_ms);
}

pub fn finishTick(comp: *Component, now_ms: i64) void {
    if (comp.lifecycle_effects_pending) return;
    for (comp.runtime_nodes) |*runtime| {
        const active_path = runtime.active();
        @memcpy(runtime.previous_path[0..active_path.len], active_path);
        runtime.previous_len = runtime.active_len;
    }
    comp.event = null;
    comp.last_tick_ms = now_ms;
}

pub fn needsServerTick(comp: *const Component) bool {
    if (comp.blackboard_dirty != 0) return true;
    if (comp.lifecycle_effects_pending) return true;
    if (comp.lifecycle_effects.items.len != 0) return true;
    if (comp.in_hate) return true;

    for (comp.runtime_nodes) |runtime| {
        if (runtime.pending_to != null) return true;
        const active_path = runtime.active();
        if (active_path.len < 2) continue;

        for (active_path[1..], 1..) |active_state, index| {
            const parent = comp.findNode(active_path[index - 1]) orelse continue;
            for (parent.Transitions) |transition| {
                const resolved = comp.resolveOverrideStates(transition.From, transition.To, false);
                if (!comp.statesEquivalent(resolved.from, active_state)) continue;
                const condition = findCondition(transition.Conditions, 0) orelse continue;
                if (!(condition.IsClient orelse false) and !std.mem.eql(u8, condition.Name, "CondHate")) return true;
            }
        }
    }

    return false;
}

pub fn lifecycleEffects(comp: *const Component) []const LifecycleEffect {
    return comp.lifecycle_effects.items;
}

pub fn lifecycleEffectsPending(comp: *const Component) bool {
    return comp.lifecycle_effects_pending;
}

pub fn markLifecycleEffectsEnqueued(comp: *Component, gpa: mem.Allocator) void {
    if (comp.lifecycle_effects.items.len == 0) return;
    comp.lifecycle_effects.deinit(gpa);
    comp.lifecycle_effects = .empty;
    comp.lifecycle_effects_pending = true;
}

pub fn completeLifecycleEffects(comp: *Component) void {
    comp.lifecycle_effects_pending = false;
}

pub fn setEncounterTarget(comp: *Component, target_id: ?i32) bool {
    return comp.setBlackboardValue(encounter_target_blackboard_key, target_id, true);
}

pub fn clearEncounterTargetReference(comp: *Component, target_id: i32) bool {
    if (comp.blackboard[encounter_target_blackboard_key] != target_id) return false;
    return comp.setEncounterTarget(null);
}

pub fn recoverExpiredPending(comp: *Component, gpa: mem.Allocator, now_ms: i64) !bool {
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
        try comp.commitPending(runtime, gpa);
    }
    return true;
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

pub fn recordClientPass(comp: *Component, gpa: mem.Allocator, key: ConditionKey, value: bool) !ClientPassResult {
    const fsm_id = comp.canonicalState(key.fsm_id);
    const runtime = comp.runtimeNode(fsm_id) orelse return .machine_not_found;
    if (!comp.stateBelongsToFsm(fsm_id, key.from)) return .invalid_source;
    if (!comp.pathContains(runtime.active(), key.from)) return .inactive_source;
    if (!comp.stateBelongsToFsm(fsm_id, key.to)) return .invalid_target;

    const resolved = comp.resolveOverrideStates(key.from, key.to, false);
    switch (comp.clientConditionLookup(fsm_id, resolved.from, resolved.to, key.index)) {
        .valid => {},
        .transition_not_found => return .transition_not_found,
        .condition_not_found => return .condition_not_found,
        .condition_not_client => return .condition_not_client,
    }

    const resolved_key: ConditionKey = .{
        .fsm_id = fsm_id,
        .from = resolved.from,
        .to = resolved.to,
        .index = key.index,
    };

    if (!value) {
        try comp.removePass(gpa, resolved_key);
        return .updated;
    }

    try comp.appendPass(gpa, resolved_key);
    return .updated;
}

pub fn confirmPending(comp: *Component, fsm_id: i32, state: i32, gpa: mem.Allocator) !ConfirmResult {
    const runtime = comp.runtimeNode(fsm_id) orelse return .machine_not_found;
    if (!comp.stateBelongsToFsm(fsm_id, state)) return .invalid_target;
    if (comp.lifecycle_effects_pending) return .no_pending;

    const pending_state = runtime.pending_to orelse return .no_pending;
    if (comp.statesEquivalent(state, pending_state)) {
        try comp.commitPending(runtime, gpa);
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
    if (comp.lifecycle_effects_pending) return .no_pending;

    const pending_state = runtime.pending_to orelse {
        if (try comp.acceptPredictedTransition(fsm_id, from, to, gpa, now_ms)) return .accepted;
        return .no_pending;
    };

    if (comp.statesEquivalent(to, pending_state)) {
        const pending_from = runtime.pending_from orelse return .{ .mismatch = comp.clientState(pending_state) };
        if (!comp.statesEquivalent(pending_from, from)) return .{ .mismatch = comp.clientState(pending_state) };

        try comp.commitPending(runtime, gpa);
        return .confirmed;
    }

    if (comp.canFoldPredictedTransition(runtime, from, to)) {
        try comp.commitPending(runtime, gpa);
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

pub fn appendReadyStateTransitions(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    ctx: EvalContext,
) !void {
    try comp.appendBlackboardNotify(entity_id, allocator, output);
    for (comp.runtime_nodes) |runtime| {
        if (try comp.findReadyTransition(runtime.fsm_id, ctx)) |transition| {
            try comp.appendBlackboardNotify(entity_id, allocator, output);
            try output.append(allocator, transitionNotify(entity_id, transition));
        }
    }
}

pub fn appendBlackboardNotify(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const dirty = comp.blackboard_dirty;
    if (dirty == 0) return;

    const values = try comp.blackboardToProto(allocator, dirty);
    if (values.items.len == 0) {
        comp.blackboard_dirty &= ~dirty;
        return;
    }

    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmBlackboardNotify = .{ .FsmBlackBoards = values } },
        },
    } });
    comp.blackboard_dirty &= ~dirty;
}

pub fn appendResetNotify(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    assets: *const Assets,
) !void {
    const blackboard = try comp.blackboardSnapshotToProto(allocator);
    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmBlackboardNotify = .{ .FsmBlackBoards = blackboard } },
        },
    } });
    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmResetNotify = .{
                .EntityFsmComponentPb = .{
                    .Fsms = try comp.getInitialFsm(allocator, assets),
                    .HashCode = comp.hash_code,
                    .CommonHashCode = comp.common_hash_code,
                    .BlackBoard = blackboard,
                    .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
                },
            } },
        },
    } });
    comp.blackboard_dirty = 0;
}

pub fn checkTransitions(
    comp: *Component,
    entity_id: i64,
    fsm_id: i32,
    ctx: EvalContext,
) !?pb.CombatReceiveData {
    if (try comp.findReadyTransition(fsm_id, ctx)) |transition| {
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
    const transition = (try comp.findReadyTransition(fsm_id, ctx)) orelse return null;
    _ = try comp.confirmPending(fsm_id, transition.to, gpa);
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
                .StateElapseTime = elapsedTime(comp.last_tick_ms, runtime.active_since_ms[runtime.active_len - 1]),
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

fn blackboardToProto(comp: *const Component, arena: mem.Allocator, dirty: ?u8) !std.ArrayList(pb.DFsmBlackBoard) {
    var result: std.ArrayList(pb.DFsmBlackBoard) = .empty;
    for (comp.blackboard[1..], 1..) |value, key| {
        const bit = blackboardBit(key);
        if (dirty) |mask| {
            if (mask & bit == 0) continue;
            try result.append(arena, .{ .Key = @intCast(key), .Value = value orelse 0 });
            continue;
        }
        if (value) |entry| {
            try result.append(arena, .{ .Key = @intCast(key), .Value = entry });
        }
    }
    return result;
}

fn blackboardSnapshotToProto(comp: *const Component, arena: mem.Allocator) !std.ArrayList(pb.DFsmBlackBoard) {
    var result: std.ArrayList(pb.DFsmBlackBoard) = .empty;
    for (comp.blackboard[1..], 1..) |value, key| {
        try result.append(arena, .{ .Key = @intCast(key), .Value = value orelse 0 });
    }
    return result;
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return assets.tables.ai_state_machine_config.getDataById("SM_Common");
}

const StateMachineConfigs = struct {
    entity: AiStateMachineConfig.StateMachineJsonData,
    common: AiStateMachineConfig.StateMachineJsonData,
};

fn findAiStateMachineConfigs(ai_id: ?i32, assets: *const Assets) ?StateMachineConfigs {
    const id = ai_id orelse return null;
    if (id <= 0) return null;

    const ai_base = assets.tables.ai_base.getDataById(id) orelse return null;
    return findStateMachineConfigs(ai_base.StateMachine, assets);
}

fn findStateMachineConfigs(id: []const u8, assets: *const Assets) ?StateMachineConfigs {
    if (id.len == 0) return null;
    const common = getCommonFsm(assets) orelse return null;
    const entity = assets.tables.ai_state_machine_config.getDataById(id) orelse return null;
    if (!hasDeclaredRoot(entity.StateMachineJson, common.StateMachineJson)) return null;

    return .{
        .entity = entity.StateMachineJson,
        .common = common.StateMachineJson,
    };
}

fn hasDeclaredRoot(
    entity: AiStateMachineConfig.StateMachineJsonData,
    common: AiStateMachineConfig.StateMachineJsonData,
) bool {
    for (entity.StateMachines) |root_id| {
        for (entity.Nodes) |node| {
            if (node.Uuid != root_id) continue;
            const effective_id = node.ReferenceUuid orelse node.Uuid;
            const nodes = if (node.ReferenceUuid != null) common.Nodes else entity.Nodes;
            for (nodes) |candidate| {
                if (candidate.Uuid == effective_id) return true;
            }
        }
    }

    return false;
}

fn fromConfig(
    state_machine_config: AiStateMachineConfig.StateMachineJsonData,
    common_state_machine: AiStateMachineConfig.StateMachineJsonData,
    gpa: mem.Allocator,
) !?Component {
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

    var component: Component = .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
        .state_list = try state_list.toOwnedSlice(gpa),
        .node_list = try fsm_tree.toOwnedSlice(gpa),
        .override_mapping = try override_mapping.toOwnedSlice(gpa),
    };
    if (!component.hasValidInitialRoot()) {
        component.deinit(gpa);
        return null;
    }

    return component;
}

fn hasValidInitialRoot(comp: *const Component) bool {
    for (comp.state_list) |fsm_id| {
        var path: [max_state_depth]i32 = @splat(0);
        if (comp.buildInitialPath(fsm_id, &path) != null) return true;
    }

    return false;
}

fn findReadyTransition(comp: *Component, fsm_id: i32, ctx: EvalContext) !?Transition {
    if (comp.lifecycle_effects_pending) return null;
    const runtime = comp.runtimeNode(fsm_id) orelse return null;
    if (runtime.pending_to != null) return null;

    const active_path = runtime.active();
    if (active_path.len < 2) return null;

    for (active_path[1..], 1..) |active_state, index| {
        const parent_node = comp.findNode(active_path[index - 1]) orelse continue;
        if (try comp.checkTransitionsForState(runtime.fsm_id, parent_node, active_state, ctx)) |transition| {
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
    ctx: EvalContext,
) !?Transition {
    const runtime = comp.runtimeNode(fsm_id) orelse return null;
    if (runtime.pending_to != null) return null;

    const children = node.Children orelse return null;
    const canonical_source = comp.canonicalState(state_to_check);

    for (node.Transitions) |transition| {
        const resolved_transition = comp.resolveOverrideStates(transition.From, transition.To, false);
        if (resolved_transition.from != canonical_source) continue;

        const target_state = resolved_transition.to;
        if (canonical_source == target_state) continue;

        const target_is_child = for (children) |child| {
            if (comp.statesEquivalent(child, target_state)) break true;
        } else false;
        if (!target_is_child) continue;

        const top_condition = findCondition(transition.Conditions, 0) orelse continue;
        if (!comp.evalCondition(fsm_id, transition, transition.Conditions, top_condition, ctx, 0)) continue;

        try comp.setPendingTransition(runtime, canonical_source, target_state, ctx.now_ms);
        return .{
            .fsm_id = comp.clientState(runtime.fsm_id),
            .from = comp.clientState(canonical_source),
            .to = comp.clientState(target_state),
        };
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
    if (condition.IsClient orelse false) {
        return comp.clientPasses(fsm_id, transition, condition.Index);
    }

    var result = comp.evalConditionRaw(fsm_id, transition, conditions, condition, ctx, depth);
    if (condition.Reverse) result = !result;
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
        return comp.timerPasses(fsm_id, transition, condition.Index, timer, ctx.now_ms);
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

    // The client owns be-hit event classification and reports it through condition passes.
    if (condition.CondListenBeHit != null) return false;

    if (condition.CondListenEvent) |listen| {
        return comp.listenEventPasses(listen);
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

    if (condition.CondTag) |tag| return if (tag.TagId) |tag_id| comp.hasTag(ctx.tags, tag_id) else false;

    if (condition.CondTaskFinish != null or condition.CondMontageTimeRemaining != null) return false;

    if (condition.CondInstStateChange) |state| return comp.hasTag(ctx.tags, state.TagId);

    if (condition.CondBuffStack) |buff| {
        return buffStackInRange(ctx.buffs, buff);
    }

    if (condition.CondPartLife) |part| {
        return partLifeInRange(ctx.parts, part);
    }

    if (condition.CondCheckPartActivated) |part| {
        return partIsActivated(ctx.parts, part.PartName);
    }

    if (condition.CondCheckDissolveCombine != null) return ctx.dissolve_combined orelse false;

    return false;
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
    if (!comp.hasPredictedTransition(runtime.fsm_id, from, to)) return false;

    try comp.changeCurrentState(fsm_id, from, to, gpa, now_ms);
    return true;
}

fn canFoldPredictedTransition(comp: *const Component, runtime: *const FsmNode, from: i32, to: i32) bool {
    if (!comp.pathContains(runtime.pending(), from)) return false;
    if (!comp.stateBelongsToFsm(runtime.fsm_id, to)) return false;
    return comp.hasPredictedTransition(runtime.fsm_id, from, to);
}

fn hasPredictedTransition(comp: *const Component, fsm_id: i32, from: i32, to: i32) bool {
    const requested = comp.resolveOverrideStates(from, to, false);
    const root = comp.findNode(fsm_id) orelse return false;
    const client_owns_animation = root.IsAnimStateMachine orelse false;

    for (comp.node_list) |entry| {
        for (entry.value.Transitions) |transition| {
            const candidate = comp.resolveOverrideStates(transition.From, transition.To, false);
            if (candidate.from != requested.from or candidate.to != requested.to) continue;
            if (client_owns_animation) return true;
            const prediction_type = transition.TransitionPredictionType orelse 0;
            if (prediction_type == 1 or prediction_type == 2) return true;
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

const ClientConditionLookup = enum {
    valid,
    transition_not_found,
    condition_not_found,
    condition_not_client,
};

fn clientConditionLookup(comp: *const Component, fsm_id: i32, from: i32, to: i32, index: i32) ClientConditionLookup {
    var found_transition = false;
    var found_condition = false;
    if (comp.findClientConditionRecursive(
        comp.canonicalState(fsm_id),
        comp.canonicalState(from),
        comp.canonicalState(to),
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
    comp: *const Component,
    node_id: i32,
    from: i32,
    to: i32,
    index: i32,
    found_transition: *bool,
    found_condition: *bool,
    depth: usize,
) bool {
    if (depth >= max_state_depth) return false;
    const node = comp.findNode(node_id) orelse return false;

    for (node.Transitions) |transition| {
        const resolved = comp.resolveOverrideStates(transition.From, transition.To, false);
        if (resolved.from != from or resolved.to != to) continue;

        found_transition.* = true;
        const condition = findCondition(transition.Conditions, index) orelse continue;
        found_condition.* = true;
        if (condition.IsClient orelse false) return true;
    }

    if (node.Children) |children| {
        for (children) |child| {
            if (comp.findClientConditionRecursive(
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
    comp: *Component,
    gpa: mem.Allocator,
    actions: []const AiStateMachineConfig.StateMachineAction,
) !void {
    for (actions) |action| {
        if (action.ActionDispatchEvent) |event_action| {
            comp.event = event_action.Event;
        }

        if (action.ActionAddBuff) |buff| try comp.appendLifecycleEffect(gpa, .{ .add_buff = buff.BuffId });
        if (action.ActionRemoveBuff) |buff| try comp.appendLifecycleEffect(gpa, .{ .remove_buff = buff.BuffId });

        if (action.ActionAddTagCount) |tag| {
            if (tag.Count > 0) try comp.updateTagCount(gpa, tag.TagId, tag.Count);
        }

        if (action.ActionRemoveTagCount) |tag| {
            if (tag.Count == -1) {
                comp.clearTag(tag.TagId);
            } else if (tag.Count > 0) {
                try comp.updateTagCount(gpa, tag.TagId, -tag.Count);
            }
        }
    }
}

fn updateBindStates(
    comp: *Component,
    gpa: mem.Allocator,
    binds: []const AiStateMachineConfig.StateMachineBindState,
    delta: i32,
) !void {
    for (binds) |bind| {
        if (bind.BindBuff) |buff| {
            if (delta > 0) {
                try comp.appendLifecycleEffect(gpa, .{ .add_buff = buff.BuffId });
            }
        }

        if (bind.BindTag) |tag| {
            try comp.updateTagCount(gpa, tag.TagId, delta);
        }
    }
}

fn appendLifecycleEffect(comp: *Component, gpa: mem.Allocator, effect: LifecycleEffect) !void {
    try comp.lifecycle_effects.append(gpa, effect);
}

fn updateTagCount(comp: *Component, gpa: mem.Allocator, tag_id: i64, delta: i32) !void {
    for (comp.tags) |*tag| {
        if (tag.id != tag_id) continue;
        const count = @as(i64, tag.count) + delta;
        if (count > std.math.maxInt(i32)) return error.FsmTagCountOverflow;
        tag.count = if (count > 0) @intCast(count) else 0;
        return;
    }

    if (delta <= 0) return;

    const old_tags = comp.tags;
    const tags = try gpa.alloc(TagCount, old_tags.len + 1);
    @memcpy(tags[0..old_tags.len], old_tags);
    tags[old_tags.len] = .{ .id = tag_id, .count = delta };
    gpa.free(old_tags);
    comp.tags = tags;
}

fn clearTag(comp: *Component, tag_id: i64) void {
    for (comp.tags) |*tag| {
        if (tag.id == tag_id) {
            tag.count = 0;
            return;
        }
    }
}

fn hasTag(comp: *const Component, tag_component: ?*const TagComponent, tag_id: i64) bool {
    for (comp.tags) |tag| {
        if (tag.id == tag_id and tag.count > 0) return true;
    }
    return if (tag_component) |tags| tags.hasTag(tag_id) else false;
}

fn enterPath(comp: *Component, gpa: mem.Allocator, path: []const i32) !void {
    for (path) |state| try comp.enterNode(gpa, state);
}

fn applyPathLifecycle(comp: *Component, gpa: mem.Allocator, active_path: []const i32, target_path: []const i32) !void {
    const common_len = commonPathPrefixLen(active_path, target_path);

    comp.event = null;

    var exit_index = active_path.len;
    while (exit_index > common_len) {
        exit_index -= 1;
        try comp.exitNode(gpa, active_path[exit_index]);
    }

    for (target_path[common_len..]) |state| try comp.enterNode(gpa, state);
}

fn enterNode(comp: *Component, gpa: mem.Allocator, state: i32) !void {
    const node = comp.findNode(state) orelse return;
    try comp.runActions(gpa, node.OnEnterActions);
    try comp.updateBindStates(gpa, node.BindStates, 1);
}

fn exitNode(comp: *Component, gpa: mem.Allocator, state: i32) !void {
    const node = comp.findNode(state) orelse return;
    try comp.runActions(gpa, node.OnExitActions);
    try comp.updateBindStates(gpa, node.BindStates, -1);
}

fn prepareInitialBlackboard(comp: *Component, now_ms: i64) void {
    var minimum_montage_count: ?usize = null;
    for (comp.node_list) |entry| {
        const task = entry.value.Task orelse continue;
        const montage = task.TaskRandomMontage orelse continue;
        if (montage.RandomByClient or montage.MontageNames.len == 0) continue;
        minimum_montage_count = if (minimum_montage_count) |count|
            @min(count, montage.MontageNames.len)
        else
            montage.MontageNames.len;
    }

    if (minimum_montage_count) |count| {
        comp.setBlackboard(montage_blackboard_key, comp.selectMontageIndex(0, now_ms, count), false);
    }
}

fn preparePathBlackboard(comp: *Component, path: []const i32, activated_at: []const i64, mark_dirty: bool) void {
    for (path, 0..) |state, index| {
        const node = comp.findNode(state) orelse continue;
        const task = node.Task orelse continue;
        if (task.TaskRandomMontage) |montage| {
            if (!montage.RandomByClient and montage.MontageNames.len != 0) {
                comp.setBlackboard(
                    montage_blackboard_key,
                    comp.selectMontageIndex(state, activated_at[index], montage.MontageNames.len),
                    mark_dirty,
                );
            }
        }
    }
}

fn setBlackboard(comp: *Component, key: usize, value: i32, mark_dirty: bool) void {
    _ = comp.setBlackboardValue(key, value, mark_dirty);
}

fn setBlackboardValue(comp: *Component, key: usize, value: ?i32, mark_dirty: bool) bool {
    if (key >= comp.blackboard.len or comp.blackboard[key] == value) return false;
    comp.blackboard[key] = value;
    if (mark_dirty) comp.blackboard_dirty |= blackboardBit(key);
    return true;
}

fn blackboardBit(key: usize) u8 {
    return @as(u8, 1) << @intCast(key);
}

fn selectMontageIndex(comp: *const Component, state: i32, activated_at: i64, count: usize) i32 {
    var seed: u64 = @bitCast(activated_at);
    const state_bits: u32 = @bitCast(state);
    const hash_bits: u32 = @bitCast(comp.hash_code);
    seed ^= @as(u64, state_bits) *% 0x9E3779B185EBCA87;
    seed ^= @as(u64, hash_bits) *% 0xC2B2AE3D27D4EB4F;
    seed ^= seed >> 12;
    seed ^= seed << 25;
    seed ^= seed >> 27;
    return @intCast(seed % count);
}

fn setPendingTransition(comp: *Component, runtime: *FsmNode, from: i32, to: i32, now_ms: i64) !void {
    const pending_len = comp.buildActivePath(runtime.fsm_id, to, &runtime.pending_path) orelse
        return error.InvalidFsmTransitionTarget;

    for (runtime.pending_path[0..pending_len], 0..) |state, index| {
        runtime.pending_since_ms[index] = if (index < runtime.active_len and runtime.active_path[index] == state)
            runtime.active_since_ms[index]
        else
            now_ms;
    }

    runtime.pending_len = @intCast(pending_len);
    runtime.pending_from = comp.canonicalState(from);
    runtime.pending_to = comp.canonicalState(to);
    runtime.pending_started_ms = now_ms;
    comp.preparePathBlackboard(runtime.pending(), runtime.pending_since_ms[0..runtime.pending_len], true);
}

fn commitPending(comp: *Component, runtime: *FsmNode, gpa: mem.Allocator) !void {
    if (runtime.pending_from == null) return;
    const pending_path = runtime.pending();
    if (pending_path.len == 0) return;

    try comp.applyPathLifecycle(gpa, runtime.active(), pending_path);
    try comp.removePassesForExitedPath(gpa, runtime.fsm_id, runtime.active(), pending_path);
    @memcpy(runtime.active_path[0..pending_path.len], pending_path);
    @memcpy(runtime.active_since_ms[0..pending_path.len], runtime.pending_since_ms[0..pending_path.len]);
    runtime.active_len = runtime.pending_len;
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
}

fn changeCurrentState(comp: *Component, fsm_id: i32, _: i32, to: i32, gpa: mem.Allocator, now_ms: i64) !void {
    const runtime = comp.runtimeNode(fsm_id) orelse return;
    var target_path: [max_state_depth]i32 = @splat(0);
    var target_since_ms: [max_state_depth]i64 = @splat(0);
    const active_len = comp.buildActivePath(runtime.fsm_id, to, &target_path) orelse return;
    for (target_path[0..active_len], 0..) |state, index| {
        target_since_ms[index] = if (index < runtime.active_len and runtime.active_path[index] == state)
            runtime.active_since_ms[index]
        else
            now_ms;
    }

    comp.preparePathBlackboard(target_path[0..active_len], target_since_ms[0..active_len], true);
    try comp.applyPathLifecycle(gpa, runtime.active(), target_path[0..active_len]);
    try comp.removePassesForExitedPath(gpa, runtime.fsm_id, runtime.active(), target_path[0..active_len]);
    @memcpy(runtime.active_path[0..active_len], target_path[0..active_len]);
    @memcpy(runtime.active_since_ms[0..active_len], target_since_ms[0..active_len]);
    runtime.active_len = @intCast(active_len);
    runtime.pending_len = 0;
    runtime.pending_from = null;
    runtime.pending_to = null;
    runtime.pending_started_ms = 0;
}

fn currentStateMatches(comp: *const Component, state: i32) bool {
    for (comp.runtime_nodes) |runtime| {
        if (comp.pathContains(runtime.active(), state)) return true;
    }

    return false;
}

fn timerPasses(
    comp: *const Component,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    condition_index: i32,
    timer: AiStateMachineConfig.ConditionTimer,
    now_ms: i64,
) bool {
    const activated_at = comp.activationTime(fsm_id, transition.From) orelse return false;
    if (now_ms < activated_at) return false;

    const min_ms = @max(@as(i64, timer.MinTime), 0);
    const configured_max = @as(i64, timer.MaxTime orelse timer.MinTime);
    const max_ms = @max(configured_max, min_ms);
    const delay_ms = timerDelayMs(
        comp.canonicalState(fsm_id),
        comp.canonicalState(transition.From),
        comp.canonicalState(transition.To),
        condition_index,
        activated_at,
        min_ms,
        max_ms,
    );
    return now_ms - activated_at >= delay_ms;
}

fn activationTime(comp: *const Component, fsm_id: i32, state: i32) ?i64 {
    const canonical_fsm = comp.canonicalState(fsm_id);
    const canonical_state = comp.canonicalState(state);
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id != canonical_fsm) continue;
        for (runtime.active(), 0..) |active_state, index| {
            if (active_state == canonical_state) return runtime.active_since_ms[index];
        }
    }
    return null;
}

fn timerDelayMs(
    fsm_id: i32,
    from: i32,
    to: i32,
    condition_index: i32,
    activated_at: i64,
    min_ms: i64,
    max_ms: i64,
) i64 {
    if (max_ms <= min_ms) return min_ms;

    var seed: u64 = @bitCast(activated_at);
    const fsm_bits: u32 = @bitCast(fsm_id);
    const from_bits: u32 = @bitCast(from);
    const to_bits: u32 = @bitCast(to);
    const condition_bits: u32 = @bitCast(condition_index);
    seed ^= @as(u64, fsm_bits) *% 0x9E3779B185EBCA87;
    seed ^= @as(u64, from_bits) *% 0xC2B2AE3D27D4EB4F;
    seed ^= @as(u64, to_bits) *% 0x165667B19E3779F9;
    seed ^= @as(u64, condition_bits) *% 0x85EBCA77C2B2AE63;
    seed ^= seed >> 12;
    seed ^= seed << 25;
    seed ^= seed >> 27;
    seed *%= 0x2545F4914F6CDD1D;

    const span: u64 = @intCast(max_ms - min_ms + 1);
    return min_ms + @as(i64, @intCast(seed % span));
}

fn elapsedTime(now_ms: i64, activated_at: i64) i32 {
    if (now_ms <= activated_at) return 0;
    return @intCast(@min(now_ms - activated_at, std.math.maxInt(i32)));
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
    for (comp.runtime_nodes) |runtime| {
        for (runtime.previous()) |state| {
            const node = comp.findNode(state) orelse continue;
            if (node.Name) |node_name| {
                if (std.mem.eql(u8, node_name, name)) return true;
            }
        }
    }
    return false;
}

fn listenEventPasses(comp: *const Component, condition: AiStateMachineConfig.ConditionListenEvent) bool {
    const event = comp.event orelse return false;
    return std.mem.eql(u8, event, condition.Event);
}

fn buffStackInRange(buffs: ?*const FightBuffComponent, condition: AiStateMachineConfig.ConditionBuffStack) bool {
    const component = buffs orelse return condition.MinStack <= 0 and condition.MaxStack >= 0;
    const stack = for (component.fight_buff_infos) |buff| {
        if (buff.BuffId == condition.BuffId) break buff.StackCount;
    } else 0;
    return stack >= condition.MinStack and stack <= condition.MaxStack;
}

fn partLifeInRange(parts: ?[]const PartState, condition: AiStateMachineConfig.ConditionPartLife) bool {
    const states = parts orelse return false;
    const part = for (states) |state| {
        if (std.mem.eql(u8, state.name, condition.PartName)) break state;
    } else return false;

    const value: f64 = if (condition.CheckRate) blk: {
        if (part.max_life <= 0) return false;
        break :blk @as(f64, part.life) * 10000.0 / @as(f64, part.max_life);
    } else part.life;
    return value >= @as(f64, @floatFromInt(condition.Min)) and value <= @as(f64, @floatFromInt(condition.Max));
}

fn partIsActivated(parts: ?[]const PartState, name: []const u8) bool {
    const states = parts orelse return false;
    for (states) |part| {
        if (std.mem.eql(u8, part.name, name)) return part.activated;
    }
    return false;
}

fn attrInRange(attribute: ?*const AttributeComponent, attribute_id: i32, min: i32, max: i32) bool {
    const attr = attrValue(attribute, attribute_id) orelse return false;
    return attr >= min and attr <= max;
}

fn attrRateInRange(attribute: ?*const AttributeComponent, attribute_id: i32, denominator_id: i32, min: i32, max: i32) bool {
    const numerator = attrValue(attribute, attribute_id) orelse return false;
    const denominator = attrValue(attribute, denominator_id) orelse return false;
    if (denominator == 0) return false;
    const rate = @divTrunc(@as(i64, numerator) * 10000, @as(i64, denominator));
    return rate >= @as(i64, min) and rate <= @as(i64, max);
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
        .fsm_id = comp.canonicalState(fsm_id),
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

fn removePassesForExitedPath(
    comp: *Component,
    gpa: mem.Allocator,
    fsm_id: i32,
    active_path: []const i32,
    target_path: []const i32,
) !void {
    const exited_path = active_path[commonPathPrefixLen(active_path, target_path)..];
    if (exited_path.len == 0 or comp.pass_pool.len == 0) return;

    const canonical_fsm = comp.canonicalState(fsm_id);
    var retained: usize = 0;
    for (comp.pass_pool) |entry| {
        const remove = entry.fsm_id == canonical_fsm and comp.pathContains(exited_path, entry.from);
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

fn commonPathPrefixLen(a: []const i32, b: []const i32) usize {
    var len: usize = 0;
    while (len < a.len and len < b.len and a[len] == b[len]) : (len += 1) {}
    return len;
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
