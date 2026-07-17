const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Assets = @import("../../data/Assets.zig");
const Components = @import("../../data/tables/entity_components/Components.zig");
const Entity = @import("../Scene.zig").Entity;

const SCALE = 10000;
const EntityLogic = @FieldType(Assets.DataTables.BlueprintConfig, "EntityLogic");

fn attrIndex(attr_type: pb.EAttributeType) usize {
    return @intCast(@intFromEnum(attr_type));
}

fn scaleProperty(value: *i32, ratio: i32) void {
    value.* = @intCast(@divTrunc(@as(i64, value.*) * @as(i64, ratio), SCALE));
}

fn scaleIfPresent(props: []i32, attr_type: pb.EAttributeType, ratio: i32) void {
    const idx = attrIndex(attr_type);
    if (idx < props.len) scaleProperty(&props[idx], ratio);
}

fn setIfPresent(props: []i32, attr_type: pb.EAttributeType, value: i32) void {
    const idx = attrIndex(attr_type);
    if (idx < props.len) props[idx] = value;
}

fn valueIfPresent(props: []const i32, attr_type: pb.EAttributeType) i32 {
    const idx = attrIndex(attr_type);
    return if (idx < props.len) props[idx] else 0;
}

fn clampLevel(level: i32) i32 {
    return std.math.clamp(level, 1, 120);
}

fn propertyId(components: *const Components, entity_logic: EntityLogic) ?i32 {
    if (components.AttributeComponent) |attr| {
        if (!(attr.Disabled orelse false)) {
            if (attr.PropertyId) |id| if (id > 0) return id;
        }
    }

    if (components.BaseInfoComponent) |base_info| {
        if (base_info.EntityPropertyId) |id| if (id > 0) return id;
    }

    return switch (entity_logic) {
        .Animal, .Monster, .Npc, .Vision => 2,
        else => null,
    };
}

fn configuredLevel(components: *const Components) i32 {
    if (components.AttributeComponent) |attr| {
        if (attr.Level) |level| return clampLevel(level);
    }

    return 1;
}

fn areaMonsterLevel(area_table: anytype, area_id: i32, world_level: i32) ?i32 {
    var current_area_id = area_id;
    var remaining = area_table.items.len;

    while (current_area_id > 0 and remaining > 0) : (remaining -= 1) {
        const area = area_table.getDataById(current_area_id) orelse return null;
        if (area.WorldMonsterLevelMax.map.get(world_level)) |level| return clampLevel(level);
        if (area.Father <= 0 or area.Father == current_area_id) return null;
        current_area_id = area.Father;
    }

    return null;
}

fn effectiveLevel(area_table: anytype, components: *const Components, area_id: i32, world_level: i32) i32 {
    const level = configuredLevel(components);
    if (level >= 10) return level;

    const attr = components.AttributeComponent orelse return level;
    const world_bonus = attr.WorldLevelBonusType orelse return level;
    if ((world_bonus.Type orelse 0) != 1) return level;

    return areaMonsterLevel(area_table, area_id, world_level) orelse level;
}

fn configuredCurveId(components: *const Components) i32 {
    if (components.AttributeComponent) |attr| {
        if (attr.MonsterPropGrowthId) |curve_id| if (curve_id > 0) return curve_id;
    }

    return 0;
}

fn hardnessModeId(components: *const Components) i32 {
    if (components.AttributeComponent) |attr| {
        if (attr.HardnessModeId) |id| return id;
    }

    return 0;
}

fn rageModeId(components: *const Components) i32 {
    if (components.AttributeComponent) |attr| {
        if (attr.RageModeId) |id| return id;
    }

    return 0;
}

fn applyMonsterGrowth(tables: *const Assets.DataTables, props: []i32, components: *const Components, level: i32) void {
    const curve_id = configuredCurveId(components);
    const growth = if (curve_id != 0)
        tables.getMonsterPropertyGrowth(level, curve_id) orelse tables.getMonsterPropertyGrowth(level, 0)
    else
        tables.getMonsterPropertyGrowth(level, 0);
    const config = growth orelse return;

    scaleIfPresent(props, .LifeMax, config.LifeMaxRatio);
    scaleIfPresent(props, .Life, config.LifeMaxRatio);
    scaleIfPresent(props, .Atk, config.AtkRatio);
    scaleIfPresent(props, .Def, config.DefRatio);
    scaleIfPresent(props, .HardnessMax, config.HardnessMaxRatio);
    scaleIfPresent(props, .Hardness, config.HardnessRatio);
    scaleIfPresent(props, .HardnessRecover, config.HardnessRecoverRatio);
    scaleIfPresent(props, .RageMax, config.RageMaxRatio);
    scaleIfPresent(props, .Rage, config.RageRatio);
    scaleIfPresent(props, .RageRecover, config.RageRecoverRatio);
    scaleIfPresent(props, .WeaknessBuildUpMax, config.WeaknessBuildUpMaxRatio);
}

fn normalizeLife(props: []i32) void {
    const life_max = valueIfPresent(props, .LifeMax);
    const life = valueIfPresent(props, .Life);
    if (life_max <= 0) return;

    if (life <= 0 or life > life_max) {
        setIfPresent(props, .Life, life_max);
    }
}

pub fn createCombatAttributes(
    assets: *const Assets,
    components: *const Components,
    entity_logic: EntityLogic,
    area_id: i32,
    world_level: i32,
    alloc: mem.Alloc,
) !?Entity.AttributeComponent {
    const prop_id = propertyId(components, entity_logic) orelse return null;
    const level = effectiveLevel(&assets.tables.area, components, area_id, world_level);
    const props = try assets.tables.getProps(prop_id, alloc.arena);
    if (props.len == 0) return null;

    setIfPresent(props, .Lv, level);
    applyMonsterGrowth(&assets.tables, props, components, level);
    normalizeLife(props);

    return try Entity.AttributeComponent.createWithModes(
        props,
        hardnessModeId(components),
        rageModeId(components),
        alloc.gpa,
    );
}

const TestArea = struct {
    AreaId: i32,
    Father: i32,
    WorldMonsterLevelMax: struct {
        map: std.array_hash_map.Auto(i32, i32) = .empty,
    } = .{},
};

const TestAreaTable = struct {
    items: []const TestArea,

    fn getDataById(table: @This(), area_id: i32) ?TestArea {
        for (table.items) |area| {
            if (area.AreaId == area_id) return area;
        }
        return null;
    }
};

test "monster growth uses its dedicated curve field" {
    const components: Components = .{
        .AttributeComponent = .{
            .MonsterPropExtraRateId = 3001,
            .MonsterPropGrowthId = 1001,
        },
    };

    try std.testing.expectEqual(@as(i32, 1001), configuredCurveId(&components));
}

test "monster extra rate is not used as a growth curve" {
    const components: Components = .{
        .AttributeComponent = .{ .MonsterPropExtraRateId = 3001 },
    };

    try std.testing.expectEqual(@as(i32, 0), configuredCurveId(&components));
}

test "area bonus resolves through parent areas" {
    var parent_levels: std.array_hash_map.Auto(i32, i32) = .empty;
    defer parent_levels.deinit(std.testing.allocator);
    try parent_levels.put(std.testing.allocator, 8, 94);

    const areas = [_]TestArea{
        .{ .AreaId = 10, .Father = 1 },
        .{ .AreaId = 1, .Father = 0, .WorldMonsterLevelMax = .{ .map = parent_levels } },
    };
    const table = TestAreaTable{ .items = &areas };
    const components: Components = .{
        .AttributeComponent = .{
            .Level = 2,
            .WorldLevelBonusType = .{ .Type = 1 },
        },
    };

    try std.testing.expectEqual(@as(i32, 94), effectiveLevel(table, &components, 10, 8));
}

test "area bonus preserves configured level without a mapping" {
    const areas = [_]TestArea{.{ .AreaId = 10, .Father = 0 }};
    const table = TestAreaTable{ .items = &areas };
    const components: Components = .{
        .AttributeComponent = .{
            .Level = 3,
            .WorldLevelBonusType = .{ .Type = 1 },
        },
    };

    try std.testing.expectEqual(@as(i32, 3), effectiveLevel(table, &components, 10, 8));
}

test "area bonus preserves explicit monster levels" {
    var levels: std.array_hash_map.Auto(i32, i32) = .empty;
    defer levels.deinit(std.testing.allocator);
    try levels.put(std.testing.allocator, 8, 94);

    const areas = [_]TestArea{.{ .AreaId = 10, .Father = 0, .WorldMonsterLevelMax = .{ .map = levels } }};
    const table = TestAreaTable{ .items = &areas };
    const components: Components = .{
        .AttributeComponent = .{
            .Level = 45,
            .WorldLevelBonusType = .{ .Type = 1 },
        },
    };

    try std.testing.expectEqual(@as(i32, 45), effectiveLevel(table, &components, 10, 8));
}

test "world level table mode preserves configured level" {
    const table = TestAreaTable{ .items = &.{} };
    const components: Components = .{
        .AttributeComponent = .{
            .Level = 4,
            .WorldLevelBonusType = .{ .Type = 0, .WorldLevelBonusId = 10011 },
        },
    };

    try std.testing.expectEqual(@as(i32, 4), effectiveLevel(table, &components, 10, 8));
}
