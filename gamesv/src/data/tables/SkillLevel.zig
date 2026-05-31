const IntMap = @import("int_map.zig").IntMap;

Id: i32,
SkillLevelGroupId: i32,
SkillId: i32,
LevelNewDescribe: []const u8,
Consume: IntMap(i32, i32),
Condition: i32,
