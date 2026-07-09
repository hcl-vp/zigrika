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
voice_language: i32 = 0,

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
        if (entry.role_skin_id == role_skin_id and entry.ornament_id != 0) return entry.ornament_id;
    }
    return 0;
}

pub fn hasOrnament(info: RoleInfo, role_skin_id: i32, ornament_id: i32) bool {
    if (ornament_id == 0) return false;
    for (info.ornaments) |entry| {
        if (entry.role_skin_id == role_skin_id and entry.ornament_id == ornament_id) return true;
    }
    return false;
}

pub fn dressOrnament(info: *RoleInfo, gpa: Allocator, assets: *const Assets, role_skin_id: i32, ornament_id: i32) !bool {
    if (ornament_id == 0 or info.hasOrnament(role_skin_id, ornament_id)) return false;

    const ornament = assets.tables.ornament.getDataById(ornament_id) orelse return error.OrnamentNotFound;
    var ornaments: std.ArrayListUnmanaged(OrnamentEquip) = .empty;
    errdefer ornaments.deinit(gpa);

    try ornaments.ensureTotalCapacity(gpa, info.ornaments.len + 1);
    for (info.ornaments) |entry| {
        if (entry.ornament_id == 0) {
            continue;
        }

        const conflicts = if (entry.role_skin_id == role_skin_id and ornament.OrGroupId != 0)
            if (assets.tables.ornament.getDataById(entry.ornament_id)) |equipped|
                equipped.OrGroupId == ornament.OrGroupId
            else
                false
        else
            false;

        if (conflicts) {
            continue;
        }

        ornaments.appendAssumeCapacity(entry);
    }
    ornaments.appendAssumeCapacity(.{ .role_skin_id = role_skin_id, .ornament_id = ornament_id });

    const new_ornaments = try ornaments.toOwnedSlice(gpa);
    if (info.ornaments.len != 0) gpa.free(info.ornaments);
    info.ornaments = new_ornaments;
    return true;
}

pub fn undressOrnament(info: *RoleInfo, gpa: Allocator, role_skin_id: i32, ornament_id: i32) !bool {
    if (ornament_id == 0) return false;

    var ornaments: std.ArrayListUnmanaged(OrnamentEquip) = .empty;
    errdefer ornaments.deinit(gpa);
    var changed = false;

    try ornaments.ensureTotalCapacity(gpa, info.ornaments.len);
    for (info.ornaments) |entry| {
        if (entry.ornament_id == 0 or (entry.role_skin_id == role_skin_id and entry.ornament_id == ornament_id)) {
            changed = true;
            continue;
        }

        ornaments.appendAssumeCapacity(entry);
    }

    if (!changed) {
        ornaments.deinit(gpa);
        return false;
    }
    const new_ornaments = try ornaments.toOwnedSlice(gpa);
    if (info.ornaments.len != 0) gpa.free(info.ornaments);
    info.ornaments = new_ornaments;
    return true;
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
        try map.put(gpa, info.Id, try createDefault(gpa, assets, info.Id));
    }
}

pub fn addDefaultSkills(info: *RoleInfo, gpa: Allocator, assets: *const Assets, id: i32) !void {
    const role_config = assets.tables.role_info.getDataById(id) orelse return error.RoleNotFound;
    const skill_tree_group_id = role_config.SkillTreeGroupId;

    var nodes: std.ArrayList(SkillNode) = .empty;
    errdefer nodes.deinit(gpa);

    var skills: std.ArrayList(struct { i32, i32 }) = .empty;
    errdefer skills.deinit(gpa);

    for (assets.tables.skill_tree.items) |node| {
        if (node.NodeGroup != skill_tree_group_id) continue;
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

pub fn createDefault(gpa: Allocator, assets: *const Assets, id: i32) !RoleInfo {
    const info = assets.tables.role_info.getDataById(id) orelse return error.RoleNotFound;
    var role: RoleInfo = .{
        .level = info.MaxLevel,
        .breakthrough = 6,
        .role_skin_id = info.SkinId,
    };
    errdefer role.deinit(gpa);

    try role.resetProperties(gpa, assets, id);
    try role.addDefaultSkills(gpa, assets, id);
    return role;
}

pub fn deinit(info: RoleInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
