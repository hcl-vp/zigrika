const PlayerComponentStorage = @This();
const std = @import("std");
const common = @import("common");
const Assets = @import("../../../data/Assets.zig");
const EchoInfo = @import("../../../fs/EchoInfo.zig");
const PlayerID = @import("../../PlayerID.zig");
const special_item_incr = @import("../../../fs/special_item_incr.zig");

const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

fs: *FileSystem,
id: PlayerID,
basic: @import("PlayerBasicComponent.zig"),
role: @import("PlayerRoleComponent.zig"),
weapon: @import("PlayerWeaponComponent.zig"),
echo: @import("PlayerEchoComponent.zig"),
cosmetic: @import("PlayerCosmeticComponent.zig"),
inventory: @import("PlayerInventoryComponent.zig"),
gacha: @import("PlayerGachaComponent.zig"),
guide: @import("PlayerGuideComponent.zig"),
map: @import("PlayerMapComponent.zig"),
music: @import("PlayerMusicComponent.zig"),
scene: @import("PlayerSceneComponent.zig"),
motor: @import("PlayerMotorComponent.zig"),

pub fn init(gpa: Allocator, fs: *FileSystem, assets: *const Assets, player_id: i32) !PlayerComponentStorage {
    var role = try @import("PlayerRoleComponent.zig").init(gpa, fs, assets, player_id);
    errdefer role.deinit(gpa);
    var weapon = try @import("PlayerWeaponComponent.zig").init(gpa, fs, assets, player_id);
    errdefer weapon.deinit(gpa);
    var echo = try @import("PlayerEchoComponent.zig").init(gpa, fs, assets, player_id);
    errdefer echo.deinit(gpa);

    const next_special_item_id = @max(
        special_item_incr.nextAfterMaps(.{ &weapon.weapon_map, &echo.echo_map }),
        EchoInfo.nextAfterPresetGroups(echo.preset_info.groups),
    );
    try special_item_incr.ensureAtLeast(
        gpa,
        fs,
        player_id,
        next_special_item_id,
    );

    return .{
        .fs = fs,
        .id = .{ .id = player_id },
        .basic = try .init(gpa, fs, player_id),
        .role = role,
        .weapon = weapon,
        .echo = echo,
        .cosmetic = try .init(gpa, fs, assets, player_id),
        .inventory = try .init(gpa, fs, assets, player_id),
        .gacha = try .init(gpa, fs, player_id),
        .guide = try .init(gpa, fs, player_id),
        .map = try .init(gpa, fs, player_id),
        .music = try .init(gpa, fs, player_id),
        .scene = try .init(gpa, fs, player_id),
        .motor = try .init(gpa, fs, assets, player_id),
    };
}

pub fn deinit(pcs: *PlayerComponentStorage, gpa: Allocator) void {
    pcs.basic.deinit(gpa);
    pcs.role.deinit(gpa);
    pcs.weapon.deinit(gpa);
    pcs.echo.deinit(gpa);
    pcs.cosmetic.deinit(gpa);
    pcs.inventory.deinit(gpa);
    pcs.gacha.deinit(gpa);
    pcs.guide.deinit(gpa);
    pcs.map.deinit(gpa);
    pcs.music.deinit(gpa);
    pcs.scene.deinit(gpa);
    pcs.motor.deinit(gpa);
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
