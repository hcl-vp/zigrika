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

test "gameplay tag hierarchy matches exact parent and ancestor tags" {
    const entries = [_]DataTables.GameplayTagParent{
        .{ .Id = 30, .ParentId = 20 },
        .{ .Id = 20, .ParentId = 10 },
        .{ .Id = 40, .ParentId = 10 },
    };
    var parents: DataTables.GameplayTagParentTable = .init;
    defer parents.index.deinit(std.testing.allocator);
    parents.items = &entries;
    for (entries, 0..) |entry, index| {
        try parents.index.put(std.testing.allocator, entry.Id, index);
    }

    try std.testing.expect(contains(&parents, 30, 30));
    try std.testing.expect(contains(&parents, 30, 20));
    try std.testing.expect(contains(&parents, 30, 10));
    try std.testing.expect(!contains(&parents, 30, 40));
    try std.testing.expect(!contains(&parents, 10, 30));
}

test "current fsm bind tag satisfies its parent condition" {
    const entries = [_]DataTables.GameplayTagParent{
        .{ .Id = 1_175_335_618, .ParentId = 1_146_758_956 },
    };
    var parents: DataTables.GameplayTagParentTable = .init;
    defer parents.index.deinit(std.testing.allocator);
    parents.items = &entries;
    try parents.index.put(std.testing.allocator, entries[0].Id, 0);

    try std.testing.expect(contains(&parents, 1_175_335_618, 1_146_758_956));
}
