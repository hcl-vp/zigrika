pub const default_state_machine = "SM_RoleBeHit";

Id: i32,
StateMachineName: []const u8,

pub fn stateMachineName(config: ?@This()) []const u8 {
    return if (config) |entry| entry.StateMachineName else default_state_machine;
}
