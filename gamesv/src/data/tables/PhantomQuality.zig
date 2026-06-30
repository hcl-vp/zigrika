const IntMap = @import("int_map.zig").IntMap;

Quality: i32,
LevelLimit: i32,
SlotUnlockLevel: []const i32,
IdentifyCost: IntMap(i32, i32),
