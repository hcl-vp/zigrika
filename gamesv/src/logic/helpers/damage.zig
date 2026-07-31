const std = @import("std");
const pb = @import("proto").pb;
const mem = @import("../../mem.zig");
const Scene = @import("../../logic/Scene.zig");
const Connection = @import("../../network/Connection.zig");
const Entity = @import("../../logic/Scene.zig").Entity;
const Assets = @import("../../data/Assets.zig");
const FileSystem = @import("common").FileSystem;
const Transaction = @import("../handlers.zig").Transaction;
const attributes_helper = @import("../../logic/helpers/attributes.zig");

// TODO: revamp this in its respective branch :)
pub fn damageEntity(
    combat_receive_pack: *std.ArrayList(pb.CombatReceiveData),
    request: pb.DamageExecuteRequest,
    damage: *const Assets.DataTables.Damage,
    scene: *Scene,
    fs: *FileSystem,
    io: std.Io,
    query: Scene.Query(&.{
        Entity,
        *Entity.FightBuffComponent,
        *Entity.AttributeComponent,
    }),
    alloc: mem.Alloc,
) !pb.DamageExecuteNotify {
    const log = std.log.scoped(.damage_math);
    const attacker_entity: Entity, _, const attacker_attr: *Entity.AttributeComponent = blk: {
        if (query.byNetId(request.AttackerEntityId)) |comps| {
            break :blk comps;
        } else {
            log.debug("couldnt find entity stuff", .{});
            return pb.DamageExecuteNotify{
                .Damage = 1,
                .ElementType = damage.Element,
            };
        }
    };

    const concerto: i32 = blk: {
        const base = if (damage.ElementPower.len > 0) damage.ElementPower[0] else break :blk 0;
        const eff_idx = @intFromEnum(pb.EAttributeType.ElementEfficiency);
        if (attacker_attr.attributes.len > eff_idx) {
            const concerto_eff = attacker_attr.attributes[eff_idx].current;
            break :blk @divTrunc(base * concerto_eff, 10000);
        }
        break :blk 0;
    };

    const change = try attributes_helper.change_attr(
        attacker_attr,
        .ElementEnergy,
        .Delta,
        .Current,
        concerto,
        alloc,
    );

    try attributes_helper.generate_attr_messages(
        combat_receive_pack,
        request.AttackerEntityId,
        attacker_attr,
        &change,
        alloc,
        io,
    );

    const e_change = try attributes_helper.change_attr(
        attacker_attr,
        .Energy,
        .Delta,
        .Current,
        10000000,
        alloc,
    );
    if (change.items.len != 0 or e_change.items.len != 0) {
        try scene.markFsmDirty(
            alloc.gpa,
            attacker_entity.net_id,
            Entity.FsmComponent.WakeReason.attribute,
        );
    }
    try scene.saveComponents(fs, alloc.gpa, attacker_entity, &.{Entity.AttributeComponent});

    try attributes_helper.generate_attr_messages(
        combat_receive_pack,
        request.AttackerEntityId,
        attacker_attr,
        &e_change,
        alloc,
        io,
    );

    return pb.DamageExecuteNotify{
        .Damage = 1,
        .ElementType = damage.Element,
    };
}
