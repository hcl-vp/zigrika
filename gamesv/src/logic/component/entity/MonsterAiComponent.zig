const Component = @This();
const pb = @import("proto").pb;
const mem = @import("../../../mem.zig");

weapon_id: i32 = 0,
hatred_group_id: i64 = 0,
ai_team_init_id: i32 = 0,
combat_message_id: i64 = 0,

pub fn toProto(comp: Component) !pb.MonsterAiComponentPb {
    return .{
        .WeaponId = comp.weapon_id,
        .HatredGroupId = comp.hatred_group_id,
        .AiTeamInitId = comp.ai_team_init_id,
        .CombatMessageId = comp.combat_message_id,
    };
}
