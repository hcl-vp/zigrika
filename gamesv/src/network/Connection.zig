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
const RawPacket = @import("../network.zig").RawPacket;
const ConnectionHandle = @import("../network.zig").ConnectionHandle;
const SessionManager = @import("../network.zig").SessionManager;
const PlayerComponentStorage = @import("../logic/component/player/PlayerComponentStorage.zig");

kcp: *Kcp,
session_key: ?[32]u8 = null,
seq: u32 = 0,

const session_idle_timeout_ms = 60_000;
const send_failure_limit = 3;

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
    try io.sleep(.fromMilliseconds(sleep_ms), .awake);
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

fn drainTimedLogicForSession(state: *State) bool {
    var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
    const timed_changed = state.timers.timed_logic.drainDue(
        state.io,
        state.scene != null,
        &event_queue,
    ) catch |err| failed: {
        std.log.scoped(.connection).err("failed to schedule timed logic tick: {t}", .{err});
        break :failed false;
    };
    if (timed_changed) logic_handlers.drainEventQueueBestEffort(&event_queue, state);
    _ = state.arena.reset(.free_all);

    return timed_changed;
}

fn nextSessionWakeDelayMs(
    handle: *ConnectionHandle,
    kcp: *const Kcp,
    state: ?*const State,
    init_time_ms: i64,
    last_receive_time_ms: i64,
) i64 {
    const now_ms = Io.Clock.awake.now(handle.io).toMilliseconds();
    const idle_delay_ms = @max(session_idle_timeout_ms - (now_ms - last_receive_time_ms), 0);
    const elapsed_ms: u32 = @intCast(now_ms - init_time_ms);
    var delay_ms: i64 = kcp.nextUpdateDelay(elapsed_ms);
    delay_ms = @min(delay_ms, idle_delay_ms);

    if (state) |s| {
        if (s.timers.timed_logic.nextWakeDelayMs(s.io, s.scene != null)) |timed_delay_ms| {
            delay_ms = @min(delay_ms, timed_delay_ms);
        }
    }

    return delay_ms;
}

fn updateKcpForSession(handle: *ConnectionHandle, kcp: *Kcp, elapsed_ms: u32) !void {
    try kcp.update(elapsed_ms);
    if (kcp.isDead()) return error.KcpDeadLink;
    if (handle.consecutive_send_failures >= send_failure_limit) return error.SendFailed;
}

fn flushKcpForSession(handle: *ConnectionHandle, kcp: *Kcp) !void {
    try kcp.flush();
    if (kcp.isDead()) return error.KcpDeadLink;
    if (handle.consecutive_send_failures >= send_failure_limit) return error.SendFailed;
}

pub fn process(
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
) void {
    const log = std.log.scoped(.connection);

    const clock: Io.Clock = .awake;
    const init_time = clock.now(handle.io).toMilliseconds();

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
    var claimed_player_id: ?i32 = null;
    defer if (claimed_player_id) |id| session_manager.release(handle, id);

    var state: ?State = null;
    defer if (state) |*s| s.deinit(fs);

    var last_receive_time_ms = init_time;

    while (true) {
        const state_ptr: ?*const State = if (state) |*s| s else null;
        const wake = waitSessionWake(
            handle,
            nextSessionWakeDelayMs(handle, &kcp, state_ptr, init_time, last_receive_time_ms),
        ) orelse break;

        var needs_flush = false;
        var kcp_updated = false;

        if (wake.packet) |packet| {
            const time = clock.now(handle.io);
            const elapsed_ms: u32 = @intCast(time.toMilliseconds() - init_time);
            needs_flush = true;

            _ = kcp.input(packet.buf[0..packet.len]) catch |err| {
                log.err("failed to input data into kcp state: {t}, disconnecting", .{err});
                return;
            };
            last_receive_time_ms = time.toMilliseconds();

            updateKcpForSession(handle, &kcp, elapsed_ms) catch |err| {
                log.err("failed to update kcp state: {t}, disconnecting", .{err});
                return;
            };
            kcp_updated = true;

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
                            session_manager.acquire(gpa, handle, id) catch |err| {
                                log.err("failed to acquire player session: {t}, disconnecting", .{err});
                                return;
                            };
                            claimed_player_id = id;

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
        }

        const now_ms = clock.now(handle.io).toMilliseconds();
        if (now_ms - last_receive_time_ms >= session_idle_timeout_ms) {
            log.info("session timed out after {d} ms without input", .{session_idle_timeout_ms});
            return;
        }

        if (wake.tick and !kcp_updated) {
            updateKcpForSession(handle, &kcp, @intCast(now_ms - init_time)) catch |err| {
                log.err("failed to update kcp state: {t}, disconnecting", .{err});
                return;
            };
        }

        if (state) |*s| {
            if (s.timers.timed_logic.shouldDrain(s.scene != null, now_ms)) {
                needs_flush = drainTimedLogicForSession(s) or needs_flush;
            }
        }

        if (needs_flush) {
            flushKcpForSession(handle, &kcp) catch |err| {
                log.err("failed to flush kcp state: {t}, disconnecting", .{err});
                return;
            };
        }
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
    if (handle.socket.send(handle.io, &handle.address, buf)) {
        handle.consecutive_send_failures = 0;
        return buf.len;
    } else |err| {
        handle.consecutive_send_failures +|= 1;
        std.log.debug(
            "send failed, conv: {d}, end_point: {f}, data_len: {d}, error: {t}",
            .{ kcp.conv, handle.address, buf.len, err },
        );
        return 0;
    }
}
