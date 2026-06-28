const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const Scene = @import("../../logic/Scene.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PositionComponent = @import("../../logic/component/entity/PositionComponent.zig");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");

pub fn onSceneTraceRequest(txn: *Transaction(pb.SceneTraceRequest)) !void {
    const log = std.log.scoped(.scene_trace);
    log.debug("trace id: {d}", .{txn.message.SceneTraceId});

    txn.respond(.{});
}

pub fn onUpdateSceneDateRequest(txn: *Transaction(pb.UpdateSceneDateRequest)) !void {
    txn.respond(.{});
}

pub fn onEntityActiveRequest(
    txn: *Transaction(pb.EntityActiveRequest),
    entities: Scene.Query(&.{Scene.Entity}),
    scene: *Scene,
    alloc: mem.Alloc,
    assets: *const Assets,
) !void {
    const log = std.log.scoped(.entity_active);
    log.debug("request id: {d}", .{txn.message.EntityId});

    const entity = entities.byNetId(txn.message.EntityId) orelse return error.EntityNotFound;
    const scene_entity: Scene.Entity = entity[0];

    const entity_pb = try scene.entities.get(scene_entity.index).entityToProto(scene_entity.net_id, alloc, assets);

    txn.respond(.{
        .IsVisible = entity_pb.IsVisible,
        .Rot = entity_pb.Rot,
        .Pos = entity_pb.Pos,
        .ComponentPbs = entity_pb.ComponentPbs,
    });
}

pub fn onPlayerMotionRequest(txn: *Transaction(pb.PlayerMotionRequest)) !void {
    txn.respond(.{});
}

pub fn onEntityPositionRequest(txn: *Transaction(pb.EntityPositionRequest)) !void {
    txn.respond(.{ .Pos = .{
        .X = -143200,
        .Y = 63380,
        .Z = 7610,
    } });
}

pub fn onSceneLoadingFinishRequest(txn: *Transaction(pb.SceneLoadingFinishRequest)) !void {
    txn.respond(.{});
}

fn currentRolePosition(
    scene: *Scene,
    controlled_roles: Scene.Query(&.{ Scene.Entity, *Scene.Entity.ConfigComponent, *Scene.Entity.PositionComponent, *Scene.Entity.DirectControlMarker }),
) ?*Scene.Entity.PositionComponent {
    const cur_role = scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)].cur_role;
    var it = controlled_roles.iterator;
    while (it.next()) |comps| {
        const config = comps[1];
        if (config.entity_type == .player and config.config_type == .character and config.config_id == cur_role) {
            return comps[2];
        }
    }
    return null;
}

pub fn onVehicleManipulateRequest(
    txn: *Transaction(pb.VehicleManipulateRequest),
    scene: *Scene,
    alloc: mem.Alloc,
    fs: *FileSystem,
    vehicles: Scene.Query(&.{ Scene.Entity, *Scene.Entity.PositionComponent, *Scene.Entity.VehicleComponent }),
    controlled_roles: Scene.Query(&.{ Scene.Entity, *Scene.Entity.ConfigComponent, *Scene.Entity.PositionComponent, *Scene.Entity.DirectControlMarker }),
) !void {
    const vehicle, const vehicle_position, const vehicle_comp = vehicles.byNetId(txn.message.EntityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrVehicleEntityNotExist });
        return;
    };

    vehicle_comp.occupied = txn.message.IsEntering;
    if (txn.message.IsEntering) {
        if (currentRolePosition(scene, controlled_roles)) |role_position| {
            vehicle_position.location = role_position.location;
            vehicle_position.rotation = role_position.rotation;
        }
    }

    try scene.saveComponents(fs, alloc.gpa, vehicle, &.{ Scene.Entity.PositionComponent, Scene.Entity.VehicleComponent });
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn VehicleFinishRequest(txn: *Transaction(pb.VehicleFinishRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onEntityEnterVehicleRequest(
    txn: *Transaction(pb.EntityEnterVehicleRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    vehicles: Scene.Query(&.{ Scene.Entity, *Scene.Entity.VehicleComponent }),
) !void {
    const vehicle, const vehicle_comp = vehicles.byNetId(txn.message.VehicleCreatureId) orelse {
        txn.respond(.{ .ErrorCode = .ErrVehicleEntityNotExist });
        return;
    };

    vehicle_comp.occupied = txn.message.IsEntering;
    try scene.saveComponents(fs, alloc.gpa, vehicle, &.{Scene.Entity.VehicleComponent});
    txn.respond(.{ .ErrorCode = .Success });
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
