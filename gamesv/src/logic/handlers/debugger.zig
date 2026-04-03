const std = @import("std");
const EventQueue = @import("../EventQueue.zig");
const Scene = @import("../Scene.zig");
const Entity = Scene.Entity;

pub fn logEntityMovement(
    event: EventQueue.Dequeue(.entity_movement),
    query: Scene.Query(&.{*Entity.PositionComponent}),
) !void {
    const log = std.log.scoped(.entity_movement);

    if (query.byEntityHandle(event.data.entity)) |item| {
        const comp = item[0];
        log.debug(
            "entity with id {d} moved to ({any}, {any})",
            .{ event.data.entity.net_id, comp.location, comp.rotation },
        );
    }
}
