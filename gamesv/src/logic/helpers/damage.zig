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

pub fn damageEntity(
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    request: pb.DamageExecuteRequest,
    damage: *const Assets.DataTables.Damage,
    scene: *Scene,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        ?*Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !pb.DamageExecuteNotify {
    const log = std.log.scoped(.damage_math);

    // --- attacker lookup ---
    const attacker_entity: Entity, _, const attacker_attr: ?*Entity.AttributeComponent = blk: {
        if (query.byNetId(request.AttackerEntityId)) |comps| {
            break :blk comps;
        } else {
            log.debug("couldnt find attacker entity {}", .{request.AttackerEntityId});
            return pb.DamageExecuteNotify{
                .Damage = 1,
                .ElementType = damage.Element,
            };
        }
    };

    // --- target lookup ---
    const target_entity: Entity, _, const target_attr: ?*Entity.AttributeComponent = blk: {
        if (query.byNetId(request.TargetEntityId)) |comps| {
            break :blk comps;
        } else {
            log.debug("couldnt find target entity {}", .{request.TargetEntityId});
            return pb.DamageExecuteNotify{
                .Damage = 1,
                .ElementType = damage.Element,
            };
        }
    };

    // --- concerto energy calculation ---
    if (attacker_attr) |attr| {
        const concerto: i32 = blk: {
            const base = if (damage.ElementPower.len > 0) damage.ElementPower[0] else break :blk 0;
            const eff_idx = @intFromEnum(pb.EAttributeType.ElementEfficiency);
            if (attr.attributes.len > eff_idx) {
                const concerto_eff = attr.attributes[eff_idx].current;
                break :blk @divTrunc(base * concerto_eff, 10000);
            }
            break :blk 0;
        };

        const change = try attributes_helper.change_attr(
            attr,
            .ElementEnergy,
            .Delta,
            .Current,
            concerto,
            alloc,
        );

        try attributes_helper.generate_attr_messages(
            combat_receive_pack,
            request.AttackerEntityId,
            attr,
            &change,
            alloc,
            io,
        );

        // Ultimate (resonance liberation) energy regen based on the damage table,
        // accelerated so the bar fills in a few seconds like on the official server.
        const energy_regen: i32 = blk: {
            const base = if (damage.Energy.len > 0) damage.Energy[0] else 0;
            const eff_idx = @intFromEnum(pb.EAttributeType.EnergyEfficiency);
            const energy_eff: i32 = if (attr.attributes.len > eff_idx) attr.attributes[eff_idx].current else 10000;
            const scaled = @divTrunc(@max(base, 0) * energy_eff, 10000);
            // Accelerate: base table values are small (50-400 vs EnergyMax=10000),
            // so charge ~900-2000 per hit to fill in a few seconds of combat.
            break :blk if (scaled > 0) scaled * 3 + 800 else 800;
        };

        const e_change = try attributes_helper.change_attr(
            attr,
            .Energy,
            .Delta,
            .Current,
            energy_regen,
            alloc,
        );
        if (change.items.len != 0 or e_change.items.len != 0) {
            try scene.markFsmDirty(
                alloc.gpa,
                attacker_entity.net_id,
                Entity.FsmComponent.WakeReason.attribute,
            );
        }

        try attributes_helper.generate_attr_messages(
            combat_receive_pack,
            request.AttackerEntityId,
            attr,
            &e_change,
            alloc,
            io,
        );
    }
    try scene.saveComponents(fs, alloc.gpa, attacker_entity, &.{Entity.AttributeComponent});

    // --- damage calculation ---
    // Get the related attribute (typically ATK=7, but config may use others)
    const related_idx: usize = if (damage.RelatedProperty > 0)
        @intCast(damage.RelatedProperty)
    else
        @intFromEnum(pb.EAttributeType.Atk); // fallback to ATK
    const related_value: i32 = if (attacker_attr) |attr| blk: {
        if (related_idx < attr.attributes.len) {
            break :blk attr.attributes[related_idx].current;
        }
        break :blk 0;
    } else 0;

    // Rate multiplier from skill level
    const skill_lv: usize = @intCast(@max(request.SkillLevel, 1));
    const rate: i32 = if (damage.RateLv.len > 0 and damage.RateLv[@min(skill_lv - 1, damage.RateLv.len - 1)] > 0)
        damage.RateLv[@min(skill_lv - 1, damage.RateLv.len - 1)]
    else
        10000;

    // Formula damage multiplier
    const formula_mul: i32 = if (damage.FormulaParam1.len > 0 and damage.FormulaParam1[0] > 0)
        damage.FormulaParam1[0]
    else
        10000;

    log.debug("dmg calc: related_idx={d} related_val={d} rate={d} formula={d}", .{ related_idx, related_value, rate, formula_mul });

    // Calculate base damage: ATK * Rate / 10000 * Formula / 10000
    const scaled: i64 = @divTrunc(@as(i64, related_value) * @as(i64, rate), 10000);
    const base: i64 = @divTrunc(scaled * @as(i64, formula_mul), 10000);

    // DEF reduction: damage * 10000 / (10000 + DEF)
    const def_value: i32 = if (target_attr) |attr| blk: {
        const def_idx = @intFromEnum(pb.EAttributeType.Def);
        break :blk if (attr.attributes.len > def_idx) attr.attributes[def_idx].current else 0;
    } else 0;
    const def_factor_num: i64 = 10000;
    const def_factor_den: i64 = 10000 + @as(i64, def_value);
    const after_def: i64 = @divTrunc(base * def_factor_num, def_factor_den);

    // Fluctuation: ±FluctuationUpper[0] / 10000 of base damage
    const fluct_ratio: i32 = if (damage.FluctuationUpper.len > 0) damage.FluctuationUpper[0] else 0;
    const variance: i64 = @divTrunc(after_def * @as(i64, fluct_ratio), 10000 * 2);

    // Fallback: if formula gives 0, use simple ATK-based damage
    const damage_amount: i32 = if (after_def > 0)
        @intCast(@max(after_def - variance, 1))
    else fallback: {
        // Simple fallback: ATK * 0.5 - DEF * 0.3, minimum 1
        const atk_idx2 = @intFromEnum(pb.EAttributeType.Atk);
        const def_idx2 = @intFromEnum(pb.EAttributeType.Def);
        const atk2: i32 = if (attacker_attr) |attr| inner: {
            break :inner if (attr.attributes.len > atk_idx2) attr.attributes[atk_idx2].current else 10;
        } else 10;
        const def2: i32 = if (target_attr) |attr| inner: {
            break :inner if (attr.attributes.len > def_idx2) attr.attributes[def_idx2].current else 0;
        } else 0;
        break :fallback @max(@divTrunc(atk2, 2) - @divTrunc(def2, 4), 1);
    };

    log.debug("dmg result: base={d} def={d} after_def={d} variance={d} final={d}", .{ base, def_value, after_def, variance, damage_amount });

    // --- determine heal vs damage: same camp = heal, different camp = damage ---
    const attacker_camp = scene.entities.items(.config)[attacker_entity.index].camp;
    const target_camp = scene.entities.items(.config)[target_entity.index].camp;
    const is_heal = attacker_camp == target_camp;
    const life_delta: i32 = if (is_heal) damage_amount else -damage_amount;

    // --- apply HP change to target ---
    if (target_attr) |attr| {
        const life_change = try attributes_helper.change_attr(
            attr,
            .Life,
            .Delta,
            .Current,
            life_delta,
            alloc,
        );

        try attributes_helper.generate_attr_messages(
            combat_receive_pack,
            request.TargetEntityId,
            attr,
            &life_change,
            alloc,
            io,
        );

        if (life_change.items.len != 0) {
            try scene.markFsmDirty(
                alloc.gpa,
                target_entity.net_id,
                Entity.FsmComponent.WakeReason.attribute,
            );
        }
    }

    // --- toughness (Tune Break) damage: consume target Tough/Hardness on non-heal hits ---
    if (!is_heal) {
        if (target_attr) |attr| {
            const tough_idx = @intFromEnum(pb.EAttributeType.Tough);
            const tough_max_idx = @intFromEnum(pb.EAttributeType.ToughMax);
            const hardness_idx = @intFromEnum(pb.EAttributeType.Hardness);
            const hardness_max_idx = @intFromEnum(pb.EAttributeType.HardnessMax);

            // Toughness damage from the damage record (index by skill level, clamped).
            const tough_damage: i32 = if (damage.ToughLv.len > 0)
                damage.ToughLv[@min(skill_lv - 1, damage.ToughLv.len - 1)]
            else
                0;
            const hardness_damage: i32 = if (damage.HardnessLv.len > 0)
                damage.HardnessLv[@min(skill_lv - 1, damage.HardnessLv.len - 1)]
            else
                0;

            var toughness_changes: std.ArrayList(pb.EAttributeType) = .empty;

            if (tough_damage != 0 and tough_idx < attr.attributes.len) {
                const tough_change = try attributes_helper.change_attr(
                    attr,
                    .Tough,
                    .Delta,
                    .Current,
                    -tough_damage,
                    alloc,
                );
                try toughness_changes.appendSlice(alloc.arena, tough_change.items);
            }
            if (hardness_damage != 0 and hardness_idx < attr.attributes.len) {
                const hardness_change = try attributes_helper.change_attr(
                    attr,
                    .Hardness,
                    .Delta,
                    .Current,
                    -hardness_damage,
                    alloc,
                );
                try toughness_changes.appendSlice(alloc.arena, hardness_change.items);
            }

            if (toughness_changes.items.len != 0) {
                try attributes_helper.generate_attr_messages(
                    combat_receive_pack,
                    request.TargetEntityId,
                    attr,
                    &toughness_changes,
                    alloc,
                    io,
                );
                try scene.markFsmDirty(
                    alloc.gpa,
                    target_entity.net_id,
                    Entity.FsmComponent.WakeReason.attribute,
                );
            }

            // --- Tune Break: when Tough (or Hardness) is fully depleted, notify paralysis/down state ---
            const tough_zero = tough_idx < attr.attributes.len and
                tough_max_idx < attr.attributes.len and
                attr.attributes[tough_max_idx].current > 0 and
                attr.attributes[tough_idx].current <= 0;
            const hardness_zero = hardness_idx < attr.attributes.len and
                hardness_max_idx < attr.attributes.len and
                attr.attributes[hardness_max_idx].current > 0 and
                attr.attributes[hardness_idx].current <= 0;
            if (tough_zero or hardness_zero) {
                try combat_receive_pack.append(alloc.arena, .{
                    .Message = .{ .CombatNotifyData = .{
                        .CombatCommon = .{ .EntityId = target_entity.net_id },
                        .Message = .{ .ExecuteQteNotify = .{
                            .DownEntityId = target_entity.net_id,
                            .UpEntityId = request.AttackerEntityId,
                            .FnvHash = 0,
                        } },
                    } },
                });
            }
        }
    }
    try scene.saveComponents(fs, alloc.gpa, target_entity, &.{Entity.AttributeComponent});

    // --- monster death handling: when a monster's HP reaches zero, notify the client ---
    if (!is_heal) {
        const life_idx = @intFromEnum(pb.EAttributeType.Life);
        const is_dead = if (target_attr) |attr|
            life_idx < attr.attributes.len and attr.attributes[life_idx].current <= 0
        else
            false;
        if (is_dead and scene.entities.items(.config)[target_entity.index].entity_type == .monster) {
            try combat_receive_pack.append(alloc.arena, .{
                .Message = .{ .CombatNotifyData = .{
                    .CombatCommon = .{ .EntityId = target_entity.net_id },
                    .Message = .{ .EntityLivingStatusNotify = .{
                        .Id = target_entity.net_id,
                        .LivingStatus = .Dead,
                    } },
                } },
            });
        }
    }

    return pb.DamageExecuteNotify{
        .Damage = damage_amount,
        .ElementType = damage.Element,
        .ChangeLife = life_delta,
    };
}
