const Component = @This();
const pb = @import("proto").pb;

player_entity_id: i64 = 0,
summon_config_id: i32 = 0,

pub fn toProto(comp: Component) !pb.FollowShooterComponentPb {
    return .{
        .PlayerEntityId = comp.player_entity_id,
        .SummonConfigId = comp.summon_config_id,
    };
}
