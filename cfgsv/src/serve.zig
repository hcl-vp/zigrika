const std = @import("std");
const encryption = @import("encryption.zig");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const FileSystem = @import("common").FileSystem;

const aes_key_size: usize = 32;
const aes_iv_size: usize = 16;

pub fn processConnection(gpa: Allocator, io: Io, fs: *FileSystem, stream: Io.net.Stream) void {
    const log = std.log.scoped(.clients);
    defer stream.close(io);

    log.debug("new connection from {f}", .{stream.socket.address});
    defer log.debug("connection from {f} disconnected", .{stream.socket.address});

    var read_buffer: [1024]u8 = undefined;
    var reader = stream.reader(io, read_buffer[0..]);

    var write_buffer: [1024]u8 = undefined;
    var writer = stream.writer(io, write_buffer[0..]);

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    serveRequest(arena.allocator(), fs, &reader.interface, &writer.interface) catch |err| if (err != error.Canceled) {
        log.err("failed to serve request for {f}: {t}", .{ stream.socket.address, err });
    };
}

fn serveRequest(
    arena: Allocator,
    fs: *FileSystem,
    reader: *Io.Reader,
    writer: *Io.Writer,
) !void {
    const log = std.log.scoped(.serve);
    const request = try Request.read(reader);

    var response: ?Response = null;
    defer if (response) |rsp| rsp.write(writer) catch {};

    if (!std.mem.eql(u8, request.method, "GET")) {
        response = .method_not_allowed;
        return;
    }

    log.info("request: {s}", .{request.path});

    if (request.path.len == 0 or std.mem.startsWith(u8, request.path, "//") or std.mem.containsAtLeast(u8, request.path, 1, "../"))
        return error.InvalidPathRequested;

    const full_path = try std.fmt.allocPrint(arena, "cfg/index/{s}", .{request.path[1..]});
    const content = try fs.readFile(arena, full_path) orelse {
        log.warn("requested file not found: {s}", .{request.path[1..]});
        response = .not_found;
        return;
    };

    var aes_key: [aes_key_size]u8 = undefined;
    var aes_iv: [aes_iv_size]u8 = undefined;
    try readAesParameters(fs, aes_key[0..], aes_iv[0..]);

    const Cipher = encryption.CBC(std.crypto.core.aes.Aes256);
    const encrypted_content = try arena.alloc(u8, Cipher.paddedLength(content.len));

    var cipher = Cipher.init(aes_key);
    cipher.encrypt(encrypted_content, content, aes_iv[0..]);

    const body = try std.fmt.allocPrint(arena, "{b64}", .{encrypted_content});

    response = .{
        .status = .OK,
        .headers = &.{
            .{ .type = .@"Content-Length", .value = .{ .int = body.len } },
            .{ .type = .@"Content-Type", .value = .{ .str = "application/json" } },
        },
        .body = body,
    };
}

const Request = struct {
    method: []const u8,
    path: []const u8,
    query: []const u8,

    pub fn read(reader: *Io.Reader) !Request {
        const request_line = try reader.takeDelimiterInclusive('\r');
        var fixed_reader = Io.Reader.fixed(request_line[0 .. request_line.len - 1]);

        return try Request.parse(&fixed_reader);
    }

    fn parse(reader: *Io.Reader) !Request {
        const method = try reader.takeDelimiter(' ') orelse return error.NoDelimiter;
        const path_and_query = try reader.takeDelimiter(' ') orelse return error.NoDelimiter;

        const path, const query = if (std.mem.findScalar(u8, path_and_query, '?')) |query_begin|
            .{ path_and_query[0..query_begin], path_and_query[query_begin + 1 ..] }
        else
            .{ path_and_query, "" };

        return .{ .method = method, .path = path, .query = query };
    }
};

const Response = struct {
    pub const not_found: Response = .{ .status = .@"Not Found" };
    pub const method_not_allowed: Response = .{ .status = .@"Method Not Allowed" };

    pub const Status = enum(u16) {
        OK = 200,
        @"Not Found" = 404,
        @"Method Not Allowed" = 405,
    };

    status: Status,
    headers: []const Header = &.{},
    body: []const u8 = "",

    pub fn write(response: Response, writer: *Io.Writer) !void {
        try writer.print("HTTP/1.1 {d} {t}\r\n", .{ response.status, response.status });
        for (response.headers) |header| {
            try writer.print("{t}: {f}\r\n", .{ header.type, header.value });
        }

        try writer.writeAll("\r\n");
        try writer.writeAll(response.body);
        try writer.flush();
    }
};

pub const Header = struct {
    type: Type,
    value: union(enum) {
        int: usize,
        str: []const u8,

        pub fn format(v: @This(), w: *Io.Writer) !void {
            switch (v) {
                .int => |int| try w.print("{d}", .{int}),
                .str => |str| try w.print("{s}", .{str}),
            }
        }
    },

    pub const Type = enum {
        @"Content-Length",
        Connection,
        @"Content-Type",
    };
};

fn readAesParameters(fs: *FileSystem, key: *[aes_key_size]u8, iv: *[aes_iv_size]u8) !void {
    const Decoder = std.base64.standard.Decoder;
    const Encoder = std.base64.standard.Encoder;
    const FBA = std.heap.FixedBufferAllocator;

    // allocators provide only the expected amount of memory.
    // this means that a failed fs.readFile would imply that the file was of invalid length.
    var key_buf: [Encoder.calcSize(aes_key_size) + 1]u8 = undefined;
    var iv_buf: [Encoder.calcSize(aes_iv_size) + 1]u8 = undefined;
    var key_fba = FBA.init(key_buf[0..]);
    var iv_fba = FBA.init(iv_buf[0..]);

    const key_b64 = (fs.readFile(key_fba.allocator(), "cfg/key") catch return error.InvalidIvFile) orelse return error.KeyFileNotExist;
    const key_len = Decoder.calcSizeForSlice(key_b64) catch return error.InvalidKeyFile;
    if (key_len != aes_key_size) return error.InvalidKeyFile;
    Decoder.decode(key, key_b64) catch return error.InvalidKeyFile;

    const iv_b64 = (fs.readFile(iv_fba.allocator(), "cfg/iv") catch return error.InvalidIvFile) orelse return error.IvFileNotExist;
    const iv_len = Decoder.calcSizeForSlice(iv_b64) catch return error.InvalidIvFile;
    if (iv_len != aes_iv_size) return error.InvalidIvFile;
    Decoder.decode(iv, iv_b64) catch return error.InvalidIvFile;
}
