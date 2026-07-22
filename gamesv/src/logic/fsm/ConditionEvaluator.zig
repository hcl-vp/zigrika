const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const AttributeComponent = @import("../component/entity/AttributeComponent.zig");
const FightBuffComponent = @import("../component/entity/FightBuffComponent.zig");
const TagComponent = @import("../component/entity/TagComponent.zig");
const gameplay_tag_hierarchy = @import("../helpers/gameplay_tags.zig");
const StateHierarchy = @import("StateHierarchy.zig");
const Types = @import("Types.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

pub fn evaluate(
    comp: anytype,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    ctx: Types.EvalContext,
    depth: usize,
) bool {
    if (depth > 12) return false;
    if (condition.IsClient orelse false) {
        return clientPasses(comp, fsm_id, transition, condition.Index);
    }

    var result = evaluateRaw(comp, fsm_id, transition, conditions, condition, ctx, depth);
    if (condition.Reverse) result = !result;
    return result;
}

fn evaluateRaw(
    comp: anytype,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    ctx: Types.EvalContext,
    depth: usize,
) bool {
    if (std.mem.eql(u8, condition.Name, "CondTrue")) return true;
    if (std.mem.eql(u8, condition.Name, "CondHate")) return comp.in_hate;

    if (condition.CondAnd) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (!evaluate(comp, fsm_id, transition, conditions, child, ctx, depth + 1)) return false;
        }
        return true;
    }

    if (condition.CondOr) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (evaluate(comp, fsm_id, transition, conditions, child, ctx, depth + 1)) return true;
        }
        return false;
    }

    if (condition.CondTimer) |timer| {
        return timerPasses(comp, fsm_id, transition, condition.Index, timer, ctx.now_ms);
    }

    if (condition.CondCheckState) |state| {
        return currentStateMatches(comp, state.TargetState);
    }

    if (condition.CondCheckStateByName) |state| {
        return currentStateNameMatches(comp, state.TargetStateName);
    }

    if (condition.CondCheckLastState) |state| {
        return lastStateNameMatches(comp, state.TargetStateName);
    }

    // The client owns be-hit event classification and reports it through condition passes.
    if (condition.CondListenBeHit != null) return false;

    if (condition.CondListenEvent) |listen| {
        return listenEventPasses(comp, listen);
    }

    if (condition.CondCheckPositionState) |position| {
        const logic_state = ctx.logic_state orelse return false;
        return logic_state.position_state == position.PositionState;
    }

    if (condition.CondAttribute) |attribute| {
        return attrInRange(ctx.attribute, attribute.AttributeId, attribute.Min, attribute.Max);
    }

    if (condition.CondAttributeRate) |attribute| {
        return attrRateInRange(ctx.attribute, attribute.AttributeId, attribute.Denominator, attribute.Min, attribute.Max);
    }

    if (condition.CondTag) |tag| return if (tag.TagId) |tag_id| hasTag(comp, ctx.tags, tag_id) else false;

    if (condition.CondTaskFinish != null or condition.CondMontageTimeRemaining != null) return false;

    if (condition.CondInstStateChange) |state| return instanceStateMatches(comp, ctx.tags, state.TagId);

    if (condition.CondBuffStack) |buff| {
        return buffStackInRange(ctx.buffs, buff);
    }

    if (condition.CondPartLife) |part| {
        return partLifeInRange(ctx.parts, part);
    }

    if (condition.CondCheckPartActivated) |part| {
        return partIsActivated(ctx.parts, part.PartName);
    }

    if (condition.CondCheckDissolveCombine != null) return comp.dissolve_combine_signal;

    return false;
}

pub fn transitionUsesDissolveCombine(conditions: []const AiStateMachineConfig.StateMachineCondition) bool {
    const root = findCondition(conditions, 0) orelse return false;
    return conditionUsesDissolveCombine(conditions, root, 0);
}

pub fn dependencyMask(
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    depth: usize,
) Types.WakeMask {
    if (depth > 12) return 0;
    if (condition.IsClient orelse false) return Types.WakeReason.client_pass;

    if (condition.CondAnd) |data| {
        var mask: Types.WakeMask = 0;
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            mask |= dependencyMask(conditions, child, depth + 1);
        }
        return mask;
    }
    if (condition.CondOr) |data| {
        var mask: Types.WakeMask = 0;
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            mask |= dependencyMask(conditions, child, depth + 1);
        }
        return mask;
    }

    if (condition.CondTimer != null) return Types.WakeReason.timer;
    if (std.mem.eql(u8, condition.Name, "CondHate")) return Types.WakeReason.hate;
    if (std.mem.eql(u8, condition.Name, "CondTrue") or
        condition.CondCheckState != null or
        condition.CondCheckStateByName != null or
        condition.CondCheckLastState != null) return Types.WakeReason.state;
    if (condition.CondListenEvent != null) return Types.WakeReason.event;
    if (condition.CondCheckPositionState != null) return Types.WakeReason.position;
    if (condition.CondAttribute != null or condition.CondAttributeRate != null) return Types.WakeReason.attribute;
    if (condition.CondTag != null or condition.CondInstStateChange != null) return Types.WakeReason.tag;
    if (condition.CondBuffStack != null) return Types.WakeReason.buff;
    if (condition.CondPartLife != null or condition.CondCheckPartActivated != null) return Types.WakeReason.part;
    if (condition.CondCheckDissolveCombine != null) return Types.WakeReason.dissolve;
    return 0;
}

pub fn nextTimerDeadline(
    comp: anytype,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    now_ms: i64,
    depth: usize,
) ?i64 {
    if (depth > 12 or (condition.IsClient orelse false)) return null;

    if (condition.CondAnd) |data| {
        var next: ?i64 = null;
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            next = earlierDeadline(next, nextTimerDeadline(
                comp,
                fsm_id,
                transition,
                conditions,
                child,
                now_ms,
                depth + 1,
            ));
        }
        return next;
    }
    if (condition.CondOr) |data| {
        var next: ?i64 = null;
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            next = earlierDeadline(next, nextTimerDeadline(
                comp,
                fsm_id,
                transition,
                conditions,
                child,
                now_ms,
                depth + 1,
            ));
        }
        return next;
    }

    const timer = condition.CondTimer orelse return null;
    const activated_at = activationTime(comp, fsm_id, transition.From) orelse return null;
    const min_ms = durationMs(timer.MinTime);
    const configured_max = durationMs(timer.MaxTime orelse timer.MinTime);
    const max_ms = @max(configured_max, min_ms);
    const deadline = activated_at + timerDelayMs(
        StateHierarchy.canonicalState(comp, fsm_id),
        StateHierarchy.canonicalState(comp, transition.From),
        StateHierarchy.canonicalState(comp, transition.To),
        condition.Index,
        activated_at,
        min_ms,
        max_ms,
    );
    return if (deadline > now_ms) deadline else null;
}

fn earlierDeadline(a: ?i64, b: ?i64) ?i64 {
    if (a) |left| return if (b) |right| @min(left, right) else left;
    return b;
}

fn conditionUsesDissolveCombine(
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    condition: AiStateMachineConfig.StateMachineCondition,
    depth: usize,
) bool {
    if (depth > 12) return false;
    if (condition.CondCheckDissolveCombine != null) return true;
    if (condition.CondAnd) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (conditionUsesDissolveCombine(conditions, child, depth + 1)) return true;
        }
    }
    if (condition.CondOr) |data| {
        for (data.Conditions) |index| {
            const child = findCondition(conditions, index) orelse continue;
            if (conditionUsesDissolveCombine(conditions, child, depth + 1)) return true;
        }
    }
    return false;
}

pub fn findCondition(
    conditions: []const AiStateMachineConfig.StateMachineCondition,
    index: i32,
) ?AiStateMachineConfig.StateMachineCondition {
    for (conditions) |condition| {
        if (condition.Index == index) return condition;
    }

    return null;
}

fn currentStateMatches(comp: anytype, state: i32) bool {
    for (comp.runtime_nodes) |runtime| {
        if (StateHierarchy.pathContains(comp, runtime.active(), state)) return true;
    }

    return false;
}

fn timerPasses(
    comp: anytype,
    fsm_id: i32,
    transition: AiStateMachineConfig.StateMachineTransition,
    condition_index: i32,
    timer: AiStateMachineConfig.ConditionTimer,
    now_ms: i64,
) bool {
    const activated_at = activationTime(comp, fsm_id, transition.From) orelse return false;
    if (now_ms < activated_at) return false;

    const min_ms = durationMs(timer.MinTime);
    const configured_max = durationMs(timer.MaxTime orelse timer.MinTime);
    const max_ms = @max(configured_max, min_ms);
    const delay_ms = timerDelayMs(
        StateHierarchy.canonicalState(comp, fsm_id),
        StateHierarchy.canonicalState(comp, transition.From),
        StateHierarchy.canonicalState(comp, transition.To),
        condition_index,
        activated_at,
        min_ms,
        max_ms,
    );
    return now_ms - activated_at >= delay_ms;
}

fn activationTime(comp: anytype, fsm_id: i32, state: i32) ?i64 {
    const canonical_fsm = StateHierarchy.canonicalState(comp, fsm_id);
    const canonical_state = StateHierarchy.canonicalState(comp, state);
    for (comp.runtime_nodes) |runtime| {
        if (runtime.fsm_id != canonical_fsm) continue;
        for (runtime.active(), 0..) |active_state, index| {
            if (active_state == canonical_state) return runtime.active_since_ms[index];
        }
    }
    return null;
}

fn timerDelayMs(
    fsm_id: i32,
    from: i32,
    to: i32,
    condition_index: i32,
    activated_at: i64,
    min_ms: i64,
    max_ms: i64,
) i64 {
    if (max_ms <= min_ms) return min_ms;

    var seed: u64 = @bitCast(activated_at);
    const fsm_bits: u32 = @bitCast(fsm_id);
    const from_bits: u32 = @bitCast(from);
    const to_bits: u32 = @bitCast(to);
    const condition_bits: u32 = @bitCast(condition_index);
    seed ^= @as(u64, fsm_bits) *% 0x9E3779B185EBCA87;
    seed ^= @as(u64, from_bits) *% 0xC2B2AE3D27D4EB4F;
    seed ^= @as(u64, to_bits) *% 0x165667B19E3779F9;
    seed ^= @as(u64, condition_bits) *% 0x85EBCA77C2B2AE63;
    seed ^= seed >> 12;
    seed ^= seed << 25;
    seed ^= seed >> 27;
    seed *%= 0x2545F4914F6CDD1D;

    const span: u64 = @intCast(max_ms - min_ms + 1);
    return min_ms + @as(i64, @intCast(seed % span));
}

fn currentStateNameMatches(comp: anytype, name: []const u8) bool {
    for (comp.runtime_nodes) |runtime| {
        for (runtime.active()) |state| {
            const node = StateHierarchy.findNode(comp, state) orelse continue;
            if (node.Name) |node_name| {
                if (std.mem.eql(u8, node_name, name)) return true;
            }
        }
    }

    return false;
}

fn lastStateNameMatches(comp: anytype, name: []const u8) bool {
    for (comp.runtime_nodes) |runtime| {
        for (runtime.previous()) |state| {
            const node = StateHierarchy.findNode(comp, state) orelse continue;
            if (node.Name) |node_name| {
                if (std.mem.eql(u8, node_name, name)) return true;
            }
        }
    }
    return false;
}

fn listenEventPasses(comp: anytype, condition: AiStateMachineConfig.ConditionListenEvent) bool {
    const event = comp.event orelse return false;
    return std.mem.eql(u8, event, condition.Event);
}

fn buffStackInRange(buffs: ?*const FightBuffComponent, condition: AiStateMachineConfig.ConditionBuffStack) bool {
    const component = buffs orelse return condition.MinStack <= 0 and condition.MaxStack >= 0;
    const stack = for (component.fight_buff_infos) |buff| {
        if (buff.BuffId == condition.BuffId) break buff.StackCount;
    } else 0;
    return stack >= condition.MinStack and stack <= condition.MaxStack;
}

fn partLifeInRange(parts: ?[]const Types.PartState, condition: AiStateMachineConfig.ConditionPartLife) bool {
    const states = parts orelse return false;
    const part = for (states) |state| {
        if (std.mem.eql(u8, state.name, condition.PartName)) break state;
    } else return false;

    const value: f64 = if (condition.CheckRate) blk: {
        if (part.max_life <= 0) return false;
        break :blk @as(f64, part.life) * 10000.0 / @as(f64, part.max_life);
    } else part.life;
    return value >= @as(f64, condition.Min) and value <= @as(f64, condition.Max);
}

fn partIsActivated(parts: ?[]const Types.PartState, name: []const u8) bool {
    const states = parts orelse return false;
    for (states) |part| {
        if (std.mem.eql(u8, part.name, name)) return part.activated;
    }
    return false;
}

fn attrInRange(attribute: ?*const AttributeComponent, attribute_id: i32, min: f32, max: f32) bool {
    const attr = attrValue(attribute, attribute_id) orelse return false;
    const value: f64 = @floatFromInt(attr);
    return value >= @as(f64, min) and value <= @as(f64, max);
}

fn attrRateInRange(attribute: ?*const AttributeComponent, attribute_id: i32, denominator: f32, min: f32, max: f32) bool {
    const denominator_id = attributeIdFromNumber(denominator) orelse return false;
    const numerator = attrValue(attribute, attribute_id) orelse return false;
    const denominator_value = attrValue(attribute, denominator_id) orelse return false;
    if (denominator_value == 0) return false;
    const rate = @as(f64, @floatFromInt(numerator)) * 10000.0 / @as(f64, @floatFromInt(denominator_value));
    return rate >= @as(f64, min) and rate <= @as(f64, max);
}

fn attributeIdFromNumber(value: f32) ?i32 {
    if (!std.math.isFinite(value) or @trunc(value) != value) return null;
    if (value < @as(f32, @floatFromInt(std.math.minInt(i32))) or
        value > @as(f32, @floatFromInt(std.math.maxInt(i32)))) return null;
    return @intFromFloat(value);
}

fn durationMs(value: f32) i64 {
    if (!std.math.isFinite(value) or value <= 0) return 0;
    const wide: f64 = value;
    const max: f64 = @floatFromInt(std.math.maxInt(i64));
    if (wide >= max) return std.math.maxInt(i64);
    return @intFromFloat(@ceil(wide));
}

fn attrValue(attribute: ?*const AttributeComponent, attribute_id: i32) ?i32 {
    if (attribute_id < 0) return null;
    const attr = attribute orelse return null;
    const index: usize = @intCast(attribute_id);
    if (index >= attr.attributes.len) return null;
    return attr.attributes[index].current;
}

fn hasTag(comp: anytype, tag_component: ?*const TagComponent, tag_id: i64) bool {
    for (comp.tags) |tag| {
        if (tag.count > 0 and gameplay_tag_hierarchy.contains(comp.tag_parents, tag.id, tag_id)) return true;
    }
    return if (tag_component) |tags| tags.hasTag(comp.tag_parents, tag_id) else false;
}

fn instanceStateMatches(comp: anytype, tag_component: ?*const TagComponent, tag_id: i64) bool {
    const expected = std.math.cast(i32, tag_id) orelse return false;
    if (comp.instance_state_tag) |state_tag| {
        return gameplay_tag_hierarchy.contains(comp.tag_parents, state_tag, expected);
    }
    return if (tag_component) |tags| tags.hasTag(comp.tag_parents, tag_id) else false;
}

fn clientPasses(comp: anytype, fsm_id: i32, transition: AiStateMachineConfig.StateMachineTransition, index: i32) bool {
    const resolved = StateHierarchy.resolveOverrideStates(comp, transition.From, transition.To, false);
    const key: Types.ConditionKey = .{
        .fsm_id = StateHierarchy.canonicalState(comp, fsm_id),
        .from = resolved.from,
        .to = resolved.to,
        .index = index,
    };
    for (comp.pass_pool) |entry| {
        if (conditionKeyEql(entry, key)) return true;
    }
    return false;
}

fn conditionKeyEql(a: Types.ConditionKey, b: Types.ConditionKey) bool {
    return a.fsm_id == b.fsm_id and
        a.from == b.from and
        a.to == b.to and
        a.index == b.index;
}
