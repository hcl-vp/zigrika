const IntMap = @import("int_map.zig").IntMap;
const PropValue = @import("PropValue.zig");

Id: i32,
SkillId: i32,
NodeIndex: i32,
NodeGroup: i32,
NodeType: i32,
Consume: IntMap(i32, i32),
Condition: []const i32,
UnLockCondition: i32,
Property: []const PropValue,
