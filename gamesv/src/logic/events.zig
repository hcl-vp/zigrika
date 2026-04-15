const Entity = @import("Scene.zig").Entity;

pub const EnterGame = struct {};
pub const PushData = struct {};
pub const PushDataComplete = struct {};
pub const InitialSceneJoin = struct {};
pub const SceneSwitch = struct {};
pub const AfterSceneJoin = struct {};
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

pub const BuffAdditionEntry = struct {
    id: i64,
    stack_count: i32 = 0,
    is_active: bool,
};

pub const BuffAddition = struct {
    target: Entity,
    instigator: Entity,
    buffs: []BuffAdditionEntry,
};

pub const BuffChange = struct { entity: Entity };

pub const ChatCommandResponse = struct { content: []const u8 };
