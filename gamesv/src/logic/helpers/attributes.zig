const std = @import("std");
const mem = @import("../../mem.zig");
const AttributeComponent = @import("../component/entity/AttributeComponent.zig");
const pb = @import("proto").pb;

pub const AttributeValueType = enum {
    Base,
    Current,
    Increment,
};

pub const AttributeChangeType = enum {
    Delta,
    Override,
};

pub const RelatedAttrKind = enum {
    Max,
    Recover,
};

pub fn get_element_bonus(element_type: i32) pb.EAttributeType {
    return switch (element_type) {
        0 => .DamageChangePhys,
        1 => .DamageChangeElement1,
        2 => .DamageChangeElement2,
        3 => .DamageChangeElement3,
        4 => .DamageChangeElement4,
        5 => .DamageChangeElement5,
        6 => .DamageChangeElement6,
        else => .DamageChangePhys,
    };
}

pub fn get_element_res(element_type: i32) pb.EAttributeType {
    return switch (element_type) {
        0 => .DamageResistancePhys,
        1 => .DamageResistanceElement1,
        2 => .DamageResistanceElement2,
        3 => .DamageResistanceElement3,
        4 => .DamageResistanceElement4,
        5 => .DamageResistanceElement5,
        6 => .DamageResistanceElement6,
        else => .DamageResistancePhys,
    };
}

pub fn get_element_pen(element_type: i32) pb.EAttributeType {
    return switch (element_type) {
        0 => .IgnoreDamageResistancePhys,
        1 => .IgnoreDamageResistanceElement1,
        2 => .IgnoreDamageResistanceElement2,
        3 => .IgnoreDamageResistanceElement3,
        4 => .IgnoreDamageResistanceElement4,
        5 => .IgnoreDamageResistanceElement5,
        6 => .IgnoreDamageResistanceElement6,
        else => .IgnoreDamageResistancePhys,
    };
}

pub fn get_element_reduce(element_type: i32) pb.EAttributeType {
    return switch (element_type) {
        0 => .DamageReducePhys,
        1 => .DamageReduceElement1,
        2 => .DamageReduceElement2,
        3 => .DamageReduceElement3,
        4 => .DamageReduceElement4,
        5 => .DamageReduceElement5,
        6 => .DamageReduceElement6,
        else => .DamageReducePhys,
    };
}

pub fn get_ability_bonus(ability_type: i32) pb.EAttributeType {
    return switch (ability_type) {
        0 => .DamageChangeAuto, // Based on Basic Attack
        1 => .DamageChangeCast, // Based on Heavy Attack
        2 => .DamageChangeUltra, // Based on Liberation Skill
        3 => .DamageChangeQte, // Based on QTE / Intro Skill
        4 => .DamageChangeNormalSkill, // Based on Resonance Skill
        5 => .DamageChangePhantom, // Based on Phantom Skill
        6 => .EAttributeTypeNone, // TODO: Based on Field/Utility
        7 => .EAttributeTypeNone, // TODO: Based on Outro Skill
        8 => .EAttributeTypeNone, // TODO: Based on Coordinated Attacks
        9 => .EAttributeTypeNone, // TODO: Based on Heal/Shield
        10 => .EAttributeTypeNone, // TODO: Based on Negative Status
        11 => .EAttributeTypeNone, // TODO: Based on Tune Break
        12 => .EAttributeTypeNone, // TODO: Based on Tune Rupture
    };
}

pub fn get_related_attr(
    attr_type: pb.EAttributeType,
    kind: RelatedAttrKind,
    allocator: std.mem.Allocator,
) !?pb.EAttributeType {
    const suffix = switch (kind) {
        .Max => "Max",
        .Recover => "Recover",
    };
    const attr_name = @tagName(attr_type);
    const attr_name_max = try std.fmt.allocPrint(allocator, "{s}{s}", .{ attr_name, suffix });
    defer allocator.free(attr_name_max);
    return std.meta.stringToEnum(pb.EAttributeType, attr_name_max);
}

const ATTR_ALLOW_NEGATIVES: []const pb.EAttributeType = &.{
    .Crit,
    .DamageReduce,
    .DamageReducePhys,
    .DamageReduceElement1,
    .DamageReduceElement2,
    .DamageReduceElement3,
    .DamageReduceElement4,
    .DamageReduceElement5,
    .DamageReduceElement6,
    .DamageResistancePhys,
    .DamageResistanceElement1,
    .DamageResistanceElement2,
    .DamageResistanceElement3,
    .DamageResistanceElement4,
    .DamageResistanceElement5,
    .DamageResistanceElement6,
    .ParalysisTimeRecover,
};

fn clamp_attr(
    attr_type: pb.EAttributeType,
    value: i32,
    max_value: ?i32,
) i32 {
    switch (attr_type) {
        .AutoAttackSpeed, .CastAttackSpeed => return std.math.clamp(value, 0, 20000),
        .DamageReduce => return std.math.clamp(value, -10000, 10000),
        else => {
            if (max_value) |max| {
                return std.math.clamp(value, 0, max);
            }
            const allows_negative = std.mem.indexOfScalar(
                pb.EAttributeType,
                ATTR_ALLOW_NEGATIVES,
                attr_type,
            ) != null;
            return if (allows_negative) value else @max(value, 0);
        },
    }
}

pub const AttributeChange = struct {
    changes: std.ArrayList(pb.GameplayAttributeData),
    recovers: std.ArrayList(pb.RecoverPropFromServer),
};

pub fn change_attr(
    attr_comp: *AttributeComponent,
    attr_type: pb.EAttributeType,
    change_type: AttributeChangeType,
    value_type: AttributeValueType,
    value: i32,
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
    const life_idx = @intFromEnum(pb.EAttributeType.Life);
    const life_max_idx = @intFromEnum(pb.EAttributeType.LifeMax);
    const is_alive = attr_comp.attributes.len > life_idx and
        attr_comp.attributes[life_idx].current > 0;

    if (attr_type == .Life and !is_alive) {
        return .empty;
    }

    const max_value: ?i32 = blk: {
        const maybe_max_attr = try get_related_attr(attr_type, .Max, alloc.gpa);
        if (maybe_max_attr) |max_attr| {
            const max_idx = @intFromEnum(max_attr);
            if (max_idx < attr_comp.attributes.len) {
                break :blk attr_comp.attributes[@intCast(max_idx)].current;
            }
        }
        break :blk null;
    };

    const hp_ratio_before: ?f32 = if (attr_type == .LifeMax) ratio: {
        if (life_idx < attr_comp.attributes.len and life_max_idx < attr_comp.attributes.len) {
            const life = attr_comp.attributes[life_idx].current;
            const life_max = attr_comp.attributes[life_max_idx].current;
            break :ratio if (life_max > 0)
                @as(f32, @floatFromInt(life)) / @as(f32, @floatFromInt(life_max))
            else
                null;
        }
        break :ratio null;
    } else null;

    const result = apply_attr_change(
        attr_comp,
        attr_type,
        change_type,
        value_type,
        value,
        max_value,
        alloc,
    );

    if (hp_ratio_before) |ratio| {
        if (life_max_idx < attr_comp.attributes.len and life_idx < attr_comp.attributes.len) {
            const new_max = attr_comp.attributes[life_max_idx].current;
            const new_hp: i32 = @intFromFloat(@round(@as(f32, @floatFromInt(new_max)) * ratio));
            const clamped = std.math.clamp(new_hp, 0, new_max);
            attr_comp.attributes[life_idx].base = clamped;
            attr_comp.attributes[life_idx].current = clamped;
        }
    }

    return result;
}

pub fn apply_attr_change(
    attr_comp: *AttributeComponent,
    attr_type: pb.EAttributeType,
    change_type: AttributeChangeType,
    value_type: AttributeValueType,
    value: i32,
    max_value: ?i32,
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
    var change: std.ArrayList(pb.EAttributeType) = .empty;

    const idx = @intFromEnum(attr_type);
    if (idx >= attr_comp.attributes.len) return change;

    const attr = &attr_comp.attributes[@intCast(idx)];

    switch (change_type) {
        .Override => switch (value_type) {
            .Base => {
                attr.base = clamp_attr(attr_type, value, max_value);
                attr.current = clamp_attr(attr_type, attr.base + attr.increment, max_value);
            },
            .Increment => {
                attr.increment = clamp_attr(attr_type, value, max_value);
                attr.current = clamp_attr(attr_type, attr.base + attr.increment, max_value);
            },
            .Current => {
                attr.current = clamp_attr(attr_type, value, max_value);
            },
        },
        .Delta => switch (value_type) {
            .Base => {
                attr.base = clamp_attr(attr_type, attr.base + value, max_value);
                attr.current = clamp_attr(attr_type, attr.base + attr.increment, max_value);
            },
            .Increment => {
                attr.increment = clamp_attr(attr_type, attr.increment + value, max_value);
                attr.current = clamp_attr(attr_type, attr.base + attr.increment, max_value);
            },
            .Current => {
                attr.current = clamp_attr(attr_type, attr.current + value, max_value);
            },
        },
    }

    try change.append(alloc.arena, attr_type);

    return change;
}

pub fn generate_attr_messages(
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    entity_id: i64,
    attr_comp: *AttributeComponent,
    changed: *const std.ArrayList(pb.EAttributeType),
    alloc: mem.Alloc,
    io: std.Io,
) !void {
    var changes: std.ArrayList(pb.GameplayAttributeData) = .empty;
    var recovers: std.ArrayList(pb.RecoverPropFromServer) = .empty;

    const recover_types = &[_]pb.EAttributeType{ .Hardness, .Tough, .ParalysisTime };

    for (changed.items) |attr_type| {
        const idx = @intFromEnum(attr_type);
        if (idx >= attr_comp.attributes.len) continue;
        const attr = &attr_comp.attributes[@intCast(idx)];

        if (std.mem.indexOfScalar(pb.EAttributeType, recover_types, attr_type) != null) {
            const max_val = blk: {
                if (try get_related_attr(attr_type, .Max, alloc.gpa)) |max_attr| {
                    const midx = @intFromEnum(max_attr);
                    if (midx < attr_comp.attributes.len) break :blk attr_comp.attributes[@intCast(midx)].current;
                }
                break :blk 0;
            };
            const recover_val = blk: {
                if (try get_related_attr(attr_type, .Recover, alloc.gpa)) |rec_attr| {
                    const ridx = @intFromEnum(rec_attr);
                    if (ridx < attr_comp.attributes.len) break :blk attr_comp.attributes[@intCast(ridx)].current;
                }
                break :blk 0;
            };
            try recovers.append(alloc.arena, .{
                .AttrId = @intCast(idx),
                .Ratio = recover_val,
                .MaxValue = max_val,
                .ValueIncrement = attr.current,
            });
        }

        const ratio_attr = switch (attr_type) {
            .Atk, .LifeMax, .Def => true,
            else => false,
        };
        try changes.append(alloc.arena, .{
            .AttributeType = attr_type,
            .CurrentValue = if (ratio_attr) attr.base else attr.current,
            .ValueIncrement = attr.current,
        });
    }

    const realtime_clock: std.Io.Clock = .real;
    try combat_receive_pack.append(alloc.arena, .{
        .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entity_id },
                .Message = .{ .AttributeChangedNotify = .{ .Attributes = changes } },
            },
        },
    });
    try combat_receive_pack.append(alloc.arena, .{
        .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entity_id },
                .Message = .{
                    .RecoverPropChangedNotify = .{
                        .Attributes = recovers,
                        .Duration = realtime_clock.now(io).toMilliseconds(),
                    },
                },
            },
        },
    });
}
