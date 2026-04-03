const Scene = @This();
const std = @import("std");
const FileSystem = @import("common").FileSystem;
const SceneInstance = @import("../fs/SceneInstance.zig");
const FormationInfo = @import("../fs/FormationInfo.zig");
const ExploreToolsInfo = @import("../fs/ExploreToolsInfo.zig");
const file_util = @import("../fs/file_util.zig");
const comp_util = @import("component/comp_util.zig");
const EntityComponentStorage = @import("component/entity/EntityComponentStorage.zig");
const incr = @import("../fs/incr.zig");

const Allocator = std.mem.Allocator;

player_id: i32,
instance_id: i32,
instance: SceneInstance,
formation_info: FormationInfo,
explore_tools_info: ExploreToolsInfo,
entities: std.MultiArrayList(EntityComponentStorage) = .empty,
net_id_map: std.AutoArrayHashMapUnmanaged(i64, usize) = .empty,

pub const Entity = struct {
    pub const ConfigComponent = @import("component/entity/ConfigComponent.zig");
    pub const PositionComponent = @import("component/entity/PositionComponent.zig");
    pub const PlayerIDComponent = @import("component/entity/PlayerIDComponent.zig");
    pub const VisibleMarker = @import("component/entity/VisibleMarker.zig");
    pub const ActorVisibleMarker = @import("component/entity/ActorVisibleMarker.zig");
    pub const DirectControlMarker = @import("component/entity/DirectControlMarker.zig");
    pub const AttributeComponent = @import("component/entity/AttributeComponent.zig");
    pub const FightBuffComponent = @import("component/entity/FightBuffComponent.zig");
    pub const CharacterAttachComponent = @import("component/entity/CharacterAttachComponent.zig");
    pub const ConcomitantComponent = @import("component/entity/ConcomitantComponent.zig");
    pub const EquipComponent = @import("component/entity/EquipComponent.zig");
    pub const FollowerComponent = @import("component/entity/FollowerComponent.zig");
    pub const LogicStateComponent = @import("component/entity/LogicStateComponent.zig");
    pub const MonsterAiComponent = @import("component/entity/MonsterAiComponent.zig");
    pub const PassiveGaSkillComponent = @import("component/entity/PassiveGaSkillComponent.zig");
    pub const PlayerBattleBinder = @import("component/entity/PlayerBattleBinder.zig");
    pub const SummonerComponent = @import("component/entity/SummonerComponent.zig");
    pub const FsmComponent = @import("component/entity/FsmComponent.zig");
    pub const VisionSkillComponent = @import("component/entity/VisionSkillComponent.zig");

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
            const entity_id_index = inline for (types, 0..) |ty, i| {
                if (ty == Entity) break i;
            } else @compileError("can't extract components by net_id when the identifier is not queried");

            var it = query.iterator;
            while (it.next()) |item| {
                if (item[entity_id_index].net_id == net_id)
                    return item;
            } else return null;
        }

        pub fn byEntityHandle(query: Q, entity: Entity) ?Item {
            var it = query.iterator;
            it.index = entity.index;

            return it.peekCurrent(it.entities.slice());
        }

        pub const Iterator = struct {
            entities: *std.MultiArrayList(EntityComponentStorage),
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

pub fn init(
    gpa: Allocator,
    fs: *FileSystem,
    player_id: i32,
    instance_id: i32,
) !Scene {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const instance = try file_util.loadOrCreateZon(
        SceneInstance,
        gpa,
        arena.allocator(),
        fs,
        "player/{d}/scene/{d}/instance",
        .{ player_id, instance_id },
    );

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

    errdefer scene.deinit(gpa);

    try scene.loadEntities(gpa, fs);

    return scene;
}

pub fn deinit(scene: *Scene, gpa: Allocator) void {
    scene.instance.deinit(gpa);
    scene.formation_info.deinit(gpa);
    scene.explore_tools_info.deinit(gpa);

    for (0..scene.entities.len) |i| {
        var entity = scene.entities.get(i);
        entity.deinit(gpa);
    }

    scene.entities.deinit(gpa);
    scene.net_id_map.deinit(gpa);
}

fn loadEntities(scene: *Scene, gpa: Allocator, fs: *FileSystem) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    const entity_dir = try std.fmt.allocPrint(
        arena.allocator(),
        "player/{d}/scene/{d}/entity/",
        .{ scene.player_id, scene.instance_id },
    );

    if (try fs.readDir(entity_dir)) |dir| {
        defer dir.deinit();

        for (dir.entries) |entry| if (entry.kind == .directory) {
            const entity_id = std.fmt.parseInt(i64, entry.basename(), 10) catch continue;

            var storage = try EntityComponentStorage.load(gpa, fs, scene.player_id, scene.instance_id, entity_id);
            errdefer storage.deinit(gpa);

            try scene.net_id_map.put(gpa, entity_id, scene.entities.len);
            try scene.entities.append(gpa, storage);
        };
    }
}

pub fn spawn(scene: *Scene, gpa: Allocator, fs: *FileSystem, components: anytype) !Entity {
    const log = std.log.scoped(.entity_spawn);
    var storage: EntityComponentStorage = undefined;

    inline for (comptime std.meta.fields(EntityComponentStorage)) |storage_field| {
        if (comptime std.mem.eql(u8, storage_field.name, "entity_id")) continue;

        const is_optional = comptime std.meta.activeTag(@typeInfo(storage_field.type)) == .optional;
        inline for (comptime std.meta.fields(@TypeOf(components)), 0..) |param_field, i| {
            if ((!is_optional and param_field.type == storage_field.type) or (is_optional and ?param_field.type == storage_field.type)) {
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

    const id = try scene.nextEntityId(fs, gpa);
    storage.entity_id = .{ .net_id = id };

    try scene.net_id_map.put(gpa, id, scene.entities.len);
    try scene.entities.append(gpa, storage);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    try storage.save(arena.allocator(), fs, scene.player_id, scene.instance_id);

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

pub fn remove(scene: *Scene, gpa: Allocator, fs: *FileSystem, net_id: i64, index: i64) !void {
    var storage = scene.entities.get(index);
    try delete(fs, scene.player_id, scene.instance_id, net_id);
    storage.deinit(gpa);
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
    const incr_path = try std.fmt.allocPrint(
        gpa,
        "player/{d}/scene/{d}/entity/next",
        .{ scene.player_id, scene.instance_id },
    );

    defer gpa.free(incr_path);

    return try incr.next(i64, fs, incr_path);
}
