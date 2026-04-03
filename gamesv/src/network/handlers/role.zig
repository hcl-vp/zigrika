const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;

pub fn SwitchRoleRequest(
    txn: *dispatch.CombatRequestTxn(.SwitchRoleRequest),
    scene: *Scene,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    const payload = txn.payload orelse return error.MissingPayload;
    scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)].cur_role = payload.RoleId;
    try scene.save(fs, alloc.gpa);
    txn.respond(.{ .ErrorCode = .Success, .RoleId = payload.RoleId });
}
