const std = @import("std");

const State = @import("../network/State.zig");
const EventQueue = @import("EventQueue.zig");

pub const namespaces: []const type = &.{
    @import("commands/entity.zig"),
    @import("commands/echo.zig"),
    @import("commands/help.zig"),
    @import("commands/photo.zig"),
    @import("commands/battle.zig"),
    @import("commands/attribute.zig"),
    @import("commands/map.zig"),
    @import("commands/flow.zig"),
    @import("commands/js_patches.zig"),
};

fn parseArg(comptime T: type, s: []const u8) !T {
    return switch (@typeInfo(T)) {
        .int => std.fmt.parseInt(T, s, 10),
        .float => std.fmt.parseFloat(T, s),
        .bool => if (std.mem.eql(u8, s, "true") or std.mem.eql(u8, s, "1"))
            true
        else if (std.mem.eql(u8, s, "false") or std.mem.eql(u8, s, "0"))
            false
        else
            error.InvalidBool,
        .optional => |o| parseArg(o.child, s),
        .pointer => |p| if (p.child == u8 and p.size == .slice)
            s
        else
            @compileError("unsupported pointer type: " ++ @typeName(T)),
        else => @compileError("unsupported arg type: " ++ @typeName(T)),
    };
}

pub fn dispatch(state: *State, events: *EventQueue, input: []const u8) !void {
    var commands = std.mem.splitScalar(u8, input, ';');
    while (commands.next()) |command| {
        var tokens: [64][]const u8 = undefined;
        var token_count: usize = 0;
        var split_iter = std.mem.splitScalar(u8, std.mem.trim(u8, command, " "), ' ');
        while (split_iter.next()) |tok| {
            if (tok.len == 0) continue;
            tokens[token_count] = tok;
            token_count += 1;
        }
        if (token_count == 0) return error.EmptyInput;

        const fn_name = tokens[0];
        const arg_tokens = tokens[1..token_count];

        // TODO: improve this and other error handling above
        var found = false;
        inline for (namespaces) |namespace| {
            inline for (comptime std.meta.declarations(namespace)) |decl| {
                const item = @field(namespace, decl.name);
                const func = blk: {
                    if (@typeInfo(@TypeOf(item)) == .@"fn") break :blk item;
                    if (@TypeOf(item) == type and
                        @typeInfo(item) == .@"struct" and
                        @hasDecl(item, "call")) break :blk item.call;
                    continue;
                };

                if (std.mem.eql(u8, decl.name, fn_name) or (@hasDecl(item, "alias") and std.mem.eql(u8, item.alias, fn_name))) {
                    const Fn = @TypeOf(func);
                    const params = comptime std.meta.fields(std.meta.ArgsTuple(Fn));

                    comptime var required_count = 0;
                    comptime var optional_count = 0;
                    inline for (params) |param| {
                        switch (@typeInfo(param.type)) {
                            .int, .float, .bool => required_count += 1,
                            .optional => optional_count += 1,
                            .pointer => |p| if (p.child == u8 and p.size == .slice) {
                                required_count += 1;
                            },
                            else => {},
                        }
                    }
                    if (arg_tokens.len < required_count or arg_tokens.len > required_count + optional_count)
                        return error.ArgCountMismatch;

                    var args: std.meta.ArgsTuple(Fn) = undefined;
                    var parse_i: usize = 0;
                    inline for (params, 0..) |param, i| {
                        switch (@typeInfo(param.type)) {
                            .int, .float, .bool => {
                                args[i] = try parseArg(param.type, arg_tokens[parse_i]);
                                parse_i += 1;
                            },
                            .optional => {
                                args[i] = if (parse_i < arg_tokens.len) blk: {
                                    const val = try parseArg(@typeInfo(param.type).optional.child, arg_tokens[parse_i]);
                                    parse_i += 1;
                                    break :blk val;
                                } else null;
                            },
                            .pointer => |p| if (p.child == u8 and p.size == .slice) {
                                args[i] = try parseArg(param.type, arg_tokens[parse_i]);
                                parse_i += 1;
                            } else if (param.type == *EventQueue) {
                                args[i] = events;
                            } else {
                                args[i] = try state.extract(param.type);
                            },
                            else => {
                                args[i] = try state.extract(param.type);
                            },
                        }
                    }

                    try @call(.auto, func, args);
                    found = true;
                }
            }
        }
        if (!found) return error.UnknownFunction;
    }
}

pub fn respond(events: *EventQueue, alloc: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    const msg = try std.fmt.allocPrint(alloc, fmt, args);
    errdefer alloc.free(msg);
    try events.enqueue(.chat_command_response, .{ .content = msg });
}
