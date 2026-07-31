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

fn fallbackMonsterLevel(world_level: i32) ?i32 {
    return switch (world_level) {
        1 => 10,
        2 => 21,
        3 => 32,
        4 => 43,
        5 => 54,
        6 => 65,
        7 => 76,
        8 => 85,
        else => null,
    };
}

fn effectiveLevel(area_table: anytype, components: *const Components, area_id: i32, world_level: i32) i32 {
    const level = configuredLevel(components);
    if (level >= 10) return level;

    _ = components.AttributeComponent orelse return level;

    return areaMonsterLevel(area_table, area_id, world_level) orelse
        fallbackMonsterLevel(world_level) orelse
        level;
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

fn monsterGrowthAt(tables: anytype, level: i32, curve_id: i32) @TypeOf(tables.getMonsterPropertyGrowth(level, curve_id)) {
    const growth = if (curve_id != 0)
        tables.getMonsterPropertyGrowth(level, curve_id) orelse tables.getMonsterPropertyGrowth(level, 0)
    else
        tables.getMonsterPropertyGrowth(level, 0);
    return growth;
}

fn applyMonsterGrowthConfig(props: []i32, config: anytype) void {
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

fn applyMonsterGrowth(tables: *const Assets.DataTables, props: []i32, components: *const Components, level: i32) void {
    const config = monsterGrowthAt(tables, level, configuredCurveId(components)) orelse return;
    applyMonsterGrowthConfig(props, config);
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
