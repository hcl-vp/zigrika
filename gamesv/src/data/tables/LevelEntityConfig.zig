const Components = @import("entity_components/Components.zig");

pub const Vector = struct {
    X: f32,
    Y: f32,
    Z: f32,
};

Id: i32,
EntityId: i64,
BlueprintType: []const u8,
InSleep: bool,
IsHidden: bool,
MapId: i32,
AreaId: i32,
Transform: []Vector,
ComponentsData: Components,
