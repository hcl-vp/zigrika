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

fn configuredCurveId(components: *const Components) i32 {
    if (components.AttributeComponent) |attr| {
        if (attr.MonsterPropExtraRateId) |curve_id| return curve_id;
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
    alloc: mem.Alloc,
) !?Entity.AttributeComponent {
    const prop_id = propertyId(components, entity_logic) orelse return null;
    const level = configuredLevel(components);
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
