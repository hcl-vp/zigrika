pub const pb = @import("pb.zig");
pub const pb_desc = @import("aki_generated.zig");
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const WireType = enum(u32) {
    var_int = 0,
    int64 = 1,
    length_prefixed = 2,
    int32 = 5,

    pub fn of(comptime T: type) WireType {
        if (T == []const u8) return .length_prefixed;

        return switch (@typeInfo(T)) {
            .int, .bool, .@"enum" => .var_int,
            .float => |float| return switch (float.bits) {
                32 => .int32,
                64 => .int64,
                else => @compileError("only f32 and f64 are supported"),
            },
            .optional, .pointer => |container| of(container.child),
            .@"struct" => .length_prefixed,
            else => @compileError("unsupported type: " ++ @typeName(T)),
        };
    }
};

pub fn encodeMessage(w: *Io.Writer, message: anytype, comptime desc_namespace: type) anyerror!void {
    const Message = @TypeOf(message);
    const message_name = @typeName(Message)[3..];
    const message_desc = blk: {
        if (!@hasDecl(desc_namespace, message_name)) {
            if (@hasDecl(Message, "map_entry")) break :blk Message else return;
        } else break :blk @field(desc_namespace, message_name);
    };

    inline for (@typeInfo(Message).@"struct".fields) |field| {
        if (comptime oneofUnion(field.type)) |_| {
            if (@field(message, field.name)) |oneof| {
                switch (oneof) {
                    inline else => |value, tag| {
                        if (@hasDecl(message_desc, @tagName(tag) ++ "_field_number")) {
                            try encodeField(w, value, @field(message_desc, @tagName(tag) ++ "_field_number"), desc_namespace);
                        }
                    },
                }
            }
        } else if (@hasDecl(message_desc, field.name ++ "_field_number")) {
            try encodeField(w, @field(message, field.name), @field(message_desc, field.name ++ "_field_number"), desc_namespace);
        }
    }
}

fn oneofUnion(comptime T: type) ?std.builtin.Type.Union {
    return switch (@typeInfo(T)) {
        .optional => |optional| switch (@typeInfo(optional.child)) {
            .@"union" => |u| u,
            else => null,
        },
        else => null,
    };
}

pub fn encodingLength(message: anytype, comptime desc_namespace: type) usize {
    var prober = Io.Writer.Discarding.init("");
    encodeMessage(&prober.writer, message, desc_namespace) catch unreachable;
    return prober.fullCount();
}

fn shouldEncodeField(value: anytype) bool {
    const Value = @TypeOf(value);
    if (Repeated(Value)) |_| {
        return value.items.len != 0;
    } else if (Optional(Value)) |_| {
        return value != null;
    } else {
        if (Value == []const u8) return value.len != 0 else switch (@typeInfo(Value)) {
            .int => return value != 0,
            .bool => return value,
            .float => return value != 0,
            .@"enum" => return @as(i32, @intFromEnum(value)) != 0,
            .@"struct" => return true,
            else => @compileError("unsupported type: " ++ @typeName(Value)),
        }
    }
}

fn encodeField(w: *Io.Writer, value: anytype, comptime number: u32, comptime desc_namespace: type) anyerror!void {
    const Value = @TypeOf(value);
    if (Repeated(Value)) |_| {
        for (value.items) |item| try encodeField(w, item, number, desc_namespace);
    } else if (Optional(Value)) |_| {
        if (value) |item| try encodeField(w, item, number, desc_namespace);
    } else if (comptime @typeInfo(Value) == .pointer and Value != []const u8) {
        try encodeField(w, value.*, number, desc_namespace);
    } else {
        try writeVarInt(w, comptime wireTag(number, .of(Value)));
        if (Value == []const u8) try writeBytes(w, value) else switch (@typeInfo(Value)) {
            .int => try writeVarInt(w, value),
            .bool => try writeVarInt(w, @as(u8, if (value) 1 else 0)),
            .float => |float| {
                const BackingInt = if (float.bits == 32) u32 else if (float.bits == 64) u64 else @compileError("encountered invalid float type: " ++ @typeName(Value));
                try w.writeInt(BackingInt, @bitCast(value), .little);
            },
            .@"enum" => try writeVarInt(w, @intFromEnum(value)),
            .@"struct" => {
                try writeVarInt(w, encodingLength(value, desc_namespace));
                try encodeMessage(w, value, desc_namespace);
            },
            else => @compileError("unsupported type: " ++ @typeName(Value)),
        }
    }
}

fn writeBytes(w: *Io.Writer, bytes: []const u8) !void {
    try writeVarInt(w, bytes.len);
    try w.writeAll(bytes);
}

fn Repeated(comptime T: type) ?type {
    return switch (@typeInfo(T)) {
        .@"struct" => if (@hasField(T, "items")) switch (@typeInfo(@FieldType(T, "items"))) {
            .pointer => |pointer| if (T == std.ArrayList(pointer.child)) return pointer.child else null,
            else => null,
        } else null,
        else => null,
    };
}

fn Optional(comptime T: type) ?type {
    return switch (@typeInfo(T)) {
        .optional => |optional| optional.child,
        else => null,
    };
}

inline fn wireTag(comptime field_number: u32, comptime wire_type: WireType) u32 {
    return (field_number << 3) | @intFromEnum(wire_type);
}

fn writeVarInt(w: *Io.Writer, value: anytype) !void {
    var v = value;
    while (v >= 0x80) : (v >>= 7) {
        try w.writeByte(@intCast(0x80 | (v & 0x7F)));
    } else try w.writeByte(@intCast(v & 0x7F));
}

pub fn decodeMessage(r: *Io.Reader, allocator: Allocator, comptime Message: type, comptime desc_namespace: type) !Message {
    @setEvalBranchQuota(100_000_000);

    const message_name = @typeName(Message)[3..];
    const message_desc = blk: {
        if (!@hasDecl(desc_namespace, message_name)) {
            if (@hasDecl(Message, "map_entry")) break :blk Message else return;
        } else break :blk @field(desc_namespace, message_name);
    };

    comptime var field_names: []const []const u8 = &.{};
    comptime var oneofs: []const []const u8 = &.{};

    inline for (comptime std.meta.fields(Message)) |field| {
        if (@hasDecl(message_desc, field.name ++ "_field_number")) {
            field_names = field_names ++ .{field.name};
        } else if (comptime oneofUnion(field.type) != null) {
            oneofs = oneofs ++ .{field.name};
            inline for (comptime std.meta.fields(std.meta.Child(field.type))) |oneof_field| {
                if (@hasDecl(message_desc, oneof_field.name ++ "_field_number")) {
                    field_names = field_names ++ .{oneof_field.name};
                }
            }
        }
    }

    if (field_names.len == 0) return Message.default;

    const FieldEnum = comptime blk: {
        var field_numbers: [field_names.len]u32 = @splat(0);
        for (field_names, 0..) |name, i| {
            field_numbers[i] = @field(message_desc, name ++ "_field_number");
        }

        break :blk @Enum(u32, .exhaustive, field_names, &field_numbers);
    };

    const has_fields = comptime std.meta.fields(FieldEnum).len != 0;
    var message = Message.default;
    while (readVarInt(r, u32) catch null) |wire_tag| {
        const wire_type = std.enums.fromInt(WireType, wire_tag & 7) orelse return error.InvalidWireType;
        if (!has_fields) {
            try skipField(r, wire_type);
            continue;
        }

        const field_variant = std.enums.fromInt(FieldEnum, wire_tag >> 3) orelse {
            try skipField(r, wire_type);
            continue;
        };

        if (has_fields) {
            switch (field_variant) {
                inline else => |variant| {
                    const field_name = @tagName(variant);
                    if (@hasField(Message, field_name) and comptime oneofUnion(@FieldType(Message, field_name)) == null) {
                        const field = comptime std.meta.fieldInfo(Message, std.meta.stringToEnum(std.meta.FieldEnum(Message), field_name).?);

                        if (comptime Repeated(field.type) != null) {
                            const Child = std.meta.Child(field.type.Slice);
                            if ((comptime WireType.of(Child) != .length_prefixed) and wire_type == .length_prefixed) {
                                const length = try readVarInt(r, usize); // packed list of scalar values
                                var reader = Io.Reader.fixed(try r.take(length));
                                while (decodeField(&reader, allocator, Child, .of(Child), desc_namespace) catch null) |value|
                                    try @field(message, field.name).append(allocator, value);
                            } else {
                                const item = try decodeField(r, allocator, Child, wire_type, desc_namespace);
                                try @field(message, field.name).append(allocator, item);
                            }
                        } else {
                            @field(message, field.name) = try decodeField(r, allocator, field.type, wire_type, desc_namespace);
                        }
                    } else inline for (oneofs) |oneof_name| {
                        const Oneof = std.meta.Child(@FieldType(Message, oneof_name));
                        if (!@hasField(Oneof, field_name)) continue;

                        const field = comptime std.meta.fieldInfo(Oneof, std.meta.stringToEnum(std.meta.FieldEnum(Oneof), field_name).?);
                        @field(message, oneof_name) = @unionInit(Oneof, field_name, try decodeField(r, allocator, field.type, wire_type, desc_namespace));
                    }
                },
            }
        }
    }

    return message;
}

fn decodeField(r: *Io.Reader, allocator: Allocator, comptime T: type, wire_type: WireType, comptime desc_namespace: type) !T {
    if (comptime Optional(T) != null)
        return try decodeField(r, allocator, std.meta.Child(T), wire_type, desc_namespace)
    else if (T == []const u8)
        return try r.readAlloc(allocator, try readVarInt(r, usize))
    else switch (@typeInfo(T)) {
        .int => return try readVarInt(r, T),
        .bool => return (try readVarInt(r, u8)) != 0,
        .float => |float| {
            const BackingInt = if (float.bits == 32) u32 else if (float.bits == 64) u64 else @compileError("encountered invalid float type: " ++ @typeName(T));
            return @bitCast(try r.takeInt(BackingInt, .little));
        },
        .@"enum" => return std.enums.fromInt(T, try readVarInt(r, i32)) orelse @enumFromInt(0),
        .@"struct" => {
            var reader = Io.Reader.fixed(try r.take(try readVarInt(r, usize)));
            return try decodeMessage(&reader, allocator, T, desc_namespace);
        },
        else => @compileError("unsupported type: " ++ @typeName(T)),
    }
}

fn readVarInt(r: *Io.Reader, comptime T: type) !T {
    const int = @typeInfo(T).int;
    var shift: std.math.Log2Int(u64) = 0;
    var result: u64 = 0;

    while (true) : (shift += 7) {
        const byte = try r.takeByte();
        result |= @as(u64, byte & 0x7F) << shift;
        if ((byte & 0x80) != 0x80) return switch (int.signedness) {
            .unsigned => @truncate(result),
            .signed => @bitCast(@as(@Int(.unsigned, int.bits), @truncate(result))),
        };

        if (shift >= @bitSizeOf(u64) - 7) return error.MalformedProtobuf;
    }
}

fn skipField(r: *Io.Reader, wire_type: WireType) !void {
    switch (wire_type) {
        .var_int => _ = try readVarInt(r, u64),
        .int32 => try r.discardAll(4),
        .int64 => try r.discardAll(8),
        .length_prefixed => {
            const length = try readVarInt(r, usize);
            try r.discardAll(length);
        },
    }
}
