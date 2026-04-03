const std = @import("std");
const pb = @import("proto").pb;
const Transaction = @import("../handlers.zig").Transaction;
const mem = @import("../../mem.zig");
const State = @import("../State.zig");

const log = std.log.scoped(.combat);

const combat_namespaces: []const type = &.{
    @import("role.zig"),
};

pub fn CombatRequestTxn(comptime Tag: anytype) type {
    const MessageUnion = @FieldType(pb.CombatRequestData, "Message");
    const RequestUnion = @FieldType(MessageUnion, @tagName(Tag));
    const req_name = @tagName(Tag);
    const resp_tag_name = req_name[0 .. req_name.len - "Request".len] ++ "Response";

    return struct {
        pub const RequestPayload = RequestUnion;
        pub const ResponseTag = resp_tag_name;

        common: ?pb.CombatCommon,
        request_id: i32,
        payload: RequestPayload,
        response: ?pb.CombatResponseData = null,

        pub fn respond(self: *@This(), msg: anytype) void {
            const ResponseMessageUnion = @typeInfo(@FieldType(pb.CombatResponseData, "Message")).optional.child;
            const ResponsePayload = @typeInfo(@FieldType(ResponseMessageUnion, resp_tag_name)).optional.child;

            var payload: ResponsePayload = std.mem.zeroes(ResponsePayload);
            inline for (comptime std.meta.fields(@TypeOf(msg))) |field| {
                @field(payload, field.name) = @field(msg, field.name);
            }

            self.response = .{
                .CombatCommon = self.common,
                .RequestId = self.request_id,
                .Message = @unionInit(
                    ResponseMessageUnion,
                    resp_tag_name,
                    payload,
                ),
            };
        }
    };
}

pub fn dispatch(
    comptime DataType: type,
    data: DataType,
    state: *State,
) !?pb.CombatReceiveData {
    const is_request = DataType == pb.CombatRequestData;

    const msg = data.Message orelse return null;

    switch (msg) {
        inline else => |payload, tag| {
            const inner = payload orelse return null;

            const handler = comptime blk: {
                for (combat_namespaces) |ns| {
                    if (@hasDecl(ns, @tagName(tag))) break :blk @field(ns, @tagName(tag));
                }
                break :blk {};
            };

            if (comptime @TypeOf(handler) == void) {
                log.warn("unhandled combat message: {s}", .{@tagName(tag)});
                return null;
            }

            log.debug("handling combat message: {s}", .{@tagName(tag)});

            const target_fn = comptime handler;
            const Args = std.meta.ArgsTuple(@TypeOf(target_fn));
            var args: Args = undefined;

            if (comptime is_request) {
                var txn: CombatRequestTxn(tag) = .{
                    .common = data.CombatCommon,
                    .request_id = data.RequestId,
                    .payload = inner,
                };
                args[0] = &txn;

                inline for (comptime std.meta.fields(Args)[1..], 1..) |param, i| {
                    args[i] = try state.extract(param.type);
                }

                try @call(.auto, target_fn, args);

                if (txn.response) |resp| {
                    return .{ .Message = .{ .CombatResponseData = resp } };
                }
            } else {
                args[0] = inner;

                inline for (comptime std.meta.fields(Args)[1..], 1..) |param, i| {
                    args[i] = try state.extract(param.type);
                }

                try @call(.auto, target_fn, args);
            }

            return null;
        },
    }
}

pub fn onCombatSendPackRequest(txn: *Transaction(pb.CombatSendPackRequest), state: *State) !void {
    var receive_data_pack: std.ArrayList(pb.CombatReceiveData) = .empty;

    for (txn.message.Data.items) |message| {
        const inner = message.Message orelse continue;
        switch (inner) {
            .Push => |maybe_push| {
                const push = maybe_push orelse continue;
                _ = try dispatch(pb.CombatPushData, push, state);
            },
            .Request => |maybe_req| {
                const req = maybe_req orelse continue;
                if (try dispatch(pb.CombatRequestData, req, state)) |response| {
                    try receive_data_pack.append(state.arena.allocator(), response);
                }
            },
        }
    }

    try txn.respond(.{ .ReceivePackNotify = .{ .Data = receive_data_pack } });
}
