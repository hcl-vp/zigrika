const PlayerEchoComponent = @This();
const std = @import("std");
const common = @import("common");
const comp_util = @import("../comp_util.zig");
const file_util = @import("../../../fs/file_util.zig");
const pb = @import("proto").pb;

const Assets = @import("../../../data/Assets.zig");
const EchoInfo = @import("../../../fs/EchoInfo.zig");
const special_item_incr = @import("../../../fs/special_item_incr.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;

player_id: i32,
echo_map: std.array_hash_map.Auto(i32, EchoInfo),
preset_info: EchoInfo.PresetInfo,
calabash_info: EchoInfo.CalabashInfo,

pub fn init(
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
    player_id: i32,
) !PlayerEchoComponent {
    var echo_map: std.array_hash_map.Auto(i32, EchoInfo) = .empty;
    errdefer comp_util.freeMap(gpa, &echo_map);

    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var preset_info = try file_util.loadZon(
        EchoInfo.PresetInfo,
        gpa,
        arena,
        fs,
        "player/{}/{s}",
        .{ player_id, EchoInfo.preset_data_path },
    ) orelse EchoInfo.PresetInfo{};
    errdefer preset_info.deinit(gpa);

    var calabash_info = try file_util.loadZon(
        EchoInfo.CalabashInfo,
        gpa,
        arena,
        fs,
        "player/{}/{s}",
        .{ player_id, EchoInfo.calabash_data_path },
    ) orelse blk: {
        var info = try EchoInfo.defaultCalabashInfo(gpa, assets);
        errdefer info.deinit(gpa);
        try saveCalabash(gpa, fs, player_id, info);
        break :blk info;
    };
    errdefer calabash_info.deinit(gpa);

    const data_dir_path = try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, EchoInfo.data_dir });
    if (try fs.readDir(data_dir_path)) |dir| {
        defer dir.deinit();

        for (dir.entries) |entry| if (entry.kind == .file) {
            const unique_id = std.fmt.parseInt(i32, entry.basename(), 10) catch continue;
            const item = file_util.loadZon(
                EchoInfo,
                gpa,
                arena,
                fs,
                "player/{}/{s}/{}",
                .{ player_id, EchoInfo.data_dir, unique_id },
            ) catch {
                std.log.err("failed to load EchoInfo with id {}", .{unique_id});
                continue;
            } orelse continue;

            try echo_map.put(gpa, unique_id, item);
        };
    }

    try special_item_incr.ensureAtLeast(gpa, fs, player_id, EchoInfo.nextAfterPresetGroups(preset_info.groups));

    if (Assets.DataTables.Config.seed_default_echoes and echo_map.count() == 0) {
        try EchoInfo.addDefaults(gpa, assets, &echo_map, try special_item_incr.current(gpa, fs, player_id));
        try saveAll(gpa, fs, player_id, echo_map);
    }
    try special_item_incr.ensureAtLeast(
        gpa,
        fs,
        player_id,
        @max(special_item_incr.nextAfterMap(echo_map), EchoInfo.nextAfterPresetGroups(preset_info.groups)),
    );
    return .{
        .player_id = player_id,
        .echo_map = echo_map,
        .preset_info = preset_info,
        .calabash_info = calabash_info,
    };
}

pub fn deinit(comp: *PlayerEchoComponent, gpa: Allocator) void {
    comp_util.freeMap(gpa, &comp.echo_map);
    comp.preset_info.deinit(gpa);
    comp.calabash_info.deinit(gpa);
}

pub fn saveAll(
    gpa: Allocator,
    fs: *FileSystem,
    player_id: i32,
    echo_map: std.array_hash_map.Auto(i32, EchoInfo),
) !void {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var iterator = echo_map.iterator();
    while (iterator.next()) |kv| {
        try comp_util.saveStruct(
            fs,
            kv.value_ptr.*,
            try std.fmt.allocPrint(arena, "player/{}/{s}/{}", .{ player_id, EchoInfo.data_dir, kv.key_ptr.* }),
            arena,
        );
    }
}

pub fn savePresets(
    gpa: Allocator,
    fs: *FileSystem,
    player_id: i32,
    preset_info: EchoInfo.PresetInfo,
) !void {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    try comp_util.saveStruct(
        fs,
        preset_info,
        try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, EchoInfo.preset_data_path }),
        arena,
    );
}

pub fn saveCalabash(
    gpa: Allocator,
    fs: *FileSystem,
    player_id: i32,
    calabash_info: EchoInfo.CalabashInfo,
) !void {
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    try comp_util.saveStruct(
        fs,
        calabash_info,
        try std.fmt.allocPrint(arena, "player/{}/{s}", .{ player_id, EchoInfo.calabash_data_path }),
        arena,
    );
}

pub fn buildVisionSkills(
    comp: *PlayerEchoComponent,
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    vision_entity_id: i64,
    combo_vision_entity_id: i64,
    explore_skill_id: i32,
) ![]pb.VisionSkillInformation {
    var skills: std.ArrayList(pb.VisionSkillInformation) = .empty;
    errdefer skills.deinit(gpa);

    const equip = comp.roleEquip(role_id);
    const combo = comp.comboEchoRuntime(assets, role_id);
    const combo_inc_id = if (combo) |partner| partner.inc_id else 0;
    for (equip.slots, 0..) |inc_id, index| {
        const skill_vision_entity_id = if (index == 0)
            vision_entity_id
        else if (inc_id != 0 and inc_id == combo_inc_id)
            combo_vision_entity_id
        else
            0;
        if (comp.echoVisionSkill(assets, inc_id, @intCast(index), skill_vision_entity_id)) |skill| {
            try skills.append(gpa, skill);
        }
    }
    if (explore_skill_id != 0) {
        try skills.append(gpa, .{
            .SkillId = explore_skill_id,
            .Index = 5,
        });
    }

    return skills.toOwnedSlice(gpa);
}

pub fn mainEchoSkillId(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) ?i32 {
    const runtime = comp.mainEchoRuntime(assets, role_id) orelse return null;
    return if (runtime.skill_id == 0) null else runtime.skill_id;
}

pub fn mainEchoBuffEffects(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) []const i64 {
    const skill_id = comp.mainEchoSkillId(assets, role_id) orelse return &.{};
    const skill = assets.tables.phantom_skill.getDataById(skill_id) orelse return &.{};
    return skill.BuffEffects;
}

pub fn activeEchoBuffEffects(comp: *PlayerEchoComponent, gpa: Allocator, assets: *const Assets, role_id: i32) ![]i64 {
    var ids: std.ArrayList(i64) = .empty;
    errdefer ids.deinit(gpa);

    const equip = comp.roleEquip(role_id);
    for (equip.slots) |inc_id| {
        const runtime = comp.echoRuntime(assets, inc_id) orelse continue;
        if (echoMarkerBuffEffect(assets, runtime.skill_id)) |buff_id| {
            try appendUniqueI64(gpa, &ids, buff_id);
        }
    }

    for (comp.mainEchoBuffEffects(assets, role_id)) |buff_id| {
        try appendUniqueI64(gpa, &ids, buff_id);
    }

    const fetter_ids = try comp.activeFetterIds(gpa, assets, role_id);
    defer gpa.free(fetter_ids);
    for (fetter_ids) |fetter_id| {
        const fetter = assets.tables.phantom_fetter.getDataById(fetter_id) orelse continue;
        for (fetter.BuffIds) |buff_id| {
            try appendUniqueI64(gpa, &ids, buff_id);
        }
    }

    return ids.toOwnedSlice(gpa);
}

pub fn mainEchoSummonId(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) ?i32 {
    const runtime = comp.mainEchoRuntime(assets, role_id) orelse return null;
    return if (runtime.summon_id == 0) null else runtime.summon_id;
}

pub fn comboEchoSummonId(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) ?i32 {
    const combo = comp.comboEchoRuntime(assets, role_id) orelse return null;
    return if (combo.runtime.summon_id == 0) null else combo.runtime.summon_id;
}

fn echoVisionSkill(comp: *PlayerEchoComponent, assets: *const Assets, inc_id: i32, index: i32, vision_entity_id: i64) ?pb.VisionSkillInformation {
    if (inc_id == 0) return null;
    const runtime = comp.echoRuntime(assets, inc_id) orelse return null;
    if (runtime.skill_id == 0) return null;

    return .{
        .SkillId = runtime.skill_id,
        .Level = runtime.level,
        .Quality = 5,
        .VisionEntityId = vision_entity_id,
        .Index = index,
    };
}

const MainEchoRuntime = struct {
    skill_id: i32,
    summon_id: i32,
    monster_id: i32,
    base_monster_id: i32,
    level: i32,
};

const ComboEchoRuntime = struct {
    inc_id: i32,
    runtime: MainEchoRuntime,
};

fn mainEchoRuntime(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) ?MainEchoRuntime {
    const equip = comp.roleEquip(role_id);

    const inc_id = equip.slots[0];
    return comp.echoRuntime(assets, inc_id);
}

fn echoRuntime(comp: *PlayerEchoComponent, assets: *const Assets, inc_id: i32) ?MainEchoRuntime {
    if (inc_id == 0) return null;
    const echo = comp.echo_map.get(inc_id) orelse return null;
    const base_item = assets.tables.phantom_item.getDataById(echo.id) orelse return null;
    const item = if (echo.skin_id != 0)
        if (assets.tables.phantom_item.getDataById(echo.skin_id)) |skin_item|
            if (skin_item.ParentMonsterId == base_item.MonsterId) skin_item else base_item
        else
            base_item
    else
        base_item;

    return .{
        .skill_id = item.SkillId,
        .summon_id = if (item.MeshId != 0) item.MeshId else item.SkillId,
        .monster_id = item.MonsterId,
        .base_monster_id = if (item.ParentMonsterId != 0) item.ParentMonsterId else item.MonsterId,
        .level = echo.level,
    };
}

fn comboEchoRuntime(comp: *PlayerEchoComponent, assets: *const Assets, role_id: i32) ?ComboEchoRuntime {
    const equip = comp.roleEquip(role_id);
    const main_runtime = comp.echoRuntime(assets, equip.slots[0]) orelse return null;
    if (main_runtime.base_monster_id == 0) return null;

    const main_group = phantomSummonGroup(assets, main_runtime.base_monster_id) orelse return null;
    for (equip.slots[1..]) |inc_id| {
        const runtime = comp.echoRuntime(assets, inc_id) orelse continue;
        if (runtime.summon_id == 0 or runtime.base_monster_id == main_runtime.base_monster_id) continue;
        if (std.mem.indexOfScalar(i32, main_group.GroupMonsterIds, runtime.base_monster_id) != null) {
            return .{ .inc_id = inc_id, .runtime = runtime };
        }
    }

    return null;
}

fn phantomSummonGroup(assets: *const Assets, monster_id: i32) ?Assets.DataTables.PhantomSummonGroup {
    for (assets.tables.phantom_summon_group.items) |group| {
        if (std.mem.indexOfScalar(i32, group.GroupMonsterIds, monster_id) != null) return group;
    }
    return null;
}

pub const EquippedEcho = struct {
    inc_id: i32,
    role_id: i32,
    pos: i32,
};

pub fn roleEquip(comp: *PlayerEchoComponent, role_id: i32) EchoInfo.RoleEquip {
    var equip = EchoInfo.RoleEquip{ .role_id = role_id };
    var iterator = comp.echo_map.iterator();
    while (iterator.next()) |kv| {
        const echo = kv.value_ptr.*;
        if (echo.role_id == null or echo.role_id.? != role_id) continue;
        if (echo.equipped_pos < 0 or echo.equipped_pos >= @as(i32, @intCast(equip.slots.len))) continue;
        equip.slots[@intCast(echo.equipped_pos)] = kv.key_ptr.*;
    }
    return equip;
}

pub fn equippedEcho(comp: *PlayerEchoComponent, role_id: i32, pos: i32) ?EquippedEcho {
    var iterator = comp.echo_map.iterator();
    while (iterator.next()) |kv| {
        const echo = kv.value_ptr.*;
        if (echo.role_id == null or echo.role_id.? != role_id or echo.equipped_pos != pos) continue;
        return .{ .inc_id = kv.key_ptr.*, .role_id = role_id, .pos = pos };
    }
    return null;
}

pub fn equippedEchoByIncrId(comp: *PlayerEchoComponent, inc_id: i32) ?EquippedEcho {
    const echo = comp.echo_map.get(inc_id) orelse return null;
    const role_id = echo.role_id orelse return null;
    if (echo.equipped_pos < 0 or echo.equipped_pos >= 5) return null;
    return .{ .inc_id = inc_id, .role_id = role_id, .pos = echo.equipped_pos };
}

pub fn activeFetterIds(comp: *PlayerEchoComponent, gpa: Allocator, assets: *const Assets, role_id: i32) ![]i32 {
    var ids: std.ArrayList(i32) = .empty;
    errdefer ids.deinit(gpa);

    const equip = comp.roleEquip(role_id);

    var counts: std.array_hash_map.Auto(i32, i32) = .empty;
    defer counts.deinit(gpa);
    var seen: std.hash_map.AutoHashMapUnmanaged(i64, void) = .empty;
    defer seen.deinit(gpa);

    for (equip.slots) |inc_id| {
        if (inc_id == 0) continue;
        const echo = comp.echo_map.get(inc_id) orelse continue;
        if (echo.fetter_group_id == 0) continue;
        const item = assets.tables.phantom_item.getDataById(echo.id) orelse continue;
        const seen_key = @as(i64, echo.fetter_group_id) * 10_000_000 + @as(i64, item.MonsterId);
        if (seen.contains(seen_key)) continue;
        try seen.put(gpa, seen_key, {});

        const gop = try counts.getOrPut(gpa, echo.fetter_group_id);
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }

    for (counts.keys(), counts.values()) |group_id, count| {
        const group = assets.tables.phantom_fetter_group.getDataById(group_id) orelse continue;
        var it = group.FetterMap.map.iterator();
        while (it.next()) |entry| {
            if (count >= entry.key_ptr.*) {
                try ids.append(gpa, entry.value_ptr.*);
            }
        }
    }

    return ids.toOwnedSlice(gpa);
}

pub fn activeEchoTags(
    comp: *PlayerEchoComponent,
    gpa: Allocator,
    assets: *const Assets,
    role_id: i32,
    role_tags: []const []const u8,
) ![][]const u8 {
    var tags: std.ArrayList([]const u8) = .empty;
    errdefer tags.deinit(gpa);

    for (role_tags) |tag| {
        if (containsTag(tags.items, tag)) continue;
        try tags.append(gpa, tag);
    }

    const equip = comp.roleEquip(role_id);
    for (equip.slots) |inc_id| {
        const runtime = comp.echoRuntime(assets, inc_id) orelse continue;
        const buff_id = echoMarkerBuffEffect(assets, runtime.skill_id) orelse continue;
        const buff = assets.tables.buff.getDataById(buff_id) orelse continue;
        for (buff.GrantedTags) |tag| {
            if (containsTag(tags.items, tag)) continue;
            try tags.append(gpa, tag);
        }
    }

    return tags.toOwnedSlice(gpa);
}

pub fn buffTagRequirementsMet(buff: Assets.DataTables.Buff, active_tags: []const []const u8) bool {
    for (buff.OngoingTagRequirements) |tag| {
        if (!containsTag(active_tags, tag)) return false;
    }
    for (buff.OngoingTagIgnores) |tag| {
        if (containsTag(active_tags, tag)) return false;
    }
    return true;
}

fn containsTag(tags: []const []const u8, needle: []const u8) bool {
    for (tags) |tag| {
        if (tagMatches(tag, needle)) return true;
    }
    return false;
}

fn tagMatches(tag: []const u8, requirement: []const u8) bool {
    if (std.mem.eql(u8, tag, requirement)) return true;
    return tag.len > requirement.len and
        tag[requirement.len] == '.' and
        std.mem.eql(u8, tag[0..requirement.len], requirement);
}

fn echoMarkerBuffEffect(assets: *const Assets, skill_id: i32) ?i64 {
    if (skill_id == 0) return null;
    const marker_id: i64 = @as(i64, skill_id) * 1000 + 1;
    const marker = assets.tables.buff.getDataById(marker_id) orelse return null;
    if (marker.GrantedTags.len == 0 or marker.ExtraEffectID != 0) return null;
    return marker_id;
}

fn appendUniqueI64(gpa: Allocator, list: *std.ArrayList(i64), value: i64) !void {
    if (std.mem.indexOfScalar(i64, list.items, value) != null) return;
    try list.append(gpa, value);
}
