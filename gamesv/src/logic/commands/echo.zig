const std = @import("std");
const pb = @import("proto").pb;
const common = @import("common");

const Assets = @import("../../data/Assets.zig");
const EchoInfo = @import("../../fs/EchoInfo.zig");
const EventQueue = @import("../../logic/EventQueue.zig");
const PlayerEchoComponent = @import("../../logic/component/player/PlayerEchoComponent.zig");
const Connection = @import("../../network/Connection.zig");
const comp_util = @import("../component/comp_util.zig");
const mem = @import("../../mem.zig");
const special_item_incr = @import("../../fs/special_item_incr.zig");
const respond = @import("../commands.zig").respond;

const FileSystem = common.FileSystem;

const MainStatDef = struct {
    letter: u8,
    prop_id: i32,
    add_type: i32,
    name: []const u8,
};

const SubStatDef = struct {
    letter: u8,
    prop_id: i32,
    add_type: i32,
    name: []const u8,
};

const SubStatInput = struct {
    letter: ?[]const u8,
    tier: ?i32,
};

const main_stats = [_]MainStatDef{
    .{ .letter = 'a', .prop_id = 8, .add_type = 1, .name = "Crit Rate" },
    .{ .letter = 'b', .prop_id = 9, .add_type = 1, .name = "Crit DMG" },
    .{ .letter = 'c', .prop_id = 10007, .add_type = 2, .name = "ATK%" },
    .{ .letter = 'd', .prop_id = 10002, .add_type = 2, .name = "HP%" },
    .{ .letter = 'e', .prop_id = 10010, .add_type = 2, .name = "DEF%" },
    .{ .letter = 'f', .prop_id = 35, .add_type = 1, .name = "Healing Bonus" },
    .{ .letter = 'g', .prop_id = 22, .add_type = 1, .name = "Glacio DMG Bonus" },
    .{ .letter = 'h', .prop_id = 23, .add_type = 1, .name = "Fusion DMG Bonus" },
    .{ .letter = 'i', .prop_id = 24, .add_type = 1, .name = "Electro DMG Bonus" },
    .{ .letter = 'j', .prop_id = 25, .add_type = 1, .name = "Aero DMG Bonus" },
    .{ .letter = 'k', .prop_id = 26, .add_type = 1, .name = "Spectro DMG Bonus" },
    .{ .letter = 'l', .prop_id = 27, .add_type = 1, .name = "Havoc DMG Bonus" },
    .{ .letter = 'm', .prop_id = 11, .add_type = 1, .name = "Energy Regen" },
};

const sub_stats = [_]SubStatDef{
    .{ .letter = 'a', .prop_id = 10002, .add_type = 1, .name = "Flat HP" },
    .{ .letter = 'b', .prop_id = 10007, .add_type = 1, .name = "Flat ATK" },
    .{ .letter = 'c', .prop_id = 10010, .add_type = 1, .name = "Flat DEF" },
    .{ .letter = 'd', .prop_id = 10002, .add_type = 2, .name = "HP%" },
    .{ .letter = 'e', .prop_id = 10007, .add_type = 2, .name = "ATK%" },
    .{ .letter = 'f', .prop_id = 10010, .add_type = 2, .name = "DEF%" },
    .{ .letter = 'g', .prop_id = 14, .add_type = 1, .name = "Resonance Skill DMG Bonus" },
    .{ .letter = 'h', .prop_id = 17, .add_type = 1, .name = "Basic Attack DMG Bonus" },
    .{ .letter = 'i', .prop_id = 18, .add_type = 1, .name = "Heavy Attack DMG Bonus" },
    .{ .letter = 'j', .prop_id = 19, .add_type = 1, .name = "Resonance Liberation DMG Bonus" },
    .{ .letter = 'k', .prop_id = 8, .add_type = 1, .name = "Crit Rate" },
    .{ .letter = 'l', .prop_id = 9, .add_type = 1, .name = "Crit DMG" },
    .{ .letter = 'm', .prop_id = 11, .add_type = 1, .name = "Energy Regen" },
};

pub const echo = struct {
    pub const alias = "ec";
    pub const description =
        \\creates a custom Echo.
        \\usage: echo [echo_id] [sonata_id] [main] [sub] [tier] ...
        \\
        \\Main stat a-m:
        \\a CR, b CD, c ATK%, d HP%, e DEF%, f Heal
        \\g Glacio, h Fusion, i Electro, j Aero
        \\k Spectro, l Havoc, m Energy
        \\
        \\Sub stats a-m:
        \\a HP, b ATK, c DEF, d HP%, e ATK%, f DEF%
        \\g Skill, h Basic, i Heavy, j Liberation
        \\k CR, l CD, m Energy
        \\
        \\tier: stat roll value. 1 is the lowest, higher is better.
    ;

    pub fn call(
        events: *EventQueue,
        alloc: mem.Alloc,
        assets: *const Assets,
        fs: *FileSystem,
        conn: *Connection,
        echo_comp: *PlayerEchoComponent,
        echo_item_id: i32,
        sonata_id: i32,
        main_letter: []const u8,
        sub1: ?[]const u8,
        tier1: ?i32,
        sub2: ?[]const u8,
        tier2: ?i32,
        sub3: ?[]const u8,
        tier3: ?i32,
        sub4: ?[]const u8,
        tier4: ?i32,
        sub5: ?[]const u8,
        tier5: ?i32,
    ) !void {
        const item = assets.tables.phantom_item.getDataById(echo_item_id) orelse {
            try respond(events, alloc.arena, "unknown Echo item id: {d}", .{echo_item_id});
            return;
        };
        if (!EchoInfo.validDefaultOwnedItem(assets, item)) {
            try respond(events, alloc.arena, "Echo item {d} cannot be owned", .{echo_item_id});
            return;
        }

        const fetter_group_id = try resolveFetterGroup(events, alloc, item, sonata_id) orelse return;
        const main_prop = try resolveMainProperty(events, alloc, assets, item.MainProp.RandGroupId, main_letter) orelse return;
        const sub_inputs = [_]SubStatInput{
            .{ .letter = sub1, .tier = tier1 },
            .{ .letter = sub2, .tier = tier2 },
            .{ .letter = sub3, .tier = tier3 },
            .{ .letter = sub4, .tier = tier4 },
            .{ .letter = sub5, .tier = tier5 },
        };

        var echo_owned_by_map = false;
        const sub_props = try buildSubProps(events, alloc, assets, item.QualityId, sub_inputs[0..]) orelse return;
        errdefer if (!echo_owned_by_map and sub_props.len != 0) alloc.gpa.free(sub_props);

        const level = try maxLevelForQuality(events, alloc, assets, item.QualityId) orelse return;
        const main_props = try EchoInfo.buildMainPropsFromGroup(alloc.gpa, assets, main_prop.PropGroup, level);
        errdefer if (!echo_owned_by_map and main_props.len != 0) alloc.gpa.free(main_props);

        const incr_id = try special_item_incr.next(alloc.gpa, fs, echo_comp.player_id);
        const new_echo: EchoInfo = .{
            .id = echo_item_id,
            .level = level,
            .main_prop = main_props,
            .sub_prop = sub_props,
            .fetter_group_id = fetter_group_id,
        };

        try echo_comp.echo_map.put(alloc.gpa, incr_id, new_echo);
        echo_owned_by_map = true;
        saveEchoInfo(alloc, fs, echo_comp.player_id, incr_id, new_echo) catch |err| {
            if (echo_comp.echo_map.get(incr_id)) |stored_echo| stored_echo.deinit(alloc.gpa);
            _ = echo_comp.echo_map.orderedRemove(incr_id);
            return err;
        };

        var list: std.ArrayList(pb.PhantomItem) = .empty;
        try list.append(alloc.arena, try new_echo.toProto(incr_id, alloc.arena));
        try conn.push(pb.PhantomItemAddNotify{ .PhantomItemList = list });

        try respond(events, alloc.arena, "created Echo {d} with incr id {d}", .{ echo_item_id, incr_id });
    }
};

fn resolveFetterGroup(
    events: *EventQueue,
    alloc: mem.Alloc,
    item: Assets.DataTables.PhantomItem,
    sonata_id: i32,
) !?i32 {
    for (item.FetterGroup) |fetter_group_id| {
        if (fetter_group_id == sonata_id) return sonata_id;
    }

    var valid: std.ArrayList(u8) = .empty;
    defer valid.deinit(alloc.gpa);
    for (item.FetterGroup) |fetter_group_id| {
        if (valid.items.len != 0) try valid.append(alloc.gpa, ' ');
        const text = try std.fmt.allocPrint(alloc.gpa, "{d}", .{fetter_group_id});
        defer alloc.gpa.free(text);
        try valid.appendSlice(alloc.gpa, text);
    }
    try respond(events, alloc.arena, "Sonata {d} is invalid for this Echo; valid: {s}", .{ sonata_id, valid.items });
    return null;
}

fn buildSubProps(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    quality: i32,
    inputs: []const SubStatInput,
) !?[]EchoInfo.Prop {
    const max_count = EchoInfo.maxUnlockedSubPropCount(assets, quality) orelse {
        try respond(events, alloc.arena, "unknown Echo quality: {d}", .{quality});
        return null;
    };

    var props: std.ArrayList(EchoInfo.Prop) = .empty;
    errdefer props.deinit(alloc.gpa);

    for (inputs) |input| {
        if (input.letter == null and input.tier == null) continue;
        if (input.letter == null or input.tier == null) {
            try respond(events, alloc.arena, "substat arguments must be letter/tier pairs", .{});
            return null;
        }
        if (props.items.len >= max_count) {
            try respond(events, alloc.arena, "Echo quality {d} allows only {d} substats", .{ quality, max_count });
            return null;
        }

        const def = resolveSubStatDef(input.letter.?) orelse {
            try respond(events, alloc.arena, "invalid substat letter: {s}", .{input.letter.?});
            return null;
        };
        const prop = findSubProperty(assets, def) orelse {
            try respond(events, alloc.arena, "missing substat data for {s}", .{def.name});
            return null;
        };
        if (EchoInfo.containsSubPropRole(assets, props.items, prop)) {
            try respond(events, alloc.arena, "duplicate substat: {s}", .{def.name});
            return null;
        }

        const tier = input.tier.?;
        const value = EchoInfo.subPropValueForTier(quality, prop, tier) orelse {
            try respond(events, alloc.arena, "{s} tier must be 1-{d} for quality {d}", .{ def.name, EchoInfo.maxSubPropTier(quality, prop), quality });
            return null;
        };
        try props.append(alloc.gpa, .{ .id = prop.Id, .value = value });
    }

    return try props.toOwnedSlice(alloc.gpa);
}

fn maxLevelForQuality(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    quality: i32,
) !?i32 {
    const config = assets.tables.phantom_quality.getDataById(quality) orelse {
        try respond(events, alloc.arena, "unknown Echo quality: {d}", .{quality});
        return null;
    };
    return config.LevelLimit;
}

fn resolveMainProperty(
    events: *EventQueue,
    alloc: mem.Alloc,
    assets: *const Assets,
    rand_group_id: i32,
    token: []const u8,
) !?Assets.DataTables.PhantomMainProperty {
    const letter = parseLetter(token) orelse {
        try respond(events, alloc.arena, "main stat must be a single letter", .{});
        return null;
    };
    const def = resolveMainStatDef(letter) orelse {
        try respond(events, alloc.arena, "invalid main stat letter: {s}", .{token});
        return null;
    };

    for (assets.tables.phantom_main_property.items) |group| {
        if (group.RandGroupId != rand_group_id or group.PropGroup.len == 0) continue;
        const prop_item = assets.tables.phantom_main_prop_item.getDataById(group.PropGroup[0]) orelse continue;
        if (prop_item.PropId == def.prop_id and prop_item.AddType == def.add_type) return group;
    }

    var valid: std.ArrayList(u8) = .empty;
    try buildValidMainLetters(&valid, alloc.gpa, assets, rand_group_id);
    defer valid.deinit(alloc.gpa);
    try respond(events, alloc.arena, "main stat {s} is invalid for this Echo; valid: {s}", .{ token, valid.items });
    return null;
}

fn buildValidMainLetters(
    valid: *std.ArrayList(u8),
    gpa: std.mem.Allocator,
    assets: *const Assets,
    rand_group_id: i32,
) !void {
    for (main_stats) |def| {
        for (assets.tables.phantom_main_property.items) |group| {
            if (group.RandGroupId != rand_group_id or group.PropGroup.len == 0) continue;
            const prop_item = assets.tables.phantom_main_prop_item.getDataById(group.PropGroup[0]) orelse continue;
            if (prop_item.PropId == def.prop_id and prop_item.AddType == def.add_type) {
                if (valid.items.len != 0) try valid.append(gpa, ' ');
                try valid.append(gpa, def.letter);
                break;
            }
        }
    }
}

fn resolveMainStatDef(letter: u8) ?MainStatDef {
    for (main_stats) |def| {
        if (def.letter == letter) return def;
    }
    return null;
}

fn resolveSubStatDef(token: []const u8) ?SubStatDef {
    const letter = parseLetter(token) orelse return null;
    for (sub_stats) |def| {
        if (def.letter == letter) return def;
    }
    return null;
}

fn findSubProperty(assets: *const Assets, def: SubStatDef) ?Assets.DataTables.PhantomSubProperty {
    for (assets.tables.phantom_sub_property.items) |prop| {
        if (prop.PropId == def.prop_id and prop.AddType == def.add_type) return prop;
    }
    return null;
}

fn parseLetter(token: []const u8) ?u8 {
    if (token.len != 1) return null;
    const letter = std.ascii.toLower(token[0]);
    if (letter < 'a' or letter > 'z') return null;
    return letter;
}

fn saveEchoInfo(
    alloc: mem.Alloc,
    fs: *FileSystem,
    player_id: i32,
    incr_id: i32,
    item: EchoInfo,
) !void {
    const path = try std.fmt.allocPrint(alloc.arena, "player/{}/{s}/{}", .{ player_id, EchoInfo.data_dir, incr_id });
    try comp_util.saveStruct(fs, item, path, alloc.arena);
}
