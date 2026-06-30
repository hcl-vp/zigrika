const IntMap = @import("int_map.zig").IntMap;

Level: i32,
LevelUpExp: i32,
LevelUpCondition: i32,
TempCatchGain: i32,
LowCostTempCatchGain: i32,
IntensifyCaptureGuarantee: i32,
LowCostIntensifyCaptureGuarantee: i32,
Cost: i32,
RewardId: i32,
QualityDropWeight: IntMap(i32, i32),
