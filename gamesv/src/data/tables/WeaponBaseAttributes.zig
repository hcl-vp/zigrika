const IntMap = @import("int_map.zig").IntMap;

ItemId: i32,
IsRatio: bool,
Attributes: []i32,
Values: IntMap(i32, i32),
