const Connection = @This();
const std = @import("std");
const proto = @import("proto");
const common = @import("common");
const auth = @import("handlers/auth.zig");
const net_handlers = @import("handlers.zig");
const logic_handlers = @import("../logic/handlers.zig");

const Io = std.Io;
const Kcp = @import("kcp.zig").Kcp;
const State = @import("State.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;
const Message = @import("Message.zig");
const Assets = @import("../data/Assets.zig");
const EventQueue = @import("../logic/EventQueue.zig");
const TimedLogicScheduler = @import("../logic/TimedLogicScheduler.zig");
const RawPacket = @import("../network.zig").RawPacket;
const ConnectionHandle = @import("../network.zig").ConnectionHandle;
const PlayerComponentStorage = @import("../logic/component/player/PlayerComponentStorage.zig");

kcp: *Kcp,
session_key: ?[32]u8 = null,
seq: u32 = 0,

const request_response_table = blk: {
    @setEvalBranchQuota(100_000);

    const request_suffix = "Request";
    var table: [std.math.maxInt(u16)]?u16 = @splat(null);

    for (std.meta.declarations(proto.pb_desc)) |decl| {
        if (@hasDecl(@field(proto.pb_desc, decl.name), "msg_id")) {
            if (std.mem.endsWith(u8, decl.name, request_suffix)) {
                const response_name = decl.name[0 .. decl.name.len - request_suffix.len] ++ "Response";
                if (@hasDecl(proto.pb_desc, response_name)) {
                    if (@hasDecl(@field(proto.pb_desc, response_name), "msg_id")) {
                        table[@field(proto.pb_desc, decl.name).msg_id] = @field(proto.pb_desc, response_name).msg_id;
                    }
                }
            }
        }
    }

    break :blk table;
};

const msg_id_name_table = blk: {
    @setEvalBranchQuota(100_000);

    var table: [std.math.maxInt(u16)]?[]const u8 = @splat(null);

    for (std.meta.declarations(proto.pb_desc)) |decl| {
        if (@hasDecl(@field(proto.pb_desc, decl.name), "msg_id")) {
            table[@field(proto.pb_desc, decl.name).msg_id] = decl.name;
        }
    }

    break :blk table;
};

const SessionWake = struct {
    packet: ?RawPacket = null,
    tick: bool = false,
    closed: bool = false,
};

const SessionSelectResult = union(enum) {
    packet: anyerror!RawPacket,
    tick: anyerror!void,
};

fn waitForPacket(handle: *ConnectionHandle) anyerror!RawPacket {
    return handle.queue.getOne(handle.io);
}

fn waitForTimedTick(io: Io, delay_ms: i64) anyerror!void {
    const sleep_ms = if (delay_ms > 0) delay_ms else 0;
    try io.sleep(.fromMilliseconds(sleep_ms), .real);
}

fn applySessionSelectResult(wake: *SessionWake, result: SessionSelectResult) void {
    switch (result) {
        .packet => |packet_result| {
            wake.packet = packet_result catch |err| switch (err) {
                error.Canceled => return,
                error.Closed => {
                    wake.closed = true;
                    return;
                },
                else => {
                    wake.closed = true;
                    return;
                },
            };
        },
        .tick => |tick_result| {
            tick_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.tick = true;
        },
    }
}

fn waitSessionWake(handle: *ConnectionHandle, tick_delay_ms: ?i64) ?SessionWake {
    const delay_ms = tick_delay_ms orelse {
        return .{ .packet = handle.queue.getOne(handle.io) catch return null };
    };

    var buffer: [2]SessionSelectResult = undefined;
    var select: Io.Select(SessionSelectResult) = .init(handle.io, &buffer);

    select.async(.packet, waitForPacket, .{handle});
    select.async(.tick, waitForTimedTick, .{ handle.io, delay_ms });

    const first = select.await() catch {
        select.cancelDiscard();
        return null;
    };

    var wake: SessionWake = .{};
    applySessionSelectResult(&wake, first);
    while (select.cancel()) |extra| {
        applySessionSelectResult(&wake, extra);
    }

    return if (wake.closed) null else wake;
}

fn drainTimedLogicForSession(state: *State, kcp: *Kcp, io: Io, init_time: i64) !bool {
    const log = std.log.scoped(.connection);
    const rtc: Io.Clock = .real;
    const time = rtc.now(io);

    try kcp.update(@intCast(time.toMilliseconds() - init_time));

    const timed_changed = TimedLogicScheduler.drainDue(state) catch |err| failed: {
        log.err("failed to execute timed logic tick: {t}", .{err});
        break :failed false;
    };
    _ = state.arena.reset(.free_all);

    return timed_changed;
}

pub fn process(handle: *ConnectionHandle, gpa: Allocator, fs: *FileSystem, assets: *const Assets) void {
    const log = std.log.scoped(.connection);

    const rtc: Io.Clock = .real;
    const init_time = rtc.now(handle.io).toMilliseconds();

    var kcp = Kcp.init(gpa, handle.conv_id, @intFromPtr(handle)) catch |err| {
        log.err("failed to initialize kcp instance: {t}", .{err});
        return;
    };

    defer kcp.deinit();

    kcp.setOutput(kcpOutput);

    var read_buffer = gpa.alloc(u8, 16384) catch {
        log.err("failed to allocate read buffer, disconnecting", .{});
        return;
    };

    defer gpa.free(read_buffer);

    var message_queue: Message.Queue = .init(gpa);
    defer message_queue.deinit();

    var connection: Connection = .{ .kcp = &kcp };

    var player_id: ?i32 = null;
    var enter: bool = false;
    var state: ?State = null;
    defer if (state) |*s| s.deinit(fs);

    // TODO: timeout
    while (waitSessionWake(handle, if (state) |*s| TimedLogicScheduler.nextWakeDelayMs(s) else null)) |wake| {
        var needs_flush = false;
        var timed_logic_checked = false;

        if (wake.packet) |packet| {
            const time = rtc.now(handle.io);
            needs_flush = true;

            _ = kcp.input(packet.buf[0..packet.len]) catch |err| {
                log.err("failed to input data into kcp state: {t}, disconnecting", .{err});
                return;
            };

            kcp.update(@intCast(time.toMilliseconds() - init_time)) catch |err| {
                log.err("failed to update kcp state: {t}, disconnecting", .{err});
                return;
            };

            while (kcp.peekSize()) |size| {
                if (size > read_buffer.len) {
                    // TODO: realloc, max allowed size check
                    log.err("received too big packet, length: {d}", .{size});
                    return;
                }

                _ = kcp.recv(read_buffer[0..size], false) catch unreachable;
                var reader = Io.Reader.fixed(read_buffer[0..size]);
                while (true) : (if (state) |*s| {
                    _ = s.arena.reset(.free_all);
                }) {
                    message_queue.fill(&reader) catch |err| {
                        log.err("failed to fill message queue: {t}, disconnecting", .{err});
                        return;
                    };

                    var message = message_queue.take() catch |err| {
                        log.err("failed to take message from queue: {t}, disconnecting", .{err});
                        return;
                    } orelse break; // queue is empty

                    if (connection.session_key) |key| message.decrypt(key);

                    if (state) |*s| {
                        net_handlers.dispatchMessage(s, message) catch |err| switch (err) {
                            error.HandlerNotFound => {
                                if (std.meta.activeTag(message.header) == .request) {
                                    if (request_response_table[message.header.getMessageId()]) |response_id| {
                                        const header: Message.Header.Response = .{
                                            .seq_no = connection.nextSeqNo(),
                                            .rpc_id = message.header.request.rpc_id,
                                            .msg_id = response_id,
                                        };

                                        if (Message.encodeAlloc(
                                            .{ .response = header },
                                            proto.pb.HeartbeatResponse{},
                                            s.arena.allocator(),
                                            connection.session_key,
                                        )) |data| _ = connection.kcp.send(data) catch {} else |_| {}
                                    }
                                }

                                const msg_id = message.header.getMessageId();
                                if (msg_id_name_table[msg_id]) |name| {
                                    log.warn("no handler for {s} (msg_id: {d})", .{ name, msg_id });
                                } else {
                                    log.warn("no handler for unknown message (msg_id: {d})", .{msg_id});
                                }
                            },
                        };
                    } else {
                        auth.handleAuthGroupRequest(message, &connection, fs, gpa, &player_id, &enter) catch |err| {
                            log.err("failed to handle auth request: {t}, disconnecting", .{err});
                            return;
                        };

                        if (enter) if (player_id) |id| { // Auth step finished. Initialize the state.
                            const player_components = PlayerComponentStorage.init(gpa, fs, assets, id) catch |err| {
                                log.err("failed to init player component storage: {t}, disconnecting", .{err});
                                return;
                            };

                            state = .init(gpa, handle.io, fs, &connection, assets, player_components, id);

                            var event_queue: EventQueue = .{ .arena = state.?.arena.allocator() };
                            event_queue.enqueue(.enter_game, .{}) catch |err| {
                                log.err("failed to enqueue enter game event: {t}, disconnecting", .{err});
                                return;
                            };

                            logic_handlers.drainEventQueue(&event_queue, &state.?) catch |err| {
                                log.err("failed to execute initial event chain: {t}, disconnecting", .{err});
                                return;
                            };
                        };
                    }
                }
            } else |_| {} // EAGAIN behavior

            if (state) |*s| {
                const now_ms = rtc.now(handle.io).toMilliseconds();
                if (TimedLogicScheduler.shouldDrain(s, now_ms)) {
                    const timed_changed = drainTimedLogicForSession(s, &kcp, handle.io, init_time) catch |err| {
                        log.err("failed to update kcp state: {t}, disconnecting", .{err});
                        return;
                    };
                    needs_flush = timed_changed or needs_flush;
                    timed_logic_checked = true;
                }
            }
        }

        if (wake.tick and !timed_logic_checked) {
            needs_flush = true;

            if (state) |*s| {
                const timed_changed = drainTimedLogicForSession(s, &kcp, handle.io, init_time) catch |err| {
                    log.err("failed to update kcp state: {t}, disconnecting", .{err});
                    return;
                };
                needs_flush = timed_changed or needs_flush;
            }
        }

        if (needs_flush) kcp.flush() catch {};
    }
}

pub fn nextSeqNo(conn: *Connection) u32 {
    conn.seq += 1;
    return conn.seq;
}

pub fn push(conn: *Connection, message: anytype, arena: Allocator) !void {
    const name = @typeName(@TypeOf(message))[3..];
    if (!@hasDecl(proto.pb_desc, name)) return;

    const header: Message.Header.Push = .{
        .seq_no = conn.nextSeqNo(),
        .msg_id = @field(proto.pb_desc, name).msg_id,
    };

    _ = try conn.kcp.send(try Message.encodeAlloc(
        .{ .push = header },
        message,
        arena,
        conn.session_key,
    ));
}

fn kcpOutput(buf: []const u8, kcp: *Kcp, user: ?usize) usize {
    const handle: *ConnectionHandle = @ptrFromInt(user.?);
    if (handle.socket.send(handle.io, &handle.address, buf)) return buf.len else |err| {
        std.log.debug(
            "send failed, conv: {d}, end_point: {f}, data_len: {d}, error: {t}",
            .{ kcp.conv, handle.address, buf.len, err },
        );
        return 0;
    }
}
