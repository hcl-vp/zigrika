const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const mem = @import("../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerCosmeticComponent = @import("../../logic/component/player/PlayerCosmeticComponent.zig");
const CosmeticInfo = @import("../../fs/CosmeticInfo.zig");
const Entity = Scene.Entity;
const shared = @import("echo/shared.zig");
const BuffTimerScheduler = @import("../../logic/schedulers/BuffTimerScheduler.zig");

const phantomItemList = shared.phantomItemList;
const equipInfoList = shared.equipInfoList;
const rolePropInfoList = shared.rolePropInfoList;
const changedEquipInfoList = shared.changedEquipInfoList;
const appendRolesWithMainEcho = shared.appendRolesWithMainEcho;
const pushRolePropUpdate = shared.pushRolePropUpdate;
const refreshRoleEntities = shared.refreshRoleEntities;

pub fn onPhantomItemRequest(
    txn: *Transaction(pb.PhantomItemRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    txn.respond(.{
        .PhantomItemList = try phantomItemList(echo_comp, alloc.arena),
        .EquipInfoList = try equipInfoList(role_comp, echo_comp, alloc.arena),
        .PropInfo = try rolePropInfoList(assets, role_comp, echo_comp, weapon_comp, alloc.gpa, alloc.arena),
        .MaxCost = maxCalabashCost(assets),
        .PhantomSkinList = try CosmeticInfo.intList(cosmetic_comp.info.phantom_skins, alloc.arena),
        .DirectRefineWeekTimes = 0,
    });
}

fn maxCalabashCost(assets: *const Assets) i32 {
    var max_level: i32 = std.math.minInt(i32);
    var cost: i32 = 0;
    for (assets.tables.calabash_level.items) |level| {
        if (level.Level > max_level) {
            max_level = level.Level;
            cost = level.Cost;
        }
    }
    return cost;
}

pub fn onPhantomSkinChangeRequest(
    txn: *Transaction(pb.PhantomSkinChangeRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene_opt: *?Scene,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    const echo = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    const item_config = assets.tables.phantom_item.getDataById(echo.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };

    if (txn.message.SkinId != 0) {
        const skin_config = assets.tables.phantom_item.getDataById(txn.message.SkinId) orelse {
            txn.respond(.{ .ErrorCode = .ErrPhantomSkinNotExist });
            return;
        };
        if (skin_config.ParentMonsterId != item_config.MonsterId or !CosmeticInfo.has(cosmetic_comp.info.phantom_skins, txn.message.SkinId)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomSkinNotUnlock });
            return;
        }
    }

    var changed_roles: std.array_hash_map.Auto(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    try appendRolesWithMainEcho(echo_comp, alloc.gpa, txn.message.IncrId, &changed_roles);

    echo.skin_id = txn.message.SkinId;
    if (txn.message.ChangeDefault) {
        for (echo_comp.echo_map.keys(), echo_comp.echo_map.values()) |inc_id, *other| {
            const other_config = assets.tables.phantom_item.getDataById(other.id) orelse continue;
            if (other_config.MonsterId == item_config.MonsterId) {
                other.skin_id = txn.message.SkinId;
                try appendRolesWithMainEcho(echo_comp, alloc.gpa, inc_id, &changed_roles);
            }
        }
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    if (changed_roles.count() != 0) {
        const scene = &(scene_opt.* orelse {
            txn.respond(.{ .ErrorCode = .Success });
            return;
        });
        const query: Scene.Query(&.{
            Entity,
            *Entity.ConfigComponent,
            *Entity.VisionSkillComponent,
            *Entity.ConcomitantComponent,
            *Entity.AttributeComponent,
            *Entity.FightBuffComponent,
        }) = .{ .iterator = .{ .entities = &scene.entities } };
        try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, now_ms);
    }
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhantomPutOnRequest(
    txn: *Transaction(pb.PhantomPutOnRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    query: Scene.Query(&.{
        Entity,
        *Entity.ConfigComponent,
        *Entity.VisionSkillComponent,
        *Entity.ConcomitantComponent,
        *Entity.AttributeComponent,
        *Entity.FightBuffComponent,
    }),
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    if (txn.message.Pos < 0 or txn.message.Pos >= 5) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }

    if (txn.message.IncId != 0 and echo_comp.echo_map.get(txn.message.IncId) == null) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }

    var changed_roles: std.array_hash_map.Auto(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    try changed_roles.put(alloc.gpa, txn.message.RoleId, {});

    const target_pos = txn.message.Pos;
    const target = echo_comp.equippedEcho(txn.message.RoleId, target_pos);
    const source = if (txn.message.IncId != 0) echo_comp.equippedEchoByIncrId(txn.message.IncId) else null;
    if (target) |equip| try changed_roles.put(alloc.gpa, equip.role_id, {});
    if (source) |equip| try changed_roles.put(alloc.gpa, equip.role_id, {});

    if (txn.message.IncId == 0) {
        if (target) |equip| {
            if (echo_comp.echo_map.getPtr(equip.inc_id)) |item| {
                item.role_id = null;
                item.equipped_pos = -1;
            }
        }
    } else {
        if (target) |target_equip| {
            if (target_equip.inc_id != txn.message.IncId) {
                const target_item = echo_comp.echo_map.getPtr(target_equip.inc_id).?;
                if (source) |source_equip| {
                    target_item.role_id = source_equip.role_id;
                    target_item.equipped_pos = source_equip.pos;
                } else {
                    target_item.role_id = null;
                    target_item.equipped_pos = -1;
                }
            }
        }
        const item = echo_comp.echo_map.getPtr(txn.message.IncId).?;
        item.role_id = txn.message.RoleId;
        item.equipped_pos = target_pos;
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
    try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, now_ms);

    txn.respond(.{
        .ErrorCode = .Success,
        .EquipInfoList = try changedEquipInfoList(echo_comp, changed_roles, alloc.arena),
    });
}

pub fn onPhantomAutoPutRequest(
    txn: *Transaction(pb.PhantomAutoPutRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    query: Scene.Query(&.{
        Entity,
        *Entity.ConfigComponent,
        *Entity.VisionSkillComponent,
        *Entity.ConcomitantComponent,
        *Entity.AttributeComponent,
        *Entity.FightBuffComponent,
    }),
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
) !void {
    const now_ms = (std.Io.Clock.awake).now(io).toMilliseconds();
    var changed_roles: std.array_hash_map.Auto(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    try changed_roles.put(alloc.gpa, txn.message.RoleId, {});

    var requested: [5]i32 = .{ 0, 0, 0, 0, 0 };
    var seen: std.hash_map.AutoHashMapUnmanaged(i32, void) = .empty;
    defer seen.deinit(alloc.gpa);

    for (txn.message.PhantomItemIncrId.items, 0..) |inc_id, index| {
        if (index >= requested.len) break;
        if (inc_id != 0) {
            if (echo_comp.echo_map.get(inc_id) == null or seen.contains(inc_id)) {
                txn.respond(.{ .ErrorCode = .RequestParamError });
                return;
            }
            try seen.put(alloc.gpa, inc_id, {});
        }
        requested[index] = inc_id;
    }

    var iterator = echo_comp.echo_map.iterator();
    while (iterator.next()) |kv| {
        const role_id = kv.value_ptr.role_id;
        const equipped_pos = kv.value_ptr.equipped_pos;
        if (role_id == null or equipped_pos < 0 or equipped_pos >= 5) continue;
        if (role_id.? == txn.message.RoleId or seen.contains(kv.key_ptr.*)) {
            try changed_roles.put(alloc.gpa, role_id.?, {});
            kv.value_ptr.role_id = null;
            kv.value_ptr.equipped_pos = -1;
        }
    }
    for (requested, 0..) |inc_id, index| {
        if (inc_id == 0) continue;
        const item = echo_comp.echo_map.getPtr(inc_id).?;
        item.role_id = txn.message.RoleId;
        item.equipped_pos = @intCast(index);
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
    try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, now_ms);

    txn.respond(.{
        .ErrorCode = .Success,
        .EquipInfoList = try changedEquipInfoList(echo_comp, changed_roles, alloc.arena),
    });
}
