const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const EventQueue = @import("../EventQueue.zig");
const PlayerID = @import("../PlayerID.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerBasicComponent = @import("../component/player/PlayerBasicComponent.zig");

pub fn pushData(
    _: EventQueue.Dequeue(.push_data),
    conn: *Connection,
    alloc: mem.Alloc,
    player_id: PlayerID,
    basic_comp: *const PlayerBasicComponent,
) !void {
    var notify: pb.BasicInfoNotify = .{ .Id = player_id.id };

    const attrs = basic_comp.info.attributes.toProto();
    (try notify.Attributes.addManyAsArray(alloc.arena, attrs.len)).* = attrs;

    try conn.push(notify, alloc.arena);
}
