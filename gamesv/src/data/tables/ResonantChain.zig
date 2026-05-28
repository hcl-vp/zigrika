const IntMap = @import("int_map.zig").IntMap;

Id: i32,
GroupId: i32,
GroupIndex: i32,
BuffIds: []const i64,
ActivateConsume: IntMap(i32, i32),
