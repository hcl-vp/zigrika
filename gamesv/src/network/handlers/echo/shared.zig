const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../../handlers.zig").Transaction;
const mem = @import("../../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../../data/Assets.zig");
const Scene = @import("../../../logic/Scene.zig");
const PlayerRoleComponent = @import("../../../logic/component/player/PlayerRoleComponent.zig");
const PlayerEchoComponent = @import("../../../logic/component/player/PlayerEchoComponent.zig");
const PlayerWeaponComponent = @import("../../../logic/component/player/PlayerWeaponComponent.zig");
const EchoInfo = @import("../../../fs/EchoInfo.zig");
const RoleInfo = @import("../../../fs/RoleInfo.zig");
const RoleEntityTemplates = @import("../../../logic/templates/RoleEntityTemplates.zig");
const RoleStats = @import("../../../logic/helpers/role_stats.zig");
const RoleHelper = @import("../../../logic/helpers/role.zig");
const Attributes = @import("../../../logic/helpers/attributes.zig");
const RoleAttributeSync = @import("../../helpers/role_attribute_sync.zig");
const sliceToArrayList = @import("../../../logic/component/entity/EntityComponentStorage.zig").sliceToArrayList;
const Entity = Scene.Entity;
const BuffTimerScheduler = @import("../../../logic/schedulers/BuffTimerScheduler.zig");
pub fn phantomItemList(echo_comp: *PlayerEchoComponent, arena: std.mem.Allocator) !std.ArrayList(pb.PhantomItem) {
    var list: std.ArrayList(pb.PhantomItem) = .empty;
    try list.ensureTotalCapacity(arena, echo_comp.echo_map.count());

    var iterator = echo_comp.echo_map.iterator();
    while (iterator.next()) |kv| {
        list.appendAssumeCapacity(try kv.value_ptr.toProto(kv.key_ptr.*, arena));
    }

    return list;
}

pub fn visionEquipGroupList(echo_comp: *PlayerEchoComponent, arena: std.mem.Allocator) !std.ArrayList(pb.RefreshVisionEquipGroupData) {
    var list: std.ArrayList(pb.RefreshVisionEquipGroupData) = .empty;
    try list.ensureTotalCapacity(arena, echo_comp.preset_info.groups.len);
    for (echo_comp.preset_info.groups) |group| {
        list.appendAssumeCapacity(try EchoInfo.presetToProto(group, arena));
    }
    return list;
}

pub fn equipInfoList(
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.RolePhantomEquipInfo) {
    var list: std.ArrayList(pb.RolePhantomEquipInfo) = .empty;
    try list.ensureTotalCapacity(arena, role_comp.role_map.count());
    for (role_comp.role_map.keys()) |role_id| {
        const equip = echo_comp.roleEquip(role_id);
        list.appendAssumeCapacity(try EchoInfo.equipToProto(equip, arena));
    }
    return list;
}

pub fn rolePropInfoList(
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.RolePhantomPropInfo) {
    var list: std.ArrayList(pb.RolePhantomPropInfo) = .empty;
    try list.ensureTotalCapacity(arena, role_comp.role_map.count());
    for (role_comp.role_map.keys()) |role_id| {
        const equip = echo_comp.roleEquip(role_id);
        list.appendAssumeCapacity(try rolePropInfo(assets, role_comp, echo_comp, weapon_comp, gpa, arena, equip));
    }
    return list;
}

pub fn changedRolePropInfoList(
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    changed_roles: std.AutoArrayHashMapUnmanaged(i32, void),
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
) !std.ArrayList(pb.RolePhantomPropInfo) {
    var list: std.ArrayList(pb.RolePhantomPropInfo) = .empty;
    try list.ensureTotalCapacity(arena, changed_roles.count());
    for (changed_roles.keys()) |role_id| {
        const equip = echo_comp.roleEquip(role_id);
        list.appendAssumeCapacity(try rolePropInfo(assets, role_comp, echo_comp, weapon_comp, gpa, arena, equip));
    }
    return list;
}

fn rolePropInfo(
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
    equip: EchoInfo.RoleEquip,
) !pb.RolePhantomPropInfo {
    var display = try RoleStats.buildPhantomDisplayProps(gpa, assets, role_comp, weapon_comp, echo_comp, equip.role_id);
    defer display.deinit(gpa);

    return .{
        .RoleId = equip.role_id,
        .BaseProp = try propMapToList(display.base_props, arena),
        .AddProp = try propMapToList(display.add_props, arena),
    };
}

fn propMapToList(map: std.AutoArrayHashMapUnmanaged(i32, i32), arena: std.mem.Allocator) !std.ArrayList(pb.ArrayIntInt) {
    var list: std.ArrayList(pb.ArrayIntInt) = .empty;
    try list.ensureTotalCapacity(arena, map.count());
    for (map.keys(), map.values()) |key, value| {
        list.appendAssumeCapacity(.{ .Key = key, .Value = value });
    }
    return list;
}

pub fn changedEquipInfoList(
    echo_comp: *PlayerEchoComponent,
    changed_roles: std.AutoArrayHashMapUnmanaged(i32, void),
    arena: std.mem.Allocator,
) !std.ArrayList(pb.RolePhantomEquipInfo) {
    var list: std.ArrayList(pb.RolePhantomEquipInfo) = .empty;
    try list.ensureTotalCapacity(arena, changed_roles.count());
    for (changed_roles.keys()) |role_id| {
        const equip = echo_comp.roleEquip(role_id);
        list.appendAssumeCapacity(try EchoInfo.equipToProto(equip, arena));
    }
    return list;
}

pub fn addConsume(
    gpa: std.mem.Allocator,
    consumes: *std.AutoArrayHashMapUnmanaged(i32, i32),
    item_id: i32,
    count: i32,
) !void {
    const current = consumes.get(item_id) orelse 0;
    try consumes.put(gpa, item_id, current + count);
}

pub const TunerCost = struct {
    item_id: i32,
    count: i32,
};

pub fn tunerCost(assets: *const Assets, quality: i32) ?TunerCost {
    const config = assets.tables.phantom_quality.getDataById(quality) orelse return null;
    var iterator = config.IdentifyCost.map.iterator();
    const entry = iterator.next() orelse return null;
    return .{ .item_id = entry.key_ptr.*, .count = entry.value_ptr.* };
}

pub fn highestPhantomLevel(assets: *const Assets, group_id: i32) ?i32 {
    var highest: ?i32 = null;
    for (assets.tables.phantom_level.items) |entry| {
        if (entry.GroupId != group_id) continue;
        if (highest == null or entry.Level > highest.?) highest = entry.Level;
    }
    return highest;
}

pub fn phantomLevelExp(assets: *const Assets, group_id: i32, level: i32) ?i32 {
    for (assets.tables.phantom_level.items) |entry| {
        if (entry.GroupId == group_id and entry.Level == level) return entry.Exp;
    }
    return null;
}

pub fn rolesEquippingEcho(
    echo_comp: *PlayerEchoComponent,
    gpa: std.mem.Allocator,
    inc_id: i32,
) !std.AutoArrayHashMapUnmanaged(i32, void) {
    var changed_roles: std.AutoArrayHashMapUnmanaged(i32, void) = .empty;
    try appendRolesEquippingEcho(echo_comp, gpa, inc_id, &changed_roles);
    return changed_roles;
}

pub fn appendRolesEquippingEcho(
    echo_comp: *PlayerEchoComponent,
    gpa: std.mem.Allocator,
    inc_id: i32,
    changed_roles: *std.AutoArrayHashMapUnmanaged(i32, void),
) !void {
    if (echo_comp.equippedEchoByIncrId(inc_id)) |equip| {
        try changed_roles.put(gpa, equip.role_id, {});
    }
}

pub fn appendRolesWithMainEcho(
    echo_comp: *PlayerEchoComponent,
    gpa: std.mem.Allocator,
    inc_id: i32,
    changed_roles: *std.AutoArrayHashMapUnmanaged(i32, void),
) !void {
    if (echo_comp.equippedEchoByIncrId(inc_id)) |equip| {
        if (equip.pos == 0) try changed_roles.put(gpa, equip.role_id, {});
    }
}

pub fn pushRolePropUpdate(
    txn: anytype,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    weapon_comp: *PlayerWeaponComponent,
    changed_roles: std.AutoArrayHashMapUnmanaged(i32, void),
) !void {
    try txn.conn.push(pb.RolePhantomPropUpdateNotify{
        .PropInfo = try changedRolePropInfoList(assets, role_comp, echo_comp, weapon_comp, changed_roles, alloc.gpa, alloc.arena),
    });
}

pub fn refreshRoleEntities(
    txn: anytype,
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
    changed_roles: std.AutoArrayHashMapUnmanaged(i32, void),
    buff_timers: *BuffTimerScheduler,
    io: std.Io,
    now_ms: i64,
) !void {
    _ = io;
    const instance_dungeon = assets.tables.instance_dungeon.getDataById(scene.instance_id) orelse return;

    var reset_roles: std.AutoArrayHashMapUnmanaged(i32, void) = .empty;
    defer reset_roles.deinit(alloc.gpa);

    var it = query.iterator;
    while (it.next()) |comps| {
        const entity = comps[0];
        const config = comps[1];
        const vision_skill_comp = comps[2];
        const concomitant_comp = comps[3];
        const attr_comp = comps[4];
        const buff_comp = comps[5];
        if (!changed_roles.contains(config.config_id)) continue;
        const role_info = role_comp.role_map.getPtr(config.config_id) orelse continue;

        const desired = desiredEchoVisionState(assets, echo_comp, config.config_id);
        if (!visionTopologyMatches(scene, concomitant_comp, desired)) {
            try reset_roles.put(alloc.gpa, config.config_id, {});
            continue;
        }

        const vision_state = try syncVisionEntities(
            txn,
            alloc,
            fs,
            scene,
            assets,
            role_info,
            instance_dungeon,
            entity.net_id,
            desired,
            concomitant_comp,
        );
        const vision_skill_changed = try syncVisionSkills(
            txn,
            alloc,
            echo_comp,
            assets,
            config.config_id,
            entity.net_id,
            vision_state.main_entity_id,
            vision_state.combo_entity_id,
            scene.explore_tools_info.active_explore_skill,
            vision_skill_comp,
        );
        const attribute_changed = try syncEchoAttributes(txn, alloc, assets, role_comp, config.config_id, weapon_comp, echo_comp, entity.net_id, attr_comp);
        const buff_changed = try syncEchoBuffEffects(txn, alloc, scene, assets, entity.net_id, config.config_id, echo_comp, buff_comp);

        if (!vision_state.changed and !vision_skill_changed and !attribute_changed and !buff_changed) continue;
        if (attribute_changed or buff_changed) {
            var wake_reason: Entity.FsmComponent.WakeMask = 0;
            if (attribute_changed) wake_reason |= Entity.FsmComponent.WakeReason.attribute;
            if (buff_changed) wake_reason |= Entity.FsmComponent.WakeReason.buff;
            try scene.markFsmDirty(alloc.gpa, entity.net_id, wake_reason);
        }
        try scene.saveComponents(fs, alloc.gpa, entity, &.{
            Entity.VisionSkillComponent,
            Entity.ConcomitantComponent,
            Entity.AttributeComponent,
            Entity.FightBuffComponent,
        });
    }

    if (reset_roles.count() != 0) {
        try RoleHelper.resetRoles(
            scene,
            fs,
            assets,
            role_comp,
            weapon_comp,
            echo_comp,
            txn.conn,
            alloc,
            reset_roles.keys(),
            buff_timers,
            now_ms,
        );
    }

    try RoleAttributeSync.pushRoleInfoNotifyForRoles(
        txn,
        alloc,
        assets,
        role_comp,
        weapon_comp,
        echo_comp,
        changed_roles.keys(),
    );
}

const DesiredVisionState = struct {
    main_summon_id: i32 = 0,
    combo_summon_id: i32 = 0,
};

const SyncedVisionState = struct {
    main_entity_id: i64 = 0,
    combo_entity_id: i64 = 0,
    changed: bool = false,
};

fn desiredEchoVisionState(
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
    role_id: i32,
) DesiredVisionState {
    return .{
        .main_summon_id = echo_comp.mainEchoSummonId(assets, role_id) orelse 0,
        .combo_summon_id = echo_comp.comboEchoSummonId(assets, role_id) orelse 0,
    };
}

fn syncVisionEntities(
    txn: anytype,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    assets: *const Assets,
    role_info: *const RoleInfo,
    instance_dungeon: Assets.DataTables.InstanceDungeon,
    role_entity_id: i64,
    desired: DesiredVisionState,
    concomitant_comp: *Entity.ConcomitantComponent,
) !SyncedVisionState {
    const desired_summons = [_]i32{ desired.main_summon_id, desired.combo_summon_id };
    var desired_entities = [_]i64{ 0, 0 };
    var used_old = [_]bool{ false, false };
    var remove_infos: std.ArrayList(pb.EntityRemoveInfo) = .empty;
    var add_pbs: std.ArrayList(pb.EntityPb) = .empty;

    for (desired_summons, 0..) |summon_id, desired_index| {
        if (summon_id == 0) continue;
        for (concomitant_comp.vision_entity_id, 0..) |entity_id, old_index| {
            if (old_index >= used_old.len or used_old[old_index]) continue;
            if (visionEntitySummonId(scene, entity_id) != summon_id) continue;
            desired_entities[desired_index] = entity_id;
            used_old[old_index] = true;
            break;
        }
    }

    for (concomitant_comp.vision_entity_id, 0..) |entity_id, old_index| {
        if (old_index < used_old.len and used_old[old_index]) continue;
        try scene.remove(alloc.gpa, fs, entity_id);
        try remove_infos.append(alloc.arena, .{ .EntityId = entity_id });
    }

    for (desired_summons, 0..) |summon_id, desired_index| {
        if (summon_id == 0 or desired_entities[desired_index] != 0) continue;
        if (try RoleEntityTemplates.createVisionEntity(
            fs,
            scene,
            alloc,
            scene.player_id,
            assets,
            role_info,
            instance_dungeon,
            summon_id,
            role_entity_id,
        )) |vision_entity| {
            desired_entities[desired_index] = vision_entity.net_id;
            const storage = scene.entities.get(vision_entity.index);
            try add_pbs.append(alloc.arena, try storage.entityToProto(vision_entity.net_id, alloc, assets));
        }
    }

    var final_ids: std.ArrayList(i64) = .empty;
    for (desired_entities) |entity_id| {
        if (entity_id != 0) try final_ids.append(alloc.gpa, entity_id);
    }

    const same_ids = std.mem.eql(i64, concomitant_comp.vision_entity_id, final_ids.items);
    if (!same_ids) {
        if (concomitant_comp.vision_entity_id.len != 0) alloc.gpa.free(concomitant_comp.vision_entity_id);
        concomitant_comp.vision_entity_id = try final_ids.toOwnedSlice(alloc.gpa);
    } else {
        final_ids.deinit(alloc.gpa);
    }

    if (remove_infos.items.len != 0) {
        try txn.conn.push(pb.EntityRemoveNotify{
            .IsRemove = true,
            .RemoveInfos = remove_infos,
        });
    }
    if (add_pbs.items.len != 0) {
        try txn.conn.push(pb.EntityAddNotify{
            .RemoveTagIds = false,
            .EntityPbs = add_pbs,
        });
    }

    return .{
        .main_entity_id = desired_entities[0],
        .combo_entity_id = desired_entities[1],
        .changed = !same_ids or remove_infos.items.len != 0 or add_pbs.items.len != 0,
    };
}

fn visionEntitySummonId(scene: *Scene, entity_id: i64) ?i32 {
    const index = scene.net_id_map.get(entity_id) orelse return null;
    const storage = scene.entities.get(index);
    const summoner = storage.summoner orelse return null;
    return summoner.summon_skill_id;
}

fn visionTopologyMatches(scene: *Scene, concomitant_comp: *Entity.ConcomitantComponent, desired: DesiredVisionState) bool {
    const expected = [_]i32{ desired.main_summon_id, desired.combo_summon_id };
    var index: usize = 0;
    for (expected) |summon_id| {
        if (summon_id == 0) continue;
        if (index >= concomitant_comp.vision_entity_id.len) return false;
        const current_summon_id = visionEntitySummonId(scene, concomitant_comp.vision_entity_id[index]) orelse return false;
        if (current_summon_id != summon_id) return false;
        index += 1;
    }
    return index == concomitant_comp.vision_entity_id.len;
}

fn syncVisionSkills(
    txn: anytype,
    alloc: mem.Alloc,
    echo_comp: *PlayerEchoComponent,
    assets: *const Assets,
    role_id: i32,
    role_entity_id: i64,
    vision_entity_id: i64,
    combo_vision_entity_id: i64,
    explore_skill_id: i32,
    vision_skill_comp: *Entity.VisionSkillComponent,
) !bool {
    const desired = try echo_comp.buildVisionSkills(
        alloc.gpa,
        assets,
        role_id,
        vision_entity_id,
        combo_vision_entity_id,
        explore_skill_id,
    );
    errdefer alloc.gpa.free(desired);

    if (visionSkillsEqual(vision_skill_comp.vision_skills, desired)) {
        alloc.gpa.free(desired);
        return false;
    }

    if (vision_skill_comp.vision_skills.len != 0) alloc.gpa.free(vision_skill_comp.vision_skills);
    vision_skill_comp.vision_skills = desired;

    try txn.conn.push(pb.VisionSkillChangeNotify{
        .EntityId = role_entity_id,
        .VisionSkillInfos = sliceToArrayList(pb.VisionSkillInformation, vision_skill_comp.vision_skills),
    });
    return true;
}

fn visionSkillsEqual(a: []const pb.VisionSkillInformation, b: []const pb.VisionSkillInformation) bool {
    if (a.len != b.len) return false;
    for (a, b) |left, right| {
        if (left.SkillId != right.SkillId or
            left.Level != right.Level or
            left.Quality != right.Quality or
            left.VisionEntityId != right.VisionEntityId or
            left.Index != right.Index)
        {
            return false;
        }
    }
    return true;
}

fn syncEchoAttributes(
    txn: anytype,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    role_id: i32,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    entity_id: i64,
    attr_comp: *Entity.AttributeComponent,
) !bool {
    const before = try alloc.gpa.dupe(Entity.AttributeComponent.Attribute, attr_comp.attributes);
    defer alloc.gpa.free(before);

    try RoleStats.refreshAttributeComponent(alloc.gpa, assets, role_comp, role_id, weapon_comp, echo_comp, attr_comp);

    var changed: std.ArrayList(pb.EAttributeType) = .empty;
    inline for (comptime std.meta.fields(pb.EAttributeType), 0..) |field, index| {
        if (index >= attr_comp.attributes.len) break;
        const attr_type = @field(pb.EAttributeType, field.name);
        const old_attr = if (index < before.len) before[index] else Entity.AttributeComponent.Attribute{ .base = 0, .increment = 0, .current = 0 };
        const new_attr = attr_comp.attributes[index];
        if (old_attr.base != new_attr.base or old_attr.increment != new_attr.increment or old_attr.current != new_attr.current) {
            try changed.append(alloc.arena, attr_type);
        }
    }

    if (changed.items.len == 0) return false;
    try pushChangedAttributes(txn, alloc, entity_id, attr_comp, changed.items);
    return true;
}

fn pushChangedAttributes(
    txn: anytype,
    alloc: mem.Alloc,
    entity_id: i64,
    attr_comp: *Entity.AttributeComponent,
    changed: []const pb.EAttributeType,
) !void {
    var attrs: std.ArrayList(pb.GameplayAttributeData) = .empty;
    var recovers: std.ArrayList(pb.RecoverPropFromServer) = .empty;
    const recover_types = &[_]pb.EAttributeType{ .Hardness, .Tough, .ParalysisTime };

    for (changed) |attr_type| {
        const index = @intFromEnum(attr_type);
        if (index < 0 or index >= attr_comp.attributes.len) continue;
        const attr_index: usize = @intCast(index);
        const attr = attr_comp.attributes[attr_index];
        try attrs.append(alloc.arena, Attributes.gameplayAttributeData(attr_type, attr));

        if (std.mem.indexOfScalar(pb.EAttributeType, recover_types, attr_type) != null) {
            const max_value = blk: {
                if (try Attributes.get_related_attr(attr_type, .Max, alloc.gpa)) |max_attr| {
                    const max_index = @intFromEnum(max_attr);
                    if (max_index >= 0 and max_index < attr_comp.attributes.len) break :blk attr_comp.attributes[@intCast(max_index)].current;
                }
                break :blk 0;
            };
            const recover_value = blk: {
                if (try Attributes.get_related_attr(attr_type, .Recover, alloc.gpa)) |recover_attr| {
                    const recover_index = @intFromEnum(recover_attr);
                    if (recover_index >= 0 and recover_index < attr_comp.attributes.len) break :blk attr_comp.attributes[@intCast(recover_index)].current;
                }
                break :blk 0;
            };
            try recovers.append(alloc.arena, .{
                .AttrId = @intCast(index),
                .Ratio = recover_value,
                .MaxValue = max_value,
                .ValueIncrement = attr.current,
            });
        }
    }

    var data: std.ArrayList(pb.CombatReceiveData) = .empty;
    try data.append(alloc.arena, .{ .Message = .{
        .CombatNotifyData = .{
            .CombatCommon = .{ .EntityId = entity_id },
            .Message = .{ .AttributeChangedNotify = .{ .Attributes = attrs } },
        },
    } });
    if (recovers.items.len != 0) {
        try data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entity_id },
                .Message = .{
                    .RecoverPropChangedNotify = .{
                        .Attributes = recovers,
                        .Duration = 0,
                    },
                },
            },
        } });
    }

    try txn.conn.push(pb.CombatReceivePackNotify{ .Data = data });
}

fn syncEchoBuffEffects(
    txn: anytype,
    alloc: mem.Alloc,
    scene: *Scene,
    assets: *const Assets,
    entity_id: i64,
    role_id: i32,
    echo_comp: *PlayerEchoComponent,
    buff_comp: *Entity.FightBuffComponent,
) !bool {
    var notify: pb.CombatReceivePackNotify = .{};
    const expected = try echo_comp.activeEchoBuffEffects(alloc.gpa, assets, role_id);
    defer alloc.gpa.free(expected);

    var i: usize = 0;
    while (i < buff_comp.fight_buff_infos.len) {
        const buff = buff_comp.fight_buff_infos[i];
        if (isEchoBuffEffect(assets, buff.BuffId) and
            std.mem.indexOfScalar(i64, expected, buff.BuffId) == null)
        {
            const handle_id = buff.HandleId;
            buff_comp.removeByHandleId(alloc.gpa, handle_id);
            try notify.Data.append(alloc.arena, .{ .Message = .{
                .CombatNotifyData = .{
                    .CombatCommon = .{ .EntityId = entity_id },
                    .Message = .{
                        .RemoveBuffS2cRequestNotify = .{
                            .Handle = handle_id,
                            .StackCount = buff.StackCount,
                            .Reason = removeEchoBuffReason(assets, buff.BuffId),
                            .InstigatorId = entity_id,
                        },
                    },
                },
            } });
            continue;
        }
        i += 1;
    }

    for (expected) |buff_id| {
        if (buff_comp.getByBuffId(buff_id) != null) continue;
        scene.*.instance.buff_handle += 1;
        buff_comp.fight_buff_infos = try alloc.gpa.realloc(buff_comp.fight_buff_infos, buff_comp.fight_buff_infos.len + 1);
        const buff_info = Assets.DataTables.createBuffInformation(scene.instance.buff_handle, buff_id, entity_id, entity_id, true);
        buff_comp.fight_buff_infos[buff_comp.fight_buff_infos.len - 1] = buff_info;
        try notify.Data.append(alloc.arena, .{ .Message = .{
            .CombatNotifyData = .{
                .CombatCommon = .{ .EntityId = entity_id },
                .Message = .{
                    .ApplyBuffS2cRequestNotify = .{
                        .Id = buff_id,
                        .Level = buff_info.Level,
                        .InstigatorId = entity_id,
                        .ApplyType = @intFromEnum(buff_info.ApplyType orelse .Common),
                        .ServerId = buff_info.ServerId,
                        .StackCount = buff_info.StackCount,
                        .IsIterable = true,
                        .Reason = 7,
                    },
                },
            },
        } });
    }

    if (notify.Data.items.len != 0) {
        try txn.conn.push(notify);
        return true;
    }
    return false;
}

fn removeEchoBuffReason(assets: *const Assets, buff_id: i64) i32 {
    for (assets.tables.phantom_fetter.items) |fetter| {
        if (std.mem.indexOfScalar(i64, fetter.BuffIds, buff_id) != null) return 36;
    }
    return 35;
}

fn isEchoBuffEffect(assets: *const Assets, buff_id: i64) bool {
    if (buff_id > 1000 and @mod(buff_id, 1000) == 1) {
        if (assets.tables.buff.getDataById(buff_id)) |buff| {
            if (buff.GrantedTags.len != 0 and buff.ExtraEffectID == 0) return true;
        }
    }
    for (assets.tables.phantom_skill.items) |skill| {
        if (std.mem.indexOfScalar(i64, skill.BuffEffects, buff_id) != null) return true;
    }
    for (assets.tables.phantom_fetter.items) |fetter| {
        if (std.mem.indexOfScalar(i64, fetter.BuffIds, buff_id) != null) return true;
    }
    return false;
}
