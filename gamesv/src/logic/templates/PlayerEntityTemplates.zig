const Scene = @import("../Scene.zig");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Entity = Scene.Entity;
const std = @import("std");
const Allocator = std.mem.Allocator;
const pb = @import("proto").pb;
const incr = @import("../../fs/incr.zig");

pub fn createPlayerSceneEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
) !Entity {
    const followers = try alloc.gpa.dupe(i32, &[_]i32{ 0, 1, 2, 3, 4, 5 });
    const entity = try scene.spawn(alloc.gpa, fs, .{
        Entity.FollowerComponent{ .list = followers },
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(390077025, alloc.arena),
            alloc.gpa,
        ),
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .player_entity,
            .config_type = .template,
            .config_id = 14750001,
        },
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = [_]f32{
                -10000.0,
                -10000.0,
                -10000.0,
            },
            .rotation = [_]f32{ 0.0, 0.0, 0.0 },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.VisibleMarker{},
        Entity.ActorVisibleMarker{},
    });

    return entity;
}

pub fn createSceneBattleEntity(
    fs: *FileSystem,
    scene: *Scene,
    alloc: mem.Alloc,
    player_id: i32,
    assets: *const Assets,
) !Entity {
    const entity = try scene.spawn(alloc.gpa, fs, .{
        try Entity.AttributeComponent.create(
            try assets.tables.getProps(390077025, alloc.arena),
            alloc.gpa,
        ),
        Entity.ConfigComponent{
            .camp = 0,
            .state = .default,
            .entity_type = .scene_entity,
            .config_type = .template,
            .config_id = 14000169,
        },
        Entity.FightBuffComponent{},
        Entity.PositionComponent{
            .location = [_]f32{
                -10000.0,
                -10000.0,
                -10000.0,
            },
            .rotation = [_]f32{ 0.0, 0.0, 0.0 },
        },
        Entity.PlayerIDComponent{ .id = player_id },
        Entity.ActorVisibleMarker{},
    });

    return entity;
}
