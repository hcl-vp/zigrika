const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const PlayerSceneComponent = @import("../../logic/component/player/PlayerSceneComponent.zig");
const LevelEntityConfig = @import("../../data/tables/LevelEntityConfig.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const Assets = @import("../../data/Assets.zig");

const log = std.log.scoped(.teleport);

pub fn onTeleportDataRequest(
    txn: *Transaction(pb.TeleportDataRequest),
    assets: *const Assets,
    alloc: mem.Alloc,
) !void {
    var ids: std.ArrayList(i32) = .empty;
    for (assets.tables.teleporter.items) |tp| {
        try ids.append(alloc.arena, tp.Id);
    }
    txn.respond(.{ .ErrorCode = .Success, .Ids = ids });
}

pub fn onTeleportTransferRequest(
    txn: *Transaction(pb.TeleportTransferRequest),
    fs: *FileSystem,
    scene: *Scene,
    assets: *const Assets,
    events: *EventQueue,
    alloc: mem.Alloc,
    scene_comp: *PlayerSceneComponent,
) !void {
    const teleporter = assets.tables.teleporter.getDataById(txn.message.Id) orelse {
        txn.respond(.{ .ErrorCode = .ErrTeleportIdNotExist });
        return;
    };

    const entity_cfg: *const LevelEntityConfig = for (assets.tables.level_entity_config.items) |*cfg| {
        if (cfg.EntityId == teleporter.TeleportEntityConfigId and cfg.MapId == teleporter.MapId)
            break cfg;
    } else {
        txn.respond(.{ .ErrorCode = .ErrTeleportCreatureIdNotExist });
        return;
    };

    const raw = entity_cfg.Transform[0];
    const scale = entity_cfg.Transform[2];

    const x = raw.X / scale.X;
    const y = raw.Y / scale.Y;
    const z = raw.Z / scale.Z;

    if (scene_comp.last_scene_info.instance_id == teleporter.MapId) {
        try txn.conn.push(pb.TeleportNotify{
            .MapId = teleporter.MapId,
            .Pos = .{ .X = x, .Y = y, .Z = z },
        });
    } else {
        try txn.conn.push(pb.LeaveSceneNotify{
            .PlayerId = scene_comp.player_id,
            .SceneId = "",
            .TransitionOption = .{},
        });
        scene_comp.last_scene_info.instance_id = teleporter.MapId;
        try scene.saveLastScene(scene_comp, fs, alloc.gpa);
        try events.enqueue(.initial_scene_join, .{ .location = .{ x, y, z } });
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .MapId = teleporter.MapId,
        .PosX = x,
        .PosY = y,
        .PosZ = z,
    });
}
