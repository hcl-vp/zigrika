const EntityComponentStorage = @This();
const std = @import("std");
const common = @import("common");
const file_util = @import("../../../fs/file_util.zig");
const comp_util = @import("../comp_util.zig");
const mem = @import("../../../mem.zig");
const pb = @import("proto").pb;
const BaseSkinComponent = @import("BaseSkinComponent.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

entity_id: struct { net_id: i64 },
config: @import("ConfigComponent.zig"),
position: ?@import("PositionComponent.zig") = null,
player_id: ?@import("PlayerIDComponent.zig") = null,
visible: ?@import("VisibleMarker.zig") = null,
actor_visible: ?@import("ActorVisibleMarker.zig") = null,
direct_control: ?@import("DirectControlMarker.zig") = null,
attribute: ?@import("AttributeComponent.zig") = null,
buffs: ?@import("FightBuffComponent.zig") = null,
character_attach: ?@import("CharacterAttachComponent.zig") = null,
concomitant: ?@import("ConcomitantComponent.zig") = null,
equip: ?@import("EquipComponent.zig") = null,
follower: ?@import("FollowerComponent.zig") = null,
logic_state: ?@import("LogicStateComponent.zig") = null,
monster_ai: ?@import("MonsterAiComponent.zig") = null,
passive_ga_skill: ?@import("PassiveGaSkillComponent.zig") = null,
player_battle_binder: ?@import("PlayerBattleBinder.zig") = null,
summoner: ?@import("SummonerComponent.zig") = null,
fsm: ?@import("FsmComponent.zig") = null,
vision_skills: ?@import("VisionSkillComponent.zig") = null,
base_skin: ?BaseSkinComponent = null,
calabash_skin: ?@import("CalabashSkinComponent.zig") = null,
weapon_skin: ?@import("WeaponSkinComponent.zig") = null,
ornament: ?@import("OrnamentComponent.zig") = null,

pub fn fieldIndexForType(comptime Component: type) usize {
    return comptime fieldByType(Component).@"1";
}

pub fn fieldByType(comptime Component: type) struct { std.builtin.Type.StructField, usize } {
    inline for (comptime std.meta.fields(EntityComponentStorage), 0..) |field, i| {
        if (*field.type == Component) return .{ field, i };

        const is_optional = comptime std.meta.activeTag(@typeInfo(field.type)) == .optional;
        if (is_optional and comptime ?*std.meta.Child(field.type) == Component) return .{ field, i };
        if (is_optional and comptime *std.meta.Child(field.type) == Component) return .{ field, i };
    }

    @compileError("requested type is not a valid component: " ++ @typeName(Component));
}

pub fn isComponentOptional(comptime Component: type) bool {
    const T = if (comptime std.meta.activeTag(@typeInfo(Component)) == .optional) std.meta.Child(Component) else Component;

    inline for (comptime std.meta.fields(EntityComponentStorage)) |field| {
        const is_optional = comptime std.meta.activeTag(@typeInfo(field.type)) == .optional;
        const C = if (is_optional) std.meta.Child(field.type) else field.type;

        if (*C == T) return is_optional;
    }

    @compileError("requested type is not a valid component: " ++ @typeName(Component));
}

pub fn load(gpa: Allocator, fs: *FileSystem, player_id: i32, scene_id: i32, entity_id: i64) !EntityComponentStorage {
    const log = std.log.scoped(.load_entity_components);
    var storage: EntityComponentStorage = undefined;

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    inline for (comptime std.meta.fields(EntityComponentStorage)) |field| {
        if (comptime std.mem.eql(u8, field.name, "entity_id")) continue;
        const is_optional = comptime std.meta.activeTag(@typeInfo(field.type)) == .optional;

        const component = try file_util.loadZon(
            comptime if (is_optional) std.meta.Child(field.type) else field.type,
            gpa,
            arena.allocator(),
            fs,
            "player/{d}/scene/{d}/entity/{d}/" ++ field.name,
            .{ player_id, scene_id, entity_id },
        );

        if (is_optional) {
            @field(storage, field.name) = component;
        } else {
            @field(storage, field.name) = component orelse {
                log.err(
                    "entity [{d}:{d}:{d}] is missing a required component '" ++ field.name ++ "'",
                    .{ player_id, scene_id, entity_id },
                );

                return error.MissingComponent;
            };
        }
    }

    storage.entity_id = .{ .net_id = entity_id };

    return storage;
}

pub fn save(
    storage: *const EntityComponentStorage,
    arena: Allocator,
    fs: *FileSystem,
    player_id: i32,
    scene_id: i32,
) !void {
    var path_buf: [512]u8 = undefined;

    inline for (comptime std.meta.fields(EntityComponentStorage)) |field| {
        if (comptime std.mem.eql(u8, field.name, "entity_id")) continue;

        const path = try std.fmt.bufPrint(
            path_buf[0..],
            "player/{d}/scene/{d}/entity/{d}/" ++ field.name,
            .{ player_id, scene_id, storage.entity_id.net_id },
        );

        try saveComponent(@field(storage, field.name), arena, fs, path);
    }
}

pub fn savePartial(
    storage: *const EntityComponentStorage,
    arena: Allocator,
    fs: *FileSystem,
    player_id: i32,
    scene_id: i32,
    comptime components: []const type,
) !void {
    var path_buf: [512]u8 = undefined;

    inline for (components) |Component| {
        const field, _ = comptime fieldByType(*Component);

        const path = try std.fmt.bufPrint(
            path_buf[0..],
            "player/{d}/scene/{d}/entity/{d}/" ++ field.name,
            .{ player_id, scene_id, storage.entity_id.net_id },
        );

        try saveComponent(@field(storage, field.name), arena, fs, path);
    }
}

pub fn saveComponent(
    component: anytype,
    arena: Allocator,
    fs: *FileSystem,
    path: []const u8,
) !void {
    const is_optional = comptime std.meta.activeTag(@typeInfo(@TypeOf(component))) == .optional;

    if (is_optional) {
        if (component) |comp| {
            try comp_util.saveStruct(fs, comp, path, arena);
        }
    } else {
        try comp_util.saveStruct(fs, component, path, arena);
    }
}

pub fn deinit(storage: *EntityComponentStorage, gpa: Allocator) void {
    inline for (comptime std.meta.fields(EntityComponentStorage)) |field| {
        const FieldType = comptime if (std.meta.activeTag(@typeInfo(field.type)) == .optional)
            std.meta.Child(field.type)
        else
            field.type;

        const has_deinit = comptime @hasDecl(FieldType, "deinit");

        if (comptime std.meta.activeTag(@typeInfo(field.type)) == .optional) {
            if (@field(storage, field.name)) |*comp| {
                if (has_deinit) comp.deinit(gpa) else std.zon.parse.free(gpa, comp.*);
            }
        } else {
            std.zon.parse.free(gpa, @field(storage, field.name));
        }
    }
}

pub fn sliceToArrayList(comptime T: type, slice: []T) std.ArrayList(T) {
    return .{
        .items = slice,
        .capacity = slice.len,
    };
}

pub fn entityToProto(
    storage: *const EntityComponentStorage,
    net_id: i64,
    alloc: mem.Alloc,
) !pb.EntityPb {
    const base_skin_comp = storage.base_skin orelse BaseSkinComponent{};
    var entity: pb.EntityPb = .{
        .Id = net_id,
        .ConfigId = storage.config.config_id,
        .ConfigType = @enumFromInt(@intFromEnum(storage.config.config_type)),
        .EntityType = @enumFromInt(@intFromEnum(storage.config.entity_type)),
        .EntityState = @enumFromInt(@intFromEnum(storage.config.state)),
        .d3s = .{ .Camp = storage.config.camp },
        .IsVisible = storage.visible != null,
        .IsActorVisible = storage.actor_visible != null,
        .PlayerId = if (storage.player_id) |comp| comp.id else 0,
        .InitLinearVelocity = .{},
        .Gravity = .{ .X = 0.0, .Y = 0.0, .Z = -1.0 },
        .RoleSkinId = base_skin_comp.role_skin_id,
        .ParaglidingSkinId = base_skin_comp.paragliding_skin_id,
        .SoarWingSkinId = base_skin_comp.soar_skin_id,
    };

    if (storage.position) |pos_comp| {
        const proto_transform: pb.Transform = pos_comp.toProto();
        entity.Pos = proto_transform.Pos;
        entity.Rot = proto_transform.Rot;
        entity.InitPos = entity.Pos;
    }

    if (storage.attribute) |attr_comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .AttributeComponent = try attr_comp.toProto(alloc) },
        });
    }

    if (storage.buffs) |buff_comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .FightBuffComponent = buff_comp.toProto() },
        });
    }

    if (storage.character_attach) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .CharacterAttachComponentPb = try comp.toProto() },
        });
    }

    if (storage.concomitant) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .ConcomitantsComponentPb = try comp.toProto() },
        });
    }

    if (storage.equip) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .EquipComponent = try comp.toProto() },
        });
    }

    if (storage.follower) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .FollowerComponentPb = try comp.toProto(alloc) },
        });
    }

    if (storage.logic_state) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .LogicStateComponentPb = try comp.toProto() },
        });
    }

    if (storage.monster_ai) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .MonsterAiComponentPb = try comp.toProto() },
        });
    }

    if (storage.passive_ga_skill) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .PassiveGaSkillComponentPb = try comp.toProto() },
        });
    }

    if (storage.player_battle_binder) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .PlayerSceneComponentPb = try comp.toProto(alloc) },
        });
    }

    if (storage.summoner) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .SummonerComponent = try comp.toProto() },
        });
    }

    if (storage.fsm) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .EntityFsmComponentPb = try comp.toProto() },
        });
    }

    if (storage.vision_skills) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .VisionSkillComponent = try comp.toProto() },
        });
    }

    if (storage.weapon_skin) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .WeaponSkinComponentPb = try comp.toProto() },
        });
    }

    if (storage.ornament) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .OrnamentComponentPb = try comp.toProto() },
        });
    }

    if (storage.calabash_skin) |comp| {
        try entity.ComponentPbs.append(alloc.arena, .{
            .ComponentPb = .{ .CalabashSkinComponentPb = try comp.toProto() },
        });
    }

    return entity;
}
