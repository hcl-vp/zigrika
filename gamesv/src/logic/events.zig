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
