const RoleInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../data/Assets.zig");

const Allocator = std.mem.Allocator;
const ArrayIntInt = []struct { i32, i32 };

pub const default: RoleInfo = .{};
pub const data_dir = "role";

level: i32 = 1,
exp: i32 = 0,
breakthrough: i32 = 0,
skills: ArrayIntInt = &.{},
phantom: ArrayIntInt = &.{},
weapon: i32 = 0,
star: i32 = 0,
favor: i32 = 5,
reson: []Reson = &.{},
cur_model: i32 = 0,
models: []i32 = &.{},
base_prop: []i32 = &.{}, // indexed by EAttributeType
add_prop: []i32 = &.{},
create_time: u32 = 0,
skill_node_state: []SkillNode = &.{},
resonant_chain_group_index: i32 = 0,
role_skin_id: i32 = 0,
paragliding_skin_id: i32 = 0,
soar_skin_id: i32 = 0,
weapon_skin_id: i32 = 0,
ornaments: []OrnamentEquip = &.{},
calabash_skin_id: i32 = 0, // we are keeping it in roleinfo just incase kuro decides to do more than just rover!
enable_self_bgm: bool = false,

pub const Reson = struct {
    id: i32,
    open: bool,
    increase: i32,
};

pub const SkillNode = struct {
    node_id: i32,
    active: bool,
    skill_id: i32,
};

pub const OrnamentEquip = struct {
    role_skin_id: i32,
    ornament_id: i32,
};

pub fn getOrnament(info: RoleInfo, role_skin_id: i32) i32 {
    for (info.ornaments) |entry| {
        if (entry.role_skin_id == role_skin_id) return entry.ornament_id;
    }
    return 0;
}

pub fn setOrnament(info: *RoleInfo, gpa: Allocator, role_skin_id: i32, ornament_id: i32) !void {
    for (info.ornaments) |*entry| {
        if (entry.role_skin_id == role_skin_id) {
            entry.ornament_id = ornament_id;
            return;
        }
    }

    const new_ornaments = try gpa.alloc(OrnamentEquip, info.ornaments.len + 1);
    @memcpy(new_ornaments[0..info.ornaments.len], info.ornaments);
    new_ornaments[info.ornaments.len] = .{
        .role_skin_id = role_skin_id,
        .ornament_id = ornament_id,
    };

    if (info.ornaments.len != 0) gpa.free(info.ornaments);
    info.ornaments = new_ornaments;
}

pub fn toProto(info: RoleInfo, arena: Allocator, id: i32) !pb.RoleInfo {
    var proto: pb.RoleInfo = .{
        .RoleId = id,
        .Name = "",
        .Level = info.level,
        .Exp = info.exp,
        .Breakthrough = info.breakthrough,
        .Skills = try arrayIntInt(info.skills, arena),
        .Phantom = try arrayIntInt(info.phantom, arena),
        .Star = info.star,
        .Favor = info.favor,
        .CurModel = info.cur_model,
        .BaseProp = try arrayIntIntByIndex(info.base_prop, arena),
        .AddProp = try arrayIntIntByIndex(info.add_prop, arena),
        .CreateTime = info.create_time,
        .ResonantChainGroupIndex = info.resonant_chain_group_index,
        .SkinId = info.role_skin_id,
        .EnableSelfBgm = info.enable_self_bgm,
    };

    try proto.Reson.ensureTotalCapacity(arena, info.reson.len);
    for (info.reson) |reson| {
        proto.Reson.appendAssumeCapacity(.{
            .ResonId = reson.id,
            .IsOpen = reson.open,
            .Increase = reson.increase,
        });
    }

    try proto.SkillNodeState.ensureTotalCapacity(arena, info.skill_node_state.len);
    for (info.skill_node_state) |node| {
        proto.SkillNodeState.appendAssumeCapacity(.{
            .SkillNodeId = node.node_id,
            .IsActive = node.active,
            .SkillId = node.skill_id,
        });
    }

    try proto.Models.appendSlice(arena, info.models);

    return proto;
}

fn arrayIntIntByIndex(data: []i32, arena: Allocator) !std.ArrayList(pb.ArrayIntInt) {
    var result: std.ArrayList(pb.ArrayIntInt) = .empty;
    try result.ensureTotalCapacity(arena, data.len);

    for (data, 0..) |value, key| {
        result.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });
    }

    return result;
}

fn arrayIntInt(data: ArrayIntInt, arena: Allocator) !std.ArrayList(pb.ArrayIntInt) {
    var result: std.ArrayList(pb.ArrayIntInt) = .empty;
    try result.ensureTotalCapacity(arena, data.len);

    for (data) |pair| {
        const key, const value = pair;
        result.appendAssumeCapacity(.{ .Key = key, .Value = value });
    }

    return result;
}

pub fn resetProperties(info: *RoleInfo, gpa: Allocator, assets: *const Assets, id: i32) !void {
    const base_property = assets.tables.base_property.getDataById(id) orelse return;

    const props = try gpa.alloc(i32, @intFromEnum(pb.EAttributeType.MAX));
    @memset(props, 0);

    inline for (comptime std.meta.fields(Assets.DataTables.BaseProperty)) |field| {
        if (!@hasField(pb.EAttributeType, field.name)) continue;
        const attr_type = @field(pb.EAttributeType, field.name);

        props[@intFromEnum(attr_type)] = @field(base_property, field.name);
    }

    gpa.free(info.base_prop);
    info.base_prop = props;
    info.scaleProperties(assets);
}

pub fn scaleProperties(info: *RoleInfo, assets: *const Assets) void {
    if (info.level > 1) if (assets.tables.getRolePropertyGrowth(info.level, info.breakthrough)) |rp_growth| {
        info.base_prop[@intFromEnum(pb.EAttributeType.Lv)] = info.level;
        scaleProperty(&info.base_prop[@intFromEnum(pb.EAttributeType.LifeMax)], rp_growth.LifeMaxRatio);
        scaleProperty(&info.base_prop[@intFromEnum(pb.EAttributeType.Life)], rp_growth.LifeMaxRatio);
        scaleProperty(&info.base_prop[@intFromEnum(pb.EAttributeType.Atk)], rp_growth.AtkRatio);
        scaleProperty(&info.base_prop[@intFromEnum(pb.EAttributeType.Def)], rp_growth.DefRatio);
    };
}

fn scaleProperty(value: *i32, ratio: i32) void {
    const float = @trunc(@as(f32, @floatFromInt(value.*)) * (@as(f32, @floatFromInt(ratio)) / 10000));
    value.* = @trunc(float);
}

pub fn addDefaults(gpa: Allocator, assets: *const Assets, map: *std.array_hash_map.Auto(i32, RoleInfo)) !void {
    for (assets.tables.role_info.items) |info| {
        if (info.Id < 1000 or info.Id > 1999) continue;
        var role: RoleInfo = .{
            .level = info.MaxLevel,
            .breakthrough = 6,
            .role_skin_id = info.SkinId,
        };

        try role.resetProperties(gpa, assets, info.Id);
        try role.addDefaultSkills(gpa, assets, info.Id);
        try map.put(gpa, info.Id, role);
    }
}

pub fn addDefaultSkills(info: *RoleInfo, gpa: Allocator, assets: *const Assets, id: i32) !void {
    var nodes: std.ArrayList(SkillNode) = .empty;
    errdefer nodes.deinit(gpa);

    var skills: std.ArrayList(struct { i32, i32 }) = .empty;
    errdefer skills.deinit(gpa);

    for (assets.tables.skill_tree.items) |node| {
        if (node.NodeGroup != id) continue;
        const active = node.Condition.len == 0 and node.UnLockCondition == 0;
        try nodes.append(gpa, .{
            .node_id = node.Id,
            .active = active,
            .skill_id = node.SkillId,
        });
        if (active and node.SkillId != 0) {
            try skills.append(gpa, .{ node.SkillId, 1 });
        }
    }

    info.skill_node_state = try nodes.toOwnedSlice(gpa);
    info.skills = try skills.toOwnedSlice(gpa);
}

pub fn deinit(info: RoleInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
