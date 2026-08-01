const RoleEquipment = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const RoleInfo = @import("../../fs/RoleInfo.zig");
const PlayerWeaponComponent = @import("../component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../component/player/PlayerEchoComponent.zig");

const Allocator = std.mem.Allocator;

pub const SourceType = enum {
    weapon,
    echo,
    skill,
    chain,
    fetter,
};

pub const SourceKey = struct {
    source_type: SourceType,
    id: i64,
};

const DisplayMode = enum {
    hidden,
    base,
    add,
};

const Contribution = struct {
    attr_index: usize,
    is_ratio: bool,
    value: i32,
    ratio: f64,
    display_mode: DisplayMode,
};

pub const Snapshot = struct {
    base_props: []i32,
    add_props: []i32,

    pub fn deinit(props: Snapshot, gpa: Allocator) void {
        gpa.free(props.base_props);
        gpa.free(props.add_props);
    }
};

pub const DisplayProps = struct {
    base_props: std.AutoArrayHashMapUnmanaged(i32, i32),
    add_props: std.AutoArrayHashMapUnmanaged(i32, i32),

    pub fn deinit(display: *DisplayProps, gpa: Allocator) void {
        display.base_props.deinit(gpa);
        display.add_props.deinit(gpa);
    }
};

original_base_values: []i32 = &.{},
base_props: []i32 = &.{},
add_props: []i32 = &.{},
equipment_contributions: std.AutoArrayHashMapUnmanaged(SourceKey, []Contribution) = .empty,

pub fn build(
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    role_info: *const RoleInfo,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !RoleEquipment {
    const attr_count: usize = @intCast(@intFromEnum(pb.EAttributeType.MAX));
    var equipment: RoleEquipment = .{
        .original_base_values = try gpa.alloc(i32, attr_count),
        .base_props = try gpa.alloc(i32, attr_count),
        .add_props = try gpa.alloc(i32, attr_count),
    };
    errdefer equipment.deinit(gpa);

    @memset(equipment.original_base_values, 0);
    @memset(equipment.base_props, 0);
    @memset(equipment.add_props, 0);
    @memcpy(equipment.original_base_values[0..@min(role_info.base_prop.len, attr_count)], role_info.base_prop[0..@min(role_info.base_prop.len, attr_count)]);

    try equipment.addWeapon(gpa, assets, role_info, weapon_comp);
    try equipment.addSkills(gpa, assets, role_info);
    try equipment.addChains(gpa, assets, role_id, role_info);
    try equipment.addEchoes(gpa, assets, role_id, role_info, weapon_comp, echo_comp);
    equipment.recalculate();

    return equipment;
}

pub fn deinit(equipment: *RoleEquipment, gpa: Allocator) void {
    var iterator = equipment.equipment_contributions.iterator();
    while (iterator.next()) |entry| {
        gpa.free(entry.value_ptr.*);
    }
    equipment.equipment_contributions.deinit(gpa);
    gpa.free(equipment.original_base_values);
    gpa.free(equipment.base_props);
    gpa.free(equipment.add_props);
    equipment.* = .{};
}

pub fn snapshot(equipment: RoleEquipment, gpa: Allocator) !Snapshot {
    return .{
        .base_props = try gpa.dupe(i32, equipment.base_props),
        .add_props = try gpa.dupe(i32, equipment.add_props),
    };
}

pub fn phantomDisplayProps(equipment: RoleEquipment, gpa: Allocator) !DisplayProps {
    var display: DisplayProps = .{
        .base_props = .empty,
        .add_props = .empty,
    };
    errdefer display.deinit(gpa);

    for (equipment.equipment_contributions.values()) |contributions| {
        for (contributions) |contribution| {
            if (contribution.display_mode == .hidden) continue;
            const attr_id: i32 = @intCast(contribution.attr_index);
            const value = valueForBase(contribution, equipment.base_props);
            switch (contribution.display_mode) {
                .hidden => {},
                .base => if (contribution.is_ratio)
                    try addDisplayProp(gpa, &display.add_props, attr_id, value)
                else
                    try addDisplayProp(gpa, &display.base_props, attr_id, value),
                .add => try addDisplayProp(gpa, &display.add_props, attr_id, value),
            }
        }
    }

    return display;
}

pub fn buildRoleTags(
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    role_info: *const RoleInfo,
    weapon_comp: *PlayerWeaponComponent,
) !std.ArrayList([]const u8) {
    var tags: std.ArrayList([]const u8) = .empty;
    errdefer tags.deinit(gpa);

    const weapon = weapon_comp.weapon_map.get(role_info.weapon) orelse return tags;
    var buffs = try assets.tables.getRoleAutoBuffs(role_id, weapon, gpa);
    defer buffs.deinit(gpa);

    for (buffs.items) |entry| {
        if (!entry.is_active) continue;
        const buff = assets.tables.buff.getDataById(entry.id) orelse continue;
        for (buff.GrantedTags) |tag| {
            if (containsTag(tags.items, tag)) continue;
            try tags.append(gpa, tag);
        }
    }

    return tags;
}

fn addWeapon(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    role_info: *const RoleInfo,
    weapon_comp: *PlayerWeaponComponent,
) !void {
    const weapon = weapon_comp.weapon_map.get(role_info.weapon) orelse return;
    const config = assets.tables.weapon_conf.getDataById(weapon.id) orelse return;
    try equipment.addWeaponProp(gpa, assets, role_info.weapon, config.FirstPropId, config.FirstCurve, weapon.level, weapon.breach);
    try equipment.addWeaponProp(gpa, assets, role_info.weapon, config.SecondPropId, config.SecondCurve, weapon.level, weapon.breach);
    try equipment.addWeaponBaseAttributes(gpa, assets, role_info.weapon, weapon.id, weapon.reson_level);
}

fn addWeaponProp(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    weapon_incr_id: i32,
    prop: Assets.DataTables.PropValue,
    curve_id: i32,
    level: i32,
    breach: i32,
) !void {
    if (prop.Id == 0) return;
    const growth = weaponGrowth(assets, curve_id, level, breach) orelse return;
    const scaled = prop.Value * @as(f64, @floatFromInt(growth.CurveValue)) / 10000.0;
    try equipment.addContribution(gpa, .{ .source_type = .weapon, .id = weapon_incr_id }, contributionFromPropValue(prop.Id, scaled, prop.IsRatio, .hidden) orelse return);
}

fn addWeaponBaseAttributes(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    weapon_incr_id: i32,
    weapon_id: i32,
    reson_level: i32,
) !void {
    const config = assets.tables.weapon_base_attributes.getDataById(weapon_id) orelse return;
    const raw_value = config.Values.map.get(reson_level) orelse return;
    const value = if (config.IsRatio)
        @as(f64, @floatFromInt(raw_value)) / 10000.0
    else
        @as(f64, @floatFromInt(raw_value));

    for (config.Attributes) |attribute| {
        try equipment.addContribution(gpa, .{ .source_type = .weapon, .id = weapon_incr_id }, contributionFromPropValue(attribute, value, config.IsRatio, .hidden) orelse continue);
    }
}

fn addSkills(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    role_info: *const RoleInfo,
) !void {
    for (role_info.skill_node_state) |state| {
        if (!state.active) continue;
        const node = assets.tables.skill_tree.getDataById(state.node_id) orelse continue;
        for (node.Property) |prop| {
            try equipment.addContribution(gpa, .{ .source_type = .skill, .id = state.node_id }, contributionFromPropValue(prop.Id, prop.Value, prop.IsRatio, .hidden) orelse continue);
        }
    }
}

fn addChains(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    role_info: *const RoleInfo,
) !void {
    const role_config = assets.tables.role_info.getDataById(role_id) orelse return;
    for (assets.tables.resonant_chain.items) |chain| {
        if (chain.GroupId != role_config.ResonantChainGroupId) continue;
        if (chain.GroupIndex > role_info.resonant_chain_group_index) continue;
        for (chain.AddProp) |prop| {
            try equipment.addContribution(gpa, .{ .source_type = .chain, .id = chain.Id }, contributionFromPropValue(prop.Id, prop.Value, prop.IsRatio, .hidden) orelse continue);
        }
    }
}

fn addEchoes(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    role_info: *const RoleInfo,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const equip = echo_comp.roleEquip(role_id);
    for (equip.slots) |inc_id| {
        if (inc_id == 0) continue;
        const echo = echo_comp.echo_map.get(inc_id) orelse continue;
        for (echo.main_prop) |prop| {
            const config = assets.tables.phantom_main_prop_item.getDataById(prop.id) orelse continue;
            try equipment.addContribution(gpa, .{ .source_type = .echo, .id = inc_id }, contributionFromEchoProp(config.PropId, config.AddType, prop.value, .base) orelse continue);
        }
        for (echo.sub_prop) |prop| {
            const config = assets.tables.phantom_sub_property.getDataById(prop.id) orelse continue;
            try equipment.addContribution(gpa, .{ .source_type = .echo, .id = inc_id }, contributionFromEchoProp(config.PropId, config.AddType, prop.value, .base) orelse continue);
        }
    }

    var role_tags = try buildRoleTags(gpa, assets, role_id, role_info, weapon_comp);
    defer role_tags.deinit(gpa);
    const active_tags = try echo_comp.activeEchoTags(gpa, assets, role_id, role_tags.items);
    defer gpa.free(active_tags);

    var seen_buffs: std.AutoHashMapUnmanaged(i64, void) = .empty;
    defer seen_buffs.deinit(gpa);

    for (equip.slots, 0..) |inc_id, index| {
        if (inc_id == 0) continue;
        if (echoMarkerBuffEffect(assets, echo_comp, inc_id)) |buff_id| {
            try equipment.addBuffContribution(gpa, assets, .{ .source_type = .echo, .id = inc_id }, buff_id, active_tags, &seen_buffs);
        }
        if (index == 0) {
            for (echo_comp.mainEchoBuffEffects(assets, role_id)) |buff_id| {
                try equipment.addBuffContribution(gpa, assets, .{ .source_type = .echo, .id = inc_id }, buff_id, active_tags, &seen_buffs);
            }
        }
    }

    const fetter_ids = try echo_comp.activeFetterIds(gpa, assets, role_id);
    defer gpa.free(fetter_ids);
    for (fetter_ids) |fetter_id| {
        const fetter = assets.tables.phantom_fetter.getDataById(fetter_id) orelse continue;
        for (fetter.AddProp) |prop| {
            try equipment.addContribution(gpa, .{ .source_type = .fetter, .id = fetter_id }, contributionFromPropValue(prop.Id, prop.Value, prop.IsRatio, .base) orelse continue);
        }
        for (fetter.BuffIds) |buff_id| {
            try equipment.addBuffContribution(gpa, assets, .{ .source_type = .fetter, .id = fetter_id }, buff_id, active_tags, &seen_buffs);
        }
    }
}

fn addBuffContribution(
    equipment: *RoleEquipment,
    gpa: Allocator,
    assets: *const Assets,
    key: SourceKey,
    buff_id: i64,
    active_tags: []const []const u8,
    seen_buffs: *std.AutoHashMapUnmanaged(i64, void),
) !void {
    if (seen_buffs.contains(buff_id)) return;
    const buff = assets.tables.buff.getDataById(buff_id) orelse return;
    if (!PlayerEchoComponent.buffTagRequirementsMet(buff, active_tags)) return;
    const contribution = contributionFromBuff(buff, .add) orelse return;
    try seen_buffs.put(gpa, buff_id, {});
    try equipment.addContribution(gpa, key, contribution);
}

fn addContribution(equipment: *RoleEquipment, gpa: Allocator, key: SourceKey, contribution: Contribution) !void {
    const gop = try equipment.equipment_contributions.getOrPut(gpa, key);
    if (!gop.found_existing) gop.value_ptr.* = &.{};
    const old = gop.value_ptr.*;
    const new = try gpa.realloc(old, old.len + 1);
    new[old.len] = contribution;
    gop.value_ptr.* = new;
}

fn recalculate(equipment: *RoleEquipment) void {
    @memcpy(equipment.base_props, equipment.original_base_values);
    @memset(equipment.add_props, 0);

    for (equipment.equipment_contributions.keys(), equipment.equipment_contributions.values()) |key, contributions| {
        if (key.source_type != .weapon) continue;
        for (contributions) |contribution| {
            if (!contribution.is_ratio) equipment.addBaseValue(contribution.attr_index, contribution.value);
        }
    }

    for (equipment.equipment_contributions.keys(), equipment.equipment_contributions.values()) |key, contributions| {
        for (contributions) |contribution| {
            if (key.source_type == .weapon and !contribution.is_ratio) continue;
            equipment.addIncrementValue(contribution.attr_index, valueForBase(contribution, equipment.base_props));
        }
    }
}

fn contributionFromPropValue(prop_id: i32, value: f64, is_ratio: bool, display_mode: DisplayMode) ?Contribution {
    const attr_index = attrIndex(prop_id) orelse return null;
    return .{
        .attr_index = attr_index,
        .is_ratio = is_ratio,
        .value = if (is_ratio) 0 else @as(i32, @intFromFloat(@round(value))),
        .ratio = if (is_ratio) value else 0,
        .display_mode = if (is_ratio) .add else display_mode,
    };
}

fn contributionFromEchoProp(prop_id: i32, add_type: i32, value: i32, display_mode: DisplayMode) ?Contribution {
    const attr_index = attrIndex(prop_id) orelse return null;
    const is_ratio = add_type == 2;
    return .{
        .attr_index = attr_index,
        .is_ratio = is_ratio,
        .value = if (is_ratio) 0 else value,
        .ratio = if (is_ratio) @as(f64, @floatFromInt(value)) / 10000.0 else 0,
        .display_mode = if (is_ratio) .add else display_mode,
    };
}

fn contributionFromBuff(buff: Assets.DataTables.Buff, display_mode: DisplayMode) ?Contribution {
    if (buff.GameAttributeID == .None or buff.GameAttributeID == .MAX or buff.ModifierMagnitude.len == 0) return null;
    const index: usize = @intCast(@intFromEnum(buff.GameAttributeID));
    return .{
        .attr_index = index,
        .is_ratio = false,
        .value = buff.ModifierMagnitude[0],
        .ratio = 0,
        .display_mode = display_mode,
    };
}

fn valueForBase(contribution: Contribution, base_props: []const i32) i32 {
    if (!contribution.is_ratio) return contribution.value;
    if (contribution.attr_index >= base_props.len) return 0;
    return @as(i32, @intFromFloat(@round(@as(f64, @floatFromInt(base_props[contribution.attr_index])) * contribution.ratio)));
}

fn addBaseValue(equipment: *RoleEquipment, attr_index: usize, value: i32) void {
    if (attr_index >= equipment.base_props.len) return;
    equipment.base_props[attr_index] += value;
    if (attrIndexType(attr_index) == .LifeMax) {
        const life_index: usize = @intCast(@intFromEnum(pb.EAttributeType.Life));
        if (life_index < equipment.base_props.len) equipment.base_props[life_index] += value;
    }
}

fn addIncrementValue(equipment: *RoleEquipment, attr_index: usize, value: i32) void {
    if (attr_index >= equipment.add_props.len) return;
    equipment.add_props[attr_index] += value;
    if (attrIndexType(attr_index) == .LifeMax) {
        const life_index: usize = @intCast(@intFromEnum(pb.EAttributeType.Life));
        if (life_index < equipment.add_props.len) equipment.add_props[life_index] += value;
    }
}

fn addDisplayProp(gpa: Allocator, map: *std.AutoArrayHashMapUnmanaged(i32, i32), key: i32, value: i32) !void {
    const current = map.get(key) orelse 0;
    try map.put(gpa, key, current + value);
}

fn attrIndex(prop_id: i32) ?usize {
    if (prop_id == 0) return null;
    const attr_type: pb.EAttributeType = switch (prop_id) {
        10002 => .LifeMax,
        10007 => .Atk,
        10010 => .Def,
        else => blk: {
            const attr_id = if (prop_id >= 10000) prop_id - 10000 else prop_id;
            break :blk std.enums.fromInt(pb.EAttributeType, attr_id) orelse return null;
        },
    };
    if (attr_type == .None or attr_type == .MAX) return null;
    return @intCast(@intFromEnum(attr_type));
}

fn attrIndexType(index: usize) ?pb.EAttributeType {
    return std.enums.fromInt(pb.EAttributeType, @as(i32, @intCast(index)));
}

fn weaponGrowth(assets: *const Assets, curve_id: i32, level: i32, breach: i32) ?Assets.DataTables.WeaponPropertyGrowth {
    for (assets.tables.weapon_property_growth.items) |entry| {
        if (entry.CurveId == curve_id and entry.Level == level and entry.BreachLevel == breach) return entry;
    }
    return null;
}

fn echoMarkerBuffEffect(assets: *const Assets, echo_comp: *PlayerEchoComponent, inc_id: i32) ?i64 {
    const echo = echo_comp.echo_map.get(inc_id) orelse return null;
    const base_item = assets.tables.phantom_item.getDataById(echo.id) orelse return null;
    const item = if (echo.skin_id != 0)
        if (assets.tables.phantom_item.getDataById(echo.skin_id)) |skin_item|
            if (skin_item.ParentMonsterId == base_item.MonsterId) skin_item else base_item
        else
            base_item
    else
        base_item;
    if (item.SkillId == 0) return null;
    const marker_id: i64 = @as(i64, item.SkillId) * 1000 + 1;
    const marker = assets.tables.buff.getDataById(marker_id) orelse return null;
    if (marker.GrantedTags.len == 0 or marker.ExtraEffectID != 0) return null;
    return marker_id;
}

fn containsTag(tags: []const []const u8, needle: []const u8) bool {
    for (tags) |tag| {
        if (std.mem.eql(u8, tag, needle)) return true;
    }
    return false;
}
