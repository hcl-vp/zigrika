const std = @import("std");

pub const default_state_machine = "SM_RoleBeHit";

Id: i32,
StateMachineName: []const u8,

pub fn stateMachineName(config: ?@This()) []const u8 {
    return if (config) |entry| entry.StateMachineName else default_state_machine;
}

test "role be-hit state machine uses mapped override with generic fallback" {
    const mapped: @This() = .{
        .Id = 1210,
        .StateMachineName = "SM_BeHit_Aimisi",
    };

    try std.testing.expectEqualStrings("SM_BeHit_Aimisi", stateMachineName(mapped));
    try std.testing.expectEqualStrings(default_state_machine, stateMachineName(null));
}
