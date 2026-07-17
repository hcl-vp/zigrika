const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const AttributeComponent = @import("../component/entity/AttributeComponent.zig");
const FightBuffComponent = @import("../component/entity/FightBuffComponent.zig");
const LogicStateComponent = @import("../component/entity/LogicStateComponent.zig");
const TagComponent = @import("../component/entity/TagComponent.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

pub const max_state_depth = 32;

pub const NodeEntry = struct {
    key: i32,
    value: AiStateMachineConfig.StateMachineNode,
};

pub const OverrideEntry = struct {
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

    pub fn active(node: *const FsmNode) []const i32 {
        return node.active_path[0..node.active_len];
    }

    pub fn pending(node: *const FsmNode) []const i32 {
        return node.pending_path[0..node.pending_len];
    }

    pub fn previous(node: *const FsmNode) []const i32 {
        return node.previous_path[0..node.previous_len];
    }

    pub fn leaf(node: *const FsmNode) ?i32 {
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

pub const TagCount = struct {
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

pub const ClientConditionLookup = enum {
    valid,
    transition_not_found,
    condition_not_found,
    condition_not_client,
};

pub const ResolvedStates = struct {
    from: i32,
    to: i32,
};

pub const StateMachineConfigs = struct {
    entity: AiStateMachineConfig.StateMachineJsonData,
    common: AiStateMachineConfig.StateMachineJsonData,
};
