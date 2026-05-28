const PlayerComponentStorage = @This();
const std = @import("std");
const common = @import("common");
const Assets = @import("../../../data/Assets.zig");
const PlayerID = @import("../../PlayerID.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

fs: *FileSystem,
id: PlayerID,
basic: @import("PlayerBasicComponent.zig"),
role: @import("PlayerRoleComponent.zig"),
weapon: @import("PlayerWeaponComponent.zig"),
cosmetic: @import("PlayerCosmeticComponent.zig"),
inventory: @import("PlayerInventoryComponent.zig"),
guide: @import("PlayerGuideComponent.zig"),
scene: @import("PlayerSceneComponent.zig"),

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerComponentStorage {
    return .{
        .fs = fs,
        .id = .{ .id = player_id },
        .basic = try .init(gpa, fs, player_id),
        .role = try .init(gpa, fs, assets, player_id),
        .weapon = try .init(gpa, fs, assets, player_id),
        .cosmetic = try .init(gpa, fs, assets, player_id),
        .inventory = try .init(gpa, fs, assets, player_id),
        .guide = try .init(gpa, fs, player_id),
        .scene = try .init(gpa, fs, player_id),
    };
}

pub fn deinit(pcs: *PlayerComponentStorage, gpa: Allocator) void {
    pcs.basic.deinit(gpa);
    pcs.role.deinit(gpa);
    pcs.weapon.deinit(gpa);
    pcs.cosmetic.deinit(gpa);
    pcs.inventory.deinit(gpa);
    pcs.guide.deinit(gpa);
    pcs.scene.deinit(gpa);
}

pub fn hasComponent(comptime Component: type) bool {
    if (comptime std.meta.activeTag(@typeInfo(Component)) != .pointer) return false;

    const ComponentType = comptime std.meta.Child(Component);
    inline for (comptime std.meta.fields(PlayerComponentStorage)) |field| {
        if (field.type == ComponentType) {
            return true;
        }
    }

    return false;
}

pub inline fn extract(pcs: *PlayerComponentStorage, comptime Component: type) Component {
    if (comptime std.meta.activeTag(@typeInfo(Component)) != .pointer) return null;

    const ComponentType = comptime std.meta.Child(Component);
    inline for (comptime std.meta.fields(PlayerComponentStorage)) |field| {
        if (field.type == ComponentType) {
            return &@field(pcs, field.name);
        }
    }

    @compileError("no component of type '" ++ @typeName(Component) ++ "' in PlayerComponentStorage");
}
