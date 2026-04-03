const std = @import("std");
const Account = @import("fs/Account.zig");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const FileSystem = @import("common").FileSystem;

pub fn processConnection(
    gpa: Allocator,
    io: Io,
    fs: *FileSystem,
    gateway: struct { []const u8, u16 },
    stream: Io.net.Stream,
) void {
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

    serveRequest(arena.allocator(), fs, gateway, &reader.interface, &writer.interface) catch |err| if (err != error.Canceled) {
        log.err("failed to serve request for {f}: {t}", .{ stream.socket.address, err });
    };
}

pub const Path = enum {
    @"/health",
    @"/api/login",
};

fn serveRequest(
    arena: Allocator,
    fs: *FileSystem,
    gateway: struct { []const u8, u16 },
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

    const path = std.meta.stringToEnum(Path, request.path) orelse {
        log.warn("unhandled request path: {s}", .{request.path});
        response = .not_found;
        return;
    };

    switch (path) {
        .@"/health" => response = .{ .status = .OK },
        .@"/api/login" => {
            const parameters = parseQuery(LoginParameters, request.query) catch |err| {
                log.warn("bad request: {t}, query string: '{s}'", .{ err, request.query });
                response = .bad_request;
                return;
            };

            const result = login(arena, fs, gateway, parameters);

            var allocating = Io.Writer.Allocating.init(arena);
            try allocating.writer.print("{f}", .{std.json.fmt(result, .{ .emit_null_optional_fields = false })});
            const body = allocating.written();

            response = .{
                .status = .OK,
                .headers = &.{
                    .{ .type = .@"Content-Length", .value = .{ .int = body.len } },
                    .{ .type = .@"Content-Type", .value = .{ .str = "application/json" } },
                },
                .body = body,
            };
        },
    }
}

const LoginParameters = struct {
    loginType: u1,
    userId: []const u8,
    userName: []const u8,
    token: []const u8,
    userData: i32,
    deviceId: ?[]const u8,
    loginTraceId: ?[]const u8,
};

fn parseQuery(comptime Repr: type, query: []const u8) !Repr {
    const Parameter = std.meta.FieldEnum(Repr);
    var set_parameters: std.EnumSet(Parameter) = .{};
    var result: Repr = undefined;

    var params = std.mem.tokenizeScalar(u8, query, '&');
    while (params.next()) |param| {
        var pair = std.mem.splitScalar(u8, param, '=');
        const name = pair.next() orelse return error.MalformedQuery;
        const value = pair.next() orelse return error.MalformedQuery;
        if (pair.next() != null) return error.MalformedQuery;

        const parameter = std.meta.stringToEnum(Parameter, name) orelse return error.InvalidParameter;

        switch (parameter) {
            inline else => |p| {
                const P = @FieldType(Repr, @tagName(p));
                const T = if (comptime std.meta.activeTag(@typeInfo(P)) == .optional) std.meta.Child(P) else P;

                switch (@typeInfo(T)) {
                    .pointer => if (T == []const u8) {
                        @field(result, @tagName(p)) = value;
                    } else @compileError("invalid parameter type: " ++ @typeName(T)),
                    .int => @field(result, @tagName(p)) = std.fmt.parseInt(T, value, 10) catch return error.InvalidParameter,
                    else => @compileError("invalid parameter type: " ++ @typeName(T)),
                }

                set_parameters.insert(p);
            },
        }
    }

    inline for (comptime std.meta.fields(Repr), comptime std.meta.fields(Parameter)) |field, parameter| {
        if (!set_parameters.contains(@field(Parameter, parameter.name))) {
            if (comptime std.meta.activeTag(@typeInfo(field.type)) == .optional) {
                @field(result, field.name) = null;
            } else {
                return error.MissingParameters;
            }
        }
    }

    return result;
}

pub const ClientGatewayConfig = struct {
    host: []const u8,
    port: u16,
};

pub const LoginResult = struct {
    code: i32,
    hasRpc: bool,
    errMessage: ?[]const u8 = null,
    token: ?[]const u8 = null,
    udpHosts: ?[]const ClientGatewayConfig = null,
    userData: ?i32 = null,
    banTimeStamp: ?i64 = null,
    sex: ?i32 = null,

    pub fn err(code: i32, message: []const u8, user_data: i32) LoginResult {
        return .{
            .code = code,
            .errMessage = message,
            .userData = user_data,
            .hasRpc = true,
        };
    }
};

fn login(
    arena: Allocator,
    fs: *FileSystem,
    gateway: struct { []const u8, u16 },
    params: LoginParameters,
) LoginResult {
    const log = std.log.scoped(.login);
    log.debug(
        "request: loginType: {d}, userId: '{s}', userName: '{s}', token: '{s}', userData: {d}, deviceId: {?s}, loginTraceId: {?s}",
        .{ params.loginType, params.userId, params.userName, params.token, params.userData, params.deviceId, params.loginTraceId },
    );

    const account = Account.loadOrCreate(arena, fs, params.userId, params.userName, params.token) catch |err| switch (err) {
        error.TokenMismatch => {
            log.warn("login failed due to token mismatch for user with id: {s}", .{params.userId});
            return LoginResult.err(1, "Login Failed", params.userData);
        },
        else => {
            log.err("login failed due to an internal error: {t}", .{err});
            return LoginResult.err(-1, "Internal Server Error", params.userData);
        },
    };

    const host, const port = gateway;
    const udp_hosts = arena.dupe(ClientGatewayConfig, &.{.{ .host = host, .port = port }}) catch |err| {
        log.err("login failed due to an internal error: out {t}", .{err});
        return LoginResult.err(-1, "Internal Server Error", params.userData);
    };

    return .{
        .code = 0,
        .hasRpc = true,
        .token = account.token,
        .udpHosts = udp_hosts,
        .userData = params.userData,
        .sex = account.sex,
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
    pub const bad_request: Response = .{ .status = .@"Bad Request" };
    pub const not_found: Response = .{ .status = .@"Not Found" };
    pub const method_not_allowed: Response = .{ .status = .@"Method Not Allowed" };

    pub const Status = enum(u16) {
        OK = 200,
        @"Bad Request" = 400,
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
