const Registry = @This();
const std = @import("std");
const DataTables = @import("DataTables.zig");

const Allocator = std.mem.Allocator;
const AiStateMachineConfig = DataTables.AiStateMachineConfig;
const Node = AiStateMachineConfig.StateMachineNode;

pub const transition_present: u8 = 1 << 0;
pub const transition_predicted: u8 = 1 << 1;
const max_state_depth = 32;

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
    alias_to_resolved: std.AutoHashMapUnmanaged(i32, i32) = .empty,
    resolved_to_alias: std.AutoHashMapUnmanaged(i32, i32) = .empty,
    transition_flags: std.AutoHashMapUnmanaged(u64, u8) = .empty,
    server_montage_count: ?usize = null,

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
    if (!hasDeclaredRoot(state_machine_config, common_state_machine)) return null;

    var state_list: std.ArrayList(i32) = .empty;
    try state_list.appendSlice(arena, state_machine_config.StateMachines);

    var nodes: std.ArrayList(GraphNode) = .empty;
    var common_nodes: std.AutoHashMapUnmanaged(i32, *const Node) = .empty;
    var common_custom_nodes: std.AutoHashMapUnmanaged(i32, *const Node) = .empty;
    for (common_state_machine.Nodes) |*node| {
        try putFirst(*const Node, &common_nodes, arena, node.Uuid, node);
        if (node.kind() == .custom) try putFirst(*const Node, &common_custom_nodes, arena, node.Uuid, node);
    }

    var graph: Graph = .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
    };

    for (state_machine_config.Nodes) |*node| {
        switch (node.kind()) {
            .reference => {
                const ref_uuid = node.ReferenceUuid.?;
                const reference = common_custom_nodes.get(ref_uuid) orelse continue;

                if (std.mem.indexOfScalar(i32, state_list.items, node.Uuid) != null) {
                    try state_list.append(arena, ref_uuid);
                }
                try insertWithDescendants(ref_uuid, reference, &common_nodes, &nodes, arena);
            },
            .override => {
                try putFirst(i32, &graph.alias_to_resolved, arena, node.Uuid, node.OverrideCommonUuid.?);
                try putFirst(i32, &graph.resolved_to_alias, arena, node.OverrideCommonUuid.?, node.Uuid);
                try nodes.append(arena, .{ .key = node.Uuid, .value = node });
            },
            .custom => try nodes.append(arena, .{ .key = node.Uuid, .value = node }),
        }
    }

    graph.state_list = try state_list.toOwnedSlice(arena);
    graph.nodes = nodes.items;
    for (nodes.items) |entry| {
        try putFirst(*const Node, &graph.exact_nodes, arena, entry.key, entry.value);
        try putFirst(*const Node, &graph.exact_nodes, arena, entry.value.Uuid, entry.value);

        if (entry.value.Task) |task| {
            if (task.TaskRandomMontage) |montage| {
                if (!montage.RandomByClient and montage.MontageNames.len != 0) {
                    graph.server_montage_count = if (graph.server_montage_count) |count|
                        @min(count, montage.MontageNames.len)
                    else
                        montage.MontageNames.len;
                }
            }
        }
    }

    for (nodes.items) |entry| {
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

fn hasDeclaredRoot(
    entity: AiStateMachineConfig.StateMachineJsonData,
    common: AiStateMachineConfig.StateMachineJsonData,
) bool {
    for (entity.StateMachines) |root_id| {
        for (entity.Nodes) |node| {
            if (node.Uuid != root_id) continue;
            const effective_id = node.ReferenceUuid orelse node.Uuid;
            const nodes = if (node.ReferenceUuid != null) common.Nodes else entity.Nodes;
            for (nodes) |candidate| {
                if (candidate.Uuid == effective_id) return true;
            }
        }
    }

    return false;
}

fn insertWithDescendants(
    node_id: i32,
    node: *const Node,
    source: *const std.AutoHashMapUnmanaged(i32, *const Node),
    target: *std.ArrayList(GraphNode),
    arena: Allocator,
) !void {
    for (target.items) |entry| {
        if (entry.key == node_id) return;
    }

    try target.append(arena, .{ .key = node_id, .value = node });
    if (node.Children) |children| {
        for (children) |child_id| {
            const child = source.get(child_id) orelse continue;
            try insertWithDescendants(child_id, child, source, target, arena);
        }
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
