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
    const request: pb.SwitchRoleRequest = txn.payload;
    const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
    const previous_role = formation.cur_role;
    formation.cur_role = request.RoleId;

    const slice = scene.entities.slice();
    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id == previous_role) {
            slice.items(.visible)[i] = null;
        } else if (config.config_id == request.RoleId) {
            slice.items(.visible)[i] = .{};
        }
    }

    try scene.save(fs, alloc.gpa);
    txn.respond(.{ .ErrorCode = .Success, .RoleId = request.RoleId });
}
