const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const Types = @import("Types.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

pub fn stateContains(comp: anytype, ancestor: i32, target: i32, depth: usize) bool {
    if (depth > Types.max_state_depth) return false;
    if (statesEquivalent(comp, ancestor, target)) return true;

    const node = findNode(comp, ancestor) orelse return false;
    const children = node.Children orelse return false;
    for (children) |child| {
        if (statesEquivalent(comp, child, target)) return true;
        if (stateContains(comp, child, target, depth + 1)) return true;
    }

    return false;
}

pub fn statesEquivalent(comp: anytype, a: i32, b: i32) bool {
    return canonicalState(comp, a) == canonicalState(comp, b);
}

pub fn stateBelongsToFsm(comp: anytype, fsm_id: i32, state: i32) bool {
    return stateContains(comp, canonicalState(comp, fsm_id), canonicalState(comp, state), 0);
}

pub fn runtimeNode(comp: anytype, fsm_id: i32) ?*Types.FsmNode {
    const canonical_fsm_id = canonicalState(comp, fsm_id);
    for (comp.runtime_nodes) |*runtime| {
        if (runtime.fsm_id == canonical_fsm_id) return runtime;
    }

    return null;
}

pub fn findNode(comp: anytype, id: i32) ?*const AiStateMachineConfig.StateMachineNode {
    return comp.graph.findNode(id);
}

pub fn findNodeExact(comp: anytype, id: i32) ?*const AiStateMachineConfig.StateMachineNode {
    return comp.graph.findNodeExact(id);
}

pub fn isConduitState(comp: anytype, state: i32) bool {
    const node = findNode(comp, state) orelse return false;
    return node.IsConduitNode;
}

pub fn validateBehavior(
    comp: anytype,
    fsm_id: i32,
    state: i32,
    index: i32,
    behavior_type: i32,
) Types.BehaviorValidation {
    const runtime = runtimeNode(comp, fsm_id) orelse return .machine_not_found;
    if (!stateBelongsToFsm(comp, runtime.fsm_id, state)) return .invalid_state;

    const path_matches = switch (behavior_type) {
        0, 2, 4 => pathContains(comp, runtime.active(), state) or pathContains(comp, runtime.pending(), state),
        1, 3 => pathContains(comp, runtime.previous(), state),
        else => return .invalid_behavior,
    };
    if (!path_matches) return .inactive_state;
    if (index < 0) return .invalid_behavior;

    const node = findNode(comp, state) orelse return .invalid_state;
    const metadata = comp.graph.findMetadata(state) orelse return .invalid_state;
    const behavior_index: usize = @intCast(index);
    return switch (behavior_type) {
        0 => if (behavior_index < metadata.enter_action_count and
            Assets.FsmGraphRegistry.actionPayloadMatches(node.OnEnterActions[behavior_index])) .valid else .invalid_behavior,
        1 => if (behavior_index < metadata.exit_action_count and
            Assets.FsmGraphRegistry.actionPayloadMatches(node.OnExitActions[behavior_index])) .valid else .invalid_behavior,
        2, 3 => if (behavior_index < metadata.bind_count and
            Assets.FsmGraphRegistry.bindPayloadMatches(node.BindStates[behavior_index])) .valid else .invalid_behavior,
        4 => if (behavior_index == 0 and metadata.task_kind != .none and
            metadata.task_kind != .unknown and metadata.task_kind != .invalid) .valid else .invalid_behavior,
        else => .invalid_behavior,
    };
}

pub fn clientTaskRequirementSatisfied(
    comp: anytype,
    path: []const i32,
    from_state: i32,
    to_state: i32,
    requirement: Types.ClientConditionRequirement,
) bool {
    if (requirement == .none) return true;
    if (path.len == 0) return false;
    return switch (requirement) {
        .none => true,
        .task => taskKindIsUsable(comp, path[path.len - 1]),
        .montage => (comp.graph.findMetadata(from_state) orelse return false).task_kind.isMontage(),
        .group_patrol => (comp.graph.findMetadata(to_state) orelse return false).task_kind == .group_patrol,
        .group_perform => (comp.graph.findMetadata(to_state) orelse return false).task_kind == .group_perform,
    };
}

fn taskKindIsUsable(comp: anytype, state: i32) bool {
    const kind = (comp.graph.findMetadata(state) orelse return false).task_kind;
    return kind != .none and kind != .unknown and kind != .invalid;
}

pub fn canonicalState(comp: anytype, state: i32) i32 {
    return comp.graph.canonicalState(state);
}

pub fn clientState(comp: anytype, state: i32) i32 {
    return comp.graph.clientState(state);
}

pub fn pathContains(comp: anytype, path: []const i32, state: i32) bool {
    const canonical_state = canonicalState(comp, state);
    for (path) |active_state| {
        if (active_state == canonical_state) return true;
    }
    return false;
}

pub fn buildInitialPath(comp: anytype, fsm_id: i32, path: *[Types.max_state_depth]i32) ?usize {
    var len: usize = 0;
    var current = canonicalState(comp, fsm_id);

    while (true) {
        if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], current) != null) return null;
        path[len] = current;
        len += 1;

        const node = findNode(comp, current) orelse return null;
        const children = node.Children orelse break;
        if (children.len == 0) break;
        current = canonicalState(comp, children[0]);
    }

    return len;
}

pub fn buildActivePath(comp: anytype, fsm_id: i32, target_state: i32, path: *[Types.max_state_depth]i32) ?usize {
    var len: usize = 0;
    if (!findPathToState(comp, canonicalState(comp, fsm_id), canonicalState(comp, target_state), path, &len, 0)) return null;

    var current = path[len - 1];
    while (true) {
        const node = findNode(comp, current) orelse return null;
        const children = node.Children orelse break;
        if (children.len == 0) break;

        current = canonicalState(comp, children[0]);
        if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], current) != null) return null;
        path[len] = current;
        len += 1;
    }

    return len;
}

fn findPathToState(
    comp: anytype,
    current_state: i32,
    target_state: i32,
    path: *[Types.max_state_depth]i32,
    len: *usize,
    depth: usize,
) bool {
    if (depth >= Types.max_state_depth or len.* >= path.len) return false;

    const canonical_current = canonicalState(comp, current_state);
    if (std.mem.indexOfScalar(i32, path[0..len.*], canonical_current) != null) return false;
    path[len.*] = canonical_current;
    len.* += 1;

    if (canonical_current == canonicalState(comp, target_state)) return true;

    if (findNode(comp, canonical_current)) |node| {
        if (node.Children) |children| {
            for (children) |child| {
                if (findPathToState(comp, child, target_state, path, len, depth + 1)) return true;
            }
        }
    }

    len.* -= 1;
    return false;
}

pub fn resolveOverrideStates(comp: anytype, from: i32, to: i32, reverse: bool) Types.ResolvedStates {
    if (reverse) {
        return .{
            .from = clientState(comp, from),
            .to = clientState(comp, to),
        };
    }

    return .{
        .from = canonicalState(comp, from),
        .to = canonicalState(comp, to),
    };
}

pub fn commonPathPrefixLen(a: []const i32, b: []const i32) usize {
    var len: usize = 0;
    while (len < a.len and len < b.len and a[len] == b[len]) : (len += 1) {}
    return len;
}
