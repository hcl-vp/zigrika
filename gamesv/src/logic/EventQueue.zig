const EventQueue = @This();
const std = @import("std");
const Allocator = std.mem.Allocator;

arena: Allocator,
deque: std.Deque(Event) = .empty,

pub fn Dequeue(comptime t: std.meta.Tag(Event)) type {
    return struct {
        pub const dequeue_event_tag = t;
        data: *const @FieldType(Event, @tagName(t)),
    };
}

pub fn enqueue(
    queue: *EventQueue,
    comptime t: std.meta.Tag(Event),
    e: @FieldType(Event, @tagName(t)),
) !void {
    try queue.deque.pushBack(
        queue.arena,
        @unionInit(Event, @tagName(t), e),
    );
}

pub const Event = blk: {
    const events = @import("events.zig");
    var type_names: []const []const u8 = &.{};

    for (std.meta.declarations(events)) |d| {
        const declaration = @field(events, d.name);
        if (@TypeOf(declaration) != type) continue;
        if (std.meta.activeTag(@typeInfo(declaration)) == .@"struct") {
            type_names = type_names ++ .{d.name};
        }
    }

    var types: [type_names.len]type = undefined;
    var indices: [type_names.len]u16 = undefined;
    var enum_names: [type_names.len][]const u8 = undefined;
    for (type_names, 0..) |name, i| {
        indices[i] = i;
        types[i] = @field(events, name);
        enum_names[i] = toSnakeCase(name);
    }

    const EventTag = @Enum(u16, .exhaustive, &enum_names, &indices);
    break :blk @Union(.auto, EventTag, &enum_names, &types, &@splat(.{}));
};

inline fn toSnakeCase(comptime name: []const u8) []const u8 {
    var result: []const u8 = "";

    for (name, 0..) |c, i| {
        if (std.ascii.isUpper(c)) {
            if (i != 0) result = result ++ "_";
            result = result ++ .{std.ascii.toLower(c)};
        } else result = result ++ .{c};
    }

    return result;
}
