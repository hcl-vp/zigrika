const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const Scene = @import("../../logic/Scene.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PositionComponent = @import("../../logic/component/entity/PositionComponent.zig");

pub fn onSceneTraceRequest(txn: *Transaction(pb.SceneTraceRequest)) !void {
    const log = std.log.scoped(.scene_trace);
    log.debug("trace id: {d}", .{txn.message.SceneTraceId});

    try txn.respond(.{});
}

pub fn onUpdateSceneDateRequest(txn: *Transaction(pb.UpdateSceneDateRequest)) !void {
    try txn.respond(.{});
}

pub fn onEntityActiveRequest(txn: *Transaction(pb.EntityActiveRequest), entities: Scene.Query(&.{Scene.Entity}), scene: *Scene, alloc: mem.Alloc) !void {
    const log = std.log.scoped(.entity_active);
    log.debug("request id: {d}", .{txn.message.EntityId});

    const entity = entities.byNetId(txn.message.EntityId) orelse return error.EntityNotFound;
    const scene_entity: Scene.Entity = entity[0];

    const entity_pb = try scene.entities.get(scene_entity.index).entityToProto(scene_entity.net_id, alloc);

    try txn.respond(.{
        .IsVisible = entity_pb.IsVisible,
        .Rot = entity_pb.Rot,
        .Pos = entity_pb.Pos,
        .ComponentPbs = entity_pb.ComponentPbs,
    });
}

pub fn onPlayerMotionRequest(txn: *Transaction(pb.PlayerMotionRequest)) !void {
    try txn.respond(.{});
}

pub fn onEntityPositionRequest(txn: *Transaction(pb.EntityPositionRequest)) !void {
    try txn.respond(.{ .Pos = .{
        .X = -143200,
        .Y = 63380,
        .Z = 7610,
    } });
}

pub fn onSceneLoadingFinishRequest(txn: *Transaction(pb.SceneLoadingFinishRequest)) !void {
    try txn.respond(.{});
}

pub fn onMovePackagePush(
    txn: *Transaction(pb.MovePackagePush),
    movable_entities: Scene.Query(&.{ Scene.Entity, *Scene.Entity.PositionComponent }),
    controlled_entities: Scene.Query(&.{ Scene.Entity, *Scene.Entity.DirectControlMarker }),
    scene: *Scene,
    sender: PlayerID,
    events: *EventQueue,
) !void {
    const log = std.log.scoped(.client_movement);

    for (txn.message.MovingEntities.items) |data| {
        const entity, const position_comp = movable_entities.byNetId(data.EntityId) orelse {
            log.warn(
                "entity with id {d} is not movable (originator: {d}, sender: {d})",
                .{ data.EntityId, data.Originator, sender.id },
            );
            continue;
        };
        const controlled_by_player = controlled_entities.byNetId(data.EntityId) != null;

        const last_move_replay = if (data.MoveInfos.items.len > 0) data.MoveInfos.items[data.MoveInfos.items.len - 1] else {
            log.warn(
                "received empty movement data for entity with id {d} (originator: {d}, sender: {d})",
                .{ data.EntityId, data.Originator, sender.id },
            );
            continue;
        };

        if (last_move_replay.Location) |location| {
            if (controlled_by_player) {
                for (scene.instance.players) |*player| {
                    if (player.id == sender.id) {
                        player.location = .{ location.X, location.Y, location.Z };
                    }
                }
            }
            position_comp.location = .{ location.X, location.Y, location.Z };

            if (last_move_replay.Rotation) |rotation| {
                if (controlled_by_player) {
                    for (scene.instance.players) |*player| {
                        if (player.id == sender.id) {
                            player.rotation = .{ rotation.Roll, rotation.Pitch, rotation.Yaw };
                        }
                    }
                }
                position_comp.rotation = .{ rotation.Roll, rotation.Pitch, rotation.Yaw };
            }

            try events.enqueue(.entity_movement, .{ .entity = entity });
        }
    }
}
