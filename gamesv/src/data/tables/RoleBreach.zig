const IntMap = @import("int_map.zig").IntMap;

Id: i32,
BreachGroupId: i32,
BreachLevel: i32,
MaxLevel: i32,
BreachConsume: IntMap(i32, i32),
BreachReward: i32,
ConditionId: i32,
