const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Alloc = struct {
    gpa: Allocator,
    arena: Allocator,
};

pub fn FixedBuffer(comptime size: usize) type {
    return struct {
        buf: [size]u8,
        len: usize,
    };
}
