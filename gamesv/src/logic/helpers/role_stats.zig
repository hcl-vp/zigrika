const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const RoleInfo = @import("../../fs/RoleInfo.zig");
const PlayerRoleComponent = @import("../component/player/PlayerRoleComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const AttributeComponent = @import("../component/entity/AttributeComponent.zig");
const RoleEquipment = @import("role_equipment.zig");

pub const Snapshot = RoleEquipment.Snapshot;
pub const DisplayProps = RoleEquipment.DisplayProps;

pub fn buildSnapshot(
    gpa: std.mem.Allocator,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    role_id: i32,
) !Snapshot {
    const equipment = try role_comp.rebuildEquipment(gpa, assets, role_id, weapon_comp, echo_comp);
    return equipment.snapshot(gpa);
}

pub fn buildPhantomDisplayProps(
    gpa: std.mem.Allocator,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    role_id: i32,
) !DisplayProps {
    const equipment = try role_comp.rebuildEquipment(gpa, assets, role_id, weapon_comp, echo_comp);
    return equipment.phantomDisplayProps(gpa);
}

pub fn refreshAttributeComponent(
    gpa: std.mem.Allocator,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    role_id: i32,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    attr_comp: *AttributeComponent,
) !void {
    const snapshot = try buildSnapshot(gpa, assets, role_comp, weapon_comp, echo_comp, role_id);
    defer snapshot.deinit(gpa);

    for (snapshot.base_props, 0..) |base, index| {
        if (index >= attr_comp.attributes.len) break;
        const increment = if (index < snapshot.add_props.len) snapshot.add_props[index] else 0;
        attr_comp.attributes[index] = .{
            .base = base,
            .increment = increment,
            .current = base + increment,
        };
    }
}

pub fn toClientRoleInfo(
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    role_id: i32,
    role_info: *const RoleInfo,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !pb.RoleInfo {
    const snapshot = try buildSnapshot(gpa, assets, role_comp, weapon_comp, echo_comp, role_id);
    defer snapshot.deinit(gpa);

    var proto: pb.RoleInfo = .{
        .RoleId = role_id,
        .Name = "",
        .Level = role_info.level,
        .Exp = role_info.exp,
        .Breakthrough = role_info.breakthrough,
        .Star = role_info.star,
        .Favor = role_info.favor,
        .CurModel = role_info.cur_model,
        .CreateTime = role_info.create_time,
        .ResonantChainGroupIndex = role_info.resonant_chain_group_index,
        .SkinId = role_info.role_skin_id,
        .EnableSelfBgm = role_info.enable_self_bgm,
    };

    try proto.Skills.ensureTotalCapacity(arena, role_info.skills.len);
    for (role_info.skills) |entry| proto.Skills.appendAssumeCapacity(.{ .Key = entry[0], .Value = entry[1] });

    try proto.Phantom.ensureTotalCapacity(arena, role_info.phantom.len);
    for (role_info.phantom) |entry| proto.Phantom.appendAssumeCapacity(.{ .Key = entry[0], .Value = entry[1] });

    try proto.BaseProp.ensureTotalCapacity(arena, snapshot.base_props.len);
    for (snapshot.base_props, 0..) |value, key| proto.BaseProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });

    try proto.AddProp.ensureTotalCapacity(arena, snapshot.add_props.len);
    for (snapshot.add_props, 0..) |value, key| proto.AddProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });

    try proto.Reson.ensureTotalCapacity(arena, role_info.reson.len);
    for (role_info.reson) |entry| proto.Reson.appendAssumeCapacity(.{ .ResonId = entry.id, .IsOpen = entry.open, .Increase = entry.increase });

    try proto.Models.appendSlice(arena, role_info.models);

    try proto.SkillNodeState.ensureTotalCapacity(arena, role_info.skill_node_state.len);
    for (role_info.skill_node_state) |node| {
        proto.SkillNodeState.appendAssumeCapacity(.{ .SkillNodeId = node.node_id, .IsActive = node.active, .SkillId = node.skill_id });
    }

    return proto;
}
