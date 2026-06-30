const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const Scene = @import("../../logic/Scene.zig");
const PlayerID = @import("../../logic/PlayerID.zig");
const mem = @import("../../mem.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const EntityComponentStorage = @import("../../logic/component/entity/EntityComponentStorage.zig");
const sliceToArrayList = EntityComponentStorage.sliceToArrayList;
const Entity = Scene.Entity;
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const RoleEntityTemplates = @import("../../logic/templates/RoleEntityTemplates.zig");
const phantom_projector = @import("../../logic/helpers/phantom_projector.zig");
const roulette_slot_count = 8;

fn ownedRouletteSkillIds(gpa: std.mem.Allocator, ids: []const i32) ![]i32 {
    const items = try gpa.alloc(i32, roulette_slot_count);
    @memset(items, 0);
    const count = @min(ids.len, roulette_slot_count);
    @memcpy(items[0..count], ids[0..count]);
    return items;
}

fn rouletteSkillIds(arena: std.mem.Allocator, ids: []const i32) !std.ArrayList(i32) {
    return sliceToArrayList(i32, try ownedRouletteSkillIds(arena, ids));
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
                scene.explore_tools_info.roulette = try ownedRouletteSkillIds(alloc.gpa, roulette.SkillIds.items);
                scene.explore_tools_info.explore_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_explore_skill = roulette.ExploreSkill;
            },
            .Function => {
                if (scene.explore_tools_info.function_roulette.len != 0) alloc.gpa.free(scene.explore_tools_info.function_roulette);
                scene.explore_tools_info.function_roulette = try ownedRouletteSkillIds(alloc.gpa, roulette.SkillIds.items);
                scene.explore_tools_info.function_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_function_skill = roulette.ExploreSkill;
            },
            .Motorcycle => {
                if (scene.explore_tools_info.motorcycle_roulette.len != 0) alloc.gpa.free(scene.explore_tools_info.motorcycle_roulette);
                scene.explore_tools_info.motorcycle_roulette = try ownedRouletteSkillIds(alloc.gpa, roulette.SkillIds.items);
                scene.explore_tools_info.motorcycle_extra_item_id = roulette.ExtraItemId;
                scene.explore_tools_info.active_motorcycle_skill = roulette.ExploreSkill;
            },
            .TrapDefense => {},
        }
        try scene.save(fs, alloc.gpa);
    }

    var roulette_info: std.ArrayList(pb.ExploreSkillRoulette) = .empty;
    try roulette_info.append(alloc.arena, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.roulette),
        .ExtraItemId = scene.explore_tools_info.explore_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_explore_skill,
    });
    try roulette_info.append(alloc.arena, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.function_roulette),
        .ExtraItemId = scene.explore_tools_info.function_extra_item_id,
        .ExploreSkill = scene.explore_tools_info.active_function_skill,
    });
    try roulette_info.append(alloc.arena, .{});
    try roulette_info.append(alloc.arena, .{
        .SkillIds = try rouletteSkillIds(alloc.arena, scene.explore_tools_info.motorcycle_roulette),
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

pub fn onSummon3Request(
    txn: *Transaction(pb.Summon3Request),
    scene: *Scene,
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
) !void {
    const info = txn.message.SummonInfo orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };
    if (info.SummonEntityId <= 0) {
        txn.respond(.{ .ErrorCode = .ErrSummonAddEntityFail });
        return;
    }
    if (scene.net_id_map.contains(info.SummonEntityId)) {
        txn.respond(.{ .ErrorCode = .ErrSummonEntityIdAlreadyExist });
        return;
    }
    if (!phantom_projector.isUnlockedMonster(assets, info.SummonConfigId)) {
        txn.respond(.{ .ErrorCode = .ErrPhantomInteractionNotUnlock });
        return;
    }

    const item = phantom_projector.displayedPhantomItem(assets, echo_comp.calabash_info, info.SummonConfigId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomInteractionConfigNotFind });
        return;
    };
    const summon_id = if (item.MeshId != 0) item.MeshId else item.SkillId;
    if (summon_id == 0) {
        txn.respond(.{ .ErrorCode = .ErrSummonCfgNotFound });
        return;
    }

    const entity = RoleEntityTemplates.createProjectorVisionEntity(
        fs,
        scene,
        alloc,
        scene.player_id,
        assets,
        summon_id,
        txn.message.SummonerEntityId,
        info.SummonEntityId,
        info.Pos orelse .{},
        info.Rot orelse .{},
    ) catch |err| switch (err) {
        error.EntityIdAlreadyExists => {
            txn.respond(.{ .ErrorCode = .ErrSummonEntityIdAlreadyExist });
            return;
        },
        else => return err,
    } orelse {
        txn.respond(.{ .ErrorCode = .ErrSummonCfgNotFound });
        return;
    };

    const storage = scene.entities.get(entity.index);
    try txn.conn.push(pb.EntityAddNotify{
        .EntityPbs = try singleEntityPb(alloc, assets, storage, entity.net_id),
    }, alloc.arena);
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onRemoveSummonEntityRequest(
    txn: *Transaction(pb.RemoveSummonEntityRequest),
    scene: *Scene,
    alloc: mem.Alloc,
    fs: *FileSystem,
) !void {
    var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;

    for (txn.message.RemoveENtityIds.items) |entity_id| {
        const index = scene.net_id_map.get(entity_id) orelse continue;
        const storage = scene.entities.get(index);
        const summoner = storage.summoner orelse continue;
        if (summoner.summoner_id != txn.message.SummonerId) continue;

        try scene.remove(alloc.gpa, fs, entity_id);
        try remove_infos.append(alloc.arena, .{ .EntityId = entity_id });
    }

    if (remove_infos.items.len != 0) {
        try txn.conn.push(pb.EntityRemoveNotify{
            .IsRemove = true,
            .RemoveInfos = remove_infos,
        }, alloc.arena);
    }

    txn.respond(.{ .ErrorCode = .Success });
}

fn singleEntityPb(
    alloc: mem.Alloc,
    assets: *const Assets,
    storage: EntityComponentStorage,
    entity_id: i64,
) !std.ArrayList(pb.EntityPb) {
    var entity_pbs: std.ArrayList(pb.EntityPb) = .empty;
    try entity_pbs.append(alloc.arena, try storage.entityToProto(entity_id, alloc, assets));
    return entity_pbs;
}
