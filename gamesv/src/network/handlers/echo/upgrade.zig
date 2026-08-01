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
const PlayerInventoryComponent = @import("../../../logic/component/player/PlayerInventoryComponent.zig");
const EchoInfo = @import("../../../fs/EchoInfo.zig");
const Entity = Scene.Entity;
const BuffTimerScheduler = @import("../../../logic/schedulers/BuffTimerScheduler.zig");
const shared = @import("shared.zig");

const addConsume = shared.addConsume;
const tunerCost = shared.tunerCost;
const highestPhantomLevel = shared.highestPhantomLevel;
const phantomLevelExp = shared.phantomLevelExp;
const rolesEquippingEcho = shared.rolesEquippingEcho;
const appendRolesEquippingEcho = shared.appendRolesEquippingEcho;
const pushRolePropUpdate = shared.pushRolePropUpdate;
const refreshRoleEntities = shared.refreshRoleEntities;

pub fn onPhantomLevelUpRequest(
    txn: *Transaction(pb.PhantomLevelUpRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    inventory_comp: *PlayerInventoryComponent,
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
    const item = echo_comp.echo_map.getPtr(txn.message.IncId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    const item_config = assets.tables.phantom_item.getDataById(item.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomConfigNotFound });
        return;
    };
    const quality = assets.tables.phantom_quality.getDataById(item_config.QualityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomQaulityNotExist });
        return;
    };
    const highest_level = @min(quality.LevelLimit, highestPhantomLevel(assets, item_config.LevelUpGroupId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomLevelConfigNotExist });
        return;
    });

    const slot_count = if (txn.message.SlotCount > 0) txn.message.SlotCount else 0;
    if (slot_count > 0) {
        const max_sub_props = EchoInfo.maxUnlockedSubPropCount(assets, item_config.QualityId) orelse {
            txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
            return;
        };
        if (item.sub_prop.len >= max_sub_props or item.sub_prop.len + @as(usize, @intCast(slot_count)) > max_sub_props) {
            txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
            return;
        }
    } else if (item.level >= highest_level) {
        txn.respond(.{ .ErrorCode = .ErrPhantomLvupMax });
        return;
    }

    var consumes: std.AutoArrayHashMapUnmanaged(i32, i32) = .empty;
    defer consumes.deinit(alloc.gpa);

    var exp_total: i32 = 0;
    for (txn.message.ConsumeList.items) |consume| {
        if (consume.Count <= 0) {
            txn.respond(.{ .ErrorCode = .ErrPhantomConsumeItemCount });
            return;
        }
        if (consume.IncId != 0) {
            txn.respond(.{ .ErrorCode = .ErrPhantomConsumeItem });
            return;
        }
        try addConsume(alloc.gpa, &consumes, consume.ItemId, consume.Count);
        if (assets.tables.phantom_exp_item.getDataById(consume.ItemId)) |exp_item| {
            exp_total += exp_item.Exp * consume.Count;
        }
    }

    if (slot_count > 0) {
        const tuner_cost = tunerCost(assets, item_config.QualityId) orelse {
            txn.respond(.{ .ErrorCode = .ErrPhantomQaulityNotExist });
            return;
        };
        try addConsume(alloc.gpa, &consumes, tuner_cost.item_id, slot_count * tuner_cost.count);
    }

    if (exp_total == 0 and slot_count == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomConsumeNoExp });
        return;
    }

    var normal_updates: std.ArrayList(pb.NormalItem) = .empty;
    for (consumes.keys()) |item_id| {
        try normal_updates.append(alloc.arena, .{
            .Id = item_id,
            .Count = inventory_comp.info.normalItemCount(item_id),
            .ExpireTime = 0,
        });
    }

    if (exp_total > 0) {
        var total = item.exp + exp_total;
        while (item.level < highest_level) {
            const next_level = item.level + 1;
            const next_exp = phantomLevelExp(assets, item_config.LevelUpGroupId, next_level) orelse break;
            if (total < next_exp) break;
            item.level = next_level;
            total -= next_exp;
        }
        item.exp = if (item.level >= highest_level) 0 else total;
        item.refreshMainPropValues(assets);
    }

    if (slot_count > 0) {
        const unlocked_sub_props = EchoInfo.unlockedSubPropCount(assets, item_config.QualityId, item.level) orelse unreachable;
        if (item.sub_prop.len + @as(usize, @intCast(slot_count)) > unlocked_sub_props) {
            txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
            return;
        }
        _ = try item.appendSubProps(
            alloc.gpa,
            assets,
            item_config.QualityId,
            unlocked_sub_props,
            @intCast(slot_count),
            randomSeed(fs),
        );
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    if (normal_updates.items.len != 0) {
        try txn.conn.push(pb.NormalItemUpdateNotify{ .NormalItemList = normal_updates });
    }

    var changed_roles = try rolesEquippingEcho(echo_comp, alloc.gpa, txn.message.IncId);
    defer changed_roles.deinit(alloc.gpa);
    if (changed_roles.count() != 0) {
        try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
        try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, io, now_ms);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .UpdateInfo = try item.toProto(txn.message.IncId, alloc.arena),
    });
}

pub fn onPhantomIdentifyRequest(
    txn: *Transaction(pb.PhantomIdentifyRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
    inventory_comp: *PlayerInventoryComponent,
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
    if (txn.message.Count <= 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomConsumeItemCount });
        return;
    }
    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    const item_config = assets.tables.phantom_item.getDataById(item.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomConfigNotFound });
        return;
    };
    const max_sub_props = EchoInfo.maxUnlockedSubPropCount(assets, item_config.QualityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
        return;
    };
    if (item.sub_prop.len >= max_sub_props or item.sub_prop.len + @as(usize, @intCast(txn.message.Count)) > max_sub_props) {
        txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
        return;
    }
    const unlocked_sub_props = EchoInfo.unlockedSubPropCount(assets, item_config.QualityId, item.level) orelse unreachable;
    if (item.sub_prop.len + @as(usize, @intCast(txn.message.Count)) > unlocked_sub_props) {
        txn.respond(.{ .ErrorCode = .ErrPhantomSubPropNotEnough });
        return;
    }

    const tuner_cost = tunerCost(assets, item_config.QualityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomQaulityNotExist });
        return;
    };

    const added = try item.appendSubProps(
        alloc.gpa,
        assets,
        item_config.QualityId,
        unlocked_sub_props,
        @intCast(txn.message.Count),
        randomSeed(fs),
    );
    if (added == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomSubPropRandomErr });
        return;
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    try txn.conn.push(pb.NormalItemUpdateNotify{ .NormalItemList = blk: {
        var list: std.ArrayList(pb.NormalItem) = .empty;
        try list.append(alloc.arena, .{
            .Id = tuner_cost.item_id,
            .Count = inventory_comp.info.normalItemCount(tuner_cost.item_id),
            .ExpireTime = 0,
        });
        break :blk list;
    } });

    var changed_roles = try rolesEquippingEcho(echo_comp, alloc.gpa, txn.message.IncrId);
    defer changed_roles.deinit(alloc.gpa);
    if (changed_roles.count() != 0) {
        try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
        try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, io, now_ms);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .UpdateInfo = try item.toProto(txn.message.IncrId, alloc.arena),
    });
}

pub fn onPhantomPolishRequest(
    txn: *Transaction(pb.PhantomPolishRequest),
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
    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    const item_config = assets.tables.phantom_item.getDataById(item.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomConfigNotFound });
        return;
    };
    if (try applyMainPropPolish(alloc.gpa, assets, item, item_config, txn.message.PhantomMainPropItemId)) |err| {
        txn.respond(.{ .ErrorCode = err });
        return;
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    var changed_roles = try rolesEquippingEcho(echo_comp, alloc.gpa, txn.message.IncrId);
    defer changed_roles.deinit(alloc.gpa);
    if (changed_roles.count() != 0) {
        try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
        try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, io, now_ms);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .UpdateInfo = try item.toProto(txn.message.IncrId, alloc.arena),
    });
}

pub fn onPhantomBatchPolishRequest(
    txn: *Transaction(pb.PhantomBatchPolishRequest),
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
    if (txn.message.IncrIds.items.len == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomBatchPolishCount });
        return;
    }

    var seen: std.hash_map.AutoHashMapUnmanaged(i32, void) = .empty;
    defer seen.deinit(alloc.gpa);
    var changed_roles: std.AutoArrayHashMapUnmanaged(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    var update_infos: std.ArrayList(pb.PhantomItem) = .empty;

    for (txn.message.IncrIds.items) |inc_id| {
        if (seen.contains(inc_id)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomBatchPolishDuplicate });
            return;
        }
        try seen.put(alloc.gpa, inc_id, {});

        const item = echo_comp.echo_map.getPtr(inc_id) orelse {
            txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
            return;
        };
        const item_config = assets.tables.phantom_item.getDataById(item.id) orelse {
            txn.respond(.{ .ErrorCode = .ErrPhantomConfigNotFound });
            return;
        };
        if (try applyMainPropPolish(alloc.gpa, assets, item, item_config, txn.message.PhantomMainPropItemId)) |err| {
            txn.respond(.{ .ErrorCode = err });
            return;
        }

        try appendRolesEquippingEcho(echo_comp, alloc.gpa, inc_id, &changed_roles);
        try update_infos.append(alloc.arena, try item.toProto(inc_id, alloc.arena));
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    if (changed_roles.count() != 0) {
        try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
        try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, io, now_ms);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .UpdateInfos = update_infos,
    });
}

pub fn onPhantomVicePolishRequest(
    txn: *Transaction(pb.PhantomVicePolishRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
) !void {
    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    const item_config = assets.tables.phantom_item.getDataById(item.id) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomConfigNotFound });
        return;
    };
    const max_sub_props = EchoInfo.maxUnlockedSubPropCount(assets, item_config.QualityId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishItemPropLimit });
        return;
    };
    if (max_sub_props == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishItemPropLimit });
        return;
    }
    if (item.sub_prop.len == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishNoneProp });
        return;
    }
    const unlocked_sub_props = EchoInfo.unlockedSubPropCount(assets, item_config.QualityId, item.level) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishItemLevelLimit });
        return;
    };
    if (unlocked_sub_props < max_sub_props) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishItemLevelLimit });
        return;
    }
    if (item.sub_prop.len < max_sub_props) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishItemPropLimit });
        return;
    }

    var lock_indices = validatedLockPropIndexes(alloc.gpa, item.sub_prop.len, txn.message.LockPropIndex.items) catch {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishParam });
        return;
    };
    defer lock_indices.deinit(alloc.gpa);
    if (assets.tables.phantom_vice_polish_config.getDataById(@intCast(lock_indices.count())) == null) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishLimit });
        return;
    }

    const new_props = try buildVicePolishProps(alloc.gpa, assets, item.*, item_config, lock_indices, randomSeed(fs));
    replacePropSlice(alloc.gpa, &item.unack_sub_prop, new_props);
    try replaceIntSlice(alloc.gpa, &item.lock_prop_index, txn.message.LockPropIndex.items);

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    txn.respond(.{
        .ErrorCode = .Success,
        .PhantomSubProp = try propList(item.unack_sub_prop, alloc.arena),
    });
}

pub fn onPhantomVicePolishAckRequest(
    txn: *Transaction(pb.PhantomVicePolishAckRequest),
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
    const item = echo_comp.echo_map.getPtr(txn.message.IncrId) orelse {
        txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
        return;
    };
    if (item.unack_sub_prop.len == 0) {
        txn.respond(.{ .ErrorCode = .ErrPhantomVicePolishNoAck });
        return;
    }

    if (txn.message.Ack) {
        clearPropSlice(alloc.gpa, &item.sub_prop);
        item.sub_prop = item.unack_sub_prop;
        item.unack_sub_prop = &.{};
    } else {
        clearPropSlice(alloc.gpa, &item.unack_sub_prop);
    }
    clearIntSlice(alloc.gpa, &item.lock_prop_index);

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);

    if (txn.message.Ack) {
        var changed_roles = try rolesEquippingEcho(echo_comp, alloc.gpa, txn.message.IncrId);
        defer changed_roles.deinit(alloc.gpa);
        if (changed_roles.count() != 0) {
            try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
            try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles, buff_timers, io, now_ms);
        }
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .UpdateInfo = try item.toProto(txn.message.IncrId, alloc.arena),
    });
}

fn applyMainPropPolish(
    gpa: std.mem.Allocator,
    assets: *const Assets,
    item: *EchoInfo,
    item_config: Assets.DataTables.PhantomItem,
    prop_item_id: i32,
) !?pb.ErrorCode {
    const main_property = findMainPropertyWithProp(assets, item_config.MainProp.RandGroupId, prop_item_id) orelse {
        return .ErrPhantomBatchPolishPropNotMatch;
    };
    if (containsProp(item.main_prop, prop_item_id)) return .PhantomPolishSamePro;

    var props: std.ArrayList(EchoInfo.Prop) = .empty;
    errdefer props.deinit(gpa);
    try props.ensureTotalCapacity(gpa, main_property.PropGroup.len);
    for (main_property.PropGroup) |main_prop_item_id| {
        const prop_item = assets.tables.phantom_main_prop_item.getDataById(main_prop_item_id) orelse continue;
        props.appendAssumeCapacity(.{
            .id = prop_item.Id,
            .value = mainPropValue(assets, prop_item, item.level),
        });
    }

    replacePropSlice(gpa, &item.main_prop, try props.toOwnedSlice(gpa));
    clearPropSlice(gpa, &item.unack_sub_prop);
    clearIntSlice(gpa, &item.lock_prop_index);
    return null;
}

fn findMainPropertyWithProp(
    assets: *const Assets,
    rand_group_id: i32,
    prop_item_id: i32,
) ?Assets.DataTables.PhantomMainProperty {
    for (assets.tables.phantom_main_property.items) |entry| {
        if (entry.RandGroupId != rand_group_id) continue;
        for (entry.PropGroup) |entry_prop_id| {
            if (entry_prop_id == prop_item_id) return entry;
        }
    }
    return null;
}

fn mainPropValue(assets: *const Assets, prop: Assets.DataTables.PhantomMainPropItem, level: i32) i32 {
    var growth: i32 = 10000;
    for (assets.tables.phantom_growth.items) |entry| {
        if (entry.GrowthId == prop.GrowthId and entry.Level == level) {
            growth = entry.Value;
            break;
        }
    }
    return @divTrunc(prop.StandardProperty * growth, 10000);
}

fn validatedLockPropIndexes(
    gpa: std.mem.Allocator,
    prop_count: usize,
    indexes: []const i32,
) !std.AutoArrayHashMapUnmanaged(usize, void) {
    var lock_indices: std.AutoArrayHashMapUnmanaged(usize, void) = .empty;
    errdefer lock_indices.deinit(gpa);

    for (indexes) |index| {
        if (index < 0 or index >= @as(i32, @intCast(prop_count))) return error.InvalidLockIndex;
        const index_usize: usize = @intCast(index);
        if (lock_indices.contains(index_usize)) return error.DuplicateLockIndex;
        try lock_indices.put(gpa, index_usize, {});
    }

    return lock_indices;
}

fn randomSeed(fs: *FileSystem) u64 {
    var seed_bytes: [8]u8 = undefined;
    std.Io.random(fs.io, &seed_bytes);
    return std.mem.readInt(u64, &seed_bytes, .little);
}

fn buildVicePolishProps(
    gpa: std.mem.Allocator,
    assets: *const Assets,
    item: EchoInfo,
    item_config: Assets.DataTables.PhantomItem,
    lock_indices: std.AutoArrayHashMapUnmanaged(usize, void),
    random_seed: u64,
) ![]EchoInfo.Prop {
    var prng = std.Random.DefaultPrng.init(random_seed);
    const rng = prng.random();

    var props: std.ArrayList(EchoInfo.Prop) = .empty;
    errdefer props.deinit(gpa);
    try props.ensureTotalCapacity(gpa, item.sub_prop.len);

    var used_props: std.ArrayList(EchoInfo.Prop) = .empty;
    defer used_props.deinit(gpa);
    try used_props.ensureTotalCapacity(gpa, item.sub_prop.len);
    for (item.sub_prop, 0..) |old_prop, index| {
        if (lock_indices.contains(index)) used_props.appendAssumeCapacity(old_prop);
    }

    for (item.sub_prop, 0..) |old_prop, index| {
        if (lock_indices.contains(index)) {
            props.appendAssumeCapacity(old_prop);
        } else {
            const replacement = pickReplacementSubProp(
                assets,
                used_props.items,
                old_prop,
                item_config.QualityId,
                rng,
            );
            props.appendAssumeCapacity(replacement);
            used_props.appendAssumeCapacity(replacement);
        }
    }

    return props.toOwnedSlice(gpa);
}

fn pickReplacementSubProp(
    assets: *const Assets,
    current: []const EchoInfo.Prop,
    old_prop: EchoInfo.Prop,
    quality: i32,
    rng: std.Random,
) EchoInfo.Prop {
    const prop = EchoInfo.pickRandomSubProperty(assets, current, rng) orelse return old_prop;
    return .{ .id = prop.Id, .value = EchoInfo.randomSubPropValue(quality, prop, rng) };
}

fn propList(data: []const EchoInfo.Prop, arena: std.mem.Allocator) !std.ArrayList(pb.PhantomPropInfo) {
    var result: std.ArrayList(pb.PhantomPropInfo) = .empty;
    try result.ensureTotalCapacity(arena, data.len);
    for (data) |prop| {
        result.appendAssumeCapacity(.{ .PhantomPropId = prop.id, .Value = prop.value });
    }
    return result;
}

fn containsProp(props: []const EchoInfo.Prop, id: i32) bool {
    for (props) |prop| {
        if (prop.id == id) return true;
    }
    return false;
}

fn replacePropSlice(gpa: std.mem.Allocator, target: *[]EchoInfo.Prop, data: []EchoInfo.Prop) void {
    clearPropSlice(gpa, target);
    target.* = data;
}

fn clearPropSlice(gpa: std.mem.Allocator, target: *[]EchoInfo.Prop) void {
    if (target.*.len != 0) gpa.free(target.*);
    target.* = &.{};
}

fn replaceIntSlice(gpa: std.mem.Allocator, target: *[]i32, data: []const i32) !void {
    clearIntSlice(gpa, target);
    target.* = try gpa.dupe(i32, data);
}

fn clearIntSlice(gpa: std.mem.Allocator, target: *[]i32) void {
    if (target.*.len != 0) gpa.free(target.*);
    target.* = &.{};
}
