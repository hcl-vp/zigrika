const std = @import("std");
const DataTables = @import("../../data/DataTables.zig");

const fnv_prime: u32 = 16_777_619;
const max_parent_depth = 32;

pub fn contains(
    parents: *const DataTables.GameplayTagParentTable,
    actual_id: i64,
    expected_id: i64,
) bool {
    const actual = std.math.cast(i32, actual_id) orelse return false;
    const expected = std.math.cast(i32, expected_id) orelse return false;
    if (actual == expected) return true;

    var current = actual;
    for (0..max_parent_depth) |_| {
        const parent = (parents.getDataById(current) orelse return false).ParentId;
        if (parent == 0) return false;
        if (parent == expected) return true;
        if (parent == current) return false;
        current = parent;
    }

    return false;
}

pub fn idFromName(name: []const u8) !i32 {
    const view = try std.unicode.Utf8View.init(name);
    var iterator = view.iterator();
    var hash: u32 = 0;

    while (iterator.nextCodepoint()) |codepoint| {
        if (codepoint <= 0xFFFF) {
            mixCodeUnit(&hash, @intCast(codepoint));
            continue;
        }

        const value: u21 = codepoint - 0x10000;
        mixCodeUnit(&hash, @intCast(0xD800 + (value >> 10)));
        mixCodeUnit(&hash, @intCast(0xDC00 + (value & 0x3FF)));
    }

    return @bitCast(hash);
}

fn mixCodeUnit(hash: *u32, code_unit: u16) void {
    hash.* = (hash.* ^ code_unit) *% fnv_prime;
}
