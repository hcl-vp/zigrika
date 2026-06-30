const std = @import("std");
const pb = @import("proto").pb;
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const mem = @import("../../mem.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const RoleStats = @import("../../logic/helpers/role_stats.zig");
const Attributes = @import("../../logic/helpers/attributes.zig");

pub fn refreshRole(
    txn: anytype,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    query: anytype,
    role_id: i32,
) !void {
    var it = query.iterator;
    while (it.next()) |item| {
        const entity, const config, const attr_comp = item;
        if (config.config_id != role_id) continue;

        try RoleStats.refreshAttributeComponent(alloc.gpa, assets, role_comp, role_id, weapon_comp, echo_comp, attr_comp);
        try scene.saveComponents(fs, alloc.gpa, entity, &.{Scene.Entity.AttributeComponent});
        try pushAttributeChange(txn, alloc, entity.net_id, attr_comp);
        break;
    }

    try pushRoleInfoNotify(txn, alloc, assets, role_comp, weapon_comp, echo_comp, role_id);
}

pub fn pushRoleInfoNotify(
    txn: anytype,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    role_id: i32,
) !void {
    try pushRoleInfoNotifyForRoles(txn, alloc, assets, role_comp, weapon_comp, echo_comp, &.{role_id});
}

pub fn pushRoleInfoNotifyForRoles(
    txn: anytype,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    role_ids: []const i32,
) !void {
    var role_list: std.ArrayList(pb.RoleInfo) = .empty;
    try role_list.ensureTotalCapacity(alloc.arena, role_ids.len);

    for (role_ids) |role_id| {
        const role_info = role_comp.role_map.getPtr(role_id) orelse continue;
        role_list.appendAssumeCapacity(try RoleStats.toClientRoleInfo(
            alloc.gpa,
            alloc.arena,
            assets,
            role_comp,
            role_id,
            role_info,
            weapon_comp,
            echo_comp,
        ));
    }

    if (role_list.items.len != 0) {
        try txn.conn.push(pb.PbGetRoleListNotify{ .RoleList = role_list }, alloc.arena);
    }
}

fn pushAttributeChange(
    txn: anytype,
    alloc: mem.Alloc,
    entity_id: i64,
    attr_comp: *Scene.Entity.AttributeComponent,
) !void {
    var attrs: std.ArrayList(pb.GameplayAttributeData) = .empty;
    inline for (comptime std.meta.fields(pb.EAttributeType), 0..) |field, index| {
        if (index >= attr_comp.attributes.len) break;
        try attrs.append(alloc.arena, Attributes.gameplayAttributeData(
            @field(pb.EAttributeType, field.name),
            attr_comp.attributes[index],
        ));
    }

    try txn.conn.push(pb.CombatReceivePackNotify{ .Data = blk: {
        var data: std.ArrayList(pb.CombatReceiveData) = .empty;
        try data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entity_id },
                .Message = .{ .AttributeChangedNotify = .{ .Attributes = attrs } },
            },
        } });
        break :blk data;
    } }, alloc.arena);
}
