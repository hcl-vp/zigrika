const InventoryInfo = @This();
const std = @import("std");
const pb = @import("proto").pb;

const Allocator = std.mem.Allocator;

pub const default: InventoryInfo = .{};
pub const data_path = "inventory_info";

pub const NormalItem = struct {
    id: i32,
    count: i32 = 1,
};

normal_items: []NormalItem = &.{},

pub fn normalItemList(info: InventoryInfo, arena: Allocator) !std.ArrayList(pb.NormalItem) {
    var list: std.ArrayList(pb.NormalItem) = .empty;
    try list.ensureTotalCapacity(arena, info.normal_items.len);
    for (info.normal_items) |item| {
        if (item.id == 0 or item.count <= 0) continue;
        list.appendAssumeCapacity(.{ .Id = item.id, .Count = item.count, .ExpireTime = 0 });
    }
    return list;
}

pub fn normalItemCount(info: InventoryInfo, id: i32) i32 {
    for (info.normal_items) |item| {
        if (item.id == id) return item.count;
    }
    return 0;
}

pub fn addNormalItem(info: *InventoryInfo, gpa: Allocator, id: i32, count: i32) !void {
    if (count <= 0) return;

    for (info.normal_items) |*item| {
        if (item.id == id) {
            item.count += count;
            return;
        }
    }

    const new_items = try gpa.alloc(NormalItem, info.normal_items.len + 1);
    @memcpy(new_items[0..info.normal_items.len], info.normal_items);
    new_items[info.normal_items.len] = .{ .id = id, .count = count };

    if (info.normal_items.len != 0) gpa.free(info.normal_items);
    info.normal_items = new_items;
}

pub fn removeNormalItem(info: *InventoryInfo, gpa: Allocator, id: i32) !bool {
    for (info.normal_items, 0..) |item, index| {
        if (item.id != id) continue;

        const new_items = try gpa.alloc(NormalItem, info.normal_items.len - 1);
        @memcpy(new_items[0..index], info.normal_items[0..index]);
        @memcpy(new_items[index..], info.normal_items[index + 1 ..]);

        if (info.normal_items.len != 0) gpa.free(info.normal_items);
        info.normal_items = new_items;
        return true;
    }

    return false;
}

pub fn consumeNormalItem(info: *InventoryInfo, gpa: Allocator, id: i32, count: i32) !bool {
    if (count <= 0) return true;

    for (info.normal_items) |*item| {
        if (item.id != id) continue;
        if (item.count < count) return false;
        if (item.count == count) return removeNormalItem(info, gpa, id);
        item.count -= count;
        return true;
    }

    return false;
}

pub fn isEmpty(info: InventoryInfo) bool {
    return info.normal_items.len == 0;
}

pub fn deinit(info: InventoryInfo, gpa: Allocator) void {
    std.zon.parse.free(gpa, info);
}
