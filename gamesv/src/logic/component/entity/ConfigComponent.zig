camp: i32,
config_id: i32,
config_type: ConfigType,
entity_type: EntityType,
state: EntityState,

pub const EntityType = enum(i32) {
    player = 0,
    npc = 1,
    monster = 2,
    scene_item = 5,
    custom = 6,
    vision = 7,
    animal = 8,
    client_only = 9,
    vehicle = 10,
    player_entity = 11,
    scene_entity = 12,
};

pub const EntityState = enum(i32) {
    default = 0,
    sleep = 1,
    born = 2,
    other = 3,
};

pub const ConfigType = enum(i32) {
    old_entity = 0,
    level = 1,
    global = 2,
    character = 3,
    template = 4,
    prefab = 5,
};
