const Components = @import("pb_components/Components.zig");

pub const Vector = struct {
    X: f32 = 0,
    Y: f32 = 0,
    Z: f32 = 0,
};

Id: i32 = 0,
EntityId: i64 = 0,
BlueprintType: []const u8 = &.{},
InSleep: bool = false,
IsHidden: bool = false,
MapId: i32 = 0,
AreaId: i32 = 0,
Transform: []Vector = &.{},
ComponentsData: Components = Components{},
