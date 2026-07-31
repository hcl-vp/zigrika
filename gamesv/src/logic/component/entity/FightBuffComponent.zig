const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

pub const default: @This() = .{};

pub const FsmBindBuffSource = struct {
    fsm_id: i32,
    state: i32,
    bind_index: i32,

    fn eql(a: FsmBindBuffSource, b: FsmBindBuffSource) bool {
        return a.fsm_id == b.fsm_id and a.state == b.state and a.bind_index == b.bind_index;
    }
};

pub const FsmBindBuffLease = struct {
    source: FsmBindBuffSource,
    handle_id: i32,
};

pub const FsmBindBuffRelease = union(enum) {
    preserve,
    remove: i32,
};

fight_buff_infos: []pb.FightBuffInformation = &.{},
buff_effect_cds: []pb.BuffEffectCd = &.{},
born_buff_ids: []i64 = &.{},
born_message_id: i64 = 0,
fsm_bind_buff_leases: []FsmBindBuffLease = &.{},
fsm_owned_buff_handles: []i32 = &.{},

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.fight_buff_infos);
    gpa.free(comp.buff_effect_cds);
    gpa.free(comp.born_buff_ids);
    gpa.free(comp.fsm_bind_buff_leases);
    gpa.free(comp.fsm_owned_buff_handles);
}

pub fn toProto(comp: Component) pb.FightBuffComponentPb {
    return .{
        .FightBuffInfos = sliceToArrayList(pb.FightBuffInformation, comp.fight_buff_infos),
        .ListBuffEffectCd = sliceToArrayList(pb.BuffEffectCd, comp.buff_effect_cds),
        .ClientBornBuffIds = sliceToArrayList(i64, comp.born_buff_ids),
        .ClientBornMessageId = comp.born_message_id,
    };
}

pub fn removeByHandleId(comp: *Component, gpa: std.mem.Allocator, handle_id: i32) void {
    const infos = comp.fight_buff_infos;
    const idx = for (infos, 0..) |info, i| {
        if (info.HandleId == handle_id) break i;
    } else return;

    comp.clearFsmBindHandle(gpa, handle_id);
    infos[idx] = infos[infos.len - 1];
    comp.fight_buff_infos = gpa.realloc(infos, infos.len - 1) catch infos[0 .. infos.len - 1];
}

pub fn getByBuffId(comp: *Component, buff_id: i64) ?*pb.FightBuffInformation {
    for (comp.fight_buff_infos) |*info| {
        if (info.BuffId == buff_id) return info;
    } else return null;
}

pub fn getByHandleId(comp: *Component, handle_id: i32) ?*pb.FightBuffInformation {
    for (comp.fight_buff_infos) |*info| {
        if (info.HandleId == handle_id) return info;
    } else return null;
}

pub fn prepareFsmBindAcquire(
    comp: *Component,
    gpa: std.mem.Allocator,
    source: FsmBindBuffSource,
) bool {
    for (comp.fsm_bind_buff_leases) |lease| {
        if (!lease.source.eql(source)) continue;
        if (comp.getByHandleId(lease.handle_id) != null) return false;
        comp.clearFsmBindHandle(gpa, lease.handle_id);
        return true;
    }
    return true;
}

pub fn addFsmBindLease(
    comp: *Component,
    gpa: std.mem.Allocator,
    source: FsmBindBuffSource,
    handle_id: i32,
    owns_handle: bool,
) !void {
    const add_owned_handle = owns_handle and !comp.fsmOwnsHandle(handle_id);
    const old_handles = comp.fsm_owned_buff_handles;
    const new_handles = if (add_owned_handle) blk: {
        const handles = try gpa.alloc(i32, old_handles.len + 1);
        @memcpy(handles[0..old_handles.len], old_handles);
        handles[old_handles.len] = handle_id;
        break :blk handles;
    } else null;
    errdefer if (new_handles) |handles| gpa.free(handles);

    const old_leases = comp.fsm_bind_buff_leases;
    const leases = try gpa.alloc(FsmBindBuffLease, old_leases.len + 1);
    @memcpy(leases[0..old_leases.len], old_leases);
    leases[old_leases.len] = .{ .source = source, .handle_id = handle_id };
    gpa.free(old_leases);
    comp.fsm_bind_buff_leases = leases;

    if (new_handles) |handles| {
        gpa.free(old_handles);
        comp.fsm_owned_buff_handles = handles;
    }
}

pub fn markFsmBindHandleExternal(comp: *Component, gpa: std.mem.Allocator, handle_id: i32) void {
    comp.removeFsmOwnedHandle(gpa, handle_id);
}

pub fn releaseFsmBindLease(
    comp: *Component,
    gpa: std.mem.Allocator,
    source: FsmBindBuffSource,
) ?FsmBindBuffRelease {
    const lease_index = for (comp.fsm_bind_buff_leases, 0..) |lease, index| {
        if (lease.source.eql(source)) break index;
    } else return null;
    const handle_id = comp.fsm_bind_buff_leases[lease_index].handle_id;
    comp.removeFsmBindLeaseAt(gpa, lease_index);

    for (comp.fsm_bind_buff_leases) |lease| {
        if (lease.handle_id == handle_id) return .preserve;
    }
    if (!comp.fsmOwnsHandle(handle_id)) return .preserve;

    comp.removeFsmOwnedHandle(gpa, handle_id);
    return .{ .remove = handle_id };
}

fn clearFsmBindHandle(comp: *Component, gpa: std.mem.Allocator, handle_id: i32) void {
    var index: usize = 0;
    while (index < comp.fsm_bind_buff_leases.len) {
        if (comp.fsm_bind_buff_leases[index].handle_id == handle_id) {
            comp.removeFsmBindLeaseAt(gpa, index);
        } else {
            index += 1;
        }
    }
    comp.removeFsmOwnedHandle(gpa, handle_id);
}

fn removeFsmBindLeaseAt(comp: *Component, gpa: std.mem.Allocator, index: usize) void {
    const leases = comp.fsm_bind_buff_leases;
    leases[index] = leases[leases.len - 1];
    comp.fsm_bind_buff_leases = gpa.realloc(leases, leases.len - 1) catch leases[0 .. leases.len - 1];
}

fn fsmOwnsHandle(comp: *const Component, handle_id: i32) bool {
    return std.mem.indexOfScalar(i32, comp.fsm_owned_buff_handles, handle_id) != null;
}

fn removeFsmOwnedHandle(comp: *Component, gpa: std.mem.Allocator, handle_id: i32) void {
    const handles = comp.fsm_owned_buff_handles;
    const index = std.mem.indexOfScalar(i32, handles, handle_id) orelse return;
    handles[index] = handles[handles.len - 1];
    comp.fsm_owned_buff_handles = gpa.realloc(handles, handles.len - 1) catch handles[0 .. handles.len - 1];
}
