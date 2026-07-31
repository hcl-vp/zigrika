const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Scene = @import("../../logic/Scene.zig");
const Connection = @import("../../network/Connection.zig");
const Entity = @import("../../logic/Scene.zig").Entity;
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const attributes_helper = @import("../../logic/helpers/attributes.zig");

pub fn configured_duration_seconds(buff_data: *const Assets.DataTables.Buff) f32 {
    return if (buff_data.DurationMagnitude.len > 0) buff_data.DurationMagnitude[0] else 0;
}

pub const CalcutionPolicy = enum(i5) {
    AdvancedMultiplyMagnitude1 = -1,
    AddValue = 0,
    AddRate = 1,
    AddFromAttr = 2,
    OverrideValue = 3,
    OverrideFromAttr = 4,
    AddTimeScaledValue = 5,
    AddTimeScaledRate = 6,
    AddFromAttrRate = 9,
};

// TODO: revamp this in its respective branch :) this fucking sucks
pub fn execute_buff_effects(
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    target_id: i64,
    instigator_id: i64,
    buff_data: *const Assets.DataTables.Buff,
    scene: *Scene,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !void {
    try executeBuffEffects(
        .instant,
        combat_receive_pack,
        target_id,
        instigator_id,
        buff_data,
        scene,
        fs,
        io,
        query,
        alloc,
    );
}

pub fn execute_periodic_buff_effects(
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    target_id: i64,
    instigator_id: i64,
    buff_data: *const Assets.DataTables.Buff,
    scene: *Scene,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !void {
    try executeBuffEffects(
        .periodic,
        combat_receive_pack,
        target_id,
        instigator_id,
        buff_data,
        scene,
        fs,
        io,
        query,
        alloc,
    );
}

const ExecutionMode = enum {
    instant,
    periodic,
};

fn executeBuffEffects(
    mode: ExecutionMode,
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    target_id: i64,
    instigator_id: i64,
    buff_data: *const Assets.DataTables.Buff,
    scene: *Scene,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !void {
    const log = std.log.scoped(.buff_helper);
    const target_entity: Entity, _, const maybe_target_attr: ?*Entity.AttributeComponent = blk: {
        if (query.byNetId(target_id)) |comps| {
            break :blk comps;
        } else {
            log.debug("couldnt find target stuff: {d}", .{target_id});
            return;
        }
    };

    log.debug("buff id {d}", .{buff_data.Id});

    switch (mode) {
        .instant => if (buff_data.DurationPolicy != .Instant) return,
        .periodic => if (buff_data.Period <= 0) return,
    }

    if (maybe_target_attr) |target_attr| {
        const calc_policy: CalcutionPolicy = blk: {
            const calc_policy = if (buff_data.CalculationPolicy.len > 0) buff_data.CalculationPolicy[0] else return;
            const valid_policy = inline for (std.meta.fields(CalcutionPolicy)) |f| {
                if (f.value == calc_policy) break true;
            } else false;
            if (valid_policy) {
                break :blk @enumFromInt(calc_policy);
            }
            break :blk CalcutionPolicy.AddValue;
        };

        const change = try calculate_buff_effects(
            target_entity,
            target_attr,
            instigator_id,
            buff_data,
            calc_policy,
            query,
            alloc,
        );
        if (change.items.len != 0) {
            try scene.markFsmDirty(alloc.gpa, target_entity.net_id, Entity.FsmComponent.WakeReason.attribute);
        }
        try scene.saveComponents(fs, alloc.gpa, target_entity, &.{Entity.AttributeComponent});
        try attributes_helper.generate_attr_messages(
            combat_receive_pack,
            target_entity.net_id,
            target_attr,
            &change,
            alloc,
            io,
        );
    }
}

fn calculate_buff_effects(
    target_entity: Entity,
    target_attr: *Entity.AttributeComponent,
    instigator_id: i64,
    buff_data: *const Assets.DataTables.Buff,
    calc_policy: CalcutionPolicy,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !std.ArrayList(pb.EAttributeType) {
    switch (calc_policy) {
        .AddValue => {
            const value = blk: {
                if (buff_data.ModifierMagnitude.len > 0) {
                    break :blk buff_data.ModifierMagnitude[0];
                }
                break :blk 0;
            };
            return try attributes_helper.change_attr(
                target_attr,
                buff_data.GameAttributeID,
                .Delta,
                .Current,
                value,
                alloc,
            );
        },
        .AddRate => {
            const modifier = blk: {
                if (buff_data.ModifierMagnitude.len > 0) {
                    break :blk @as(f64, @floatFromInt(buff_data.ModifierMagnitude[0]));
                }
                break :blk 0.0;
            };

            const current: i32 = blk: {
                const idx = @intFromEnum(buff_data.GameAttributeID);
                if (target_attr.attributes.len > idx) {
                    break :blk target_attr.attributes[@intCast(idx)].current;
                }
                break :blk 0;
            };
            const increment: i32 = @intFromFloat(@as(f64, @floatFromInt(current)) * modifier / 1e4);

            return try attributes_helper.change_attr(
                target_attr,
                buff_data.GameAttributeID,
                .Delta,
                .Current,
                increment,
                alloc,
            );
        },
        .AddFromAttr => {
            if (buff_data.CalculationPolicy.len < 2) return error.InvalidCalculationPolicy;
            const modifier = blk: {
                if (buff_data.ModifierMagnitude.len > 0) {
                    break :blk @as(f64, @floatFromInt(buff_data.ModifierMagnitude[0]));
                }
                break :blk 0.0;
            };
            const based_attr_id = buff_data.CalculationPolicy[1];
            const source_id: i64 = if (buff_data.CalculationPolicy.len > 2 and buff_data.CalculationPolicy[2] == 1)
                instigator_id
            else
                target_entity.net_id;

            const source_query_result = query.byNetId(source_id) orelse return error.MissingComponents;
            const source_attr: *Entity.AttributeComponent = source_query_result[2] orelse return error.MissingAttributeComponent;

            const min_required = blk: {
                if (buff_data.CalculationPolicy.len > 5) {
                    break :blk @as(f64, @floatFromInt(buff_data.CalculationPolicy[5]));
                }
                break :blk 0.0;
            };
            const conversion_factor = blk: {
                if (buff_data.CalculationPolicy.len > 6) {
                    break :blk @max(1.0, @as(f64, @floatFromInt(buff_data.CalculationPolicy[6])));
                }
                break :blk 1.0;
            };
            const source_value = blk: {
                const raw =
                    if (source_attr.attributes.len > based_attr_id)
                        source_attr.attributes[@intCast(based_attr_id)].current
                    else
                        return error.MissingAttribute;
                break :blk @as(f64, @floatFromInt(raw));
            };
            if (source_value < min_required) return error.UnreachableCalculation;
            const max_value = blk: {
                if (buff_data.CalculationPolicy.len > 7) {
                    break :blk @as(f64, @floatFromInt(buff_data.CalculationPolicy[7]));
                }
                break :blk @as(f64, @floatFromInt(std.math.maxInt(i32)));
            };

            const calculated = ((source_value - min_required) / conversion_factor) * (modifier / 1e4);
            return try attributes_helper.change_attr(
                target_attr,
                buff_data.GameAttributeID,
                .Delta,
                .Current,
                @as(i32, @trunc(@min(calculated, max_value))),
                alloc,
            );
        },
        .OverrideValue => {
            const value = blk: {
                if (buff_data.ModifierMagnitude.len > 0) {
                    break :blk buff_data.ModifierMagnitude[0];
                }
                break :blk 0;
            };
            return try attributes_helper.change_attr(
                target_attr,
                buff_data.GameAttributeID,
                .Override,
                .Current,
                value,
                alloc,
            );
        },
        else => {},
    }

    return .empty;
}
