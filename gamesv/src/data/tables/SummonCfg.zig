Id: i32,
BlueprintType: []const u8,
BornBuffId: []const i64,

pub fn getConcomCount(role_id: i32) ?usize {
    const count_override = [_][2]usize{
        .{ 1105, 3 },
        .{ 1301, 4 },
    };
    for (count_override) |entry| {
        if (entry[0] == role_id) return entry[1];
    }
    return null;
}
