const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const StateHierarchy = @import("StateHierarchy.zig");
const Types = @import("Types.zig");

const montage_blackboard_key = 1;

pub fn toProto(comp: anytype, arena: mem.Allocator, assets: *const Assets) !pb.EntityFsmComponentPb {
    return .{
        .Fsms = try getInitialFsm(comp, arena, assets),
        .HashCode = comp.hash_code,
        .CommonHashCode = comp.common_hash_code,
        .BlackBoard = try blackboardToProto(comp, arena, null),
        .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
    };
}

pub fn appendBlackboardNotify(
    comp: anytype,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
) !void {
    const dirty = comp.blackboard_dirty;
    if (dirty == 0) return;

    const values = try blackboardToProto(comp, allocator, dirty);
    if (values.items.len == 0) {
        comp.blackboard_dirty &= ~dirty;
        return;
    }

    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmBlackboardNotify = .{ .FsmBlackBoards = values } },
        },
    } });
    comp.blackboard_dirty &= ~dirty;
}

pub fn appendResetNotify(
    comp: anytype,
    entity_id: i64,
    allocator: mem.Allocator,
    output: *std.ArrayList(pb.CombatReceiveData),
    assets: *const Assets,
) !void {
    const blackboard = try blackboardSnapshotToProto(comp, allocator);
    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmBlackboardNotify = .{ .FsmBlackBoards = blackboard } },
        },
    } });
    try output.append(allocator, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .FsmResetNotify = .{
                .EntityFsmComponentPb = .{
                    .Fsms = try getInitialFsm(comp, allocator, assets),
                    .HashCode = comp.hash_code,
                    .CommonHashCode = comp.common_hash_code,
                    .BlackBoard = blackboard,
                    .FsmCustomBlackboardDatas = .{ .BlackboardIntValues = .empty },
                },
            } },
        },
    } });
    comp.blackboard_dirty = 0;
}

pub fn getInitialFsm(
    comp: anytype,
    arena: mem.Allocator,
    assets: *const Assets,
) !std.ArrayList(pb.DFsm) {
    _ = assets;

    var result: std.ArrayList(pb.DFsm) = try .initCapacity(arena, 1);

    if (comp.runtime_nodes.len != 0) {
        for (comp.runtime_nodes) |runtime| {
            const node = StateHierarchy.findNode(comp, runtime.fsm_id);
            const current_state = runtime.leaf() orelse continue;
            try result.append(arena, .{
                .FsmId = StateHierarchy.clientState(comp, runtime.fsm_id),
                .CurrentState = StateHierarchy.clientState(comp, current_state),
                .Flag = if (node) |entry| if (entry.IsAnimStateMachine orelse false) 1 else 0 else 0,
                .StateElapseTime = elapsedTime(comp.last_tick_ms, runtime.active_since_ms[runtime.active_len - 1]),
            });
        }
        return result;
    }

    var seen_roots: [Types.max_state_depth]i32 = @splat(0);
    var seen_len: usize = 0;
    for (comp.state_list) |raw_id| {
        const id = StateHierarchy.canonicalState(comp, raw_id);
        if (std.mem.indexOfScalar(i32, seen_roots[0..seen_len], id) != null) continue;
        if (seen_len >= seen_roots.len) return error.FsmRootLimitExceeded;
        seen_roots[seen_len] = id;
        seen_len += 1;

        const node = StateHierarchy.findNode(comp, id) orelse continue;
        var active_path: [Types.max_state_depth]i32 = @splat(0);
        const active_len = StateHierarchy.buildInitialPath(comp, id, &active_path) orelse continue;
        try result.append(arena, .{
            .FsmId = StateHierarchy.clientState(comp, id),
            .CurrentState = StateHierarchy.clientState(comp, active_path[active_len - 1]),
            .Flag = if (node.IsAnimStateMachine orelse false) 1 else 0,
            .StateElapseTime = 0,
        });
    }

    return result;
}

pub fn prepareInitial(comp: anytype, now_ms: i64) void {
    var minimum_montage_count: ?usize = null;
    for (comp.node_list) |entry| {
        const task = entry.value.Task orelse continue;
        const montage = task.TaskRandomMontage orelse continue;
        if (montage.RandomByClient or montage.MontageNames.len == 0) continue;
        minimum_montage_count = if (minimum_montage_count) |count|
            @min(count, montage.MontageNames.len)
        else
            montage.MontageNames.len;
    }

    if (minimum_montage_count) |count| {
        set(comp, montage_blackboard_key, selectMontageIndex(comp, 0, now_ms, count), false);
    }
}

pub fn preparePath(comp: anytype, path: []const i32, activated_at: []const i64, mark_dirty: bool) void {
    for (path, 0..) |state, index| {
        const node = StateHierarchy.findNode(comp, state) orelse continue;
        const task = node.Task orelse continue;
        if (task.TaskRandomMontage) |montage| {
            if (!montage.RandomByClient and montage.MontageNames.len != 0) {
                set(
                    comp,
                    montage_blackboard_key,
                    selectMontageIndex(comp, state, activated_at[index], montage.MontageNames.len),
                    mark_dirty,
                );
            }
        }
    }
}

pub fn setValue(comp: anytype, key: usize, value: ?i32, mark_dirty: bool) bool {
    if (key >= comp.blackboard.len or comp.blackboard[key] == value) return false;
    comp.blackboard[key] = value;
    if (mark_dirty) comp.blackboard_dirty |= blackboardBit(key);
    return true;
}

fn blackboardToProto(comp: anytype, arena: mem.Allocator, dirty: ?u8) !std.ArrayList(pb.DFsmBlackBoard) {
    var result: std.ArrayList(pb.DFsmBlackBoard) = .empty;
    for (comp.blackboard[1..], 1..) |value, key| {
        const bit = blackboardBit(key);
        if (dirty) |mask| {
            if (mask & bit == 0) continue;
            try result.append(arena, .{ .Key = @intCast(key), .Value = value orelse 0 });
            continue;
        }
        if (value) |entry| {
            try result.append(arena, .{ .Key = @intCast(key), .Value = entry });
        }
    }
    return result;
}

fn blackboardSnapshotToProto(comp: anytype, arena: mem.Allocator) !std.ArrayList(pb.DFsmBlackBoard) {
    var result: std.ArrayList(pb.DFsmBlackBoard) = .empty;
    for (comp.blackboard[1..], 1..) |value, key| {
        try result.append(arena, .{ .Key = @intCast(key), .Value = value orelse 0 });
    }
    return result;
}

fn set(comp: anytype, key: usize, value: i32, mark_dirty: bool) void {
    _ = setValue(comp, key, value, mark_dirty);
}

fn blackboardBit(key: usize) u8 {
    return @as(u8, 1) << @intCast(key);
}

fn selectMontageIndex(comp: anytype, state: i32, activated_at: i64, count: usize) i32 {
    var seed: u64 = @bitCast(activated_at);
    const state_bits: u32 = @bitCast(state);
    const hash_bits: u32 = @bitCast(comp.hash_code);
    seed ^= @as(u64, state_bits) *% 0x9E3779B185EBCA87;
    seed ^= @as(u64, hash_bits) *% 0xC2B2AE3D27D4EB4F;
    seed ^= seed >> 12;
    seed ^= seed << 25;
    seed ^= seed >> 27;
    return @intCast(seed % count);
}

fn elapsedTime(now_ms: i64, activated_at: i64) i32 {
    if (now_ms <= activated_at) return 0;
    return @intCast(@min(now_ms - activated_at, std.math.maxInt(i32)));
}
