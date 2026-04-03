const Message = @This();
const std = @import("std");
const proto = @import("proto");
const encryption = @import("encryption.zig");
const Io = std.Io;
const Crc32 = std.hash.Crc32;
const Allocator = std.mem.Allocator;

header: Header,
payload: []u8,

pub const Type = enum(u8) {
    request = 1,
    response = 2,
    push = 4,
};

pub const Header = union(Type) {
    request: Request,
    response: Response,
    push: Push,

    pub const Request = struct {
        seq_no: u32,
        rpc_id: u16,
        msg_id: u16,
    };

    pub const Response = struct {
        seq_no: u32,
        rpc_id: u16,
        msg_id: u16,
    };

    pub const Push = struct {
        seq_no: u32,
        msg_id: u16,
    };

    fn decode(reader: *Io.Reader) !Header {
        return switch (try reader.takeEnum(Type, .little)) {
            .request => .{ .request = .{
                .seq_no = try reader.takeInt(u32, .little),
                .rpc_id = try reader.takeInt(u16, .little),
                .msg_id = try reader.takeInt(u16, .little),
            } },
            .response => .{ .response = .{
                .seq_no = try reader.takeInt(u32, .little),
                .rpc_id = try reader.takeInt(u16, .little),
                .msg_id = try reader.takeInt(u16, .little),
            } },
            .push => .{ .push = .{
                .seq_no = try reader.takeInt(u32, .little),
                .msg_id = try reader.takeInt(u16, .little),
            } },
        };
    }

    fn encode(h: Header, writer: *Io.Writer) !void {
        switch (h) {
            inline else => |header, tag| {
                try writer.writeByte(@intFromEnum(tag));
                inline for (comptime std.meta.fields(@TypeOf(header))) |field| {
                    try writer.writeInt(field.type, @field(header, field.name), .little);
                }
            },
        }
    }

    pub fn getSeqNo(header: Header) u32 {
        return switch (header) {
            inline else => |h| h.seq_no,
        };
    }

    pub fn getMessageId(header: Header) u32 {
        return switch (header) {
            inline else => |h| h.msg_id,
        };
    }
};

pub fn decode(reader: *Io.Reader) !Message {
    return .{
        .header = try .decode(reader),
        .payload = blk: {
            const checksum = try reader.takeInt(u32, .little);
            const payload = reader.buffer[0..reader.end][reader.seek..];
            var hashing = Io.Writer.Hashing(Crc32).initHasher(.init(), "");
            _ = reader.streamRemaining(&hashing.writer) catch unreachable;

            if (hashing.hasher.final() != checksum) return error.ChecksumMismatch;

            break :blk payload;
        },
    };
}

pub fn decrypt(message: *Message, key: [32]u8) void {
    message.payload.len = encryption.aesDecrypt(message.payload, key, message.payload);
    const seq_no = switch (message.header) {
        inline else => |header| header.seq_no,
    };

    if (message.payload.len != 0) {
        message.payload[seq_no % message.payload.len] ^= key[seq_no % 32];
    }
}

pub fn encodeAlloc(header: Header, message: anytype, gpa: Allocator, key: ?[32]u8) ![]u8 {
    var allocating = Io.Writer.Allocating.init(gpa);
    defer allocating.deinit();

    const w = &allocating.writer;
    try w.writeInt(u24, 0, .little);
    try header.encode(w);

    const crc_index = allocating.written().len;
    try w.writeInt(u32, 0, .little); // checksum

    var hashed = Io.Writer.Hashed(Crc32).initHasher(&allocating.writer, .init(), "");
    const writer = &hashed.writer;

    if (key) |k| {
        var counter = Io.Writer.Discarding.init("");
        proto.encodeMessage(&counter.writer, message, proto.pb_desc) catch unreachable;

        const buffer: []u8 = gpa.alloc(u8, encryption.EcbWriter.suggestBufferSize(counter.fullCount())) catch "";
        defer gpa.free(buffer);

        var ew = encryption.EcbWriter.init(k, writer, header.getSeqNo(), counter.fullCount(), buffer);
        try proto.encodeMessage(&ew.interface, message, proto.pb_desc);
        try ew.interface.flush();
        try ew.finish();
    } else {
        try proto.encodeMessage(writer, message, proto.pb_desc);
    }

    const buffer = try allocating.toOwnedSlice();
    std.mem.writeInt(u24, buffer[0..3], @truncate(buffer.len - 3), .little);
    std.mem.writeInt(u32, buffer[crc_index..][0..4], hashed.hasher.final(), .little);

    return buffer;
}

pub const Queue = struct {
    expected_len: ?usize = null,
    accumulator: Io.Writer.Allocating,

    pub fn init(gpa: Allocator) Queue {
        return .{ .accumulator = .init(gpa) };
    }

    pub fn deinit(queue: *Queue) void {
        queue.accumulator.deinit();
    }

    pub fn fill(queue: *Queue, reader: *Io.Reader) !void {
        if (queue.expected_len == null) {
            queue.accumulator.clearRetainingCapacity();
            queue.expected_len = reader.takeInt(u24, .little) catch return;
        }

        const limit: Io.Limit = .limited(queue.expected_len.? - queue.accumulator.written().len);
        _ = try reader.stream(&queue.accumulator.writer, limit);
    }

    pub fn take(queue: *Queue) !?Message {
        const buffer = queue.accumulator.written();
        if (buffer.len != queue.expected_len) return null;
        queue.expected_len = null;

        var reader = Io.Reader.fixed(buffer);
        return try Message.decode(&reader);
    }
};
