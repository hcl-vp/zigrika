const pb = @import("proto").pb;
const Assets = @import("../../data/Assets.zig");
const mem = @import("../../mem.zig");
const Scene = @import("../Scene.zig");
const BuffTimerScheduler = @import("../schedulers/BuffTimerScheduler.zig");

pub fn build(
    alloc: mem.Alloc,
    assets: *const Assets,
    scene: *Scene,
    buff_timers: *BuffTimerScheduler,
    entity_id: i64,
    now_ms: i64,
) !pb.EntityPb {
    try buff_timers.ensureEntityRegistered(alloc.gpa, scene, assets, entity_id, now_ms);
    buff_timers.syncEntityLeftDurations(scene, entity_id, now_ms);

    const index = scene.net_id_map.get(entity_id) orelse return error.EntityNotFound;
    return scene.entities.get(index).entityToProto(entity_id, alloc, assets);
}
