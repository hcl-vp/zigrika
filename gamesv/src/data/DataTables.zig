const DataTables = @This();
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const IndexMap = std.array_hash_map.Auto(i64, usize);
const pb = @import("proto").pb;
const WeaponItem = @import("../fs/WeaponItem.zig");

pub const RoleInfo = @import("tables/RoleInfo.zig");
pub const BaseProperty = @import("tables/BaseProperty.zig");
pub const FunctionCondition = @import("tables/FunctionCondition.zig");
pub const RolePropertyGrowth = @import("tables/RolePropertyGrowth.zig");
pub const InstanceDungeon = @import("tables/InstanceDungeon.zig");
pub const Buff = @import("tables/Buff.zig");
pub const SummonCfg = @import("tables/SummonCfg.zig");
pub const ModelConfigPreload = @import("tables/ModelConfigPreload.zig");
pub const BlueprintConfig = @import("tables/BlueprintConfig.zig");
pub const RoleSkin = @import("tables/RoleSkin.zig");
pub const TemplateConfig = @import("tables/TemplateConfig.zig");
pub const ExploreTools = @import("tables/ExploreTools.zig");
pub const WeaponConf = @import("tables/WeaponConf.zig");
pub const WeaponReson = @import("tables/WeaponReson.zig");
pub const LevelEntityConfig = @import("tables/LevelEntityConfig.zig");
pub const Damage = @import("tables/Damage.zig");
pub const Area = @import("tables/Area.zig");
pub const InfrV2TreeBuild = @import("tables/InfrV2TreeBuild.zig");
pub const Teleporter = @import("tables/Teleporter.zig");
pub const Activity = @import("tables/Activity.zig");

arena: ArenaAllocator,
role_info: Table(RoleInfo, "Id"),
base_property: Table(BaseProperty, "Id"),
function_condition: Table(FunctionCondition, "FunctionId"),
role_property_growth: Table(RolePropertyGrowth, "Id"),
instance_dungeon: Table(InstanceDungeon, "Id"),
buff: Table(Buff, "Id"),
summon_cfg: Table(SummonCfg, "Id"),
model_config_preload: Table(ModelConfigPreload, "Id"),
blueprint_config: Table(BlueprintConfig, "Id"),
role_skin: Table(RoleSkin, "Id"),
template_config: Table(TemplateConfig, "Id"),
explore_tools: Table(ExploreTools, "PhantomSkillId"),
weapon_conf: Table(WeaponConf, "ItemId"),
weapon_reson: Table(WeaponReson, "Id"),
level_entity_config: Table(LevelEntityConfig, "EntityId"),
damage: Table(Damage, "Id"),
area: Table(Area, "AreaId"),
infr_v2_tree_build: Table(InfrV2TreeBuild, "Id"),
teleporter: Table(Teleporter, "Id"),
activity: Table(Activity, "Id"),

fn loadTableItems(
    comptime T: type,
    gpa: Allocator,
    arena: *ArenaAllocator,
    io: Io,
    base_path: []const u8,
) !T {
    if (Io.Dir.readFileAlloc(Io.Dir.cwd(), io, base_path, gpa, Io.Limit.unlimited)) |content| {
        defer gpa.free(content);
        return try std.json.parseFromSliceLeaky(
            T,
            arena.allocator(),
            content,
            .{ .ignore_unknown_fields = true, .allocate = .alloc_always },
        );
    } else |_| {}

    const base = base_path[0 .. base_path.len - ".json".len];

    const Item = std.meta.Child(T);
    var all_items: std.ArrayListUnmanaged(Item) = .empty;
    defer all_items.deinit(gpa);

    var chunk: usize = 1;
    while (true) : (chunk += 1) {
        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(
            &path_buf,
            "{s}_{d}.json",
            .{ base, chunk },
        ) catch return error.PathTooLong;

        const content = Io.Dir.readFileAlloc(Io.Dir.cwd(), io, path, gpa, Io.Limit.unlimited) catch |err| switch (err) {
            error.FileNotFound => break,
            else => return err,
        };
        defer gpa.free(content);

        const chunk_items = try std.json.parseFromSliceLeaky(
            T,
            arena.allocator(),
            content,
            .{ .ignore_unknown_fields = true, .allocate = .alloc_always },
        );
        try all_items.appendSlice(gpa, chunk_items);
    }

    if (chunk == 1) return error.FileNotFound;
    return try arena.allocator().dupe(Item, all_items.items);
}

pub fn load(gpa: Allocator, io: Io) !DataTables {
    var tables: DataTables = undefined;

    tables.arena = ArenaAllocator.init(gpa);
    errdefer tables.arena.deinit();

    inline for (std.meta.fields(DataTables)) |field| {
        if (field.type == ArenaAllocator) continue;

        var table: field.type = .init;
        const base_path = "assets/BinData/" ++ field.type.json;

        const items = try loadTableItems(
            @FieldType(field.type, "items"),
            gpa,
            &tables.arena,
            io,
            base_path,
        );
        table.items = items;

        for (table.items, 0..) |item, index| {
            const key = @field(item, field.type.key);
            try table.index.put(tables.arena.allocator(), key, index);
        }

        @field(tables, field.name) = table;
    }

    return tables;
}

pub fn deinit(tables: *DataTables) void {
    tables.arena.deinit();
}

pub fn Table(comptime T: type, comptime key_field: [:0]const u8) type {
    return struct {
        pub const key = key_field;
        pub const init: @This() = .{ .items = &.{}, .index = .empty };
        pub const json = blk: {
            const t_name = @typeName(T);
            break :blk t_name[std.mem.findScalarLast(u8, t_name, '.').? + 1 ..] ++ ".json";
        };

        items: []const T,
        index: IndexMap,

        pub fn getDataById(table: @This(), id: i64) ?T {
            return if (table.index.get(id)) |i| table.items[i] else null;
        }
    };
}

pub fn getRolePropertyGrowth(tables: *const DataTables, level: i32, breach: i32) ?*const RolePropertyGrowth {
    for (tables.role_property_growth.items) |*config| {
        if (config.Level == level and config.BreachLevel == breach)
            return config;
    } else return null;
}

pub fn getProps(tables: *const DataTables, property_id: i32, gpa: Allocator) ![]i32 {
    const base_property = tables.base_property.getDataById(property_id) orelse return &.{};

    const props = try gpa.alloc(i32, @intFromEnum(pb.EAttributeType.MAX));
    @memset(props, 0);

    inline for (comptime std.meta.fields(DataTables.BaseProperty)) |field| {
        if (!@hasField(pb.EAttributeType, field.name)) continue;
        const attr_type = @field(pb.EAttributeType, field.name);

        props[@intFromEnum(attr_type)] = @field(base_property, field.name);
    }

    return props;
}

const BuffAdditionEntry = @import("../logic/events.zig").BuffAdditionEntry;

pub fn getRoleAutoBuffs(
    tables: *const DataTables,
    role_id: i32,
    weapon: WeaponItem,
    gpa: Allocator,
) !std.ArrayListUnmanaged(BuffAdditionEntry) {
    const reson_conf = tables.getWeaponReson((tables.weapon_conf.getDataById(weapon.id) orelse unreachable).ResonId, weapon.reson_level) orelse unreachable;
    const additional_buffs = [_]i64{
        3003, // Remove wall run prohibition
        3004, // Remove gliding prohibition
        3127, // qte energy
        3134, // dodge energy
        1213, // Reduce stamina while flying
        1214, // Reduce stamina while flying in sprint
        1215, // Reduce stamina while flying up in sprint
        1216, // Reduce stamina while flying down in sprint
        1101002011, // 120 charge ultimate skill restores concerto energy
        1001000000, // Character initial buff mount
        70000077, // Role-IOU deduction control
        291724064, // Male MC Tag
        291724065, // Female MC Tag
    };
    const blacklisted_buff_id_combos = [_][]const u8{
        "666", "990", "777", "095", "402", "403", "302", "291", "98", "009", "020",
    };
    const blacklisted_tag_components = [_][]const u8{
        "Rogue",
        "肉鸽",
        "试用",
        "零能量",
        "59b4b0a5",
        "371b7a72",
        "角色.R2T1JiyanMd10011.技能标识.大招状态", // jiyan
        "23d0723c", // denia forms stuff
        "20b04084", // lynae roguelike
        "8c658780", // mornye roguelik
        "9296f07f", // amy roguelike
    };

    var results: std.ArrayListUnmanaged(BuffAdditionEntry) = .empty;
    errdefer results.deinit(gpa);

    for (tables.buff.items) |*buff| {
        var id_buf: [20]u8 = undefined;
        var role_buf: [20]u8 = undefined;
        const id_str = std.fmt.bufPrint(&id_buf, "{d}", .{buff.Id}) catch continue;
        const role_str = std.fmt.bufPrint(&role_buf, "{d}", .{role_id}) catch continue;

        // autobuff
        if (!std.mem.startsWith(u8, id_str, role_str)) continue;
        if (id_str.len <= 4) continue;
        if (buff.DurationPolicy != .Permanent) continue;
        if (buff.ApplicationSourceTagRequirements.len != 0) continue;
        if (buff.ApplicationTagRequirements.len != 0) continue;
        if (buff.PrematureExpirationEffects.len != 0) continue;

        // roguelike buff removal
        const suffix = id_str[4..];
        const blacklisted_combo = blk: {
            for (blacklisted_buff_id_combos) |combo| {
                if (std.mem.startsWith(u8, suffix, combo)) break :blk true;
            }
            break :blk false;
        };
        if (blacklisted_combo) continue;

        const blacklisted_tag = tag_cond: {
            for (buff.GrantedTags) |tag| {
                for (blacklisted_tag_components) |component| {
                    if (std.mem.find(u8, tag, component) != null) break :tag_cond true;
                }
            }
            break :tag_cond false;
        };
        if (blacklisted_tag) continue;

        if (buff.ExtraEffectID == 5) {
            const valid = buff.ExtraEffectParameters.len > 1 and calc_policy_cond: {
                const param = buff.ExtraEffectParameters[1];
                const hash_pos = std.mem.indexOfScalar(u8, param, '#') orelse param.len;
                const ref_id = std.fmt.parseInt(i64, param[0..hash_pos], 10) catch break :calc_policy_cond true;
                const ref_buff = tables.buff.getDataById(@intCast(ref_id)) orelse break :calc_policy_cond true;
                break :calc_policy_cond ref_buff.CalculationPolicy.len > 0 and ref_buff.CalculationPolicy[0] != 0;
            };
            if (!valid) continue;
        }

        // is_buff_active check from wicked
        const is_active =
            buff.ModifierMagnitude.len == 0 and
            buff.BuffAction.len == 0 and
            buff.OngoingTagRequirements.len == 0 and
            buff.OngoingTagIgnores.len == 0 and
            buff.RemovalTagRequirements.len == 0 and
            buff.RemovalTagIgnores.len == 0 and
            buff.ApplicationSourceTagIgnores.len == 0 and
            buff.ApplicationTagIgnores.len == 0 and
            buff.ExtraEffectRequirements.len == 0;

        try results.append(gpa, .{ .id = buff.Id, .is_active = is_active });
    }

    for (additional_buffs) |id| {
        try results.append(gpa, .{ .id = id, .is_active = true });
    }

    for (reson_conf.Effect) |id| {
        try results.append(gpa, .{ .id = id, .is_active = true });
    }

    // le denia (handle ee id 6 (attribute event))
    var illegal_ids: std.AutoHashMapUnmanaged(i64, void) = .empty;
    defer illegal_ids.deinit(gpa);

    for (results.items) |entry| {
        const buff = tables.buff.getDataById(@intCast(entry.id)) orelse continue;
        if (buff.ExtraEffectID != 6) continue;
        const result_param = if (buff.ExtraEffectParameters.len > 3)
            buff.ExtraEffectParameters[3]
        else
            continue;
        var it = std.mem.splitScalar(u8, result_param, '#');
        while (it.next()) |id_str| {
            const id = std.fmt.parseInt(i64, id_str, 10) catch continue;
            try illegal_ids.put(gpa, id, {});
        }
    }

    if (illegal_ids.count() > 0) {
        var i: usize = 0;
        while (i < results.items.len) {
            if (illegal_ids.contains(results.items[i].id)) {
                _ = results.swapRemove(i);
            } else {
                i += 1;
            }
        }
    }

    return results;
}

pub fn createBuffInformation(
    handle_id: i32,
    buff_id: i64,
    instigator_id: i64,
    entity_id: i64,
    is_active: bool,
) pb.FightBuffInformation {
    return .{
        .HandleId = handle_id,
        .BuffId = buff_id,
        .Level = 1,
        .StackCount = 1,
        .InstigatorId = instigator_id,
        .EntityId = entity_id,
        .Duration = -1.0,
        .LeftDuration = -1.0,
        .IsActive = is_active,
        .ApplyType = .Common,
        .MessageId = -1,
        .ServerId = 0,
    };
}

pub fn getWeaponReson(tables: *const DataTables, reson_id: i32, level: i32) ?*const WeaponReson {
    for (tables.weapon_reson.items) |*reson| {
        if (reson.ResonId == reson_id and reson.Level == level) return reson;
    }
    return null;
}
