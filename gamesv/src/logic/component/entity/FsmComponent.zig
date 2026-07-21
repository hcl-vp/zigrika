const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const Assets = @import("../../../data/Assets.zig");
const Blackboard = @import("../../fsm/Blackboard.zig");
const ConfigLoader = @import("../../fsm/ConfigLoader.zig");
const FsmTypes = @import("../../fsm/Types.zig");
const StateHierarchy = @import("../../fsm/StateHierarchy.zig");
const TransitionEngine = @import("../../fsm/TransitionEngine.zig");
const FsmGraph = Assets.FsmGraphRegistry.Graph;
const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;
const GameplayTagParentTable = Assets.DataTables.GameplayTagParentTable;

const encounter_target_blackboard_key = 2;

pub const transient = true;

const TagCount = FsmTypes.TagCount;
pub const FsmNode = FsmTypes.FsmNode;
pub const ConditionKey = FsmTypes.ConditionKey;
pub const EvalContext = FsmTypes.EvalContext;
pub const PartState = FsmTypes.PartState;
pub const Transition = FsmTypes.Transition;
pub const LifecycleEffect = FsmTypes.LifecycleEffect;
pub const ConfirmResult = FsmTypes.ConfirmResult;
pub const ClientPassResult = FsmTypes.ClientPassResult;
pub const WakeMask = FsmTypes.WakeMask;
pub const WakeReason = FsmTypes.WakeReason;

graph: *const FsmGraph = &FsmGraph.empty,
tag_parents: *const GameplayTagParentTable = &GameplayTagParentTable.init,
runtime_nodes: []FsmNode = &.{},
pass_pool: []ConditionKey = &.{},
tags: []TagCount = &.{},
lifecycle_effects: std.ArrayList(LifecycleEffect) = .empty,
lifecycle_effects_pending: bool = false,
lifecycle_recheck_requested: bool = false,
in_hate: bool = false,
paralysis_active: bool = false,
paralysis_last_ms: i64 = 0,
paralysis_next_ms: ?i64 = null,
dissolve_combine_signal: bool = false,
instance_state_tag: ?i32 = null,
event: ?[]const u8 = null,
last_tick_ms: i64 = 0,
blackboard: [3]?i32 = .{ null, null, null },
blackboard_dirty: u8 = 0,

pub fn deinit(comp: *Component, gpa: mem.Allocator) void {
    gpa.free(comp.runtime_nodes);
    gpa.free(comp.pass_pool);
    gpa.free(comp.tags);
    comp.lifecycle_effects.deinit(gpa);
}

pub fn toProto(comp: Component, arena: mem.Allocator, assets: *const Assets) !pb.EntityFsmComponentPb {
    return Blackboard.toProto(comp, arena, assets);
}

pub fn fromAiBaseId(ai_id: ?i32, assets: *const Assets) ?Component {
    return ConfigLoader.fromAiBaseId(Component, ai_id, assets);
}

pub fn hasUsableAiBaseId(ai_id: ?i32, assets: *const Assets) bool {
    return ConfigLoader.hasUsableAiBaseId(ai_id, assets);
}

pub fn fromStateMachineId(id: []const u8, assets: *const Assets) !Component {
    return ConfigLoader.fromStateMachineId(Component, id, assets);
}

pub fn initRuntime(comp: *Component, gpa: mem.Allocator, now_ms: i64) !void {
    if (comp.runtime_nodes.len != 0) return;

    var runtime_nodes: std.ArrayList(FsmNode) = .empty;
    defer runtime_nodes.deinit(gpa);

    for (comp.graph.state_list) |raw_fsm_id| {
        const fsm_id = StateHierarchy.canonicalState(comp, raw_fsm_id);
        const already_added = for (runtime_nodes.items) |runtime| {
            if (runtime.fsm_id == fsm_id) break true;
        } else false;
        if (already_added) continue;

        var runtime: FsmNode = .{ .fsm_id = fsm_id };
        const active_len = StateHierarchy.buildInitialPath(comp, fsm_id, &runtime.active_path) orelse continue;
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
    Blackboard.prepareInitial(comp, now_ms);
    for (comp.runtime_nodes) |runtime| {
        Blackboard.preparePath(comp, runtime.active(), runtime.active_since_ms[0..runtime.active_len], false);
        try TransitionEngine.enterPath(comp, gpa, runtime.active());
    }
    TransitionEngine.refreshWakeRequirements(comp, now_ms);
    _ = TransitionEngine.markDirty(comp, WakeReason.initial);
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

pub fn markDirty(comp: *Component, reason: WakeMask) bool {
    return TransitionEngine.markDirty(comp, reason);
}

pub fn markRootDirty(comp: *Component, fsm_id: i32, reason: WakeMask) bool {
    return TransitionEngine.markRootDirty(comp, fsm_id, reason);
}

pub fn clearDirtyReason(comp: *Component, reason: WakeMask) void {
    for (comp.runtime_nodes) |*runtime| runtime.dirty_reasons &= ~reason;
}

pub fn pendingDeadline(comp: *const Component) ?i64 {
    return TransitionEngine.pendingDeadline(comp);
}

pub fn activateParalysis(comp: *Component, now_ms: i64) void {
    comp.paralysis_active = true;
    comp.paralysis_last_ms = now_ms;
    comp.paralysis_next_ms = now_ms + 50;
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

pub fn requestLifecycleRecheck(comp: *Component, requested: bool) void {
    comp.lifecycle_recheck_requested = comp.lifecycle_recheck_requested or requested;
}

pub fn takeLifecycleRecheckRequest(comp: *Component) bool {
    const requested = comp.lifecycle_recheck_requested;
    comp.lifecycle_recheck_requested = false;
    return requested;
}

pub fn setEncounterTarget(comp: *Component, target_id: ?i32) bool {
    return Blackboard.setValue(comp, encounter_target_blackboard_key, target_id, true);
}

pub fn clearEncounterTargetReference(comp: *Component, target_id: i32) bool {
    if (comp.blackboard[encounter_target_blackboard_key] != target_id) return false;
    return comp.setEncounterTarget(null);
}

pub fn recoverExpiredPending(comp: *Component, gpa: mem.Allocator, now_ms: i64) !bool {
    const recovered = try TransitionEngine.recoverExpiredPending(comp, gpa, now_ms);
    if (recovered) {
        TransitionEngine.refreshWakeRequirements(comp, now_ms);
        _ = TransitionEngine.markDirty(comp, WakeReason.initial);
    }
    return recovered;
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

pub fn signalDissolveCombine(comp: *Component) void {
    comp.dissolve_combine_signal = true;
}

pub fn recordClientPass(comp: *Component, gpa: mem.Allocator, key: ConditionKey, value: bool) !ClientPassResult {
    return TransitionEngine.recordClientPass(comp, gpa, key, value);
}

pub fn confirmPending(comp: *Component, fsm_id: i32, state: i32, gpa: mem.Allocator, now_ms: i64) !ConfirmResult {
    const result = try TransitionEngine.confirmPending(comp, fsm_id, state, gpa);
    switch (result) {
        .confirmed, .accepted => {
            TransitionEngine.refreshWakeRequirements(comp, now_ms);
            _ = TransitionEngine.markRootDirty(comp, fsm_id, WakeReason.initial);
        },
        else => {},
    }
    return result;
}

pub fn confirmStateRequest(
    comp: *Component,
    fsm_id: i32,
    from: i32,
    to: i32,
    gpa: mem.Allocator,
    now_ms: i64,
) !ConfirmResult {
    const result = try TransitionEngine.confirmStateRequest(comp, fsm_id, from, to, gpa, now_ms);
    switch (result) {
        .confirmed, .accepted => {
            TransitionEngine.refreshWakeRequirements(comp, now_ms);
            _ = TransitionEngine.markRootDirty(comp, fsm_id, WakeReason.initial);
        },
        else => {},
    }
    return result;
}

pub fn currentState(comp: *const Component, fsm_id: i32) ?i32 {
    return TransitionEngine.currentState(comp, fsm_id);
}

pub fn appendReadyStateTransitions(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    ctx: EvalContext,
) !void {
    try comp.appendBlackboardNotify(entity_id, allocator, output);
    for (comp.runtime_nodes, 0..) |runtime, index| {
        if (runtime.pending_to != null) continue;
        if (try comp.findReadyTransition(runtime.fsm_id, ctx)) |transition| {
            try comp.appendBlackboardNotify(entity_id, allocator, output);
            try output.append(allocator, transitionNotify(entity_id, transition));
        }
        comp.runtime_nodes[index].dirty_reasons = 0;
    }
    TransitionEngine.refreshWakeRequirements(comp, ctx.now_ms);
    if (comp.canDiscardDissolveCombineSignal()) comp.dissolve_combine_signal = false;
}

pub fn appendDirtyStateTransitions(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    ctx: EvalContext,
) !void {
    try comp.appendBlackboardNotify(entity_id, allocator, output);
    for (comp.runtime_nodes, 0..) |runtime, index| {
        if (runtime.dirty_reasons == 0 or runtime.pending_to != null) continue;
        const dirty_reasons = runtime.dirty_reasons;
        if (try comp.findReadyTransition(runtime.fsm_id, ctx)) |transition| {
            try comp.appendBlackboardNotify(entity_id, allocator, output);
            try output.append(allocator, transitionNotify(entity_id, transition));
        }
        comp.runtime_nodes[index].dirty_reasons = 0;
        if (dirty_reasons & WakeReason.timer != 0) {
            TransitionEngine.refreshRootTimer(comp, runtime.fsm_id, ctx.now_ms);
        }
    }
    if (comp.canDiscardDissolveCombineSignal()) comp.dissolve_combine_signal = false;
}

pub fn appendBlackboardNotify(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
) !void {
    return Blackboard.appendBlackboardNotify(comp, entity_id, allocator, output);
}

pub fn appendResetNotify(
    comp: *Component,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    assets: *const Assets,
) !void {
    return Blackboard.appendResetNotify(comp, entity_id, allocator, output, assets);
}

pub fn checkTransitions(
    comp: *Component,
    entity_id: i64,
    fsm_id: i32,
    ctx: EvalContext,
) !?pb.CombatReceiveData {
    const runtime = StateHierarchy.runtimeNode(comp, fsm_id);
    if (runtime) |node| {
        if (node.pending_to != null) return null;
    }
    if (try comp.findReadyTransition(fsm_id, ctx)) |transition| {
        if (runtime) |node| node.dirty_reasons = 0;
        return transitionNotify(entity_id, transition);
    }
    if (runtime) |node| node.dirty_reasons = 0;

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
    return Blackboard.getInitialFsm(comp, arena, assets);
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return ConfigLoader.getCommonFsm(assets);
}

fn findReadyTransition(comp: *Component, fsm_id: i32, ctx: EvalContext) !?Transition {
    return TransitionEngine.findReadyTransition(comp, fsm_id, ctx);
}

fn canDiscardDissolveCombineSignal(comp: *const Component) bool {
    if (!comp.dissolve_combine_signal or comp.lifecycle_effects_pending or comp.lifecycle_effects.items.len != 0) return false;
    for (comp.runtime_nodes) |runtime| {
        if (runtime.pending_to != null) return false;
    }
    return true;
}
