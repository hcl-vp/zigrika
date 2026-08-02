const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Scene = @import("../../logic/Scene.zig");
const Entity = @import("../../logic/Scene.zig").Entity;
const dispatch = @import("combat.zig");
const attributes_helper = @import("../../logic/helpers/attributes.zig");
const Assets = @import("../../data/Assets.zig");

pub fn SkillRequest(txn: *dispatch.CombatRequestTxn(.SkillRequest)) !void {
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn UseSkillRequest(
    txn: *dispatch.CombatRequestTxn(.UseSkillRequest),
    scene: *Scene,
    assets: *const Assets,
    query: Scene.Query(&.{
        Entity,
        ?*Entity.AttributeComponent,
    }),
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const request: pb.UseSkillRequest = txn.payload;
    if (commonEntityId(txn.common)) |entity_id| {
        if (skillId(request.UseSkillInfo)) |skill_id| {
            try scene.noteFsmSkillStart(alloc.gpa, entity_id, skill_id, queryNow(io));

            // Resonance liberation (ultimate) skill: consume the caster's energy.
            if (assets.tables.skill.getDataById(skill_id)) |skill| {
                if (skill.SkillShowTagType == 2) {
                    if (query.byNetId(entity_id)) |target| {
                        const entity, const attr = target;
                        _ = entity;
                        if (attr) |attribute| {
                            var receive: std.ArrayList(pb.CombatReceiveData) = .empty;
                            defer receive.deinit(alloc.gpa);

                            const e_change = try attributes_helper.change_attr(
                                attribute,
                                .Energy,
                                .Override,
                                .Current,
                                0,
                                alloc,
                            );
                            try attributes_helper.generate_attr_messages(
                                &receive,
                                entity_id,
                                attribute,
                                &e_change,
                                alloc,
                                io,
                            );
                            if (receive.items.len != 0) {
                                try txn.receive_data_pack.appendSlice(alloc.arena, receive.items);
                            }
                        }
                    }
                }
            }
        }
    }
    txn.respond(.{
        .ErrorCode = .Success,
        .UseSkillInfo = request.UseSkillInfo,
        .SkillSingleId = request.SkillSingleId,
    });
}

pub fn EndSkillRequest(
    txn: *dispatch.CombatRequestTxn(.EndSkillRequest),
    scene: *Scene,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const request: pb.EndSkillRequest = txn.payload;
    if (commonEntityId(txn.common)) |entity_id| {
        if (skillId(request.UseSkillInfo)) |skill_id| {
            try scene.signalFsmSkillEnd(alloc.gpa, entity_id, skill_id, queryNow(io));
        }
    }
    txn.respond(.{
        .ErrorCode = .Success,
        .UseSkillInfo = request.UseSkillInfo,
        .SkillSingleId = request.SkillSingleId,
    });
}

pub fn EndSkillPush(
    push: pb.EndSkillPush,
    common: ?pb.CombatCommon,
    scene: *Scene,
    io: std.Io,
    alloc: mem.Alloc,
) !void {
    const entity_id = commonEntityId(common) orelse return;
    const skill_id = skillId(push.UseSkillInfo) orelse return;
    try scene.signalFsmSkillEnd(alloc.gpa, entity_id, skill_id, queryNow(io));
}

fn skillId(info: ?pb.UseSkillInformation) ?i32 {
    const value = info orelse return null;
    if (value.SkillId <= 0) return null;
    return std.math.cast(i32, value.SkillId);
}

fn commonEntityId(common: ?pb.CombatCommon) ?i64 {
    const value = common orelse return null;
    if (value.EntityId == 0) return null;
    return value.EntityId;
}

fn queryNow(io: std.Io) i64 {
    const rtc: std.Io.Clock = .awake;
    return rtc.now(io).toMilliseconds();
}
