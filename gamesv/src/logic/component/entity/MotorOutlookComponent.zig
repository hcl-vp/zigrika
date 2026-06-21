const pb = @import("proto").pb;
const sliceToArrayList = @import("EntityComponentStorage.zig").sliceToArrayList;

skin: i32 = 0,
stickers: []i32 = &.{},
decorations: []i32 = &.{},
frame: i32 = 0,

pub fn toProto(comp: @This()) pb.MotorDiyEquippedPb {
    return .{
        .SkinEquipped = comp.skin,
        .StickerEquipped = sliceToArrayList(i32, comp.stickers),
        .DecorationsEquipped = sliceToArrayList(i32, comp.decorations),
        .FrameEquipped = comp.frame,
    };
}
