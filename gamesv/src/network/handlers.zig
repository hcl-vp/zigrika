const std = @import("std");
const proto = @import("proto");
const State = @import("State.zig");
const Message = @import("Message.zig");
const Connection = @import("Connection.zig");
const EventQueue = @import("../logic/EventQueue.zig");
const logic_handlers = @import("../logic/handlers.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;

const log = std.log.scoped(.net_handler);

const net_namespaces: []const type = &.{
    @import("handlers/player.zig"),
    @import("handlers/scene.zig"),
    @import("handlers/formation.zig"),
    @import("handlers/weapon.zig"),
    @import("handlers/guide.zig"),
    @import("handlers/adventure.zig"),
    @import("handlers/quest.zig"),
    @import("handlers/map.zig"),
    @import("handlers/teleport.zig"),
    @import("handlers/explore.zig"),
    @import("handlers/voxel.zig"),
    @import("handlers/settings.zig"),
    @import("handlers/mail.zig"),
    @import("handlers/access_path.zig"),
    @import("handlers/loading.zig"),
    @import("handlers/music.zig"),
    @import("handlers/direct_train.zig"),
    @import("handlers/lord_gym.zig"),
    @import("handlers/tower.zig"),
    @import("handlers/fishing.zig"),
    @import("handlers/combat.zig"),
    @import("handlers/role.zig"),
    @import("handlers/chat.zig"),
    @import("handlers/friend.zig"),
    @import("handlers/damage.zig"),
    // @import("handlers/activity.zig"), VERY BUGGY, DISABLED BY DEFAULT!!!
};

pub fn Transaction(comptime T: type) type {
    return struct {
        pub const MessagePB = T;

        pub const Response = blk: {
            const message_name = @typeName(T)[3..];
            if (!(std.mem.endsWith(u8, message_name, "Request"))) break :blk void;
            const response_name = message_name[0 .. message_name.len - 7] ++ "Response";
            if (!@hasDecl(proto.pb, response_name)) break :blk void;
            break :blk @field(proto.pb, response_name);
        };

        conn: *Connection,
        message: T,
        response: ?Response,

        pub fn respond(txn: *@This(), response: Response) !void {
            if (txn.response != null) return error.RespondTwice;
            txn.response = response;
        }
    };
}

pub const NetEventHandler = struct {
    namespace: type,
    Message: type,
    name: []const u8,

    pub inline fn invoke(
        comptime handler: NetEventHandler,
        state: *State,
        message: handler.Message,
        rpc_id: u16,
    ) !void {
        const Txn = Transaction(handler.Message);
        var txn: Txn = .{
            .conn = state.conn,
            .message = message,
            .response = null,
        };

        var event_queue: EventQueue = .{ .arena = state.arena.allocator() };

        const target_fn = @field(handler.namespace, handler.name);
        const Args = std.meta.ArgsTuple(@TypeOf(target_fn));

        var args: Args = undefined;
        args[0] = &txn;

        inline for (comptime std.meta.fields(Args)[1..], 1..) |param, i| {
            if (param.type == *EventQueue)
                args[i] = &event_queue
            else
                args[i] = try state.extract(param.type);
        }

        try @call(.auto, target_fn, args);

        try logic_handlers.drainEventQueue(&event_queue, state);

        if (Txn.Response != void) {
            if (txn.response) |response| {
                const name = @typeName(@TypeOf(response))[3..];
                if (!@hasDecl(proto.pb_desc, name)) return;

                const header: Message.Header.Response = .{
                    .rpc_id = rpc_id,
                    .seq_no = txn.conn.nextSeqNo(),
                    .msg_id = @field(proto.pb_desc, name).msg_id,
                };

                _ = try txn.conn.kcp.send(try Message.encodeAlloc(
                    .{ .response = header },
                    response,
                    state.arena.allocator(),
                    txn.conn.session_key,
                ));
            } else log.err("response of type {s} is not set", .{@typeName(Txn.Response)});
        }
    }
};

const MessageId = build_enum: {
    var msg_names: []const []const u8 = &.{};

    for (net_namespaces) |namespace| {
        for (std.meta.declarations(namespace)) |decl| {
            switch (@typeInfo(@TypeOf(@field(namespace, decl.name)))) {
                .@"fn" => |fn_info| {
                    if (fn_info.params.len == 0) continue;
                    const param_type = fn_info.params[0].type orelse continue;
                    if (@typeInfo(param_type) != .pointer) continue;
                    const Txn = @typeInfo(param_type).pointer.child;
                    if (!@hasDecl(Txn, "MessagePB")) continue;

                    const MessagePB = Txn.MessagePB;
                    const message_name = @typeName(MessagePB)[3..];
                    if (!@hasDecl(proto.pb_desc, message_name)) continue;

                    const message_desc = @field(proto.pb_desc, message_name);
                    if (!@hasDecl(message_desc, "msg_id")) continue;

                    msg_names = msg_names ++ .{message_name};
                },
                else => {},
            }
        }
    }

    var message_ids: [msg_names.len]u16 = undefined;
    for (msg_names, 0..) |name, i| {
        message_ids[i] = @field(proto.pb_desc, name).msg_id;
    }

    break :build_enum @Enum(u16, .exhaustive, msg_names, &message_ids);
};

pub fn dispatchMessage(
    state: *State,
    message: Message,
) !void {
    const message_id = std.enums.fromInt(MessageId, message.header.getMessageId()) orelse return error.HandlerNotFound;
    const rpc_id = switch (message.header) {
        .request => |request| request.rpc_id,
        else => 0,
    };

    switch (message_id) {
        inline else => |id| {
            const handler = getNetEventHandler(id);

            var reader = Io.Reader.fixed(message.payload);
            const msg = proto.decodeMessage(&reader, state.arena.allocator(), handler.Message, proto.pb_desc) catch |err| {
                log.err("failed to decode message of type {s}: {}", .{ @typeName(handler.Message), err });
                return;
            };

            handler.invoke(state, msg, rpc_id) catch |err| {
                log.err("failed to handle message of type {s}: {}", .{ @typeName(handler.Message), err });
                return;
            };

            log.debug("handled message of type {s}", .{@typeName(handler.Message)});
        },
    }
}

pub inline fn getNetEventHandler(comptime message_id: MessageId) NetEventHandler {
    @setEvalBranchQuota(100_000);

    inline for (net_namespaces) |namespace| {
        inline for (comptime std.meta.declarations(namespace)) |decl| {
            switch (@typeInfo(@TypeOf(@field(namespace, decl.name)))) {
                .@"fn" => |fn_info| {
                    if (fn_info.params.len == 0) continue;

                    const param_type = fn_info.params[0].type orelse continue;
                    if (@typeInfo(param_type) != .pointer) continue;
                    const Txn = @typeInfo(param_type).pointer.child;
                    if (!@hasDecl(Txn, "MessagePB")) continue;

                    const MessagePB = Txn.MessagePB;
                    const message_name = @typeName(MessagePB)[3..];
                    if (!@hasDecl(proto.pb_desc, message_name)) continue;

                    const message_desc = @field(proto.pb_desc, message_name);
                    if (!@hasDecl(message_desc, "msg_id")) continue;

                    const handler_message_id: MessageId = @enumFromInt(message_desc.msg_id);

                    if (message_id == handler_message_id) {
                        return .{
                            .namespace = namespace,
                            .Message = MessagePB,
                            .name = decl.name,
                        };
                    }
                },
                else => {},
            }
        }
    }
}
