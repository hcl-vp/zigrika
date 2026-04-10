const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");

player_entity_id: i64 = 0,
battle_scene_entity_id: i64 = 0,

pub fn init(player_entity_id: i64, battle_scene_entity_id: i64) Component {
    return .{
        .player_entity_id = if (player_entity_id > 0) player_entity_id else 0,
        .battle_scene_entity_id = if (battle_scene_entity_id > 0) battle_scene_entity_id else 0,
    };
}

pub fn toProto(comp: Component, alloc: mem.Alloc) !pb.PlayerSceneComponentPb {
    var entity_ids = std.ArrayList(i64).empty;
    try entity_ids.append(alloc.arena, comp.player_entity_id);
    try entity_ids.append(alloc.arena, comp.battle_scene_entity_id);
    try entity_ids.append(alloc.arena, comp.player_entity_id);
    try entity_ids.append(alloc.arena, comp.battle_scene_entity_id);
    return .{
        .EntityIds = entity_ids,
    };
}
