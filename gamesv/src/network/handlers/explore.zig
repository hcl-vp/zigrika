const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const Scene = @import("../../logic/Scene.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const sliceToArrayList = @import("../../logic/component/entity/EntityComponentStorage.zig").sliceToArrayList;
const Entity = Scene.Entity;
const FileSystem = @import("common").FileSystem;

pub fn onExploreProgressRequest(txn: *Transaction(pb.ExploreProgressRequest)) !void {
    txn.respond(.{});
}

pub fn onEnterAreaRequest(txn: *Transaction(pb.EnterAreaRequest)) !void {
    txn.respond(.{ .Id = txn.message.Id });
}

pub fn onVisionExploreSkillSetRequest(
    txn: *Transaction(pb.VisionExploreSkillSetRequest),
    scene: *Scene,
    alloc: mem.Alloc,
    fs: *FileSystem,
    query: Scene.Query(&.{
        Entity,
        *Entity.VisionSkillComponent,
    }),
) !void {
    const old_skill = scene.explore_tools_info.active_explore_skill;
    scene.explore_tools_info.active_explore_skill = txn.message.SkillId;

    var it = query.iterator;
    while (it.next()) |comps| {
        const entity = comps[0];
        const vision_skill_comp = comps[1];

        for (vision_skill_comp.vision_skills) |*skill| {
            if (skill.SkillId == old_skill) {
                skill.SkillId = txn.message.SkillId;
            }
        }

        try scene.saveEntity(fs, alloc.gpa, entity);
        try txn.conn.push(pb.VisionSkillChangeNotify{
            .EntityId = entity.net_id,
            .VisionSkillInfos = sliceToArrayList(pb.VisionSkillInformation, vision_skill_comp.vision_skills),
        }, alloc.arena);
    }

    txn.respond(.{ .SkillId = txn.message.SkillId });
}
