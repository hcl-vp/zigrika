const std = @import("std");
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const StateHierarchy = @import("StateHierarchy.zig");
const Types = @import("Types.zig");

const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;
const log = std.log.scoped(.fsm_config);

pub fn fromAiBaseId(
    comptime Component: type,
    ai_id: ?i32,
    assets: *const Assets,
    gpa: mem.Allocator,
) !?Component {
    const configs = findAiStateMachineConfigs(ai_id, assets) orelse return null;
    return fromConfig(Component, configs.entity, configs.common, gpa);
}

pub fn hasUsableAiBaseId(ai_id: ?i32, assets: *const Assets) bool {
    return findAiStateMachineConfigs(ai_id, assets) != null;
}

pub fn fromStateMachineId(
    comptime Component: type,
    id: []const u8,
    assets: *const Assets,
    gpa: mem.Allocator,
) !Component {
    const configs = findStateMachineConfigs(id, assets) orelse return error.InvalidFsmConfiguration;
    return (try fromConfig(Component, configs.entity, configs.common, gpa)) orelse error.InvalidFsmConfiguration;
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return assets.tables.ai_state_machine_config.getDataById("SM_Common");
}

fn findAiStateMachineConfigs(ai_id: ?i32, assets: *const Assets) ?Types.StateMachineConfigs {
    const id = ai_id orelse return null;
    if (id <= 0) return null;

    const ai_base = assets.tables.ai_base.getDataById(id) orelse return null;
    return findStateMachineConfigs(ai_base.StateMachine, assets);
}

fn findStateMachineConfigs(id: []const u8, assets: *const Assets) ?Types.StateMachineConfigs {
    if (id.len == 0) return null;
    const common = getCommonFsm(assets) orelse return null;
    const entity = assets.tables.ai_state_machine_config.getDataById(id) orelse return null;
    if (!hasDeclaredRoot(entity.StateMachineJson, common.StateMachineJson)) return null;

    return .{
        .entity = entity.StateMachineJson,
        .common = common.StateMachineJson,
    };
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

fn fromConfig(
    comptime Component: type,
    state_machine_config: AiStateMachineConfig.StateMachineJsonData,
    common_state_machine: AiStateMachineConfig.StateMachineJsonData,
    gpa: mem.Allocator,
) !?Component {
    var state_list: std.ArrayList(i32) = try .initCapacity(gpa, 1);
    defer state_list.deinit(gpa);
    try state_list.appendSlice(gpa, state_machine_config.StateMachines);

    var fsm_tree: std.ArrayList(Types.NodeEntry) = try .initCapacity(gpa, 1);
    defer fsm_tree.deinit(gpa);

    var override_mapping: std.ArrayList(Types.OverrideEntry) = try .initCapacity(gpa, 1);
    defer override_mapping.deinit(gpa);

    for (state_machine_config.Nodes) |node| {
        switch (node.kind()) {
            .reference => {
                const ref_uuid = node.ReferenceUuid.?;
                const reference = for (common_state_machine.Nodes) |common_node| {
                    if (common_node.kind() == .custom and common_node.Uuid == ref_uuid)
                        break common_node;
                } else null;

                if (reference) |ref_node| {
                    const in_state_list = for (state_list.items) |sid| {
                        if (sid == node.Uuid) break true;
                    } else false;

                    if (in_state_list) try state_list.append(gpa, ref_uuid);
                    try insertWithDescendants(ref_node.Uuid, ref_node, common_state_machine, &fsm_tree, gpa);
                }
            },
            .override => {
                try override_mapping.append(gpa, .{
                    .key = node.Uuid,
                    .value = node.OverrideCommonUuid.?,
                });
                try fsm_tree.append(gpa, .{ .key = node.Uuid, .value = node });
            },
            .custom => try fsm_tree.append(gpa, .{ .key = node.Uuid, .value = node }),
        }
    }

    var component: Component = .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
        .state_list = try state_list.toOwnedSlice(gpa),
        .node_list = try fsm_tree.toOwnedSlice(gpa),
        .override_mapping = try override_mapping.toOwnedSlice(gpa),
    };
    if (!hasValidInitialRoot(&component)) {
        component.deinit(gpa);
        return null;
    }

    return component;
}

fn hasValidInitialRoot(comp: anytype) bool {
    for (comp.state_list) |fsm_id| {
        var path: [Types.max_state_depth]i32 = @splat(0);
        if (StateHierarchy.buildInitialPath(comp, fsm_id, &path) != null) return true;
    }

    return false;
}

fn insertWithDescendants(
    node_id: i32,
    node: AiStateMachineConfig.StateMachineNode,
    source: AiStateMachineConfig.StateMachineJsonData,
    target: *std.ArrayList(Types.NodeEntry),
    gpa: mem.Allocator,
) !void {
    const already_exists = for (target.items) |entry| {
        if (entry.key == node_id) break true;
    } else false;

    if (already_exists) return;

    try target.append(gpa, .{ .key = node_id, .value = node });

    if (node.Children) |children| {
        for (children) |child_id| {
            const child_node = for (source.Nodes) |source_node| {
                if (source_node.Uuid == child_id) break source_node;
            } else null;

            if (child_node) |child| {
                try insertWithDescendants(child_id, child, source, target, gpa);
            } else {
                log.warn("Child node {} of parent {} not found in source_nodes", .{ child_id, node_id });
            }
        }
    }
}
