const Entity = @import("Scene.zig").Entity;
const std = @import("std");

// shitty solution for a shitty problem...
pub const PendingFlow = struct {
    inc_id: i32,
    namespace: []const u8,
    id: i32,
    state: i32,
};

pub const EnterGame = struct {};
pub const PushData = struct {};
pub const PushDataComplete = struct {};
pub const InitialSceneJoin = struct {
    location: ?[3]f32 = null,
    rotation: ?[3]f32 = null,
    pending_flow: ?PendingFlow = null,
};
pub const SceneSwitch = struct {
    pending_flow: ?PendingFlow = null,
};
pub const AfterSceneJoin = struct {
    pending_flow: ?PendingFlow = null,
};
pub const UpdateFormations = struct {};

pub const RoleInfoModified = struct {
    role_id: i32,
};

pub const WeaponInfoModified = struct {
    incr_id: i32,
};

pub const EntityMovement = struct {
    entity: Entity,
};

pub const BuffRemoval = struct {
    entity: Entity,
    handle_ids: []i32,
};

pub const BuffRemovalById = struct {
    entity: Entity,
    buff_id: i64,
};

pub const BuffAdditionEntry = struct {
    id: i64,
    stack_count: i32 = 0,
    is_active: bool,
    duration_seconds: ?f32 = null,
};

pub const BuffAddition = struct {
    target: Entity,
    instigator: Entity,
    buffs: []BuffAdditionEntry,
};

pub const BuffChange = struct { entity: Entity };

pub const BuffTimerTick = struct {
    now_ms: i64,
};

pub const FsmTimerTick = struct {
    now_ms: i64,
};

pub const FsmServerActionKind = union(enum) {
    cue_paralysis,
    reset_status,
    set_rage_full,
    instance_state: i32,
};

pub const FsmServerAction = struct {
    entity: Entity,
    kind: FsmServerActionKind,
};

pub const FsmLifecycleComplete = struct {
    entity: Entity,
    now_ms: i64,
    recheck: bool = true,
};

pub const LevelPlayTimerTick = struct {
    now_ms: i64,
};

pub const SceneCleanupTick = struct {
    now_ms: i64,
};

pub const DirtySaveTick = struct {
    now_ms: i64,
};

pub const GameplayTagChange = struct {
    entity: Entity,
    add_tag_ids: []i32,
    remove_tag_ids: []i32,
};

pub const ChatCommandResponse = struct { content: []const u8 };

pub const TickTime = struct {
    now_ms: i64,
};
