const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");
const std = @import("std");
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

pub const default: @This() = .{};

fight_buff_infos: []pb.FightBuffInformation = &.{},
buff_effect_cds: []pb.BuffEffectCd = &.{},
born_buff_ids: []i64 = &.{},
born_message_id: i64 = 0,

pub fn deinit(comp: *Component, gpa: std.mem.Allocator) void {
    gpa.free(comp.fight_buff_infos);
    gpa.free(comp.buff_effect_cds);
    gpa.free(comp.born_buff_ids);
}

pub fn toProto(comp: Component) pb.FightBuffComponentPb {
    return .{
        .FightBuffInfos = sliceToArrayList(pb.FightBuffInformation, comp.fight_buff_infos),
        .ListBuffEffectCd = sliceToArrayList(pb.BuffEffectCd, comp.buff_effect_cds),
        .ClientBornBuffIds = sliceToArrayList(i64, comp.born_buff_ids),
        .ClientBornMessageId = comp.born_message_id,
    };
}

pub fn removeByHandleId(comp: *Component, gpa: std.mem.Allocator, handle_id: i32) void {
    const infos = comp.fight_buff_infos;
    const idx = for (infos, 0..) |info, i| {
        if (info.HandleId == handle_id) break i;
    } else return;

    infos[idx] = infos[infos.len - 1];
    comp.fight_buff_infos = gpa.realloc(infos, infos.len - 1) catch infos[0 .. infos.len - 1];
}

pub fn getByBuffId(comp: *Component, buff_id: i64) ?*pb.FightBuffInformation {
    for (comp.fight_buff_infos) |*info| {
        if (info.BuffId == buff_id) return info;
    } else return null;
}
