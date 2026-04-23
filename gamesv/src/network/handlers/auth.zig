const std = @import("std");
const proto = @import("proto");
const encryption = @import("../encryption.zig");

const Io = std.Io;
const pb = proto.pb;
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const Message = @import("../Message.zig");
const Connection = @import("../Connection.zig");
const Account = @import("../../fs/Account.zig");
const FileSystem = @import("common").FileSystem;

const proto_key_type: i32 = 2;

pub fn handleAuthGroupRequest(message: Message, conn: *Connection, fs: *FileSystem, gpa: Allocator, player_id: *?i32, enter: *bool) !void {
    if (std.meta.activeTag(message.header) != .request) return error.InvalidMessageType;
    const auth_message_type = std.enums.fromInt(AuthMessageType, message.header.request.msg_id) orelse return error.UnexpectedMessageId;

    switch (auth_message_type) {
        inline else => |msg| {
            inline for (comptime std.meta.declarations(@This())) |decl| {
                switch (@typeInfo(@TypeOf(@field(@This(), decl.name)))) {
                    .@"fn" => |f| {
                        if (f.params.len != 3) continue;
                        const Context = f.params[0].type.?;
                        if (!@hasDecl(Context, "Request")) continue;

                        if (comptime !std.mem.eql(u8, @tagName(msg), @typeName(Context.Request)[3..])) continue;

                        var arena = ArenaAllocator.init(gpa);
                        defer arena.deinit();

                        var reader = Io.Reader.fixed(message.payload);
                        const request = try proto.decodeMessage(&reader, arena.allocator(), Context.Request, proto.pb_desc);

                        try @field(@This(), decl.name)(.{
                            .rpc_id = message.header.request.rpc_id,
                            .request = request,
                            .conn = conn,
                            .player_id = player_id,
                            .enter = enter,
                        }, arena.allocator(), fs);
                    },
                    else => {},
                }
            }
        },
    }
}

const AuthMessageType = blk: {
    var names: []const []const u8 = &.{};

    for (std.meta.declarations(@This())) |decl| {
        switch (@typeInfo(@TypeOf(@field(@This(), decl.name)))) {
            .@"fn" => |f| {
                if (f.params.len != 3) continue;
                const Context = f.params[0].type.?;

                if (!@hasDecl(Context, "Request")) continue;

                names = names ++ .{@typeName(Context.Request)[3..]};
            },
            else => {},
        }
    }

    var msg_ids: [names.len]u16 = @splat(0);
    for (names, 0..) |name, i| {
        msg_ids[i] = @field(proto.pb_desc, name).msg_id;
    }

    break :blk @Enum(u16, .exhaustive, names, &msg_ids);
};

fn AuthContext(comptime R: type) type {
    return struct {
        pub const Request = R;

        rpc_id: u16,
        request: Request,
        conn: *Connection,
        player_id: *?i32,
        enter: *bool,

        pub fn respond(ac: @This(), response: anytype, arena: Allocator) !void {
            const name = @typeName(@TypeOf(response))[3..];
            if (!@hasDecl(proto.pb_desc, name)) return;

            const header: Message.Header.Response = .{
                .rpc_id = ac.rpc_id,
                .seq_no = ac.conn.nextSeqNo(),
                .msg_id = @field(proto.pb_desc, name).msg_id,
            };

            _ = try ac.conn.kcp.send(try Message.encodeAlloc(
                .{ .response = header },
                response,
                arena,
                ac.conn.session_key,
            ));
        }
    };
}

pub fn handleProtoKeyRequest(ac: AuthContext(pb.ProtoKeyRequest), arena: Allocator, fs: *FileSystem) !void {
    const log = std.log.scoped(.proto_key);
    log.debug("request: {}", .{ac.request});

    var session_key: [32]u8 = undefined;
    Io.random(fs.io, &session_key);

    const public_key_der = try fs.readFile(arena, "gateway/client_public_key.der") orelse return error.NoClientPublicKey;

    var encrypted_key: [encryption.pkcsv1_5_padded_size]u8 = undefined;
    try encryption.rsaEncrypt(public_key_der, session_key[0..], encrypted_key[0..], fs.io);

    try ac.respond(pb.ProtoKeyResponse{
        .Type = proto_key_type,
        .Key = encrypted_key[0..],
    }, arena);

    ac.conn.session_key = session_key;
}

pub fn handleLoginRequest(ac: AuthContext(pb.LoginRequest), arena: Allocator, fs: *FileSystem) !void {
    const log = std.log.scoped(.login);
    log.debug("request: {}", .{ac.request});

    const account = try Account.loadOrCreate(arena, fs, ac.request.Account);
    ac.player_id.* = account.player_id;

    try ac.respond(pb.LoginResponse{
        .Timestamp = Io.Clock.real.now(fs.io).toMilliseconds(),
    }, arena);
}

pub fn handleEnterGameRequest(ac: AuthContext(pb.EnterGameRequest), arena: Allocator, fs: *FileSystem) !void {
    const log = std.log.scoped(.enter_game);
    log.debug("request: {}", .{ac.request});

    _ = fs;
    ac.enter.* = true; // switch state
    try ac.respond(pb.EnterGameResponse{}, arena);
}
