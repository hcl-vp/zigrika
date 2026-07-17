const std = @import("std");

const fnv_prime: u32 = 16_777_619;

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

test "gameplay tag hashes match client fixtures" {
    try std.testing.expectEqual(
        @as(i32, -1276461747),
        try idFromName("\u{602a}\u{7269}.common.\u{5173}\u{5361}.\u{96be}\u{5ea6}AI\u{5206}\u{7c7b}.\u{5267}\u{60c5}"),
    );
    try std.testing.expectEqual(
        @as(i32, 1639442014),
        try idFromName("\u{602a}\u{7269}.common.\u{5173}\u{5361}.\u{96be}\u{5ea6}AI\u{5206}\u{7c7b}.\u{9886}\u{4e3b}\u{590d}\u{5237}"),
    );
    try std.testing.expectEqual(
        @as(i32, -1462667236),
        try idFromName("\u{602a}\u{7269}.common.\u{5173}\u{5361}.\u{751f}\u{6001}.\u{901a}\u{7528}.\u{7761}\u{89c9}"),
    );
}

test "gameplay tag hashing uses UTF-16 surrogate pairs" {
    try std.testing.expectEqual(@as(i32, -637552684), try idFromName("A\u{1F600}B"));
}
