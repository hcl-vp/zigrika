const FsmComponent = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

hash_code: i32,
common_hash_code: i32,
fsms: []pb.DFsm = &.{},

pub fn deinit(comp: *FsmComponent, gpa: std.mem.Allocator) void {
    gpa.free(comp.fsms);
}

pub fn toProto(comp: FsmComponent) !pb.EntityFsmComponentPb {
    return .{
        .HashCode = comp.hash_code,
        .CommonHashCode = comp.common_hash_code,
        .Fsms = sliceToArrayList(pb.DFsm, comp.fsms),
    };
}
