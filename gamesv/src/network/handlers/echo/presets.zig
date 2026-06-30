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
const special_item_incr = @import("../../../fs/special_item_incr.zig");
const Entity = Scene.Entity;
const shared = @import("shared.zig");

const visionEquipGroupList = shared.visionEquipGroupList;
const changedEquipInfoList = shared.changedEquipInfoList;
const pushRolePropUpdate = shared.pushRolePropUpdate;
const refreshRoleEntities = shared.refreshRoleEntities;

pub fn onVisionEquipGroupInfoRequest(
    txn: *Transaction(pb.VisionEquipGroupInfoRequest),
    alloc: mem.Alloc,
    echo_comp: *PlayerEchoComponent,
) !void {
    txn.respond(.{
        .ErrorCode = .Success,
        .VisionEquipList = try visionEquipGroupList(echo_comp, alloc.arena),
    });
}

pub fn onAddVisionEquipGroupRequest(
    txn: *Transaction(pb.AddVisionEquipGroupRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    role_comp: *PlayerRoleComponent,
    echo_comp: *PlayerEchoComponent,
) !void {
    if (role_comp.role_map.get(txn.message.RoleId) == null) {
        txn.respond(.{ .ErrorCode = .RequestParamError });
        return;
    }
    const equip = echo_comp.roleEquip(txn.message.RoleId);
    if (echo_comp.preset_info.groups.len >= 20) {
        txn.respond(.{ .ErrorCode = .ErrVisionSkillSlotNotFound });
        return;
    }

    const incr_id = try special_item_incr.next(alloc.gpa, fs, echo_comp.player_id);
    try appendVisionGroup(alloc.gpa, echo_comp, incr_id, txn.message.Name, equip.slots);
    try PlayerEchoComponent.savePresets(alloc.gpa, fs, echo_comp.player_id, echo_comp.preset_info);

    txn.respond(.{
        .ErrorCode = .Success,
        .VisionEquipList = try visionEquipGroupList(echo_comp, alloc.arena),
    });
}

pub fn onApplyVisionGroupRequest(
    txn: *Transaction(pb.ApplyVisionGroupRequest),
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
) !void {
    if (txn.message.Index < 0 or txn.message.Index >= echo_comp.preset_info.groups.len) {
        txn.respond(.{ .ErrorCode = .ErrVisionSkillSlotNotFound });
        return;
    }
    const group = echo_comp.preset_info.groups[@intCast(txn.message.Index)];

    var seen: std.hash_map.AutoHashMapUnmanaged(i32, void) = .empty;
    defer seen.deinit(alloc.gpa);
    for (group.slots) |inc_id| {
        if (inc_id == 0) continue;
        if (echo_comp.echo_map.get(inc_id) == null or seen.contains(inc_id)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomItemNotExist });
            return;
        }
        try seen.put(alloc.gpa, inc_id, {});
    }

    var changed_roles: std.array_hash_map.Auto(i32, void) = .empty;
    defer changed_roles.deinit(alloc.gpa);
    try changed_roles.put(alloc.gpa, txn.message.RoleId, {});

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
    for (group.slots, 0..) |inc_id, index| {
        if (inc_id == 0) continue;
        const item = echo_comp.echo_map.getPtr(inc_id).?;
        item.role_id = txn.message.RoleId;
        item.equipped_pos = @intCast(index);
    }

    try PlayerEchoComponent.saveAll(alloc.gpa, fs, echo_comp.player_id, echo_comp.echo_map);
    try pushRolePropUpdate(txn, alloc, assets, role_comp, echo_comp, weapon_comp, changed_roles);
    try refreshRoleEntities(txn, alloc, fs, assets, scene, role_comp, echo_comp, weapon_comp, query, changed_roles);

    txn.respond(.{
        .ErrorCode = .Success,
        .EquipInfoList = try changedEquipInfoList(echo_comp, changed_roles, alloc.arena),
    });
}

pub fn onPutVisionGroupToTopRequest(
    txn: *Transaction(pb.PutVisionGroupToTopRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    echo_comp: *PlayerEchoComponent,
) !void {
    if (txn.message.Index < 0 or txn.message.Index >= echo_comp.preset_info.groups.len) {
        txn.respond(.{ .ErrorCode = .ErrVisionSkillSlotNotFound });
        return;
    }
    const index: usize = @intCast(txn.message.Index);
    if (index != 0) {
        const group = echo_comp.preset_info.groups[index];
        std.mem.copyBackwards(EchoInfo.VisionGroup, echo_comp.preset_info.groups[1 .. index + 1], echo_comp.preset_info.groups[0..index]);
        echo_comp.preset_info.groups[0] = group;
        try PlayerEchoComponent.savePresets(alloc.gpa, fs, echo_comp.player_id, echo_comp.preset_info);
    }

    txn.respond(.{
        .ErrorCode = .Success,
        .VisionEquipList = try visionEquipGroupList(echo_comp, alloc.arena),
    });
}

pub fn onChangeVisionGroupNameRequest(
    txn: *Transaction(pb.ChangeVisionGroupNameRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    echo_comp: *PlayerEchoComponent,
) !void {
    if (txn.message.Index < 0 or txn.message.Index >= echo_comp.preset_info.groups.len) {
        txn.respond(.{ .ErrorCode = .ErrVisionSkillSlotNotFound });
        return;
    }
    const index: usize = @intCast(txn.message.Index);
    if (echo_comp.preset_info.groups[index].name.len != 0) {
        alloc.gpa.free(echo_comp.preset_info.groups[index].name);
    }
    echo_comp.preset_info.groups[index].name = try alloc.gpa.dupe(u8, txn.message.Name);
    try PlayerEchoComponent.savePresets(alloc.gpa, fs, echo_comp.player_id, echo_comp.preset_info);

    txn.respond(.{
        .ErrorCode = .Success,
        .VisionEquipList = try visionEquipGroupList(echo_comp, alloc.arena),
    });
}

pub fn onDeleteVisionEquipGroupRequest(
    txn: *Transaction(pb.DeleteVisionEquipGroupRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    echo_comp: *PlayerEchoComponent,
) !void {
    if (txn.message.Index < 0 or txn.message.Index >= echo_comp.preset_info.groups.len) {
        txn.respond(.{ .ErrorCode = .ErrVisionSkillSlotNotFound });
        return;
    }
    try removeVisionGroup(alloc.gpa, echo_comp, @intCast(txn.message.Index));
    try PlayerEchoComponent.savePresets(alloc.gpa, fs, echo_comp.player_id, echo_comp.preset_info);

    txn.respond(.{
        .ErrorCode = .Success,
        .VisionEquipList = try visionEquipGroupList(echo_comp, alloc.arena),
    });
}

fn appendVisionGroup(
    gpa: std.mem.Allocator,
    echo_comp: *PlayerEchoComponent,
    incr_id: i32,
    name: []const u8,
    slots: [5]i32,
) !void {
    const new_groups = try gpa.alloc(EchoInfo.VisionGroup, echo_comp.preset_info.groups.len + 1);
    @memcpy(new_groups[0..echo_comp.preset_info.groups.len], echo_comp.preset_info.groups);
    new_groups[echo_comp.preset_info.groups.len] = .{
        .incr_id = incr_id,
        .name = try gpa.dupe(u8, name),
        .slots = slots,
    };

    if (echo_comp.preset_info.groups.len != 0) gpa.free(echo_comp.preset_info.groups);
    echo_comp.preset_info.groups = new_groups;
}

fn removeVisionGroup(
    gpa: std.mem.Allocator,
    echo_comp: *PlayerEchoComponent,
    index: usize,
) !void {
    if (echo_comp.preset_info.groups[index].name.len != 0) {
        gpa.free(echo_comp.preset_info.groups[index].name);
    }

    const new_groups = try gpa.alloc(EchoInfo.VisionGroup, echo_comp.preset_info.groups.len - 1);
    @memcpy(new_groups[0..index], echo_comp.preset_info.groups[0..index]);
    @memcpy(new_groups[index..], echo_comp.preset_info.groups[index + 1 ..]);

    if (echo_comp.preset_info.groups.len != 0) gpa.free(echo_comp.preset_info.groups);
    echo_comp.preset_info.groups = new_groups;
}
