const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");

summoner_id: i64 = 0,
summon_cfg_id: i32 = 0,
summon_skill_id: i32 = 0,
player_id: i32 = 0,
summon_type: pb.ESummonType = .ESummonTypeDefault,

pub fn toProto(comp: Component) !pb.SummonerComponentPb {
    return .{
        .SummonerId = comp.summoner_id,
        .SummonCfgId = comp.summon_cfg_id,
        .SummonSkillId = comp.summon_skill_id,
        .PlayerId = comp.player_id,
        .Type = comp.summon_type,
    };
}
