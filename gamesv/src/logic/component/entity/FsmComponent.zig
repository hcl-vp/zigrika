const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;
const Assets = @import("../../../data/Assets.zig");
const AiStateMachineConfig = Assets.DataTables.AiStateMachineConfig;

const log = std.log.scoped(.fsm_component);

const NodeEntry = struct {
    key: i32,
    value: AiStateMachineConfig.StateMachineNode,
};

const OverrideEntry = struct {
    key: i32,
    value: i32,
};

hash_code: i32 = 0,
common_hash_code: i32 = 0,
state_list: []const i32 = &.{},
node_list: []const NodeEntry = &.{},
override_mapping: []const OverrideEntry = &.{},

pub fn deinit(comp: *Component, gpa: mem.Allocator) void {
    gpa.free(comp.state_list);
    gpa.free(comp.node_list);
    gpa.free(comp.override_mapping);
}

pub fn toProto(comp: Component, arena: mem.Allocator, assets: *const Assets) !pb.EntityFsmComponentPb {
    return .{
        .Fsms = try comp.getInitialFsm(arena, assets),
        .HashCode = comp.hash_code,
        .CommonHashCode = comp.common_hash_code,
        .BlackBoard = .empty,
        .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
    };
}

pub fn fromAiBaseId(ai_id: ?i32, assets: *const Assets, gpa: mem.Allocator) !Component {
    const common_fsm = getCommonFsm(assets) orelse {
        log.warn("Common state machine missing", .{});
        return .{};
    };

    const ai_base = assets.tables.ai_base.getDataById(ai_id orelse {
        return .{};
    }) orelse {
        log.warn("Ai base with id {?} not found", .{ai_id});
        return .{};
    };

    const entry = assets.tables.ai_state_machine_config.getDataById(ai_base.StateMachine) orelse {
        log.warn("Requested state machine with id {s} not found in config", .{ai_base.StateMachine});
        return .{};
    };

    const state_machine_config = entry.StateMachineJson;
    const common_state_machine = common_fsm.StateMachineJson;

    var state_list: std.ArrayList(i32) = try .initCapacity(gpa, 1);
    defer state_list.deinit(gpa);
    try state_list.appendSlice(gpa, state_machine_config.StateMachines);

    var fsm_tree: std.ArrayList(NodeEntry) = try .initCapacity(gpa, 1);
    defer fsm_tree.deinit(gpa);

    var override_mapping: std.ArrayList(OverrideEntry) = try .initCapacity(gpa, 1);
    defer override_mapping.deinit(gpa);

    for (state_machine_config.StateMachines) |_| {
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

                        if (in_state_list) {
                            try state_list.append(gpa, ref_uuid);
                        }

                        try insertWithDescendants(
                            ref_node.Uuid,
                            ref_node,
                            common_state_machine,
                            &fsm_tree,
                            gpa,
                        );
                    }
                },
                .override => {
                    try override_mapping.append(gpa, .{
                        .key = node.Uuid,
                        .value = node.OverrideCommonUuid.?,
                    });
                    try fsm_tree.append(gpa, .{
                        .key = node.Uuid,
                        .value = node,
                    });
                },
                .custom => {
                    try fsm_tree.append(gpa, .{
                        .key = node.Uuid,
                        .value = node,
                    });
                },
            }
        }
    }

    return .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
        .state_list = try state_list.toOwnedSlice(gpa),
        .node_list = try fsm_tree.toOwnedSlice(gpa),
        .override_mapping = try override_mapping.toOwnedSlice(gpa),
    };
}

pub fn fromStateMachineId(id: []const u8, assets: *const Assets, gpa: mem.Allocator) !Component {
    const common_fsm = getCommonFsm(assets) orelse {
        log.warn("Common state machine missing", .{});
        return .{};
    };

    const entry = assets.tables.ai_state_machine_config.getDataById(id) orelse {
        log.warn("Requested state machine with id {s} not found in config", .{id});
        return .{};
    };

    const state_machine_config = entry.StateMachineJson;
    const common_state_machine = common_fsm.StateMachineJson;

    var state_list: std.ArrayList(i32) = try .initCapacity(gpa, 1);
    defer state_list.deinit(gpa);
    try state_list.appendSlice(gpa, state_machine_config.StateMachines);

    var fsm_tree: std.ArrayList(NodeEntry) = try .initCapacity(gpa, 1);
    defer fsm_tree.deinit(gpa);

    var override_mapping: std.ArrayList(OverrideEntry) = try .initCapacity(gpa, 1);
    defer override_mapping.deinit(gpa);

    for (state_machine_config.StateMachines) |_| {
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

                        if (in_state_list) {
                            try state_list.append(gpa, ref_uuid);
                        }

                        try insertWithDescendants(
                            ref_node.Uuid,
                            ref_node,
                            common_state_machine,
                            &fsm_tree,
                            gpa,
                        );
                    }
                },
                .override => {
                    try override_mapping.append(gpa, .{
                        .key = node.Uuid,
                        .value = node.OverrideCommonUuid.?,
                    });
                },
                .custom => {
                    try fsm_tree.append(gpa, .{
                        .key = node.Uuid,
                        .value = node,
                    });
                },
            }
        }
    }

    return .{
        .hash_code = state_machine_config.Version,
        .common_hash_code = common_state_machine.Version,
        .state_list = try state_list.toOwnedSlice(gpa),
        .node_list = try fsm_tree.toOwnedSlice(gpa),
        .override_mapping = try override_mapping.toOwnedSlice(gpa),
    };
}

pub fn getInitialFsm(
    comp: *const Component,
    arena: mem.Allocator,
    assets: *const Assets,
) !std.ArrayList(pb.DFsm) {
    var result: std.ArrayList(pb.DFsm) = try .initCapacity(arena, 1);

    for (comp.node_list) |entry| {
        const id = entry.key;
        const node = entry.value;

        const is_state_list = for (comp.state_list) |state_id| {
            if (state_id == id) break true;
        } else false;

        if (!is_state_list) continue;

        const common_fsm = getCommonFsm(assets) orelse {
            log.warn("Common state machine missing", .{});
            return .empty;
        };

        try result.append(arena, .{
            .FsmId = id,
            .CurrentState = getDeepestChild(node, common_fsm.StateMachineJson),
            .Flag = if (node.IsAnimStateMachine orelse false) 1 else 0,
            .StateElapseTime = 0,
        });
    }

    return result;
}

pub fn getCommonFsm(assets: *const Assets) ?AiStateMachineConfig {
    return assets.tables.ai_state_machine_config.getDataById("SM_Common");
}

fn getDeepestChild(
    node: AiStateMachineConfig.StateMachineNode,
    source: AiStateMachineConfig.StateMachineJsonData,
) i32 {
    if (node.Children) |children| {
        if (children.len > 0) {
            const first_child_id = children[0];

            const child_node = for (source.Nodes) |source_node| {
                if (source_node.Uuid == first_child_id) {
                    switch (source_node.kind()) {
                        .custom, .reference, .override => break source_node,
                    }
                }
            } else null;

            if (child_node) |child| {
                return getDeepestChild(child, source);
            }
        }
    }

    return node.Uuid;
}

fn insertWithDescendants(
    node_id: i32,
    node: AiStateMachineConfig.StateMachineNode,
    source: AiStateMachineConfig.StateMachineJsonData,
    target: *std.ArrayList(NodeEntry),
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
