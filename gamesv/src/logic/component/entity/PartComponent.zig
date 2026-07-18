const Component = @This();
const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const CharacterPartConfig = @import("../../../data/tables/CharacterPartConfig.zig");
const FsmTypes = @import("../../fsm/Types.zig");
const TagComponent = @import("TagComponent.zig");

pub const transient = true;

parts: []FsmTypes.PartState = &.{},

pub fn init(config: CharacterPartConfig, entity_life_max: i32, gpa: std.mem.Allocator) !Component {
    const parts = try gpa.alloc(FsmTypes.PartState, config.Parts.len);
    errdefer gpa.free(parts);

    for (config.Parts, parts) |part, *state| {
        const max_life: f32 = if (part.LifeRatio > 0)
            @as(f32, @floatFromInt(entity_life_max)) * part.LifeRatio
        else
            -1;
        state.* = .{
            .index = part.Index,
            .name = part.Name,
            .life = max_life,
            .max_life = max_life,
            .activated = part.BirthActivated,
            .birth_activated = part.BirthActivated,
            .part_tag_id = part.PartTagId,
            .active_tag_id = part.ActiveTagId,
            .combine_socket = part.CombineSocket,
        };
    }

    return .{ .parts = parts };
}

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.parts);
}

pub fn states(comp: *const Component) []const FsmTypes.PartState {
    return comp.parts;
}

pub fn supportsCombinePart(comp: *const Component, part_index: i32) bool {
    for (comp.parts) |part| {
        if (part.index == part_index) return part.combine_socket.len != 0;
    }
    return false;
}

pub fn toProto(comp: *const Component, alloc: mem.Alloc) !pb.PartComponentPb {
    var result: pb.PartComponentPb = .{};
    for (comp.parts) |part| {
        try result.PartLifeInfos.append(alloc.arena, partInfo(part));
    }
    return result;
}

pub fn appendPartInfo(comp: *const Component, index: usize, output: *std.ArrayList(pb.PartInformation), arena: std.mem.Allocator) !void {
    if (index >= comp.parts.len) return;
    try output.append(arena, partInfo(comp.parts[index]));
}

pub fn activate(
    comp: *Component,
    part_name: []const u8,
    activated: bool,
    tags: ?*TagComponent,
    changed: *std.ArrayList(usize),
    gpa: std.mem.Allocator,
) !void {
    if (part_name.len == 0) return;
    for (comp.parts, 0..) |*part, index| {
        if (!std.mem.eql(u8, part.name, part_name)) continue;
        if (part.activated == activated) return;
        part.activated = activated;
        try changed.append(gpa, index);
        try comp.syncActiveTags(tags, gpa);
        return;
    }
}

pub fn reset(
    comp: *Component,
    part_name: []const u8,
    reset_activate: bool,
    reset_life: bool,
    tags: ?*TagComponent,
    changed: *std.ArrayList(usize),
    gpa: std.mem.Allocator,
) !void {
    var activation_changed = false;
    for (comp.parts, 0..) |*part, index| {
        if (part_name.len != 0 and !std.mem.eql(u8, part.name, part_name)) continue;

        var part_changed = false;
        if (reset_life and part.life != part.max_life) {
            part.life = part.max_life;
            part_changed = true;
        }
        if (reset_activate and part.activated != part.birth_activated) {
            part.activated = part.birth_activated;
            activation_changed = true;
            part_changed = true;
        }
        if (part_changed) try changed.append(gpa, index);
    }
    if (activation_changed) try comp.syncActiveTags(tags, gpa);
}

pub fn syncActiveTags(comp: *const Component, tags: ?*TagComponent, gpa: std.mem.Allocator) !void {
    const tag_comp = tags orelse return;
    for (comp.parts, 0..) |part, index| {
        var duplicate = false;
        for (comp.parts[0..index]) |previous| {
            if (previous.active_tag_id == part.active_tag_id) {
                duplicate = true;
                break;
            }
        }
        if (duplicate) continue;

        var active_count: i32 = 0;
        for (comp.parts) |candidate| {
            if (candidate.active_tag_id == part.active_tag_id and candidate.activated) active_count += 1;
        }
        try tag_comp.setGameplayTagCount(gpa, part.active_tag_id, active_count);
    }
}

fn partInfo(part: FsmTypes.PartState) pb.PartInformation {
    return .{
        .PartIndex = part.index,
        .LifeValue = part.life,
        .LifeMax = part.max_life,
        .Activated = part.activated,
        .PartTag = part.part_tag_id,
    };
}
