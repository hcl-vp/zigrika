const Scene = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const SceneInstance = @import("../fs/SceneInstance.zig");
const FormationInfo = @import("../fs/FormationInfo.zig");
const ExploreToolsInfo = @import("../fs/ExploreToolsInfo.zig");
const file_util = @import("../fs/file_util.zig");
const comp_util = @import("component/comp_util.zig");
const EntityComponentStorage = @import("component/entity/EntityComponentStorage.zig");
const PlayerSceneComponent = @import("component/player/PlayerSceneComponent.zig");
const FsmWakeScheduler = @import("schedulers/FsmWakeScheduler.zig");
const incr = @import("../fs/incr.zig");

const Allocator = std.mem.Allocator;

player_id: i32,
instance_id: i32,
instance: SceneInstance,
formation_info: FormationInfo,
explore_tools_info: ExploreToolsInfo,
entities: std.MultiArrayList(EntityComponentStorage) = .empty,
net_id_map: std.array_hash_map.Auto(i64, usize) = .empty,
scene_time: TimeInfo = .{},
active_battle_entities: std.AutoHashMapUnmanaged(i64, void) = .empty,
combine_relations: std.AutoHashMapUnmanaged(i64, CombineRelation) = .empty,
pending_combine_detaches: std.ArrayListUnmanaged(CombineDetach) = .empty,
debug_spawn_routes: std.AutoHashMapUnmanaged(i64, DebugSpawnRoute) = .empty,
debug_spawn_route_owners: std.AutoHashMapUnmanaged(i64, i64) = .empty,
fsm_wakes: FsmWakeScheduler = .{},
player_in_battle: bool = false,
battle_state_notified: bool = false,
battle_state_dirty: bool = false,

pub const DebugSpawnRoute = struct {
    source_map_id: i32,
    repeat_boss: bool,
    owner_count: usize,

    pub fn matches(route: DebugSpawnRoute, source_map_id: i32, repeat_boss: bool) bool {
        return route.source_map_id == source_map_id and route.repeat_boss == repeat_boss;
    }
};

pub const CombineRelation = struct {
    target_entity_id: i64,
    part_index: i32,
    position: pb.Vector,
    rotation: pb.Rotator,

    pub fn matches(relation: CombineRelation, other: CombineRelation) bool {
        return relation.target_entity_id == other.target_entity_id and
            relation.part_index == other.part_index and
            std.meta.eql(relation.position, other.position) and
            std.meta.eql(relation.rotation, other.rotation);
    }
};

pub const CombineDetach = struct {
    combine_entity_id: i64,
    target_entity_id: i64,
};

pub const CombineRegisterResult = enum {
    added,
    existing,
};

pub const TimeInfo = struct {
    timestamp: i64 = 0,
    last_packet_time: i64 = 0,
    dilation: f64 = 0.0,
};

pub const Entity = struct {
    pub const ConfigComponent = @import("component/entity/ConfigComponent.zig");
    pub const PositionComponent = @import("component/entity/PositionComponent.zig");
    pub const PlayerIDComponent = @import("component/entity/PlayerIDComponent.zig");
    pub const VisibleMarker = @import("component/entity/VisibleMarker.zig");
    pub const ActorVisibleMarker = @import("component/entity/ActorVisibleMarker.zig");
    pub const DirectControlMarker = @import("component/entity/DirectControlMarker.zig");
    pub const AttributeComponent = @import("component/entity/AttributeComponent.zig");
    pub const TagComponent = @import("component/entity/TagComponent.zig");
    pub const PartComponent = @import("component/entity/PartComponent.zig");
    pub const FightBuffComponent = @import("component/entity/FightBuffComponent.zig");
    pub const CharacterAttachComponent = @import("component/entity/CharacterAttachComponent.zig");
    pub const ConcomitantComponent = @import("component/entity/ConcomitantComponent.zig");
    pub const EquipComponent = @import("component/entity/EquipComponent.zig");
    pub const FollowerComponent = @import("component/entity/FollowerComponent.zig");
    pub const VehicleComponent = @import("component/entity/VehicleComponent.zig");
    pub const NpcDriveVehicleComponent = @import("component/entity/NpcDriveVehicleComponent.zig");
    pub const MotorOutlookComponent = @import("component/entity/MotorOutlookComponent.zig");
    pub const MotorDaCtxComponent = @import("component/entity/MotorDaCtxComponent.zig");
    pub const LogicStateComponent = @import("component/entity/LogicStateComponent.zig");
    pub const MonsterAiComponent = @import("component/entity/MonsterAiComponent.zig");
    pub const PassiveGaSkillComponent = @import("component/entity/PassiveGaSkillComponent.zig");
    pub const PlayerBattleBinder = @import("component/entity/PlayerBattleBinder.zig");
    pub const SummonerComponent = @import("component/entity/SummonerComponent.zig");
    pub const FollowShooterComponent = @import("component/entity/FollowShooterComponent.zig");
    pub const FollowEntityComponent = @import("component/entity/FollowEntityComponent.zig");
    pub const FsmComponent = @import("component/entity/FsmComponent.zig");
    pub const VisionSkillComponent = @import("component/entity/VisionSkillComponent.zig");
    pub const BaseSkinComponent = @import("component/entity/BaseSkinComponent.zig");
    pub const WeaponSkinComponent = @import("component/entity/WeaponSkinComponent.zig");
    pub const OrnamentComponent = @import("component/entity/OrnamentComponent.zig");
    pub const CalabashSkinComponent = @import("component/entity/CalabashSkinComponent.zig");

    index: usize,
    net_id: i64,
};

pub fn Query(comptime types: []const type) type {
    return struct {
        const Q = @This();
        pub const scene_query_types = types;
        pub const Item = @Tuple(types);

        iterator: Iterator,

        pub fn byNetId(query: Q, net_id: i64) ?Item {
            inline for (types) |ty| {
                if (ty == Entity) break;
            } else @compileError("can't extract components by net_id when the identifier is not queried");

            if (query.iterator.net_id_map) |map| {
                const index = map.get(net_id) orelse return null;
                var it = query.iterator;
                it.index = index;
                return it.peekCurrent(it.entities.slice());
            }

            var it = query.iterator;
            while (it.next()) |item| {
                inline for (types, 0..) |ty, i| {
                    if (ty == Entity and item[i].net_id == net_id) return item;
                }
            } else return null;
        }

        pub fn byEntityHandle(query: Q, entity: Entity) ?Item {
            var it = query.iterator;
            it.index = entity.index;

            return it.peekCurrent(it.entities.slice());
        }

        pub const Iterator = struct {
            entities: *std.MultiArrayList(EntityComponentStorage),
            net_id_map: ?*const std.array_hash_map.Auto(i64, usize) = null,
            index: usize = 0,

            pub fn next(it: *Iterator) ?Item {
                const slice = it.entities.slice();
                while (it.index < it.entities.len) : (it.index += 1) {
                    if (it.peekCurrent(slice)) |item| {
                        it.index += 1;
                        return item;
                    }
                }

                return null;
            }

            fn peekCurrent(it: *Iterator, slice: std.MultiArrayList(EntityComponentStorage).Slice) ?Item {
                @setEvalBranchQuota(2_000);
                var item: Item = undefined;

                inline for (types, 0..) |Component, i| {
                    if (Component == Entity) {
                        item[i] = .{
                            .index = it.index,
                            .net_id = slice.items(.entity_id)[it.index].net_id,
                        };

                        continue;
                    }

                    const index = comptime EntityComponentStorage.fieldIndexForType(Component);
                    const items = slice.items(@enumFromInt(index));
                    const requested_optional = comptime std.meta.activeTag(@typeInfo(Component)) == .optional;
                    const is_component_optional = comptime EntityComponentStorage.isComponentOptional(Component);

                    if (requested_optional and is_component_optional) {
                        item[i] = if (items[it.index]) |*comp| comp else null;
                    } else if (is_component_optional) {
                        // if the request is non-optional and component is null, skip this entity right away
                        item[i] = if (items[it.index]) |*comp| comp else return null;
                    } else {
                        item[i] = &items[it.index];
                    }
                }

                return item;
            }
        };
    };
}

pub fn clear_entities(scene: *Scene, arena: *std.heap.ArenaAllocator, fs: *FileSystem) !void {
    const entity_dir = try std.fmt.allocPrint(
        arena.allocator(),
        "state/player/{d}/scene/{d}/entity",
        .{ scene.player_id, scene.instance_id },
    );

    try std.Io.Dir.cwd().deleteTree(fs.io, entity_dir);
}

pub fn init(
    gpa: Allocator,
    fs: *FileSystem,
    player_id: i32,
    instance_id: i32,
) !Scene {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    var instance = try file_util.loadOrCreateZon(
        SceneInstance,
        gpa,
        arena.allocator(),
        fs,
        "player/{d}/scene/{d}/instance",
        .{ player_id, instance_id },
    );
    instance.buff_handle = 0;

    const formation_info = try file_util.loadOrCreateZon(
        FormationInfo,
        gpa,
        arena.allocator(),
        fs,
        "player/{d}/formation_info",
        .{player_id},
    );

    const explore_tools_info = try file_util.loadOrCreateZon(
        ExploreToolsInfo,
        gpa,
        arena.allocator(),
        fs,
        "player/{d}/explore_tools_info",
        .{player_id},
    );

    var scene: Scene = .{
        .player_id = player_id,
        .instance_id = instance_id,
        .instance = instance,
        .formation_info = formation_info,
        .explore_tools_info = explore_tools_info,
    };

    try scene.clear_entities(&arena, fs);

    errdefer scene.deinit(gpa, fs);

    return scene;
}

pub fn deinit(scene: *Scene, gpa: Allocator, fs: *FileSystem) void {
    scene.instance.deinit(gpa);
    scene.formation_info.deinit(gpa);
    scene.explore_tools_info.deinit(gpa);

    for (0..scene.entities.len) |i| {
        var entity = scene.entities.get(i);
        entity.deinit(gpa);
    }

    scene.entities.deinit(gpa);
    scene.net_id_map.deinit(gpa);
    scene.active_battle_entities.deinit(gpa);
    scene.combine_relations.deinit(gpa);
    scene.pending_combine_detaches.deinit(gpa);
    scene.debug_spawn_routes.deinit(gpa);
    scene.debug_spawn_route_owners.deinit(gpa);
    scene.fsm_wakes.deinit(gpa);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    scene.clear_entities(&arena, fs) catch return;
}

pub fn spawn(scene: *Scene, gpa: Allocator, fs: *FileSystem, components: anytype) !Entity {
    return try spawnWithOptionalNetId(scene, gpa, fs, components, null);
}

pub fn spawnWithNetId(scene: *Scene, gpa: Allocator, fs: *FileSystem, net_id: i64, components: anytype) !Entity {
    if (net_id <= 0) return error.InvalidEntityId;
    if (scene.net_id_map.contains(net_id)) return error.EntityIdAlreadyExists;
    return try spawnWithOptionalNetId(scene, gpa, fs, components, net_id);
}

pub fn initFsmRuntimes(scene: *Scene, gpa: Allocator, now_ms: i64) !void {
    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.fsm)) |entity_id, *optional_fsm| {
        if (optional_fsm.*) |*fsm| {
            try fsm.initRuntime(gpa, now_ms);
            try scene.fsm_wakes.markDirty(gpa, entity_id.net_id);
        }
    }
}

pub fn setFsmEncounterTarget(scene: *Scene, gpa: Allocator, fsm_entity_id: i64, target_entity_id: ?i64) !bool {
    const fsm_index = scene.net_id_map.get(fsm_entity_id) orelse return error.EntityNotFound;
    const fsm_slot = &scene.entities.items(.fsm)[fsm_index];
    const fsm = if (fsm_slot.*) |*component| component else return error.EntityFsmNotFound;

    const target = if (target_entity_id) |target_id| blk: {
        if (!scene.net_id_map.contains(target_id)) return error.TargetEntityNotFound;
        break :blk std.math.cast(i32, target_id) orelse return error.FsmBlackboardTargetOutOfRange;
    } else null;

    const changed = fsm.setEncounterTarget(target);
    if (changed) try scene.fsm_wakes.markDirty(gpa, fsm_entity_id);
    return changed;
}

pub fn markFsmDirty(scene: *Scene, gpa: Allocator, entity_id: i64, reason: Entity.FsmComponent.WakeMask) !void {
    const index = scene.net_id_map.get(entity_id) orelse return;
    const fsm_slot = &scene.entities.items(.fsm)[index];
    const fsm = if (fsm_slot.*) |*component| component else return;
    if (fsm.markDirty(reason)) try scene.fsm_wakes.markDirty(gpa, entity_id);
}

pub fn markFsmRootDirty(
    scene: *Scene,
    gpa: Allocator,
    entity_id: i64,
    fsm_id: i32,
    reason: Entity.FsmComponent.WakeMask,
) !void {
    const index = scene.net_id_map.get(entity_id) orelse return;
    const fsm_slot = &scene.entities.items(.fsm)[index];
    const fsm = if (fsm_slot.*) |*component| component else return;
    if (fsm.markRootDirty(fsm_id, reason)) try scene.fsm_wakes.markDirty(gpa, entity_id);
}

pub fn queueFsmSync(scene: *Scene, gpa: Allocator, entity_id: i64) !void {
    const index = scene.net_id_map.get(entity_id) orelse return;
    if (scene.entities.items(.fsm)[index] == null) return;
    try scene.fsm_wakes.markDirty(gpa, entity_id);
}

pub fn syncFsmDeadlines(
    scene: *Scene,
    gpa: Allocator,
    entity_id: i64,
    fsm: *Entity.FsmComponent,
) !void {
    for (fsm.runtime_nodes) |runtime| {
        if (runtime.next_timer_due_ms) |due_ms| {
            try scene.fsm_wakes.upsert(gpa, .{
                .entity_id = entity_id,
                .fsm_id = runtime.fsm_id,
                .kind = .root_timer,
                .due_ms = due_ms,
            });
        } else {
            scene.fsm_wakes.cancel(entity_id, runtime.fsm_id, .root_timer);
        }
    }

    if (fsm.pendingDeadline()) |due_ms| {
        try scene.fsm_wakes.upsert(gpa, .{
            .entity_id = entity_id,
            .kind = .pending_timeout,
            .due_ms = due_ms,
        });
    } else {
        scene.fsm_wakes.cancel(entity_id, 0, .pending_timeout);
    }

    if (fsm.paralysis_active and fsm.paralysis_next_ms != null) {
        try scene.fsm_wakes.upsert(gpa, .{
            .entity_id = entity_id,
            .kind = .paralysis,
            .due_ms = fsm.paralysis_next_ms.?,
        });
    } else {
        scene.fsm_wakes.cancel(entity_id, 0, .paralysis);
    }
}

pub fn hateTargetsFormation(scene: *const Scene, hate_list: []const pb.AiHateEntity) bool {
    const formation_index = std.math.cast(usize, scene.formation_info.cur_formation) orelse return false;
    if (formation_index >= scene.formation_info.formations.len) return false;
    const formation = scene.formation_info.formations[formation_index];

    for (hate_list) |hate| {
        if (hate.HatredValue < 1) continue;
        for (formation.roles) |maybe_role| {
            const role = maybe_role orelse continue;
            if (role.entity_id == hate.EntityId) return true;
        }
    }
    return false;
}

pub fn setBattleEntityActive(scene: *Scene, gpa: Allocator, entity_id: i64, active: bool) !void {
    if (active) {
        try scene.active_battle_entities.put(gpa, entity_id, {});
    } else {
        _ = scene.active_battle_entities.remove(entity_id);
    }
    scene.updateBattleState();
}

pub fn updateBattleEntityFromHate(
    scene: *Scene,
    gpa: Allocator,
    entity_id: i64,
    hate_list: []const pb.AiHateEntity,
) !void {
    try scene.setBattleEntityActive(gpa, entity_id, scene.hateTargetsFormation(hate_list));
}

pub fn forceBattleState(scene: *Scene, mode: bool) void {
    scene.active_battle_entities.clearRetainingCapacity();
    scene.player_in_battle = mode;
    scene.battle_state_dirty = scene.player_in_battle != scene.battle_state_notified;
}

pub fn combineRelation(scene: *const Scene, combine_entity_id: i64) ?CombineRelation {
    return scene.combine_relations.get(combine_entity_id);
}

pub fn registerCombineRelation(
    scene: *Scene,
    gpa: Allocator,
    combine_entity_id: i64,
    relation: CombineRelation,
) !CombineRegisterResult {
    if (scene.combine_relations.get(combine_entity_id)) |existing| {
        if (existing.matches(relation)) return .existing;
        return error.CombineRelationConflict;
    }

    try scene.combine_relations.put(gpa, combine_entity_id, relation);
    return .added;
}

pub fn detachCombineRelation(
    scene: *Scene,
    combine_entity_id: i64,
    target_entity_id: i64,
) ?CombineRelation {
    const relation = scene.combine_relations.get(combine_entity_id) orelse return null;
    if (relation.target_entity_id != target_entity_id) return null;
    _ = scene.combine_relations.remove(combine_entity_id);
    return relation;
}

pub fn removeCombineRelationsForEntity(scene: *Scene, gpa: Allocator, entity_id: i64) !void {
    var affected: std.ArrayList(i64) = .empty;
    defer affected.deinit(gpa);

    var detach_count: usize = 0;
    var iterator = scene.combine_relations.iterator();
    while (iterator.next()) |entry| {
        if (entry.key_ptr.* != entity_id and entry.value_ptr.target_entity_id != entity_id) continue;
        try affected.append(gpa, entry.key_ptr.*);
        if (entry.value_ptr.target_entity_id == entity_id and entry.key_ptr.* != entity_id) detach_count += 1;
    }

    try scene.pending_combine_detaches.ensureUnusedCapacity(gpa, detach_count);
    for (affected.items) |combine_entity_id| {
        const relation = scene.combine_relations.get(combine_entity_id) orelse continue;
        _ = scene.combine_relations.remove(combine_entity_id);
        if (relation.target_entity_id == entity_id and combine_entity_id != entity_id) {
            scene.pending_combine_detaches.appendAssumeCapacity(.{
                .combine_entity_id = combine_entity_id,
                .target_entity_id = relation.target_entity_id,
            });
        }
    }
}

pub fn pendingCombineDetaches(scene: *const Scene) []const CombineDetach {
    return scene.pending_combine_detaches.items;
}

pub fn clearPendingCombineDetaches(scene: *Scene) void {
    scene.pending_combine_detaches.clearRetainingCapacity();
}

pub fn signalFsmDissolveCombine(scene: *Scene, gpa: Allocator, entity_id: i64) !void {
    const index = scene.net_id_map.get(entity_id) orelse return;
    const fsm_slot = &scene.entities.items(.fsm)[index];
    if (fsm_slot.*) |*fsm| {
        fsm.signalDissolveCombine();
        _ = fsm.markDirty(Entity.FsmComponent.WakeReason.dissolve);
        try scene.fsm_wakes.markDirty(gpa, entity_id);
    }
}

pub fn removeCombineNotify(detach: CombineDetach) pb.CombatReceiveData {
    return .{ .Message = .{ .CombatNotifyData = .{
        .CombatCommon = .{ .EntityId = detach.combine_entity_id },
        .Message = .{ .RemoveCombineRelationNotify = .{
            .CombineEntity = detach.combine_entity_id,
            .TargetEntity = detach.target_entity_id,
        } },
    } } };
}

pub fn debugSpawnRoute(scene: *const Scene, config_id: i64) ?DebugSpawnRoute {
    return scene.debug_spawn_routes.get(config_id);
}

pub fn registerDebugSpawnRoute(
    scene: *Scene,
    gpa: Allocator,
    net_id: i64,
    config_id: i64,
    source_map_id: i32,
    repeat_boss: bool,
) !void {
    if (scene.debug_spawn_route_owners.contains(net_id)) return error.DebugSpawnRouteOwnerExists;

    if (scene.debug_spawn_routes.getPtr(config_id)) |route| {
        if (!route.matches(source_map_id, repeat_boss)) return error.DebugSpawnRouteConflict;
        try scene.debug_spawn_route_owners.put(gpa, net_id, config_id);
        route.owner_count += 1;
        return;
    }

    try scene.debug_spawn_routes.put(gpa, config_id, .{
        .source_map_id = source_map_id,
        .repeat_boss = repeat_boss,
        .owner_count = 1,
    });
    errdefer _ = scene.debug_spawn_routes.remove(config_id);
    try scene.debug_spawn_route_owners.put(gpa, net_id, config_id);
}

pub fn unregisterDebugSpawnRoute(scene: *Scene, net_id: i64) void {
    const config_id = scene.debug_spawn_route_owners.get(net_id) orelse return;
    _ = scene.debug_spawn_route_owners.remove(net_id);

    const route = scene.debug_spawn_routes.getPtr(config_id) orelse return;
    if (route.owner_count > 1) {
        route.owner_count -= 1;
    } else {
        _ = scene.debug_spawn_routes.remove(config_id);
    }
}

pub fn appendBattleStateNotify(
    scene: *Scene,
    arena: Allocator,
    data: *std.ArrayList(pb.CombatReceiveData),
) !bool {
    if (!scene.battle_state_dirty) return false;

    try data.append(arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = scene.currentRoleEntityId() },
            .Message = .{
                .PlayerBattleStateChangeNotify = .{
                    .PlayerId = scene.player_id,
                    .InBattle = scene.player_in_battle,
                },
            },
        },
    } });
    scene.battle_state_notified = scene.player_in_battle;
    scene.battle_state_dirty = false;
    return true;
}

fn currentRoleEntityId(scene: *const Scene) i64 {
    const formation_index = std.math.cast(usize, scene.formation_info.cur_formation) orelse return -1;
    if (formation_index >= scene.formation_info.formations.len) return -1;
    const formation = scene.formation_info.formations[formation_index];
    for (formation.roles) |maybe_role| {
        const role = maybe_role orelse continue;
        if (role.role_id == formation.cur_role) return role.entity_id;
    }
    return -1;
}

fn updateBattleState(scene: *Scene) void {
    scene.player_in_battle = scene.active_battle_entities.count() != 0;
    scene.battle_state_dirty = scene.player_in_battle != scene.battle_state_notified;
}

fn spawnWithOptionalNetId(scene: *Scene, gpa: Allocator, fs: *FileSystem, components: anytype, requested_net_id: ?i64) !Entity {
    const log = std.log.scoped(.entity_spawn);
    var storage: EntityComponentStorage = undefined;

    inline for (comptime std.meta.fields(EntityComponentStorage)) |storage_field| {
        if (comptime std.mem.eql(u8, storage_field.name, "entity_id")) continue;

        const is_optional = comptime std.meta.activeTag(@typeInfo(storage_field.type)) == .optional;
        inline for (comptime std.meta.fields(@TypeOf(components)), 0..) |param_field, i| {
            if ((!is_optional and param_field.type == storage_field.type) or
                (is_optional and (param_field.type == storage_field.type or ?param_field.type == storage_field.type)))
            {
                @field(storage, storage_field.name) = components[i];
                break;
            }
        } else if (!is_optional) {
            log.err("missing required component '" ++ @typeName(storage_field.type) ++ "'", .{});
            return error.MissingRequiredComponent;
        } else {
            @field(storage, storage_field.name) = null;
        }
    }

    const id = requested_net_id orelse try scene.nextEntityId(fs, gpa);
    if (requested_net_id != null) try scene.ensureNextEntityIdAtLeast(fs, gpa, id + 1);

    storage.entity_id = .{ .net_id = id };
    if (storage.motor_da_ctx) |*comp| {
        if (comp.context_id == 0) comp.context_id = id;
    }
    if (storage.fsm) |*fsm| {
        try fsm.initRuntime(gpa, std.Io.Clock.awake.now(fs.io).toMilliseconds());
    }

    try scene.net_id_map.put(gpa, id, scene.entities.len);
    try scene.entities.append(gpa, storage);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    try storage.save(arena.allocator(), fs, scene.player_id, scene.instance_id);

    if (storage.fsm != null) try scene.fsm_wakes.markDirty(gpa, id);

    return .{ .index = scene.entities.len - 1, .net_id = id };
}

pub fn delete(
    fs: *FileSystem,
    player_id: i32,
    scene_id: i32,
    net_id: i64,
) !void {
    var path_buf: [512]u8 = undefined;
    const path = try std.fmt.bufPrint(
        path_buf[0..],
        "player/{d}/scene/{d}/entity/{d}",
        .{ player_id, scene_id, net_id },
    );
    try fs.root_dir.deleteTree(fs.io, path);

    try fs.map_lock.lock(fs.io);
    defer fs.map_lock.unlock(fs.io);

    if (fs.map.fetchSwapRemove(path)) |entry| {
        fs.gpa.free(entry.key);
        if (entry.value.content) |content| {
            fs.gpa.free(content);
        }
    }
}

pub fn remove(scene: *Scene, gpa: Allocator, fs: *FileSystem, net_id: i64) !void {
    const index = scene.net_id_map.get(net_id) orelse return;
    try delete(fs, scene.player_id, scene.instance_id, net_id);
    try scene.removeEntityState(gpa, index, net_id);
}

pub fn rollbackSpawn(scene: *Scene, gpa: Allocator, fs: *FileSystem, net_id: i64) !void {
    const index = scene.net_id_map.get(net_id) orelse return;
    const delete_error: ?anyerror = blk: {
        delete(fs, scene.player_id, scene.instance_id, net_id) catch |err| break :blk err;
        break :blk null;
    };

    try scene.removeEntityState(gpa, index, net_id);
    if (delete_error) |err| return err;
}

fn removeEntityState(scene: *Scene, gpa: Allocator, index: usize, net_id: i64) !void {
    try scene.clearFsmEncounterTargetReferences(gpa, net_id);
    try scene.removeCombineRelationsForEntity(gpa, net_id);
    scene.fsm_wakes.cancelEntity(net_id);
    scene.unregisterDebugSpawnRoute(net_id);
    _ = scene.active_battle_entities.remove(net_id);
    scene.updateBattleState();
    var storage = scene.entities.get(index);
    storage.deinit(gpa);
    scene.entities.swapRemove(index);
    _ = scene.net_id_map.swapRemove(net_id);
    if (index < scene.entities.len) {
        const swapped_id = scene.entities.items(.entity_id)[index].net_id;
        try scene.net_id_map.put(gpa, swapped_id, index);
    }
}

fn clearFsmEncounterTargetReferences(scene: *Scene, gpa: Allocator, target_entity_id: i64) !void {
    const target_id = std.math.cast(i32, target_entity_id) orelse return;
    const slice = scene.entities.slice();
    for (slice.items(.entity_id), slice.items(.fsm)) |entity_id, *optional_fsm| {
        if (optional_fsm.*) |*fsm| {
            if (fsm.clearEncounterTargetReference(target_id)) {
                try scene.fsm_wakes.markDirty(gpa, entity_id.net_id);
            }
        }
    }
}

pub fn save(scene: *Scene, fs: *FileSystem, gpa: Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const instance_path = try std.fmt.allocPrint(arena.allocator(), "player/{d}/scene/{d}/instance", .{ scene.player_id, scene.instance_id });
    try comp_util.saveStruct(fs, scene.instance, instance_path, arena.allocator());
    const formation_path = try std.fmt.allocPrint(arena.allocator(), "player/{d}/formation_info", .{scene.player_id});
    try comp_util.saveStruct(fs, scene.formation_info, formation_path, arena.allocator());
    const explore_tools_path = try std.fmt.allocPrint(arena.allocator(), "player/{d}/explore_tools_info", .{scene.player_id});
    try comp_util.saveStruct(fs, scene.explore_tools_info, explore_tools_path, arena.allocator());

    for (0..scene.entities.len) |i| {
        const entity = scene.entities.get(i);
        try entity.save(arena.allocator(), fs, scene.player_id, scene.instance_id);
    }
}

pub fn saveLastScene(scene: *Scene, scene_comp: *PlayerSceneComponent, fs: *FileSystem, gpa: Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const last_scene_info = try std.fmt.allocPrint(arena.allocator(), "player/{}/last_scene", .{scene.player_id});
    try comp_util.saveStruct(fs, scene_comp.last_scene_info, last_scene_info, arena.allocator());
}

pub fn saveEntity(
    scene: *Scene,
    fs: *FileSystem,
    gpa: Allocator,
    entity: Entity,
) !void {
    const storage = scene.entities.get(entity.index);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    try storage.save(arena.allocator(), fs, scene.player_id, scene.instance_id);
}

pub fn saveComponents(
    scene: *Scene,
    fs: *FileSystem,
    gpa: Allocator,
    entity: Entity,
    comptime components: []const type,
) !void {
    const storage = scene.entities.get(entity.index);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    try storage.savePartial(arena.allocator(), fs, scene.player_id, scene.instance_id, components);
}

pub fn saveInstance(scene: *Scene, fs: *FileSystem, gpa: Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const path = try std.fmt.allocPrint(
        arena.allocator(),
        "player/{d}/scene/{d}/instance",
        .{ scene.player_id, scene.instance_id },
    );
    try comp_util.saveStruct(fs, scene.instance, path, arena.allocator());
}

pub fn nextEntityId(scene: *Scene, fs: *FileSystem, gpa: Allocator) !i64 {
    const incr_path = try scene.entityCounterPath(gpa);
    defer gpa.free(incr_path);

    return try incr.next(i64, fs, incr_path);
}

pub fn ensureNextEntityIdAtLeast(scene: *Scene, fs: *FileSystem, gpa: Allocator, next_id: i64) !void {
    if (next_id <= 1) return;

    const incr_path = try scene.entityCounterPath(gpa);
    defer gpa.free(incr_path);

    var buf: [32]u8 = undefined;
    if (try fs.lockFile(incr_path)) |lock_value| {
        var lock = lock_value;
        var tokens = std.mem.tokenizeAny(u8, lock.content, " \r\n");
        const current_id = std.fmt.parseInt(i64, tokens.next() orelse {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        }, 10) catch {
            try lock.unlock(null);
            return error.InvalidCounterFile;
        };

        if (current_id < next_id) {
            try lock.unlock(try std.fmt.bufPrint(&buf, "{d}\n", .{next_id}));
        } else {
            try lock.unlock(null);
        }
        return;
    }

    try fs.writeFile(incr_path, try std.fmt.bufPrint(&buf, "{d}\n", .{next_id}));
}

fn entityCounterPath(scene: *Scene, gpa: Allocator) ![]u8 {
    return try std.fmt.allocPrint(
        gpa,
        "player/{d}/scene/{d}/entity/next",
        .{ scene.player_id, scene.instance_id },
    );
}

const BuffAdditionEntry = @import("../logic/events.zig").BuffAdditionEntry;
pub fn buildFightBuffInfos(
    scene: *Scene,
    role_buffs: std.ArrayListUnmanaged(BuffAdditionEntry),
    net_id: i64,
    gpa: Allocator,
) ![]pb.FightBuffInformation {
    var infos: std.ArrayList(pb.FightBuffInformation) = .empty;
    errdefer infos.deinit(gpa);
    for (role_buffs.items) |entry| {
        scene.*.instance.buff_handle += 1;
        try infos.append(gpa, Assets.DataTables.createBuffInformation(
            scene.instance.buff_handle,
            entry.id,
            net_id,
            net_id,
            entry.is_active,
        ));
    }
    return infos.toOwnedSlice(gpa);
}
