const EchoInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;
const Assets = @import("../data/Assets.zig");

const Allocator = std.mem.Allocator;

const SubPropRollProfile = struct {
    weights: []const i32,
    multipliers: []const i32,
};

const flat_sub_prop_weights = [_]i32{ 15, 15, 35, 35 };
const normal_sub_prop_weights = [_]i32{ 5, 5, 10, 10, 15, 15, 17, 23 };
const flat_atk_def_multipliers = [_]i32{ 813, 1083, 1353, 1623 };
const critical_multipliers = [_]i32{ 1263, 1383, 1503, 1623, 1743, 1863, 1983, 2103 };
const normal_sub_prop_multipliers = [_]i32{ 853, 953, 1053, 1153, 1253, 1353, 1453, 1553 };

pub const data_dir = "echo";
pub const preset_data_path = "echo/presets";
pub const calabash_data_path = "echo/calabash";

id: i32,
func_value: i32 = 0,
level: i32 = 0,
exp: i32 = 0,
main_prop: []Prop = &.{},
sub_prop: []Prop = &.{},
fetter_group_id: i32 = 0,
skin_id: i32 = 0,
role_id: ?i32 = null,
equipped_pos: i32 = -1,
unack_sub_prop: []Prop = &.{},
lock_prop_index: []i32 = &.{},

pub const Prop = struct {
    id: i32,
    value: i32,
};

pub const RoleEquip = struct {
    role_id: i32,
    slots: [5]i32 = .{ 0, 0, 0, 0, 0 },
};

pub const VisionGroup = struct {
    incr_id: i32 = 0,
    name: []const u8 = "",
    slots: [5]i32 = .{ 0, 0, 0, 0, 0 },
};

pub const PresetInfo = struct {
    pub const default: PresetInfo = .{};
    groups: []VisionGroup = &.{},

    pub fn deinit(info: PresetInfo, gpa: Allocator) void {
        std.zon.parse.free(gpa, info);
    }
};

pub fn nextAfterPresetGroups(groups: []const VisionGroup) i32 {
    var next_id: i32 = 1;
    for (groups) |group| {
        next_id = @max(next_id, group.incr_id + 1);
    }
    return next_id;
}

pub const CalabashInfo = struct {
    pub const default: CalabashInfo = .{};
    rewarded_levels: []i32 = &.{},
    projector_monster_ids: []i32 = &.{},
    projector_skins: []ProjectorSkin = &.{},

    pub fn deinit(info: CalabashInfo, gpa: Allocator) void {
        std.zon.parse.free(gpa, info);
    }
};

pub const ProjectorSkin = struct {
    monster_id: i32,
    skin_id: i32,
};

pub fn defaultCalabashInfo(gpa: Allocator, assets: *const Assets) !CalabashInfo {
    var levels: std.ArrayList(i32) = .empty;
    errdefer levels.deinit(gpa);

    try levels.ensureTotalCapacity(gpa, assets.tables.calabash_level.items.len);
    for (assets.tables.calabash_level.items) |level| {
        if (level.Level > 0) levels.appendAssumeCapacity(level.Level);
    }

    return .{ .rewarded_levels = try levels.toOwnedSlice(gpa) };
}

pub fn toProto(item: EchoInfo, incr_id: i32, arena: Allocator) !pb.PhantomItem {
    return .{
        .Id = item.id,
        .IncrId = incr_id,
        .FuncValue = item.func_value,
        .PhantomLevel = item.level,
        .PhantomExp = item.exp,
        .PhantomMainProp = try propList(item.main_prop, arena),
        .PhantomSubProp = try propList(item.sub_prop, arena),
        .FetterGroupId = item.fetter_group_id,
        .SkinId = item.skin_id,
        .UnAckSubProp = try propList(item.unack_sub_prop, arena),
        .LockPropIndex = try intList(item.lock_prop_index, arena),
    };
}

pub fn equipToProto(equip: RoleEquip, arena: Allocator) !pb.RolePhantomEquipInfo {
    var slots: std.ArrayList(i32) = .empty;
    try slots.appendSlice(arena, &equip.slots);
    return .{
        .RoleId = equip.role_id,
        .PhantomItemIncrId = slots,
    };
}

pub fn presetToProto(group: VisionGroup, arena: Allocator) !pb.RefreshVisionEquipGroupData {
    var slots: std.ArrayList(i32) = .empty;
    try slots.appendSlice(arena, &group.slots);
    return .{
        .IncId = slots,
        .Name = group.name,
    };
}

pub fn addDefaults(
    gpa: Allocator,
    assets: *const Assets,
    echo_map: *std.array_hash_map.Auto(i32, EchoInfo),
    start_incr_id: i32,
) !void {
    var next_incr_id = start_incr_id;

    for (assets.tables.phantom_item.items) |item| {
        if (!validDefaultOwnedItem(assets, item)) continue;
        try echo_map.put(gpa, next_incr_id, try buildDefaultEcho(gpa, assets, item));
        next_incr_id += 1;
    }
}

fn validDefaultOwnedItem(assets: *const Assets, item: Assets.DataTables.PhantomItem) bool {
    if (item.PhantomType != 1 or item.ParentMonsterId != 0) return false;
    if (!item.ShowInBag or !item.Destructible or item.FetterGroup.len == 0) return false;
    if (assets.tables.phantom_rarity.getDataById(item.Rarity) == null) return false;
    if (assets.tables.phantom_quality.getDataById(item.QualityId) == null) return false;
    return findMainProperty(assets, item.MainProp.RandGroupId) != null;
}

fn buildDefaultEcho(
    gpa: Allocator,
    assets: *const Assets,
    item: Assets.DataTables.PhantomItem,
) !EchoInfo {
    return .{
        .id = item.ItemId,
        .main_prop = try buildMainProps(gpa, assets, item.MainProp.RandGroupId, 0),
        .fetter_group_id = item.FetterGroup[0],
    };
}

fn buildMainProps(gpa: Allocator, assets: *const Assets, rand_group_id: i32, level: i32) ![]Prop {
    const main_property = findMainProperty(assets, rand_group_id) orelse return &.{};
    var props: std.ArrayList(Prop) = .empty;
    errdefer props.deinit(gpa);

    for (main_property.PropGroup) |prop_item_id| {
        const prop_item = assets.tables.phantom_main_prop_item.getDataById(prop_item_id) orelse continue;
        try props.append(gpa, .{
            .id = prop_item.Id,
            .value = mainPropValue(assets, prop_item, level),
        });
    }

    return props.toOwnedSlice(gpa);
}

pub fn rebuildMainProps(item: *EchoInfo, gpa: Allocator, assets: *const Assets, rand_group_id: i32) !void {
    const new_props = try buildMainProps(gpa, assets, rand_group_id, item.level);
    if (item.main_prop.len != 0) gpa.free(item.main_prop);
    item.main_prop = new_props;
}

pub fn refreshMainPropValues(item: *EchoInfo, assets: *const Assets) void {
    for (item.main_prop) |*prop| {
        const prop_item = assets.tables.phantom_main_prop_item.getDataById(prop.id) orelse continue;
        prop.value = mainPropValue(assets, prop_item, item.level);
    }
}

pub fn maxUnlockedSubPropCount(assets: *const Assets, quality: i32) ?usize {
    const config = assets.tables.phantom_quality.getDataById(quality) orelse return null;
    return config.SlotUnlockLevel.len;
}

pub fn unlockedSubPropCount(assets: *const Assets, quality: i32, level: i32) ?usize {
    const config = assets.tables.phantom_quality.getDataById(quality) orelse return null;
    var count: usize = 0;
    for (config.SlotUnlockLevel) |unlock_level| {
        if (level >= unlock_level) count += 1;
    }
    return count;
}

pub fn appendSubProps(
    item: *EchoInfo,
    gpa: Allocator,
    assets: *const Assets,
    quality: i32,
    max_count: usize,
    count: usize,
    random_seed: u64,
) !usize {
    if (item.sub_prop.len >= max_count or count == 0 or assets.tables.phantom_sub_property.items.len == 0) return 0;

    var prng = std.Random.DefaultPrng.init(random_seed);
    const rng = prng.random();

    var props: std.ArrayList(Prop) = .empty;
    errdefer props.deinit(gpa);
    try props.appendSlice(gpa, item.sub_prop);

    while (props.items.len < max_count and props.items.len < item.sub_prop.len + count) {
        const prop = pickRandomSubProperty(assets, props.items, rng) orelse break;
        try props.append(gpa, .{ .id = prop.Id, .value = randomSubPropValue(quality, prop, rng) });
    }

    const added = props.items.len - item.sub_prop.len;
    if (added == 0) return 0;

    const new_props = try props.toOwnedSlice(gpa);
    if (item.sub_prop.len != 0) gpa.free(item.sub_prop);
    item.sub_prop = new_props;
    return added;
}

pub fn containsSubPropRole(assets: *const Assets, props: []const Prop, candidate: Assets.DataTables.PhantomSubProperty) bool {
    for (props) |prop| {
        const existing = assets.tables.phantom_sub_property.getDataById(prop.id) orelse continue;
        if (sameSubPropType(existing, candidate)) return true;
    }
    return false;
}

pub fn sameSubPropType(a: Assets.DataTables.PhantomSubProperty, b: Assets.DataTables.PhantomSubProperty) bool {
    if (isFlatPercentSubProp(a) and isFlatPercentSubProp(b)) {
        return a.PropId == b.PropId and a.AddType == b.AddType;
    }
    return a.PropId == b.PropId;
}

fn isFlatPercentSubProp(prop: Assets.DataTables.PhantomSubProperty) bool {
    return prop.PropId == 10002 or prop.PropId == 10007 or prop.PropId == 10010;
}

pub fn pickRandomSubProperty(
    assets: *const Assets,
    props: []const Prop,
    rng: std.Random,
) ?Assets.DataTables.PhantomSubProperty {
    var available_count: usize = 0;
    for (assets.tables.phantom_sub_property.items) |prop| {
        if (!containsSubPropRole(assets, props, prop)) available_count += 1;
    }
    if (available_count == 0) return null;

    const chosen = rng.uintLessThan(usize, available_count);
    var current: usize = 0;
    for (assets.tables.phantom_sub_property.items) |prop| {
        if (containsSubPropRole(assets, props, prop)) continue;
        if (current == chosen) return prop;
        current += 1;
    }
    return null;
}

pub fn randomSubPropValue(quality: i32, prop: Assets.DataTables.PhantomSubProperty, rng: std.Random) i32 {
    const profile = subPropRollProfile(prop);
    const max_index = maxSubPropRollIndex(quality, profile.multipliers.len);
    const multiplier = profile.multipliers[randomWeightedIndex(rng, profile.weights, max_index)];
    return scaledSubPropValue(prop.SubStandardProperty, multiplier);
}

fn subPropRollProfile(prop: Assets.DataTables.PhantomSubProperty) SubPropRollProfile {
    if (isFlatAtkDefSubProp(prop)) {
        return .{ .weights = flat_sub_prop_weights[0..], .multipliers = flat_atk_def_multipliers[0..] };
    }
    if (isCriticalSubProp(prop)) {
        return .{ .weights = normal_sub_prop_weights[0..], .multipliers = critical_multipliers[0..] };
    }
    return .{ .weights = normal_sub_prop_weights[0..], .multipliers = normal_sub_prop_multipliers[0..] };
}

fn maxSubPropRollIndex(quality: i32, multiplier_count: usize) usize {
    if (multiplier_count == flat_atk_def_multipliers.len) {
        return switch (quality) {
            3 => 1,
            4 => 2,
            else => 3,
        };
    }
    return switch (quality) {
        3 => 3,
        4 => 5,
        else => 7,
    };
}

fn isFlatAtkDefSubProp(prop: Assets.DataTables.PhantomSubProperty) bool {
    return (prop.PropId == 10007 or prop.PropId == 10010) and prop.AddType == 1;
}

fn isCriticalSubProp(prop: Assets.DataTables.PhantomSubProperty) bool {
    return prop.PropId == 8 or prop.PropId == 9;
}

fn randomWeightedIndex(rng: std.Random, weights: []const i32, max_index: usize) usize {
    const capped_index = @min(max_index, weights.len - 1);
    var total: u32 = 0;
    for (weights[0 .. capped_index + 1]) |weight| total += @intCast(weight);

    var roll = rng.uintLessThan(u32, total);
    for (weights[0 .. capped_index + 1], 0..) |weight, index| {
        const weight_value: u32 = @intCast(weight);
        if (roll < weight_value) return index;
        roll -= weight_value;
    }
    return capped_index;
}

fn scaledSubPropValue(value: i32, multiplier: i32) i32 {
    return @divTrunc(value * multiplier + 5000, 10000) * 10;
}

fn findMainProperty(assets: *const Assets, rand_group_id: i32) ?Assets.DataTables.PhantomMainProperty {
    for (assets.tables.phantom_main_property.items) |entry| {
        if (entry.RandGroupId == rand_group_id) return entry;
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

fn propList(data: []const Prop, arena: Allocator) !std.ArrayList(pb.PhantomPropInfo) {
    var result: std.ArrayList(pb.PhantomPropInfo) = .empty;
    try result.ensureTotalCapacity(arena, data.len);
    for (data) |prop| {
        result.appendAssumeCapacity(.{ .PhantomPropId = prop.id, .Value = prop.value });
    }
    return result;
}

fn intList(data: []const i32, arena: Allocator) !std.ArrayList(i32) {
    var result: std.ArrayList(i32) = .empty;
    try result.appendSlice(arena, data);
    return result;
}

pub fn deinit(item: EchoInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, item);
}
