const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const dispatch = @import("combat.zig");
const Assets = @import("../../data/Assets.zig");
const Scene = @import("../../logic/Scene.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const PlayerRoleComponent = @import("../../logic/component/player/PlayerRoleComponent.zig");
const PlayerBasicComponent = @import("../../logic/component/player/PlayerBasicComponent.zig");
const PlayerWeaponComponent = @import("../../logic/component/player/PlayerWeaponComponent.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const PlayerInventoryComponent = @import("../../logic/component/player/PlayerInventoryComponent.zig");
const InventoryInfo = @import("../../fs/InventoryInfo.zig");
const Account = @import("../../fs/Account.zig");
const comp_util = @import("../../logic/component/comp_util.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const Events = @import("../../logic/events.zig");
const RoleAttributeSync = @import("../helpers/role_attribute_sync.zig");
const RoleStats = @import("../../logic/helpers/role_stats.zig");
const RoleHelper = @import("../../logic/helpers/role.zig");
const EchoShared = @import("echo/shared.zig");

fn pushWeaponEquipNotify(txn: anytype, alloc: mem.Alloc, role_id: i32, weapon_id: i32) !void {
    if (weapon_id == 0) return;

    var data_list: std.ArrayList(pb.RoleLoadEquipData) = .empty;
    defer data_list.deinit(alloc.arena);
    try data_list.append(alloc.arena, .{
        .RoleId = role_id,
        .Pos = .Weapon,
        .EquipIncId = weapon_id,
    });

    try txn.conn.push(pb.EquipTakeOnNotify{ .DataList = data_list }, alloc.arena);
}

fn pushPhantomEquipNotify(
    txn: anytype,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    role_id: i32,
) !void {
    var changed_roles: std.array_hash_map.Auto(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    try changed_roles.put(alloc.gpa, role_id, {});

    try EchoShared.pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
    try txn.conn.push(pb.PhantomPutOnNotify{
        .EquipInfoList = try EchoShared.changedEquipInfoList(echo_comp, changed_roles, alloc.arena),
    }, alloc.arena);
}

pub fn onRoleFavorListRequest(
    txn: *Transaction(pb.RoleFavorListRequest),
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    var favor_list: std.ArrayList(pb.RoleFavor) = .empty;

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |role_entry| {
        const role_id = role_entry.key_ptr.*;

        var role_favor: pb.RoleFavor = .{
            .RoleId = role_id,
            .Level = 5,
            .Exp = 16800,
        };

        for (assets.tables.favor_word.items) |word| {
            if (word.RoleId == role_id) {
                try role_favor.WordIds.append(alloc.arena, .{
                    .Id = word.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_story.items) |story| {
            if (story.RoleId == role_id) {
                try role_favor.StoryIds.append(alloc.arena, .{
                    .Id = story.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        for (assets.tables.favor_goods.items) |goods| {
            if (goods.RoleId == role_id) {
                try role_favor.GoodsIds.append(alloc.arena, .{
                    .Id = goods.Id,
                    .Status = .ItemUnLocked,
                });
            }
        }

        try favor_list.append(alloc.arena, role_favor);
    }

    txn.respond(.{ .FavorList = favor_list });
}

pub fn onRoleSexChangeRequest(
    txn: *Transaction(pb.RoleSexChangeRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    basic_comp: *PlayerBasicComponent,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const target_gender = txn.message.Sex;
    const current_gender = basic_comp.info.attributes.sex;

    if (target_gender == current_gender) {
        txn.respond(.{
            .ErrorCode = .Success,
            .Sex = current_gender,
        });
        return;
    }

    const source_role_id = RoleHelper.currentFormationMainRoleId(assets, scene, current_gender) orelse
        RoleHelper.selectedMainRoleId(assets, role_comp, current_gender, basic_comp.info.selected_main_role_id) orelse {
        txn.respond(.{
            .ErrorCode = .ErrRoleSexFuncNotOpen,
            .Sex = current_gender,
        });
        return;
    };
    const source_role_config = assets.tables.role_info.getDataById(source_role_id) orelse {
        txn.respond(.{
            .ErrorCode = .RequestParamError,
            .Sex = current_gender,
        });
        return;
    };
    const target_role_id = RoleHelper.mainRoleIdForElement(assets, target_gender, source_role_config.ElementId) orelse {
        txn.respond(.{
            .ErrorCode = .ErrRoleSexFuncNotOpen,
            .Sex = current_gender,
        });
        return;
    };

    const transfer = try RoleHelper.transferMainRoleState(
        alloc,
        fs,
        assets,
        scene,
        basic_comp,
        role_comp,
        weapon_comp,
        echo_comp,
        source_role_id,
        target_role_id,
    );
    try events.enqueue(.role_info_modified, .{ .role_id = target_role_id });

    basic_comp.info.attributes.sex = target_gender;
    try RoleHelper.saveBasicInfo(fs, alloc.arena, basic_comp);
    try Account.syncLoginSexForPlayer(alloc.arena, fs, basic_comp.player_id, target_gender);

    if (transfer.formation_changed) {
        try RoleHelper.resetRoles(
            scene,
            fs,
            assets,
            role_comp,
            weapon_comp,
            echo_comp,
            txn.conn,
            alloc,
            &.{target_role_id},
        );
        try scene.save(fs, alloc.gpa);
        try events.enqueue(.update_formations, .{});
    }

    const target_role = role_comp.role_map.getPtr(target_role_id) orelse {
        txn.respond(.{
            .ErrorCode = .RequestParamError,
            .Sex = current_gender,
        });
        return;
    };

    try txn.conn.push(pb.RoleChangeNotify{
        .SourceRoleId = source_role_id,
        .RoleInfo = try RoleStats.toClientRoleInfo(
            alloc.gpa,
            alloc.arena,
            assets,
            role_comp,
            target_role_id,
            target_role,
            weapon_comp,
            echo_comp,
        ),
    }, alloc.arena);
    try txn.conn.push(pb.RoleChangeUnlockNotify{
        .UnlockRoleIds = try RoleHelper.mainRoleUnlockList(assets, target_gender, alloc.arena),
    }, alloc.arena);

    txn.respond(.{
        .ErrorCode = .Success,
        .Sex = target_gender,
    });
    try txn.conn.push(pb.LogoutNotify{
        .ErrorCode = .ErrSexChangeLogout,
    }, alloc.arena);
}

pub fn onRoleElementChangeRequest(
    txn: *Transaction(pb.RoleElementChangeRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    scene: *Scene,
    basic_comp: *PlayerBasicComponent,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const gender = basic_comp.info.attributes.sex;
    const target_role_id = RoleHelper.mainRoleIdForElement(assets, gender, txn.message.ElementType) orelse {
        txn.respond(.{ .ErrorCode = .ErrRoleChangeElementFunc });
        return;
    };
    const source_role_id = RoleHelper.currentFormationMainRoleId(assets, scene, gender) orelse
        RoleHelper.selectedMainRoleId(assets, role_comp, gender, basic_comp.info.selected_main_role_id) orelse target_role_id;

    const transfer = try RoleHelper.transferMainRoleState(
        alloc,
        fs,
        assets,
        scene,
        basic_comp,
        role_comp,
        weapon_comp,
        echo_comp,
        source_role_id,
        target_role_id,
    );
    if (transfer.basic_changed) try RoleHelper.saveBasicInfo(fs, alloc.arena, basic_comp);
    try events.enqueue(.role_info_modified, .{ .role_id = target_role_id });

    if (transfer.formation_changed) {
        try RoleHelper.resetRoles(
            scene,
            fs,
            assets,
            role_comp,
            weapon_comp,
            echo_comp,
            txn.conn,
            alloc,
            &.{target_role_id},
        );
        try scene.save(fs, alloc.gpa);
        try events.enqueue(.update_formations, .{});
    }

    const target_role = role_comp.role_map.getPtr(target_role_id) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    try pushWeaponEquipNotify(txn, alloc, target_role_id, target_role.weapon);
    try txn.conn.push(pb.RoleChangeNotify{
        .SourceRoleId = source_role_id,
        .RoleInfo = try RoleStats.toClientRoleInfo(
            alloc.gpa,
            alloc.arena,
            assets,
            role_comp,
            target_role_id,
            target_role,
            weapon_comp,
            echo_comp,
        ),
    }, alloc.arena);
    try pushPhantomEquipNotify(txn, alloc, assets, role_comp, weapon_comp, echo_comp, target_role_id);

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn SwitchRoleRequest(
    txn: *dispatch.CombatRequestTxn(.SwitchRoleRequest),
    scene: *Scene,
    fs: *FileSystem,
    alloc: mem.Alloc,
) !void {
    const request: pb.SwitchRoleRequest = txn.payload;
    const formation = &scene.formation_info.formations[@intCast(scene.formation_info.cur_formation)];
    const previous_role = formation.cur_role;
    formation.cur_role = request.RoleId;

    const slice = scene.entities.slice();
    for (slice.items(.config), 0..) |config, i| {
        if (config.config_id == previous_role) {
            slice.items(.visible)[i] = null;
        } else if (config.config_id == request.RoleId) {
            slice.items(.visible)[i] = .{};
        }
    }

    try scene.save(fs, alloc.gpa);
    txn.respond(.{ .ErrorCode = .Success, .RoleId = request.RoleId });
}

fn setSkillLevel(role: anytype, gpa: std.mem.Allocator, skill_id: i32, level: i32) !void {
    for (role.skills) |*entry| {
        if (entry[0] == skill_id) {
            entry[1] = level;
            return;
        }
    }

    const new_skills = try gpa.alloc(@typeInfo(@TypeOf(role.skills)).pointer.child, role.skills.len + 1);
    @memcpy(new_skills[0..role.skills.len], role.skills);
    new_skills[role.skills.len] = .{ skill_id, level };

    if (role.skills.len != 0) gpa.free(role.skills);
    role.skills = new_skills;
}

fn getSkillLevel(role: anytype, skill_id: i32) i32 {
    for (role.skills) |entry| {
        if (entry[0] == skill_id) return entry[1];
    }
    return 0;
}

fn setSkillNodeState(role: anytype, gpa: std.mem.Allocator, node_id: i32, active: bool, skill_id: i32) !void {
    for (role.skill_node_state) |*entry| {
        if (entry.node_id == node_id) {
            entry.active = active;
            entry.skill_id = skill_id;
            return;
        }
    }

    const new_nodes = try gpa.alloc(@typeInfo(@TypeOf(role.skill_node_state)).pointer.child, role.skill_node_state.len + 1);
    @memcpy(new_nodes[0..role.skill_node_state.len], role.skill_node_state);
    new_nodes[role.skill_node_state.len] = .{ .node_id = node_id, .active = active, .skill_id = skill_id };

    if (role.skill_node_state.len != 0) gpa.free(role.skill_node_state);
    role.skill_node_state = new_nodes;
}

fn getMaxResonantChainIndex(assets: *const Assets, group_id: i32) i32 {
    var max_index: i32 = 0;
    for (assets.tables.resonant_chain.items) |chain| {
        if (chain.GroupId == group_id and chain.GroupIndex > max_index) max_index = chain.GroupIndex;
    }
    return max_index;
}

fn getResonantChainByIndex(assets: *const Assets, group_id: i32, index: i32) ?Assets.DataTables.ResonantChain {
    for (assets.tables.resonant_chain.items) |chain| {
        if (chain.GroupId == group_id and chain.GroupIndex == index) return chain;
    }
    return null;
}

fn hasActivateConsumeItems(info: InventoryInfo, chain: anytype) bool {
    var iterator = chain.ActivateConsume.map.iterator();
    while (iterator.next()) |entry| {
        if (info.normalItemCount(entry.key_ptr.*) < entry.value_ptr.*) return false;
    }
    return true;
}

fn consumeActivateItems(
    info: *InventoryInfo,
    gpa: std.mem.Allocator,
    arena: std.mem.Allocator,
    chain: anytype,
) !std.ArrayList(pb.NormalItem) {
    var updated_items: std.ArrayList(pb.NormalItem) = .empty;
    var iterator = chain.ActivateConsume.map.iterator();
    while (iterator.next()) |entry| {
        _ = try InventoryInfo.consumeNormalItem(info, gpa, entry.key_ptr.*, entry.value_ptr.*);
        try updated_items.append(arena, .{
            .Id = entry.key_ptr.*,
            .Count = info.normalItemCount(entry.key_ptr.*),
            .ExpireTime = 0,
        });
    }
    return updated_items;
}

fn toClientRoleInfo(info: anytype, arena: std.mem.Allocator, id: i32) !pb.RoleInfo {
    var proto: pb.RoleInfo = .{
        .RoleId = id,
        .Name = "",
        .Level = info.level,
        .Exp = info.exp,
        .Breakthrough = info.breakthrough,
        .Star = info.star,
        .Favor = info.favor,
        .CurModel = info.cur_model,
        .CreateTime = info.create_time,
        .ResonantChainGroupIndex = info.resonant_chain_group_index,
        .SkinId = info.role_skin_id,
        .EnableSelfBgm = info.enable_self_bgm,
    };

    try proto.Skills.ensureTotalCapacity(arena, info.skills.len);
    for (info.skills) |entry| proto.Skills.appendAssumeCapacity(.{ .Key = entry[0], .Value = entry[1] });

    try proto.Phantom.ensureTotalCapacity(arena, info.phantom.len);
    for (info.phantom) |entry| proto.Phantom.appendAssumeCapacity(.{ .Key = entry[0], .Value = entry[1] });

    try proto.BaseProp.ensureTotalCapacity(arena, info.base_prop.len);
    for (info.base_prop, 0..) |value, key| proto.BaseProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });

    try proto.AddProp.ensureTotalCapacity(arena, info.add_prop.len);
    for (info.add_prop, 0..) |value, key| proto.AddProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });

    try proto.Reson.ensureTotalCapacity(arena, info.reson.len);
    for (info.reson) |entry| proto.Reson.appendAssumeCapacity(.{ .ResonId = entry.id, .IsOpen = entry.open, .Increase = entry.increase });

    try proto.Models.appendSlice(arena, info.models);

    try proto.SkillNodeState.ensureTotalCapacity(arena, info.skill_node_state.len);
    for (info.skill_node_state) |node| {
        proto.SkillNodeState.appendAssumeCapacity(.{ .SkillNodeId = node.node_id, .IsActive = node.active, .SkillId = node.skill_id });
    }

    return proto;
}

pub fn onRobotRolePropRequest(
    txn: *Transaction(pb.RobotRolePropRequest),
    alloc: mem.Alloc,
    role_comp: *PlayerRoleComponent,
) !void {
    var prop_list: std.ArrayList(pb.RobotRoleInfo) = .empty;

    for (txn.message.RoleIds.items) |role_id| {
        const role = role_comp.role_map.get(role_id) orelse continue;
        var prop: pb.RobotRoleInfo = .{ .RoleId = role_id };

        try prop.BaseProp.ensureTotalCapacity(alloc.arena, role.base_prop.len);
        for (role.base_prop, 0..) |value, key| {
            prop.BaseProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });
        }

        try prop.AddProp.ensureTotalCapacity(alloc.arena, role.add_prop.len);
        for (role.add_prop, 0..) |value, key| {
            prop.AddProp.appendAssumeCapacity(.{ .Key = @intCast(key), .Value = value });
        }

        try prop_list.append(alloc.arena, prop);
    }

    txn.respond(.{
        .Error = .Success,
        .RobotRoleInfo = prop_list,
    });
}

pub fn onPbUpLevelSkillRequest(
    txn: *Transaction(pb.PbUpLevelSkillRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
) !void {
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const skill = assets.tables.skill.getDataById(request.SkillId) orelse {
        txn.respond(.{ .ErrorCode = .ErrSkillInfoParamError });
        return;
    };

    const current_level = getSkillLevel(role, request.SkillId);
    const next_level = @min(current_level + 1, skill.MaxSkillLevel);
    try setSkillLevel(role, alloc.gpa, request.SkillId, next_level);
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });

    txn.respond(.{
        .ErrorCode = .Success,
        .RoleId = request.RoleId,
        .SkillInfo = .{ .Key = request.SkillId, .Value = next_level },
    });
}

pub fn onRoleActivateSkillRequest(
    txn: *Transaction(pb.RoleActivateSkillRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    stat_query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.AttributeComponent,
    }),
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const node = assets.tables.skill_tree.getDataById(request.SkillNodeId) orelse {
        txn.respond(.{ .ErrorCode = .ErrRolSkillNodeTypeUlock });
        return;
    };

    try setSkillNodeState(role, alloc.gpa, request.SkillNodeId, true, node.SkillId);
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });

    var node_states: std.ArrayList(pb.ArraySkillNode) = .empty;
    try node_states.ensureTotalCapacity(alloc.arena, role.skill_node_state.len);
    for (role.skill_node_state) |entry| {
        node_states.appendAssumeCapacity(.{
            .SkillNodeId = entry.node_id,
            .IsActive = entry.active,
            .SkillId = entry.skill_id,
        });
    }

    try txn.conn.push(pb.RoleSkillNodeNotify{
        .RoleId = request.RoleId,
        .SkillNodeState = node_states,
    }, alloc.arena);
    try RoleAttributeSync.refreshRole(txn, alloc, fs, scene, assets, role_comp, weapon_comp, echo_comp, stat_query, request.RoleId);

    txn.respond(.{
        .ErrorCode = .Success,
        .RoleId = request.RoleId,
        .SkillInfo = .{ .Key = node.SkillId, .Value = 1 },
    });
}

pub fn onRoleSkillLevelUpViewRequest(
    txn: *Transaction(pb.RoleSkillLevelUpViewRequest),
    assets: *const Assets,
) !void {
    if (assets.tables.skill.getDataById(txn.message.SkillId) == null) {
        txn.respond(.{ .ErrorCode = .ErrSkillInfoParamError });
        return;
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onRoleSkillViewRequest(
    txn: *Transaction(pb.RoleSkillViewRequest),
    assets: *const Assets,
) !void {
    if (assets.tables.skill.getDataById(txn.message.SkillId) == null) {
        txn.respond(.{ .ErrorCode = .ErrSkillInfoParamError });
        return;
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .IsConditionFinish = true,
    });
}

pub fn onRoleSkillQuickLevelUpRequest(
    txn: *Transaction(pb.RoleSkillQuickLevelUpRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const skill = assets.tables.skill.getDataById(request.SkillId) orelse {
        txn.respond(.{ .ErrorCode = .ErrSkillInfoParamError });
        return;
    };

    const current_level = getSkillLevel(role, request.SkillId);
    const requested_level = if (request.TargetLevel > current_level) request.TargetLevel else current_level + 1;
    const next_level = @min(requested_level, skill.MaxSkillLevel);

    try setSkillLevel(role, alloc.gpa, request.SkillId, next_level);
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });

    txn.respond(.{
        .ErrorCode = .Success,
        .RoleInfo = try RoleStats.toClientRoleInfo(
            alloc.gpa,
            alloc.arena,
            assets,
            role_comp,
            request.RoleId,
            role,
            weapon_comp,
            echo_comp,
        ),
    });
}

pub fn onPlayerVoiceLanguageRequest(
    txn: *Transaction(pb.PlayerVoiceLanguageRequest),
    alloc: mem.Alloc,
    role_comp: *PlayerRoleComponent,
) !void {
    var role_voices: std.ArrayList(pb.RoleVoice) = .empty;

    var iterator = role_comp.role_map.iterator();
    while (iterator.next()) |entry| {
        if (entry.value_ptr.voice_language == 0) continue;

        try role_voices.append(alloc.arena, .{
            .RoleId = entry.key_ptr.*,
            .VoiceId = entry.value_ptr.voice_language,
        });
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .RoleVoices = role_voices,
    });
}

pub fn onPlayerRoleVoiceSetRequest(
    txn: *Transaction(pb.PlayerRoleVoiceSetRequest),
    events: *EventQueue,
    role_comp: *PlayerRoleComponent,
) !void {
    if (txn.message.RoleVoices.items.len == 0) {
        var iterator = role_comp.role_map.iterator();
        while (iterator.next()) |entry| {
            if (entry.value_ptr.voice_language == 0) continue;
            entry.value_ptr.voice_language = 0;
            try events.enqueue(.role_info_modified, .{ .role_id = entry.key_ptr.* });
        }

        txn.respond(.{ .ErrorCode = .Success });
        return;
    }

    for (txn.message.RoleVoices.items) |voice| {
        const role = role_comp.role_map.getPtr(voice.RoleId) orelse continue;
        if (role.voice_language == voice.VoiceLanguage) continue;

        role.voice_language = voice.VoiceLanguage;
        try events.enqueue(.role_info_modified, .{ .role_id = voice.RoleId });
    }

    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onResonantChainUnlockRequest(
    txn: *Transaction(pb.ResonantChainUnlockRequest),
    events: *EventQueue,
    alloc: mem.Alloc,
    fs: *FileSystem,
    scene: *Scene,
    query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
    }),
    stat_query: Scene.Query(&.{
        Scene.Entity,
        *Scene.Entity.ConfigComponent,
        *Scene.Entity.AttributeComponent,
    }),
    assets: *const Assets,
    role_comp: *PlayerRoleComponent,
    weapon_comp: *PlayerWeaponComponent,
    echo_comp: *PlayerEchoComponent,
    inventory_comp: *PlayerInventoryComponent,
) !void {
    const request = txn.message;
    const role = role_comp.role_map.getPtr(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };
    const role_config = assets.tables.role_info.getDataById(request.RoleId) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };

    const max_index = getMaxResonantChainIndex(assets, role_config.ResonantChainGroupId);
    if (max_index == 0) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }
    if (role.resonant_chain_group_index >= max_index) {
        txn.respond(.{
            .ErrorCode = .Success,
            .RoleId = request.RoleId,
            .ResonantChainGroupIndex = role.resonant_chain_group_index,
        });
        return;
    }

    const next_index = role.resonant_chain_group_index + 1;
    const chain = getResonantChainByIndex(assets, role_config.ResonantChainGroupId, next_index) orelse {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    };
    if (!hasActivateConsumeItems(inventory_comp.info, chain)) {
        txn.respond(.{ .ErrorCode = .ErrRoleItemListNoEnough });
        return;
    }
    const updated_items = try consumeActivateItems(&inventory_comp.info, alloc.gpa, alloc.arena, chain);

    role.resonant_chain_group_index = @min(role.resonant_chain_group_index + 1, max_index);
    try events.enqueue(.role_info_modified, .{ .role_id = request.RoleId });

    if (getResonantChainByIndex(assets, role_config.ResonantChainGroupId, role.resonant_chain_group_index)) |new_chain| {
        if (new_chain.BuffIds.len > 0) {
            var entity_handle: ?Scene.Entity = null;
            var it = query.iterator;
            while (it.next()) |item| {
                const entity, const config_item = item;
                if (config_item.config_id == request.RoleId) {
                    entity_handle = entity;
                    break;
                }
            }

            if (entity_handle) |handle| {
                var buffs = try std.ArrayList(Events.BuffAdditionEntry).initCapacity(alloc.gpa, new_chain.BuffIds.len);
                defer buffs.deinit(alloc.gpa);
                for (new_chain.BuffIds) |buff_id| {
                    buffs.appendAssumeCapacity(.{
                        .id = buff_id,
                        .is_active = true,
                        .stack_count = 1,
                    });
                }
                try events.enqueue(.buff_addition, .{
                    .target = handle,
                    .instigator = handle,
                    .buffs = try buffs.toOwnedSlice(alloc.gpa),
                });
            }
        }
    }

    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}", .{ inventory_comp.player_id, InventoryInfo.data_path });
    try comp_util.saveStruct(fs, inventory_comp.info, path, alloc.arena);
    try txn.conn.push(pb.NormalItemUpdateNotify{
        .NormalItemList = updated_items,
        .NoTips = true,
    }, alloc.arena);
    try RoleAttributeSync.refreshRole(txn, alloc, fs, scene, assets, role_comp, weapon_comp, echo_comp, stat_query, request.RoleId);

    txn.respond(.{
        .ErrorCode = .Success,
        .RoleId = request.RoleId,
        .ResonantChainGroupIndex = role.resonant_chain_group_index,
    });
}
