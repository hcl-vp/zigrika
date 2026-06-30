const pb = @import("proto").pb;
const Transaction = @import("../../handlers.zig").Transaction;
const mem = @import("../../../mem.zig");
const FileSystem = @import("common").FileSystem;
const Assets = @import("../../../data/Assets.zig");
const PlayerEchoComponent = @import("../../../logic/component/player/PlayerEchoComponent.zig");
const PlayerCosmeticComponent = @import("../../../logic/component/player/PlayerCosmeticComponent.zig");
const phantom_projector = @import("../../../logic/helpers/phantom_projector.zig");

pub fn onPhantomInteractionEquipRequest(
    txn: *Transaction(pb.PhantomInteractionEquipRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
) !void {
    if (txn.message.EquipedMonsterIds.items.len != phantom_projector.slot_count) {
        txn.respond(.{ .ErrorCode = .ErrPhantomInteractionEquipCountNotMatch });
        return;
    }

    for (txn.message.EquipedMonsterIds.items) |monster_id| {
        if (monster_id != 0 and !phantom_projector.isUnlockedMonster(assets, monster_id)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomInteractionNotUnlock });
            return;
        }
    }

    try phantom_projector.replaceEquippedMonsters(
        alloc.gpa,
        &echo_comp.calabash_info,
        txn.message.EquipedMonsterIds.items,
    );
    try PlayerEchoComponent.saveCalabash(alloc.gpa, fs, echo_comp.player_id, echo_comp.calabash_info);
    txn.respond(.{ .ErrorCode = .Success });
}

pub fn onPhantomInteractionSkinChangeRequest(
    txn: *Transaction(pb.PhantomInteractionSkinChangeRequest),
    alloc: mem.Alloc,
    fs: *FileSystem,
    assets: *const Assets,
    echo_comp: *PlayerEchoComponent,
    cosmetic_comp: *PlayerCosmeticComponent,
) !void {
    for (txn.message.SkinChangeInfos.items) |info| {
        if (!phantom_projector.isUnlockedMonster(assets, info.MonsterId)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomInteractionNotUnlock });
            return;
        }
        if (!phantom_projector.isValidSkin(assets, cosmetic_comp.info, info.MonsterId, info.SkinId)) {
            txn.respond(.{ .ErrorCode = .ErrPhantomSkinNotUnlock });
            return;
        }
    }

    for (txn.message.SkinChangeInfos.items) |info| {
        try phantom_projector.setEquippedSkin(alloc.gpa, &echo_comp.calabash_info, info.MonsterId, info.SkinId);
    }

    try PlayerEchoComponent.saveCalabash(alloc.gpa, fs, echo_comp.player_id, echo_comp.calabash_info);
    txn.respond(.{ .ErrorCode = .Success });
}
