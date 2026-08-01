const DataTables = @This();
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const pb = @import("proto").pb;
const WeaponItem = @import("../fs/WeaponItem.zig");
pub const Config = @import("zon/config.zon");
const ConcertoExceptions: []const i32 = @import("zon/concerto_exceptions.zon");

pub const RoleInfo = @import("tables/RoleInfo.zig");
pub const RoleBeHitMap = @import("tables/RoleBeHitMap.zig");
pub const MainRoleConfig = @import("tables/MainRoleConfig.zig");
pub const BaseProperty = @import("tables/BaseProperty.zig");
pub const FunctionCondition = @import("tables/FunctionCondition.zig");
pub const RolePropertyGrowth = @import("tables/RolePropertyGrowth.zig");
pub const MonsterPropertyGrowth = @import("tables/MonsterPropertyGrowth.zig");
pub const InstanceDungeon = @import("tables/InstanceDungeon.zig");
pub const Buff = @import("tables/Buff.zig");
pub const SummonCfg = @import("tables/SummonCfg.zig");
pub const ModelConfigPreload = @import("tables/ModelConfigPreload.zig");
pub const CharacterPartConfig = @import("tables/CharacterPartConfig.zig");
pub const GameplayTagParent = @import("tables/GameplayTagParent.zig");
pub const GameplayTagRemap = @import("tables/GameplayTagRemap.zig");
pub const BlueprintConfig = @import("tables/BlueprintConfig.zig");
pub const RoleSkin = @import("tables/RoleSkin.zig");
pub const FlySkinConfig = @import("tables/FlySkinConfig.zig");
pub const WeaponSkin = @import("tables/WeaponSkin.zig");
pub const Ornament = @import("tables/Ornament.zig");
pub const TemplateConfig = @import("tables/TemplateConfig.zig");
pub const ExploreTools = @import("tables/ExploreTools.zig");
pub const WeaponConf = @import("tables/WeaponConf.zig");
pub const WeaponBaseAttributes = @import("tables/WeaponBaseAttributes.zig");
pub const WeaponPropertyGrowth = @import("tables/WeaponPropertyGrowth.zig");
pub const WeaponReson = @import("tables/WeaponReson.zig");
pub const WeaponExpItem = @import("tables/WeaponExpItem.zig");
pub const WeaponLevel = @import("tables/WeaponLevel.zig");
pub const WeaponBreach = @import("tables/WeaponBreach.zig");
pub const RoleBreach = @import("tables/RoleBreach.zig");
pub const SkillLevel = @import("tables/SkillLevel.zig");
pub const LevelEntityConfig = @import("tables/LevelEntityConfig.zig");
pub const Damage = @import("tables/Damage.zig");
pub const Area = @import("tables/Area.zig");
pub const InfrV2TreeBuild = @import("tables/InfrV2TreeBuild.zig");
pub const InfrRoadBuild = @import("tables/InfrRoadBuild.zig");
pub const Teleporter = @import("tables/Teleporter.zig");
pub const Activity = @import("tables/Activity.zig");
pub const MapFog = @import("tables/MapFog.zig");
pub const MultiMap = @import("tables/MultiMap.zig");
pub const MapBlockInfo = @import("tables/MapBlockInfo.zig");
pub const ExploreProgressReward = @import("tables/ExploreProgressReward.zig");
pub const ExploreReward = @import("tables/ExploreReward.zig");
pub const ExploreScore = @import("tables/ExploreScore.zig");
pub const Flow = @import("tables/Flow.zig");
pub const Skill = @import("tables/Skill.zig");
pub const SkillTree = @import("tables/SkillTree.zig");
pub const ResonantChain = @import("tables/ResonantChain.zig");
pub const RogueResCharacterBuff = @import("tables/RogueResCharacterBuff.zig");
pub const HonamiStoryEffect = @import("tables/HonamiStoryEffect.zig");
pub const ComboTeaching = @import("tables/ComboTeaching.zig");
pub const EntitySkillPreload = @import("tables/EntitySkillPreload.zig");
pub const CommonSkillPreload = @import("tables/CommonSkillPreload.zig");
pub const FavorWord = @import("tables/FavorWord.zig");
pub const FavorStory = @import("tables/FavorStory.zig");
pub const FavorGoods = @import("tables/FavorGoods.zig");
pub const Motion = @import("tables/Motion.zig");
pub const GuideGroup = @import("tables/GuideGroup.zig");
pub const CharacterInitInfo = @import("tables/CharacterInitInfo.zig");
pub const SkillBranchBuff = @import("tables/SkillBranchBuff.zig");
pub const PhonographMusic = @import("tables/PhonographMusic.zig");
pub const BackgroundCard = @import("tables/BackgroundCard.zig");
pub const PlayerHeadRe = @import("tables/PlayerHeadRe.zig");
pub const PlayerTitle = @import("tables/PlayerTitle.zig");
pub const MotorTechTree = @import("tables/MotorTechTree.zig");
pub const MotorLvl = @import("tables/MotorLvl.zig");
pub const MotorTech = @import("tables/MotorTech.zig");
pub const MotorTechLv = @import("tables/MotorTechLv.zig");
pub const MotorTask = @import("tables/MotorTask.zig");
pub const MotorSkin = @import("tables/MotorSkin.zig");
pub const MotorSticker = @import("tables/MotorSticker.zig");
pub const MotorStickerPart = @import("tables/MotorStickerPart.zig");
pub const MotorLoadProject = @import("tables/MotorLoadProject.zig");
pub const MotorGeneralPreview = @import("tables/MotorGeneralPreview.zig");
pub const MotorDecalIp = @import("tables/MotorDecalIp.zig");
pub const MotorLinkageIp = @import("tables/MotorLinkageIp.zig");
pub const MotorFrame = @import("tables/MotorFrame.zig");
pub const MotorDecorations = @import("tables/MotorDecorations.zig");
pub const MotorDecorationsPart = @import("tables/MotorDecorationsPart.zig");
pub const Gacha = @import("tables/Gacha.zig");
pub const GachaPool = @import("tables/GachaPool.zig");
pub const GachaViewInfo = @import("tables/GachaViewInfo.zig");
pub const GachaTextureInfo = @import("tables/GachaTextureInfo.zig");
pub const AiStateMachineConfig = @import("tables/AiStateMachineConfig.zig");
pub const AiBase = @import("tables/AiBase.zig");
pub const PhantomItem = @import("tables/PhantomItem.zig");
pub const PhantomSkill = @import("tables/PhantomSkill.zig");
pub const PhantomSummonGroup = @import("tables/PhantomSummonGroup.zig");
pub const PhantomFetter = @import("tables/PhantomFetter.zig");
pub const PhantomFetterGroup = @import("tables/PhantomFetterGroup.zig");
pub const PhantomMainProperty = @import("tables/PhantomMainProperty.zig");
pub const PhantomMainPropItem = @import("tables/PhantomMainPropItem.zig");
pub const PhantomSubProperty = @import("tables/PhantomSubProperty.zig");
pub const PhantomRarity = @import("tables/PhantomRarity.zig");
pub const PhantomQuality = @import("tables/PhantomQuality.zig");
pub const PhantomGrowth = @import("tables/PhantomGrowth.zig");
pub const PhantomLevel = @import("tables/PhantomLevel.zig");
pub const PhantomExpItem = @import("tables/PhantomExpItem.zig");
pub const PhantomVicePolishConfig = @import("tables/PhantomVicePolishConfig.zig");
pub const CalabashLevel = @import("tables/CalabashLevel.zig");
pub const CalabashDevelopReward = @import("tables/CalabashDevelopReward.zig");
pub const CalabashSkin = @import("tables/CalabashSkin.zig");
pub const DropPackage = @import("tables/DropPackage.zig");
pub const PropValue = @import("tables/PropValue.zig");

pub const GameplayTagParentTable = Table(GameplayTagParent, "Id");
pub const GameplayTagRemapTable = Table(GameplayTagRemap, "RawId");

arena: ArenaAllocator,
role_info: Table(RoleInfo, "Id"),
role_be_hit_map: Table(RoleBeHitMap, "Id"),
main_role_config: Table(MainRoleConfig, "Id"),
base_property: Table(BaseProperty, "Id"),
function_condition: Table(FunctionCondition, "FunctionId"),
role_property_growth: Table(RolePropertyGrowth, "Id"),
monster_property_growth: Table(MonsterPropertyGrowth, "Id"),
instance_dungeon: Table(InstanceDungeon, "Id"),
buff: Table(Buff, "Id"),
summon_cfg: Table(SummonCfg, "Id"),
model_config_preload: Table(ModelConfigPreload, "Id"),
character_part_config: Table(CharacterPartConfig, "ModelId"),
gameplay_tag_parent: GameplayTagParentTable,
gameplay_tag_remap: GameplayTagRemapTable,
blueprint_config: Table(BlueprintConfig, "Id"),
role_skin: Table(RoleSkin, "Id"),
fly_skin_config: Table(FlySkinConfig, "Id"),
weapon_skin: Table(WeaponSkin, "Id"),
ornament: Table(Ornament, "Id"),
template_config: Table(TemplateConfig, "Id"),
explore_tools: Table(ExploreTools, "PhantomSkillId"),
weapon_conf: Table(WeaponConf, "ItemId"),
weapon_base_attributes: Table(WeaponBaseAttributes, "ItemId"),
weapon_property_growth: Table(WeaponPropertyGrowth, "Id"),
weapon_reson: Table(WeaponReson, "Id"),
weapon_exp_item: Table(WeaponExpItem, "Id"),
weapon_level: Table(WeaponLevel, "Id"),
weapon_breach: Table(WeaponBreach, "Id"),
role_breach: Table(RoleBreach, "Id"),
skill_level: Table(SkillLevel, "Id"),
level_entity_config: Table(LevelEntityConfig, "EntityId"),
damage: Table(Damage, "Id"),
area: Table(Area, "AreaId"),
infr_v2_tree_build: Table(InfrV2TreeBuild, "Id"),
infr_road_build: Table(InfrRoadBuild, "Id"),
teleporter: Table(Teleporter, "Id"),
activity: Table(Activity, "Id"),
map_fog: Table(MapFog, "Fog"),
multi_map: Table(MultiMap, "Id"),
map_block_info: Table(MapBlockInfo, "BlockId"),
explore_progress_reward: Table(ExploreProgressReward, "Id"),
explore_reward: Table(ExploreReward, "Id"),
explore_score: Table(ExploreScore, "Area"),
flow: Table(Flow, "Id"),
skill: Table(Skill, "Id"),
skill_tree: Table(SkillTree, "Id"),
resonant_chain: Table(ResonantChain, "Id"),
rogue_res_buff: Table(RogueResCharacterBuff, "Id"),
honami_story_effect: Table(HonamiStoryEffect, "Id"),
combo_teaching: Table(ComboTeaching, "Id"),
entity_skill_preload: Table(EntitySkillPreload, "Id"),
common_skill_preload: Table(CommonSkillPreload, "Id"),
favor_word: Table(FavorWord, "Id"),
favor_story: Table(FavorStory, "Id"),
favor_goods: Table(FavorGoods, "Id"),
motion: Table(Motion, "Id"),
guide_group: Table(GuideGroup, "Id"),
char_init_info: Table(CharacterInitInfo, "RoleId"),
skill_branch_buff: Table(SkillBranchBuff, "BranchId"),
phonograph_music: Table(PhonographMusic, "Id"),
background_card: Table(BackgroundCard, "Id"),
player_head_re: Table(PlayerHeadRe, "Id"),
player_title: Table(PlayerTitle, "Id"),
motor_tech_tree: Table(MotorTechTree, "Id"),
motor_lvl: Table(MotorLvl, "Level"),
motor_tech: Table(MotorTech, "Id"),
motor_tech_lv: Table(MotorTechLv, "Id"),
motor_task: Table(MotorTask, "Id"),
motor_skin: Table(MotorSkin, "Id"),
motor_sticker: Table(MotorSticker, "Id"),
motor_sticker_part: Table(MotorStickerPart, "Id"),
motor_load_project: Table(MotorLoadProject, "Id"),
motor_general_preview: Table(MotorGeneralPreview, "Id"),
motor_decal_ip: Table(MotorDecalIp, "Id"),
motor_linkage_ip: Table(MotorLinkageIp, "Id"),
motor_frame: Table(MotorFrame, "Id"),
motor_decorations: Table(MotorDecorations, "Id"),
motor_decorations_part: Table(MotorDecorationsPart, "Id"),
gacha: Table(Gacha, "Id"),
gacha_pool: Table(GachaPool, "Id"),
gacha_view_info: Table(GachaViewInfo, "Id"),
gacha_texture_info: Table(GachaTextureInfo, "Id"),
ai_state_machine_config: Table(AiStateMachineConfig, "Id"),
ai_base: Table(AiBase, "Id"),
phantom_item: Table(PhantomItem, "ItemId"),
phantom_skill: Table(PhantomSkill, "PhantomSkillId"),
phantom_summon_group: Table(PhantomSummonGroup, "Id"),
phantom_fetter: Table(PhantomFetter, "Id"),
phantom_fetter_group: Table(PhantomFetterGroup, "Id"),
phantom_main_property: Table(PhantomMainProperty, "Id"),
phantom_main_prop_item: Table(PhantomMainPropItem, "Id"),
phantom_sub_property: Table(PhantomSubProperty, "Id"),
phantom_rarity: Table(PhantomRarity, "Rare"),
phantom_quality: Table(PhantomQuality, "Quality"),
phantom_growth: Table(PhantomGrowth, "Id"),
phantom_level: Table(PhantomLevel, "Id"),
phantom_exp_item: Table(PhantomExpItem, "ItemId"),
phantom_vice_polish_config: Table(PhantomVicePolishConfig, "PropCount"),
calabash_level: Table(CalabashLevel, "Level"),
calabash_develop_reward: Table(CalabashDevelopReward, "MonsterId"),
calabash_skin: Table(CalabashSkin, "Id"),
drop_package: Table(DropPackage, "Id"),

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
    const KeyType = @FieldType(T, key_field);
    const IndexMap = switch (@typeInfo(KeyType)) {
        .int, .comptime_int => std.AutoArrayHashMapUnmanaged(KeyType, usize),
        .pointer => std.StringArrayHashMapUnmanaged(usize),
        else => @compileError("unsupported key type: " ++ @typeName(KeyType)),
    };

    return struct {
        pub const key = key_field;
        pub const init: @This() = .{ .items = &.{}, .index = .empty };
        pub const json = blk: {
            const t_name = @typeName(T);
            break :blk t_name[std.mem.findScalarLast(u8, t_name, '.').? + 1 ..] ++ ".json";
        };

        items: []const T,
        index: IndexMap,

        pub fn getDataById(table: @This(), id: KeyType) ?T {
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

pub fn getMonsterPropertyGrowth(tables: *const DataTables, level: i32, curve_id: i32) ?*const MonsterPropertyGrowth {
    for (tables.monster_property_growth.items) |*config| {
        if (config.Level == level and config.CurveId == curve_id)
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

pub fn getMotorcycleConfigId(tables: *const DataTables) ?i32 {
    for (tables.explore_tools.items) |tool| {
        if (tool.SummonConfigId == 0) continue;

        const summon = tables.summon_cfg.getDataById(tool.SummonConfigId) orelse continue;
        const blueprint = blk: {
            for (tables.blueprint_config.items) |entry| {
                if (std.mem.eql(u8, entry.BlueprintType, summon.BlueprintType)) break :blk entry;
            }
            continue;
        };
        if (blueprint.EntityLogic != .Vehicle) continue;

        for (tables.template_config.items) |template| {
            if (std.mem.eql(u8, template.BlueprintType, summon.BlueprintType)) return template.Id;
        }
    }

    return null;
}

const BuffAdditionEntry = @import("../logic/events.zig").BuffAdditionEntry;

pub fn getRoleAutoBuffs(
    tables: *const DataTables,
    role_id: i32,
    weapon: WeaponItem,
    gpa: Allocator,
) !std.ArrayListUnmanaged(BuffAdditionEntry) {
    const logger = std.log.scoped(.autobuff);
    const role_info = tables.role_info.getDataById(role_id) orelse return error.RoleNotFound;
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
        1001000000, // Character initial buff mount
        70000077, // Role-IOU deduction control
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
        "c79fde44", // qingxiao
        "fbcbee28",
        "功能.功能制作.禁止体力恢复", // qingxiao2
    };

    const maybe_init_info = tables.char_init_info.getDataById(role_id);
    var results: std.ArrayListUnmanaged(BuffAdditionEntry) = .empty;
    errdefer results.deinit(gpa);

    var do_autobuff = true;

    if (maybe_init_info) |init_info| {
        if (init_info.FightBuffs.len > 0) {
            do_autobuff = false;

            for (init_info.FightBuffs) |buff_id| {
                const buff = tables.buff.getDataById(buff_id) orelse continue;
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

                try results.append(gpa, .{ .id = buff_id, .is_active = is_active });
            }
        }
    }

    if (do_autobuff) {
        for (tables.buff.items) |*buff| {
            var id_buf: [20]u8 = undefined;
            var role_buf: [20]u8 = undefined;
            const id_str = std.fmt.bufPrint(&id_buf, "{d}", .{buff.Id}) catch continue;
            const role_str = std.fmt.bufPrint(&role_buf, "{d}", .{role_id}) catch continue;

            // autobuff
            if (!std.mem.startsWith(u8, id_str, role_str)) continue;
            if (id_str.len <= 4) continue;
            if (buff.DurationPolicy != .Infinite) continue;
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
    }

    for (additional_buffs) |id| {
        try results.append(gpa, .{ .id = id, .is_active = true });
    }

    if (tables.main_role_config.getDataById(role_id)) |main_role| {
        if (mainRoleTagBuffId(main_role.Gender)) |tag_buff_id| {
            try results.append(gpa, .{ .id = tag_buff_id, .is_active = true });
        }
    }

    if (std.mem.findScalar(i32, ConcertoExceptions, role_id) == null) {
        try results.append(gpa, .{ .id = 1101002011, .is_active = true });
    }

    for (reson_conf.Effect) |id| {
        try results.append(gpa, .{ .id = id, .is_active = true });
    }

    try results.append(gpa, .{ .id = 1101007999 + role_info.ElementId, .is_active = true });
    try results.append(gpa, .{ .id = 1001001015 + (role_info.ElementId * 2), .is_active = true });
    try results.append(gpa, .{ .id = 3080 + role_info.ElementId, .is_active = true });

    if (do_autobuff) {
        var illegal_ids: std.AutoHashMapUnmanaged(i64, void) = .empty;
        defer illegal_ids.deinit(gpa);

        // resonant chain buff removal
        for (tables.resonant_chain.items) |chain| {
            if (chain.GroupId != role_id) continue;
            for (chain.BuffIds) |buff_id| {
                try illegal_ids.put(gpa, buff_id, {});
            }
        }

        // further rogue buff removal
        for (tables.rogue_res_buff.items) |rogue_char_buffs| {
            var buff_id_buf: [20]u8 = undefined;
            var role_buf: [20]u8 = undefined;
            const role_str = std.fmt.bufPrint(&role_buf, "{d}", .{role_id}) catch continue;
            const buff_id_str = std.fmt.bufPrint(&buff_id_buf, "{d}", .{rogue_char_buffs.BuffId}) catch continue;
            if (std.mem.startsWith(u8, buff_id_str, role_str)) {
                try illegal_ids.put(gpa, rogue_char_buffs.BuffId, {});
            }
            for (rogue_char_buffs.BuffIds) |buff_id| {
                var bid_buf: [20]u8 = undefined;
                const bid_str = std.fmt.bufPrint(&bid_buf, "{d}", .{buff_id}) catch continue;
                if (std.mem.startsWith(u8, bid_str, role_str)) {
                    try illegal_ids.put(gpa, buff_id, {});
                }
            }
        }

        // honami
        for (tables.honami_story_effect.items) |honami| {
            for (honami.Param) |param| {
                if (param.len < 7) continue;
                const id = std.fmt.parseInt(i64, param, 10) catch continue;
                try illegal_ids.put(gpa, id, {});
            }
        }

        // combo teaching buff removal
        for (tables.combo_teaching.items) |combo| {
            for (combo.AddBuffID) |buff_id| {
                try illegal_ids.put(gpa, buff_id, {});
            }
        }

        // le denia (handle ee id 6 (attribute event))
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
    }
    logger.info("autobuff results for: {d}, {any}", .{ role_id, results.items });

    return results;
}

fn mainRoleTagBuffId(gender: i32) ?i64 {
    return switch (gender) {
        1 => 291724064,
        0 => 291724065,
        else => null,
    };
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
