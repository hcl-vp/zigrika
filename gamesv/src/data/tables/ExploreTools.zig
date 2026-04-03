const IntMap = @import("int_map.zig").IntMap;

PhantomSkillId: i32,
SkillType: i32,
SortId: i32,
AutoFill: bool,
ShowUnlock: bool,
SkillGroupId: i32,
IsUseInPhantomTeam: bool,
SummonConfigId: i32,
Authorization: IntMap(i32, i32),
