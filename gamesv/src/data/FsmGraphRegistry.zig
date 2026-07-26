const Registry = @This();
const std = @import("std");
const DataTables = @import("DataTables.zig");

const Allocator = std.mem.Allocator;
const AiStateMachineConfig = DataTables.AiStateMachineConfig;
const Node = AiStateMachineConfig.StateMachineNode;

pub const transition_present: u8 = 1 << 0;
pub const transition_predicted: u8 = 1 << 1;
const max_state_depth = 32;

pub const TaskKind = enum {
    none,
    skill,
    skill_by_name,
    random_montage,
    leave_fight,
    montage,
    move_to_target,
    patrol,
    be_hit_montage,
    group_patrol,
    group_perform,
    unknown,
    invalid,

    pub fn isMontage(kind: TaskKind) bool {
        return kind == .random_montage or kind == .montage or kind == .be_hit_montage;
    }
};

pub const NodeMetadata = struct {
    task_kind: TaskKind = .none,
    blackboard_mask: u8 = 0,
    enter_action_count: usize = 0,
    exit_action_count: usize = 0,
    bind_count: usize = 0,
    take_control_type: i32 = 0,
};

pub const GraphNode = struct {
    key: i32,
    value: *const Node,
};

pub const Graph = struct {
    pub const empty: Graph = .{};

    hash_code: i32 = 0,
    common_hash_code: i32 = 0,
    state_list: []const i32 = &.{},
    nodes: []const GraphNode = &.{},
    exact_nodes: std.AutoHashMapUnmanaged(i32, *const Node) = .empty,
    node_metadata: std.AutoHashMapUnmanaged(i32, NodeMetadata) = .empty,
    alias_to_resolved: std.AutoHashMapUnmanaged(i32, i32) = .empty,
    resolved_to_alias: std.AutoHashMapUnmanaged(i32, i32) = .empty,
    transition_flags: std.AutoHashMapUnmanaged(u64, u8) = .empty,

    pub fn findNodeExact(graph: *const Graph, id: i32) ?*const Node {
        return graph.exact_nodes.get(id);
    }

    pub fn canonicalState(graph: *const Graph, state: i32) i32 {
        return graph.alias_to_resolved.get(state) orelse state;
    }

    pub fn clientState(graph: *const Graph, state: i32) i32 {
        const canonical = graph.canonicalState(state);
        return graph.resolved_to_alias.get(canonical) orelse canonical;
    }

    pub fn findNode(graph: *const Graph, id: i32) ?*const Node {
        const canonical = graph.canonicalState(id);
        if (graph.resolved_to_alias.get(canonical)) |alias| {
            if (graph.findNodeExact(alias)) |node| return node;
        }
        return graph.findNodeExact(canonical);
    }

    pub fn findMetadata(graph: *const Graph, id: i32) ?NodeMetadata {
        const canonical = graph.canonicalState(id);
        if (graph.resolved_to_alias.get(canonical)) |alias| {
            if (graph.node_metadata.get(alias)) |metadata| return metadata;
        }
        return graph.node_metadata.get(canonical);
    }

    pub fn transitionFlags(graph: *const Graph, from: i32, to: i32) u8 {
        return graph.transition_flags.get(edgeKey(graph.canonicalState(from), graph.canonicalState(to))) orelse 0;
    }
};

arena: std.heap.ArenaAllocator,
graphs: std.StringArrayHashMapUnmanaged(*const Graph) = .empty,

pub fn init(gpa: Allocator, tables: *const DataTables) !Registry {
    return initFromConfigs(gpa, tables.ai_state_machine_config.items);
}

fn initFromConfigs(gpa: Allocator, configs: []const AiStateMachineConfig) !Registry {
    var registry: Registry = .{ .arena = .init(gpa) };
    errdefer registry.arena.deinit();

    const common_config = for (configs) |*config| {
        if (std.mem.eql(u8, config.Id, "SM_Common")) break config;
    } else return registry;
    for (configs) |*config| {
        if (std.mem.eql(u8, config.Id, "SM_Common")) continue;
        const graph = try buildGraph(
            registry.arena.allocator(),
            config.StateMachineJson,
            common_config.StateMachineJson,
        ) orelse continue;
        const graph_ptr = try registry.arena.allocator().create(Graph);
        graph_ptr.* = graph;
        try registry.graphs.put(registry.arena.allocator(), config.Id, graph_ptr);
    }

    return registry;
}

pub fn deinit(registry: *Registry) void {
    registry.arena.deinit();
}

pub fn get(registry: *const Registry, id: []const u8) ?*const Graph {
    return registry.graphs.get(id);
}

pub fn buildGraph(
    arena: Allocator,
    state_machine_config: AiStateMachineConfig.StateMachineJsonData,
    common_state_machine: AiStateMachineConfig.StateMachineJsonData,
) !?Graph {
    var unified_nodes: std.AutoHashMapUnmanaged(i32, *const Node) = .empty;
    for (common_state_machine.Nodes) |*node| {
        try unified_nodes.put(arena, node.Uuid, node);
    }
    for (state_machine_config.Nodes) |*node| {
        try unified_nodes.put(arena, node.Uuid, node);
    }

    var graph: Graph = .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
    };

    var reference_targets: std.AutoHashMapUnmanaged(i32, i32) = .empty;
    var reference_order: std.ArrayList(i32) = .empty;
    for (common_state_machine.Nodes) |node| {
        if (node.ReferenceUuid) |target_id| {
            try putReference(&reference_targets, &reference_order, arena, node.Uuid, target_id);
        }
    }
    for (state_machine_config.Nodes) |*node| {
        if (node.OverrideCommonUuid) |common_id| {
            try graph.alias_to_resolved.put(arena, node.Uuid, common_id);
            try graph.resolved_to_alias.put(arena, common_id, node.Uuid);
        }
        if (node.ReferenceUuid) |target_id| {
            try putReference(&reference_targets, &reference_order, arena, node.Uuid, target_id);
        }
    }

    var state_list: std.ArrayList(i32) = .empty;
    for (state_machine_config.StateMachines) |root_id| {
        const effective_id = graph.resolved_to_alias.get(root_id) orelse root_id;
        if (!unified_nodes.contains(effective_id)) continue;
        if (!reference_targets.contains(effective_id)) try appendUnique(&state_list, arena, root_id);
    }
    for (reference_order.items) |alias_id| {
        const target_id = reference_targets.get(alias_id).?;
        if (!validateReferenceChain(target_id, &unified_nodes, &reference_targets, &graph)) return null;
        try appendUnique(&state_list, arena, target_id);
    }

    var nodes: std.ArrayList(GraphNode) = .empty;
    for (state_list.items) |root_id| {
        try insertWithDescendants(
            root_id,
            &unified_nodes,
            &graph.resolved_to_alias,
            &reference_targets,
            &nodes,
            arena,
        );
    }

    graph.state_list = try state_list.toOwnedSlice(arena);
    graph.nodes = nodes.items;
    for (nodes.items) |entry| {
        try putFirst(*const Node, &graph.exact_nodes, arena, entry.key, entry.value);
        try putFirst(*const Node, &graph.exact_nodes, arena, entry.value.Uuid, entry.value);
        const metadata = if (reference_targets.contains(entry.key)) NodeMetadata{} else nodeMetadata(entry.value);
        try putFirst(NodeMetadata, &graph.node_metadata, arena, entry.key, metadata);
    }

    for (nodes.items) |entry| {
        if (reference_targets.contains(entry.key)) continue;
        for (entry.value.Transitions) |transition| {
            const key = edgeKey(graph.canonicalState(transition.From), graph.canonicalState(transition.To));
            const gop = try graph.transition_flags.getOrPut(arena, key);
            if (!gop.found_existing) gop.value_ptr.* = 0;
            gop.value_ptr.* |= transition_present;
            const prediction_type = transition.TransitionPredictionType orelse 0;
            if (prediction_type == 1 or prediction_type == 2) gop.value_ptr.* |= transition_predicted;
        }
    }

    if (!hasValidInitialRoot(&graph)) return null;
    return graph;
}

pub fn taskKind(task: AiStateMachineConfig.StateMachineTask) TaskKind {
    return switch (task.Type orelse return .invalid) {
        1 => if (task.TaskSkill != null) .skill else .invalid,
        2 => if (task.TaskSkillByName != null) .skill_by_name else .invalid,
        3 => if (task.TaskRandomMontage != null) .random_montage else .invalid,
        101 => if (task.TaskLeaveFight != null) .leave_fight else .invalid,
        102 => if (task.TaskMontage != null) .montage else .invalid,
        103 => if (task.TaskMoveToTarget != null) .move_to_target else .invalid,
        104 => if (task.TaskPatrol != null) .patrol else .invalid,
        105 => if (task.TaskBeHitMontage != null) .be_hit_montage else .invalid,
        106 => if (task.TaskGroupPatrol != null) .group_patrol else .invalid,
        107 => if (task.TaskGroupPerform != null) .group_perform else .invalid,
        else => .unknown,
    };
}

pub fn actionPayloadMatches(action: AiStateMachineConfig.StateMachineAction) bool {
    return switch (action.Type orelse return false) {
        1 => action.ActionAddBuff != null,
        2 => action.ActionRemoveBuff != null,
        3 => action.ActionCastSkill != null,
        4 => action.ActionCancelSkill != null,
        7 => action.ActionResetStatus != null,
        8 => action.ActionEnterFight != null,
        9 => action.ActionCastSkillByName != null,
        10 => action.ActionCancelSkillByName != null,
        11 => action.ActionInstChangeStateTag != null,
        12 => action.ActionResetPart != null,
        13 => action.ActionActivatePart != null,
        14 => action.ActionActivateSkillGroup != null,
        15 => action.ActionDispatchEvent != null,
        19 => action.ActionSetRageFullAttribute != null,
        20 => action.ActionAddTagCount != null,
        21 => action.ActionRemoveTagCount != null,
        22 => action.ActionDispatchGameEvent != null,
        101 => action.ActionCue != null,
        102 => action.ActionStopMontage != null,
        103 => action.ActionExitHit != null,
        104 => action.ActionSendGameplayEvent != null,
        105 => action.ActionCameraLockOn != null,
        else => false,
    };
}

pub fn bindPayloadMatches(bind: AiStateMachineConfig.StateMachineBindState) bool {
    return switch (bind.Type orelse return false) {
        1 => bind.BindBuff != null,
        2 => bind.BindSkill != null,
        3 => bind.BindTag != null,
        4 => bind.BindSkillByName != null,
        6 => bind.BindSkillCounter != null,
        7 => bind.BindDelaySuicide != null,
        102 => bind.BindAiHateConfig != null,
        103 => bind.BindAiSenseEnable != null,
        104 => bind.BindCue != null,
        105 => bind.BindDisableActor != null,
        108 => bind.BindBoneVisible != null,
        109 => bind.BindMeshVisible != null,
        110 => bind.BindBoneCollision != null,
        111 => bind.BindPartPanelVisible != null,
        112 => bind.BindDeathMontage != null,
        113 => bind.BindPalsy != null,
        114 => bind.BindCollisionChannel != null,
        115 => bind.BindDisableCollision != null,
        116 => bind.BindDeathMontageByTag != null,
        else => false,
    };
}

pub fn conditionPayloadMatches(condition: AiStateMachineConfig.StateMachineCondition) bool {
    return switch (condition.Type orelse return false) {
        1 => condition.CondAnd != null,
        2 => condition.CondOr != null,
        4 => true,
        11 => condition.CondHpLessThan != null,
        13 => true,
        14 => condition.CondTag != null,
        15 => condition.CondBBValueCompare != null,
        16 => condition.CondAttrCompare != null,
        17 => condition.CondAttribute != null,
        18 => condition.CondAttributeRate != null,
        19 => condition.CondCheckState != null,
        20 => true,
        22 => condition.CondTimer != null,
        23 => true,
        24 => condition.CondCheckStateByName != null,
        25 => condition.CondInstStateChange != null,
        26 => condition.CondBuffStack != null,
        27 => condition.CondPartLife != null,
        28 => condition.CondCheckPartActivated != null,
        29 => condition.CondListenEvent != null,
        31 => condition.CondCheckLastState != null,
        32 => condition.CondCheckDissolveCombine != null,
        101 => condition.CondTaskFinish != null,
        102 => condition.CondMontageTimeRemaining != null,
        103 => condition.CondListenBeHit != null,
        104 => condition.CondHasMoveInput != null,
        105 => condition.CondMontageTimeElapsing != null,
        106 => condition.CondCheckGroupPatrol != null,
        108 => condition.CondCheckPositionState != null,
        109 => condition.CondCheckGroupPerform != null,
        else => false,
    };
}

fn nodeMetadata(node: *const Node) NodeMetadata {
    var metadata: NodeMetadata = .{
        .enter_action_count = node.OnEnterActions.len,
        .exit_action_count = node.OnExitActions.len,
        .bind_count = node.BindStates.len,
        .take_control_type = node.TakeControlType,
    };
    const task = node.Task orelse return metadata;
    metadata.task_kind = taskKind(task);
    if (task.TaskRandomMontage) |montage| {
        if (!montage.RandomByClient and montage.MontageNames.len != 0) metadata.blackboard_mask |= 1 << 1;
    }
    if (task.TaskMoveToTarget) |move| {
        if (move.TargetType == 0) metadata.blackboard_mask |= 1 << 2;
    }
    return metadata;
}

fn insertWithDescendants(
    node_id: i32,
    source: *const std.AutoHashMapUnmanaged(i32, *const Node),
    overrides: *const std.AutoHashMapUnmanaged(i32, i32),
    references: *const std.AutoHashMapUnmanaged(i32, i32),
    target: *std.ArrayList(GraphNode),
    arena: Allocator,
) !void {
    const effective_id = overrides.get(node_id) orelse node_id;
    const node = source.get(effective_id) orelse return;
    for (target.items) |entry| {
        if (entry.key == effective_id) return;
    }

    if (references.contains(effective_id)) {
        const reference_node = try arena.create(Node);
        reference_node.* = .{
            .Uuid = node.Uuid,
            .Name = node.Name,
        };
        _ = try appendNode(effective_id, reference_node, target, arena);
        return;
    }

    _ = try appendNode(effective_id, node, target, arena);
    if (node.Children) |children| {
        for (children) |child_id| {
            try insertWithDescendants(child_id, source, overrides, references, target, arena);
        }
    }
}

fn appendNode(
    key: i32,
    node: *const Node,
    nodes: *std.ArrayList(GraphNode),
    arena: Allocator,
) !bool {
    for (nodes.items) |entry| {
        if (entry.key == key) return false;
    }
    try nodes.append(arena, .{ .key = key, .value = node });
    return true;
}

fn appendUnique(list: *std.ArrayList(i32), arena: Allocator, value: i32) !void {
    if (std.mem.indexOfScalar(i32, list.items, value) == null) try list.append(arena, value);
}

fn putReference(
    targets: *std.AutoHashMapUnmanaged(i32, i32),
    order: *std.ArrayList(i32),
    arena: Allocator,
    alias_id: i32,
    target_id: i32,
) !void {
    const gop = try targets.getOrPut(arena, alias_id);
    if (!gop.found_existing) try order.append(arena, alias_id);
    gop.value_ptr.* = target_id;
}

fn validateReferenceChain(
    start_id: i32,
    nodes: *const std.AutoHashMapUnmanaged(i32, *const Node),
    references: *const std.AutoHashMapUnmanaged(i32, i32),
    graph: *const Graph,
) bool {
    var path: [max_state_depth]i32 = @splat(0);
    var len: usize = 0;
    var current = start_id;

    while (true) {
        const effective_id = graph.resolved_to_alias.get(current) orelse current;
        if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], effective_id) != null) return false;
        path[len] = effective_id;
        len += 1;

        if (!nodes.contains(effective_id)) return false;
        const target_id = references.get(effective_id) orelse return true;
        current = target_id;
    }
}

fn hasValidInitialRoot(graph: *const Graph) bool {
    for (graph.state_list) |raw_id| {
        var path: [max_state_depth]i32 = @splat(0);
        var len: usize = 0;
        var current = graph.canonicalState(raw_id);

        while (true) {
            if (len >= path.len or std.mem.indexOfScalar(i32, path[0..len], current) != null) break;
            path[len] = current;
            len += 1;

            const node = graph.findNode(current) orelse break;
            const children = node.Children orelse return true;
            if (children.len == 0) return true;
            current = graph.canonicalState(children[0]);
        }
    }

    return false;
}

fn putFirst(
    comptime V: type,
    map: *std.AutoHashMapUnmanaged(i32, V),
    allocator: Allocator,
    key: i32,
    value: V,
) !void {
    const gop = try map.getOrPut(allocator, key);
    if (!gop.found_existing) gop.value_ptr.* = value;
}

fn edgeKey(from: i32, to: i32) u64 {
    const from_bits: u32 = @bitCast(from);
    const to_bits: u32 = @bitCast(to);
    return (@as(u64, from_bits) << 32) | @as(u64, to_bits);
}
