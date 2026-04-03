const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const EventQueue = @import("../EventQueue.zig");
const Connection = @import("../../network/Connection.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");

pub fn ensureRoleAttributes(
    _: EventQueue.Dequeue(.enter_game),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |kv| {
        const id = kv.key_ptr.*;
        const role = kv.value_ptr;

        if (role.base_prop.len != @as(i32, @intFromEnum(pb.EAttributeType.MAX))) {
            // A new attribute type was introduced. Rebuild property table.
            try role.resetProperties(alloc.gpa, assets, id);
            try events.enqueue(.role_info_modified, .{ .role_id = id });
        }
    }
}

pub fn pushData(
    _: EventQueue.Dequeue(.push_data),
    conn: *Connection,
    alloc: mem.Alloc,
    role_comp: *PlayerRoleComponent,
) !void {
    var notify: pb.PbGetRoleListNotify = .default;

    try notify.RoleList.ensureTotalCapacity(alloc.arena, role_comp.role_map.count());
    var iterator = role_comp.role_map.iterator();

    while (iterator.next()) |role| {
        notify.RoleList.appendAssumeCapacity(try role.value_ptr.toProto(alloc.arena, role.key_ptr.*));
    }

    try conn.push(notify, alloc.arena);
}
