const IntMap = @import("int_map.zig").IntMap;
const PropValue = @import("PropValue.zig");

Id: i32,
GroupId: i32,
GroupIndex: i32,
BuffIds: []const i64,
ActivateConsume: IntMap(i32, i32),
AddProp: []const PropValue,
