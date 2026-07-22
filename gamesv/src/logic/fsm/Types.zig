const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const AttributeComponent = @import("../component/entity/AttributeComponent.zig");
const FightBuffComponent = @import("../component/entity/FightBuffComponent.zig");
const LogicStateComponent = @import("../component/entity/LogicStateComponent.zig");
const TagComponent = @import("../component/entity/TagComponent.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

pub const max_state_depth = 32;

pub const WakeMask = u16;

pub const WakeReason = struct {
    pub const initial: WakeMask = 1 << 0;
    pub const state: WakeMask = 1 << 1;
    pub const timer: WakeMask = 1 << 2;
    pub const tag: WakeMask = 1 << 3;
    pub const attribute: WakeMask = 1 << 4;
    pub const buff: WakeMask = 1 << 5;
    pub const hate: WakeMask = 1 << 6;
    pub const position: WakeMask = 1 << 7;
    pub const part: WakeMask = 1 << 8;
    pub const dissolve: WakeMask = 1 << 9;
    pub const client_pass: WakeMask = 1 << 10;
    pub const event: WakeMask = 1 << 11;
    pub const all: WakeMask = std.math.maxInt(WakeMask);
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
    wake_dependencies: WakeMask = 0,
    dirty_reasons: WakeMask = 0,
    next_timer_due_ms: ?i64 = null,

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
    now_ms: i64,
};

pub const PartState = struct {
    index: i32,
    name: []const u8,
    life: f32,
    max_life: f32,
    activated: bool,
    birth_activated: bool,
    part_tag_id: i32,
    active_tag_id: i32,
    combine_socket: []const u8 = "",
};

pub const Transition = struct {
    fsm_id: i32,
    from: i32,
    to: i32,
};

pub const LifecycleEffect = union(enum) {
    add_buff: i64,
    remove_buff: i64,
    cue_paralysis,
    reset_status,
    set_rage_full,
    set_instance_state: i32,
    activate_part: PartActivation,
    reset_part: PartReset,
};

pub const PartActivation = struct {
    name: []const u8,
    activate: bool,
};

pub const PartReset = struct {
    name: []const u8,
    reset_activate: bool,
    reset_life: bool,
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
    condition_context_invalid,
};

pub const ClientConditionRequirement = enum {
    none,
    task,
    montage,
    group_patrol,
    group_perform,
};

pub const ClientConditionLookup = union(enum) {
    valid: ClientConditionRequirement,
    transition_not_found,
    condition_not_found,
    condition_not_client,
    condition_invalid,
};

pub const BehaviorValidation = enum {
    valid,
    machine_not_found,
    invalid_state,
    inactive_state,
    invalid_behavior,
};

pub const ResolvedStates = struct {
    from: i32,
    to: i32,
};
