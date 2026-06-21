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

pub fn onExploreSkillRouletteSetRequest(
    txn: *Transaction(pb.ExploreSkillRouletteSetRequest),
    scene: *Scene,
    alloc: mem.Alloc,
    fs: *FileSystem,
) !void {
    const roulette_type = txn.message.RouletteType orelse .Explore;
    const selected_roulette: ?pb.ExploreSkillRoulette = txn.message.SkillRoulette orelse if (txn.message.SkillRoulettes.items.len != 0)
        txn.message.SkillRoulettes.items[0]
    else
        null;

    if (selected_roulette) |roulette| {
        switch (roulette_type) {
            .Explore => {
                if (scene.explore_tools_info.roulette.len != 0) alloc.gpa.free(scene.explore_tools_info.roulette);
                scene.explore_tools_info.roulette = try alloc.gpa.dupe(i32, roulette.SkillIds.items);
                scene.explore_tools_info.explore_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_explore_skill = roulette.ExploreSkill;
            },
            .Function => {
                if (scene.explore_tools_info.function_roulette.len != 0) alloc.gpa.free(scene.explore_tools_info.function_roulette);
                scene.explore_tools_info.function_roulette = try alloc.gpa.dupe(i32, roulette.SkillIds.items);
                scene.explore_tools_info.function_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_function_skill = roulette.ExploreSkill;
            },
            .Motorcycle => {
                if (scene.explore_tools_info.motorcycle_roulette.len != 0) alloc.gpa.free(scene.explore_tools_info.motorcycle_roulette);
                scene.explore_tools_info.motorcycle_roulette = try alloc.gpa.dupe(i32, roulette.SkillIds.items);
                scene.explore_tools_info.motorcycle_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_motorcycle_skill = roulette.ExploreSkill;
            },
            .TrapDefense => {},
        }
        try scene.save(fs, alloc.gpa);
    }

    var roulette_info: std.ArrayList(pb.ExploreSkillRoulette) = .empty;
    try roulette_info.append(alloc.arena, .{
        .SkillIds = sliceToArrayList(i32, scene.explore_tools_info.roulette),
        .ExtraItemId = scene.explore_tools_info.explore_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_explore_skill,
    });
    try roulette_info.append(alloc.arena, .{
        .SkillIds = sliceToArrayList(i32, scene.explore_tools_info.function_roulette),
        .ExtraItemId = scene.explore_tools_info.function_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_function_skill,
    });
    try roulette_info.append(alloc.arena, .{});
    try roulette_info.append(alloc.arena, .{
        .SkillIds = sliceToArrayList(i32, scene.explore_tools_info.motorcycle_roulette),
        .ExtraItemId = scene.explore_tools_info.motorcycle_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_motorcycle_skill,
    });

    try txn.conn.push(pb.ExploreSkillRouletteUpdateNotify{
        .RouletteInfo = roulette_info,
    }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .SkillRoulette = selected_roulette,
        .RouletteType = roulette_type,
        .SkillRoulettes = roulette_info,
    });
}
