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
const OwnedFrame = @import("../network.zig").OwnedFrame;
const ConnectionHandle = @import("../network.zig").ConnectionHandle;
const SessionManager = @import("../network.zig").SessionManager;
const PlayerComponentStorage = @import("../logic/component/player/PlayerComponentStorage.zig");

io: Io,
gpa: Allocator,
outbound: *Io.Queue(OwnedFrame),
session_key: ?[32]u8 = null,
seq: u32 = 0,

const session_idle_timeout_ms = 60_000;
const send_failure_limit = 3;
const gameplay_event_limit = 64;
const gameplay_time_limit_ns = 2 * std.time.ns_per_ms;

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

const TransportWake = struct {
    packet_ready: ?RawPacket = null,
    application_ready: bool = false,
    outbound_ready: ?OwnedFrame = null,
    kcp_deadline: bool = false,
    idle_timeout: bool = false,
    closed: bool = false,
};

const TransportSelectResult = union(enum) {
    packet_ready: anyerror!RawPacket,
    application_ready: anyerror!void,
    outbound_ready: anyerror!OwnedFrame,
    kcp_deadline: anyerror!void,
    idle_timeout: anyerror!void,
    closed: anyerror!void,
};

const GameplayWake = struct {
    inbound_ready: ?OwnedFrame = null,
    message_ready: bool = false,
    gameplay_deadline: bool = false,
    closed: bool = false,
};

const GameplaySelectResult = union(enum) {
    inbound_ready: anyerror!OwnedFrame,
    message_ready: anyerror!void,
    gameplay_deadline: anyerror!void,
    closed: anyerror!void,
};

const InboundMessageReader = struct {
    buffer: []u8,
    start: usize = 0,
    end: usize = 0,
    messages: Message.Queue,

    fn init(gpa: Allocator, buffer: []u8) InboundMessageReader {
        return .{
            .buffer = buffer,
            .messages = .init(gpa),
        };
    }

    fn deinit(reader: *InboundMessageReader) void {
        reader.messages.deinit();
    }

    fn appendBytes(reader: *InboundMessageReader, bytes: []const u8) !void {
        try reader.prepareAppend(bytes.len);
        @memcpy(reader.buffer[reader.end..][0..bytes.len], bytes);
        reader.end += bytes.len;
    }

    fn consumeBuffered(reader: *InboundMessageReader) !?Message {
        if (reader.start == reader.end) return null;

        var input = Io.Reader.fixed(reader.buffer[reader.start..reader.end]);
        try reader.messages.fill(&input);
        reader.start += input.seek;
        if (reader.start == reader.end) {
            reader.start = 0;
            reader.end = 0;
        }
        return reader.messages.take();
    }

    fn hasCompleteBufferedMessage(reader: *InboundMessageReader) bool {
        const available = reader.end - reader.start;
        if (reader.messages.expected_len) |expected_len| {
            return reader.messages.accumulator.written().len + available >= expected_len;
        }
        if (available < 3) return false;

        const expected_len = std.mem.readInt(u24, reader.buffer[reader.start..][0..3], .little);
        return available - 3 >= expected_len;
    }

    fn prepareAppend(reader: *InboundMessageReader, additional_len: usize) !void {
        if (additional_len <= reader.buffer.len - reader.end) return;

        const remaining = reader.end - reader.start;
        if (reader.start != 0) {
            std.mem.copyForwards(u8, reader.buffer[0..remaining], reader.buffer[reader.start..reader.end]);
            reader.start = 0;
            reader.end = remaining;
        }
        if (additional_len > reader.buffer.len - reader.end) return error.MessageTooLarge;
    }
};

const GameplayBudget = struct {
    started_ns: i96,
    completed_events: usize = 0,

    fn init(started_ns: i96) GameplayBudget {
        return .{ .started_ns = started_ns };
    }

    fn canStart(budget: GameplayBudget, now_ns: i96) bool {
        if (budget.completed_events == 0) return true;
        return budget.completed_events < gameplay_event_limit and
            now_ns - budget.started_ns < gameplay_time_limit_ns;
    }

    fn complete(budget: *GameplayBudget) void {
        budget.completed_events += 1;
    }
};

fn waitForPacket(handle: *ConnectionHandle) anyerror!RawPacket {
    return handle.queue.getOne(handle.io);
}

fn waitForInbound(handle: *ConnectionHandle) anyerror!OwnedFrame {
    return handle.inbound.getOne(handle.io);
}

fn waitForOutbound(handle: *ConnectionHandle) anyerror!OwnedFrame {
    return handle.outbound.getOne(handle.io);
}

fn waitForDeadline(io: Io, delay_ms: i64) anyerror!void {
    const sleep_ms = if (delay_ms > 0) delay_ms else 0;
    try io.sleep(.fromMilliseconds(sleep_ms), .awake);
}

fn waitForClosed(handle: *ConnectionHandle) anyerror!void {
    try handle.closed_event.wait(handle.io);
}

fn applyTransportSelectResult(wake: *TransportWake, result: TransportSelectResult) void {
    switch (result) {
        .packet_ready => |packet_result| {
            wake.packet_ready = packet_result catch |err| switch (err) {
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
        .application_ready => |application_result| {
            application_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.application_ready = true;
        },
        .outbound_ready => |frame_result| {
            wake.outbound_ready = frame_result catch |err| switch (err) {
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
        .kcp_deadline => |deadline_result| {
            deadline_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.kcp_deadline = true;
        },
        .idle_timeout => |timeout_result| {
            timeout_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.idle_timeout = true;
        },
        .closed => |closed_result| {
            closed_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.closed = true;
        },
    }
}

fn waitTransportWake(
    handle: *ConnectionHandle,
    application_ready: bool,
    kcp_delay_ms: i64,
    idle_delay_ms: i64,
) ?TransportWake {
    var buffer: [6]TransportSelectResult = undefined;
    var select: Io.Select(TransportSelectResult) = .init(handle.io, &buffer);

    select.async(.packet_ready, waitForPacket, .{handle});
    if (application_ready) {
        select.async(.application_ready, waitForDeadline, .{ handle.io, 0 });
    }
    select.async(.outbound_ready, waitForOutbound, .{handle});
    select.async(.kcp_deadline, waitForDeadline, .{ handle.io, kcp_delay_ms });
    select.async(.idle_timeout, waitForDeadline, .{ handle.io, idle_delay_ms });
    select.async(.closed, waitForClosed, .{handle});

    const first = select.await() catch {
        select.cancelDiscard();
        return null;
    };

    var wake: TransportWake = .{};
    applyTransportSelectResult(&wake, first);
    while (select.cancel()) |extra| {
        applyTransportSelectResult(&wake, extra);
    }

    return wake;
}

fn applyGameplaySelectResult(wake: *GameplayWake, result: GameplaySelectResult) void {
    switch (result) {
        .inbound_ready => |frame_result| {
            wake.inbound_ready = frame_result catch |err| switch (err) {
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
        .message_ready => |message_result| {
            message_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.message_ready = true;
        },
        .gameplay_deadline => |deadline_result| {
            deadline_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.gameplay_deadline = true;
        },
        .closed => |closed_result| {
            closed_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.closed = true;
        },
    }
}

fn waitGameplayWake(
    handle: *ConnectionHandle,
    message_ready: bool,
    gameplay_delay_ms: ?i64,
) ?GameplayWake {
    var buffer: [4]GameplaySelectResult = undefined;
    var select: Io.Select(GameplaySelectResult) = .init(handle.io, &buffer);

    select.async(.inbound_ready, waitForInbound, .{handle});
    if (message_ready) {
        select.async(.message_ready, waitForDeadline, .{ handle.io, 0 });
    }
    if (gameplay_delay_ms) |delay_ms| {
        select.async(.gameplay_deadline, waitForDeadline, .{ handle.io, delay_ms });
    }
    select.async(.closed, waitForClosed, .{handle});

    const first = select.await() catch {
        select.cancelDiscard();
        return null;
    };

    var wake: GameplayWake = .{};
    applyGameplaySelectResult(&wake, first);
    while (select.cancel()) |extra| {
        applyGameplaySelectResult(&wake, extra);
    }

    return wake;
}

fn drainScheduledLogicForSession(state: *State, now_ms: i64) bool {
    const clock: Io.Clock = .awake;
    var budget = GameplayBudget.init(clock.now(state.io).toNanoseconds());
    var scheduled_changed = false;

    if (state.dirty_saves.isDue(now_ms) and budget.canStart(clock.now(state.io).toNanoseconds())) {
        var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
        if (state.dirty_saves.enqueueDue(&event_queue, now_ms)) |dirty_due| {
            if (dirty_due) {
                drainEventChain(state, &event_queue);
                budget.complete();
                scheduled_changed = true;
            }
        } else |err| {
            std.log.scoped(.connection).err("failed to schedule dirty save: {t}", .{err});
            _ = state.arena.reset(.free_all);
        }
    }

    if (state.scene) |*scene| {
        if (!budget.canStart(clock.now(state.io).toNanoseconds())) return scheduled_changed;

        state.timers.buffs.ensureInitialized(
            state.gpa,
            scene,
            state.assets,
            now_ms,
        ) catch |err| {
            std.log.scoped(.connection).err("failed to initialize buff timers: {t}", .{err});
            return scheduled_changed;
        };

        if (budget.canStart(clock.now(state.io).toNanoseconds())) {
            var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
            const timed_due = state.timers.timed_logic.drainDue(
                now_ms,
                true,
                &event_queue,
            ) catch |err| failed: {
                std.log.scoped(.connection).err("failed to schedule timed logic tick: {t}", .{err});
                break :failed false;
            };
            if (timed_due) {
                drainEventChain(state, &event_queue);
                budget.complete();
                scheduled_changed = true;
            } else {
                _ = state.arena.reset(.free_all);
            }
        }

        while (budget.canStart(clock.now(state.io).toNanoseconds()) and
            buffDeadlineDue(&state.timers.buffs, now_ms))
        {
            var event_queue: EventQueue = .{ .arena = state.arena.allocator() };
            event_queue.enqueue(.buff_timer_tick, .{ .now_ms = now_ms }) catch |err| {
                std.log.scoped(.connection).err("failed to continue buff timers: {t}", .{err});
                _ = state.arena.reset(.free_all);
                break;
            };
            drainEventChain(state, &event_queue);
            budget.complete();
            scheduled_changed = true;
        }
    }

    return scheduled_changed;
}

fn drainEventChain(state: *State, event_queue: *EventQueue) void {
    logic_handlers.drainEventQueueBestEffort(event_queue, state);
    _ = state.arena.reset(.free_all);
}

fn buffDeadlineDue(scheduler: *const @import("../logic/schedulers/BuffTimerScheduler.zig"), now_ms: i64) bool {
    const due_ms = scheduler.peekDueMs() orelse return false;
    return due_ms <= now_ms;
}

fn nextGameplayWakeDelayMs(state: ?*const State, now_ms: i64) ?i64 {
    const s = state orelse return null;
    return gameplayWakeDelayMs(
        s.timers.timed_logic.nextWakeDelayMs(now_ms, s.scene != null),
        s.dirty_saves.nextWakeDelayMs(now_ms),
        s.scene != null and buffDeadlineDue(&s.timers.buffs, now_ms),
    );
}

fn gameplayWakeDelayMs(timed_delay_ms: ?i64, dirty_delay_ms: ?i64, overdue_buffs: bool) ?i64 {
    if (overdue_buffs) return 0;
    if (dirty_delay_ms) |dirty_delay| {
        return if (timed_delay_ms) |timed_delay| @min(timed_delay, dirty_delay) else dirty_delay;
    }
    return timed_delay_ms;
}

fn idleWakeDelayMs(now_ms: i64, last_receive_time_ms: i64) i64 {
    return @max(session_idle_timeout_ms - (now_ms - last_receive_time_ms), 0);
}

fn idleExpired(now_ms: i64, last_receive_time_ms: i64) bool {
    return now_ms - last_receive_time_ms >= session_idle_timeout_ms;
}

fn needsFinalKcpFlush(packet_output: bool, kcp_updated: bool, outbound_output: bool) bool {
    return (packet_output or outbound_output) and !kcp_updated;
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
    const gameplay_args = .{ handle, session_manager, gpa, fs, assets };
    var gameplay = handle.io.concurrent(gameplayLoop, gameplay_args) catch
        handle.io.async(gameplayLoop, gameplay_args);

    transportLoop(handle, gpa);
    handle.close();
    gameplay.await(handle.io);
    drainOwnedQueue(gpa, handle.io, &handle.inbound);
    drainOwnedQueue(gpa, handle.io, &handle.outbound);
}

fn transportLoop(handle: *ConnectionHandle, gpa: Allocator) void {
    const log = std.log.scoped(.connection);
    const clock: Io.Clock = .awake;
    const init_time = clock.now(handle.io).toMilliseconds();

    var kcp = Kcp.init(gpa, handle.conv_id, @intFromPtr(handle)) catch |err| {
        log.err("failed to initialize kcp instance: {t}", .{err});
        return;
    };

    defer kcp.deinit();
    kcp.setOutput(kcpOutput);

    var last_receive_time_ms = init_time;

    while (true) {
        const wait_now_ms = clock.now(handle.io).toMilliseconds();
        const elapsed_ms: u32 = @intCast(wait_now_ms - init_time);
        const wake = waitTransportWake(
            handle,
            kcpApplicationReady(&kcp),
            kcp.nextUpdateDelay(elapsed_ms),
            idleWakeDelayMs(wait_now_ms, last_receive_time_ms),
        ) orelse return;

        if (wake.closed) {
            if (wake.outbound_ready) |frame| gpa.free(frame.bytes);
            return;
        }

        var packet_output = false;
        var outbound_output = false;
        var kcp_updated = false;

        if (wake.packet_ready) |packet| {
            const time = clock.now(handle.io);
            packet_output = true;

            _ = kcp.input(packet.buf[0..packet.len]) catch |err| {
                log.err("failed to input data into kcp state: {t}, disconnecting", .{err});
                return;
            };
            last_receive_time_ms = time.toMilliseconds();
        }

        if (wake.application_ready or wake.packet_ready != null) {
            forwardOneApplicationFrame(handle, gpa, &kcp) catch |err| switch (err) {
                error.Closed, error.Canceled => return,
                else => {
                    log.err("failed to forward application data: {t}, disconnecting", .{err});
                    return;
                },
            };
        }

        if (wake.outbound_ready) |frame| {
            defer gpa.free(frame.bytes);
            _ = kcp.send(frame.bytes) catch |err| {
                log.err("failed to queue outbound frame in kcp: {t}, disconnecting", .{err});
                return;
            };
            outbound_output = true;
        }

        const now_ms = clock.now(handle.io).toMilliseconds();
        if (wake.idle_timeout and idleExpired(now_ms, last_receive_time_ms)) {
            log.info("session timed out after {d} ms without input", .{session_idle_timeout_ms});
            return;
        }

        if (wake.kcp_deadline) {
            updateKcpForSession(handle, &kcp, @intCast(now_ms - init_time)) catch |err| {
                log.err("failed to update kcp state: {t}, disconnecting", .{err});
                return;
            };
            kcp_updated = true;
        }

        if (needsFinalKcpFlush(packet_output, kcp_updated, outbound_output)) {
            flushKcpForSession(handle, &kcp) catch |err| {
                log.err("failed to flush kcp state: {t}, disconnecting", .{err});
                return;
            };
        }
    }
}

fn gameplayLoop(
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
) void {
    const log = std.log.scoped(.connection);
    defer handle.close();

    const read_buffer = gpa.alloc(u8, 16384) catch {
        log.err("failed to allocate read buffer, disconnecting", .{});
        return;
    };

    defer gpa.free(read_buffer);

    var inbound_messages = InboundMessageReader.init(gpa, read_buffer);
    defer inbound_messages.deinit();

    var connection: Connection = .{
        .io = handle.io,
        .gpa = gpa,
        .outbound = &handle.outbound,
    };

    var player_id: ?i32 = null;
    var enter: bool = false;
    var claimed_player_id: ?i32 = null;
    defer if (claimed_player_id) |id| session_manager.release(handle, id);

    var state: ?State = null;
    defer if (state) |*s| s.deinit(fs);

    while (true) {
        const wait_now_ms = (Io.Clock.awake).now(handle.io).toMilliseconds();
        const state_ptr: ?*const State = if (state) |*s| s else null;
        const wake = waitGameplayWake(
            handle,
            inbound_messages.hasCompleteBufferedMessage(),
            nextGameplayWakeDelayMs(state_ptr, wait_now_ms),
        ) orelse break;

        if (wake.closed) {
            if (wake.inbound_ready) |frame| gpa.free(frame.bytes);
            return;
        }

        if (wake.inbound_ready) |frame| {
            defer gpa.free(frame.bytes);
            inbound_messages.appendBytes(frame.bytes) catch |err| {
                log.err("failed to buffer application data: {t}, disconnecting", .{err});
                return;
            };
        }

        if (wake.inbound_ready != null or wake.message_ready) {
            var message = inbound_messages.consumeBuffered() catch |err| {
                log.err("failed to read application message: {t}, disconnecting", .{err});
                return;
            };
            if (message) |*ready_message| {
                if (connection.session_key) |key| ready_message.decrypt(key);

                if (state) |*s| {
                    net_handlers.dispatchMessage(s, ready_message.*) catch |err| switch (err) {
                        error.HandlerNotFound => {
                            if (std.meta.activeTag(ready_message.header) == .request) {
                                if (request_response_table[ready_message.header.getMessageId()]) |response_id| {
                                    connection.respondWithMessageId(
                                        ready_message.header.request.rpc_id,
                                        response_id,
                                        proto.pb.HeartbeatResponse{},
                                    ) catch |send_err| switch (send_err) {
                                        error.Closed, error.Canceled => return,
                                        else => {},
                                    };
                                }
                            }

                            const msg_id = ready_message.header.getMessageId();
                            if (msg_id_name_table[msg_id]) |name| {
                                log.warn("no handler for {s} (msg_id: {d})", .{ name, msg_id });
                            } else {
                                log.warn("no handler for unknown message (msg_id: {d})", .{msg_id});
                            }
                        },
                        error.Closed, error.Canceled => return,
                        else => {
                            log.err("failed to dispatch application message: {t}, disconnecting", .{err});
                            return;
                        },
                    };
                    _ = s.arena.reset(.free_all);
                } else {
                    auth.handleAuthGroupRequest(ready_message.*, &connection, fs, gpa, &player_id, &enter) catch |err| {
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
                        _ = state.?.arena.reset(.free_all);
                    };
                }
            }
        }

        if (wake.gameplay_deadline) {
            if (state) |*s| {
                _ = drainScheduledLogicForSession(s, (Io.Clock.awake).now(handle.io).toMilliseconds());
            }
        }
    }
}

fn kcpApplicationReady(kcp: *Kcp) bool {
    _ = kcp.peekSize() catch return false;
    return true;
}

fn forwardOneApplicationFrame(handle: *ConnectionHandle, gpa: Allocator, kcp: *Kcp) !void {
    const size = kcp.peekSize() catch return;
    const bytes = try gpa.alloc(u8, size);
    errdefer gpa.free(bytes);
    const received = try kcp.recv(bytes, false);
    std.debug.assert(received == size);
    try handle.inbound.putOne(handle.io, .{ .bytes = bytes });
}

fn drainOwnedQueue(gpa: Allocator, io: Io, queue: *Io.Queue(OwnedFrame)) void {
    var frames: [32]OwnedFrame = undefined;
    while (true) {
        const count = queue.get(io, &frames, 0) catch return;
        if (count == 0) return;
        for (frames[0..count]) |frame| gpa.free(frame.bytes);
    }
}

pub fn nextSeqNo(conn: *Connection) u32 {
    conn.seq += 1;
    return conn.seq;
}

fn enqueue(conn: *Connection, header: Message.Header, message: anytype) !void {
    const bytes = try Message.encodeAlloc(header, message, conn.gpa, conn.session_key);
    errdefer conn.gpa.free(bytes);
    try conn.outbound.putOne(conn.io, .{ .bytes = bytes });
}

pub fn push(conn: *Connection, message: anytype) !void {
    const name = @typeName(@TypeOf(message))[3..];
    if (!@hasDecl(proto.pb_desc, name)) return;

    const header: Message.Header.Push = .{
        .seq_no = conn.nextSeqNo(),
        .msg_id = @field(proto.pb_desc, name).msg_id,
    };

    try conn.enqueue(.{ .push = header }, message);
}

pub fn respond(conn: *Connection, rpc_id: u16, response: anytype) !void {
    const name = @typeName(@TypeOf(response))[3..];
    if (!@hasDecl(proto.pb_desc, name)) return;
    try conn.respondWithMessageId(rpc_id, @field(proto.pb_desc, name).msg_id, response);
}

fn respondWithMessageId(conn: *Connection, rpc_id: u16, message_id: u16, response: anytype) !void {
    const header: Message.Header.Response = .{
        .rpc_id = rpc_id,
        .seq_no = conn.nextSeqNo(),
        .msg_id = message_id,
    };
    try conn.enqueue(.{ .response = header }, response);
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

fn decodeOwnedFrame(frame: OwnedFrame, key: ?[32]u8) !Message {
    var reader = Io.Reader.fixed(frame.bytes[3..]);
    var message = try Message.decode(&reader);
    if (key) |session_key| message.decrypt(session_key);
    return message;
}

test "connection queues owned push and response frames in sequence order" {
    var outbound_buffer: [4]OwnedFrame = undefined;
    var outbound = Io.Queue(OwnedFrame).init(&outbound_buffer);
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
    };

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const content = try arena.allocator().dupe(u8, "owned after arena reset");
    try conn.push(proto.pb.JSPatchNotify{ .Content = content });
    _ = arena.reset(.free_all);
    try conn.respond(77, proto.pb.HeartbeatResponse{});
    try conn.respondWithMessageId(88, 1234, proto.pb.HeartbeatResponse{});

    const push_frame = try outbound.getOne(std.testing.io);
    defer std.testing.allocator.free(push_frame.bytes);
    const response_frame = try outbound.getOne(std.testing.io);
    defer std.testing.allocator.free(response_frame.bytes);
    const fallback_frame = try outbound.getOne(std.testing.io);
    defer std.testing.allocator.free(fallback_frame.bytes);

    const push_message = try decodeOwnedFrame(push_frame, null);
    const response_message = try decodeOwnedFrame(response_frame, null);
    const fallback_message = try decodeOwnedFrame(fallback_frame, null);
    try std.testing.expectEqual(@as(u32, 1), push_message.header.getSeqNo());
    try std.testing.expectEqual(@as(u32, 2), response_message.header.getSeqNo());
    try std.testing.expectEqual(@as(u32, 3), fallback_message.header.getSeqNo());
    try std.testing.expectEqual(@as(u16, 77), response_message.header.response.rpc_id);
    try std.testing.expectEqual(@as(u16, 88), fallback_message.header.response.rpc_id);
    try std.testing.expectEqual(@as(u16, 1234), fallback_message.header.response.msg_id);

    var decode_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer decode_arena.deinit();
    var payload_reader = Io.Reader.fixed(push_message.payload);
    const notify = try proto.decodeMessage(
        &payload_reader,
        decode_arena.allocator(),
        proto.pb.JSPatchNotify,
        proto.pb_desc,
    );
    try std.testing.expectEqualStrings("owned after arena reset", notify.Content);
}

test "queued proto key response retains the old key boundary" {
    var outbound_buffer: [2]OwnedFrame = undefined;
    var outbound = Io.Queue(OwnedFrame).init(&outbound_buffer);
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
    };

    try conn.respond(9, proto.pb.ProtoKeyResponse{
        .Type = 2,
        .Key = "unencrypted",
    });

    const session_key: [32]u8 = @splat(0x5a);
    conn.session_key = session_key;
    try conn.push(proto.pb.JSPatchNotify{ .Content = "encrypted" });

    const key_frame = try outbound.getOne(std.testing.io);
    defer std.testing.allocator.free(key_frame.bytes);
    const encrypted_frame = try outbound.getOne(std.testing.io);
    defer std.testing.allocator.free(encrypted_frame.bytes);

    const key_message = try decodeOwnedFrame(key_frame, null);
    const encrypted_message = try decodeOwnedFrame(encrypted_frame, session_key);
    try std.testing.expectEqual(@as(u32, 1), key_message.header.getSeqNo());
    try std.testing.expectEqual(@as(u32, 2), encrypted_message.header.getSeqNo());

    var decode_arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer decode_arena.deinit();
    var key_payload_reader = Io.Reader.fixed(key_message.payload);
    const key_response = try proto.decodeMessage(
        &key_payload_reader,
        decode_arena.allocator(),
        proto.pb.ProtoKeyResponse,
        proto.pb_desc,
    );
    try std.testing.expectEqualStrings("unencrypted", key_response.Key);

    var payload_reader = Io.Reader.fixed(encrypted_message.payload);
    const notify = try proto.decodeMessage(
        &payload_reader,
        decode_arena.allocator(),
        proto.pb.JSPatchNotify,
        proto.pb_desc,
    );
    try std.testing.expectEqualStrings("encrypted", notify.Content);
}

test "closing a full outbound queue wakes and releases its producer" {
    var outbound_buffer: [1]OwnedFrame = undefined;
    var outbound = Io.Queue(OwnedFrame).init(&outbound_buffer);
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
    };
    try conn.push(proto.pb.JSPatchNotify{ .Content = "queued" });

    const Producer = struct {
        fn run(connection: *Connection) !void {
            try connection.push(proto.pb.JSPatchNotify{ .Content = "blocked" });
        }
    };
    const args = .{&conn};
    var producer = std.testing.io.concurrent(Producer.run, args) catch
        std.testing.io.async(Producer.run, args);

    outbound.close(std.testing.io);
    try std.testing.expectError(error.Closed, producer.await(std.testing.io));

    const queued = try outbound.getOne(std.testing.io);
    std.testing.allocator.free(queued.bytes);
    try std.testing.expectError(error.Closed, outbound.getOne(std.testing.io));
}

test "transport and gameplay wake reasons preserve simultaneous completions" {
    var transport: TransportWake = .{};
    const packet: RawPacket = .{ .buf = undefined, .len = 0 };
    const frame: OwnedFrame = .{ .bytes = undefined };

    applyTransportSelectResult(&transport, .{ .packet_ready = packet });
    applyTransportSelectResult(&transport, .{ .application_ready = {} });
    applyTransportSelectResult(&transport, .{ .outbound_ready = frame });
    applyTransportSelectResult(&transport, .{ .kcp_deadline = {} });
    applyTransportSelectResult(&transport, .{ .idle_timeout = {} });

    try std.testing.expect(transport.packet_ready != null);
    try std.testing.expect(transport.application_ready);
    try std.testing.expect(transport.outbound_ready != null);
    try std.testing.expect(transport.kcp_deadline);
    try std.testing.expect(transport.idle_timeout);
    try std.testing.expect(!transport.closed);

    var gameplay: GameplayWake = .{};
    applyGameplaySelectResult(&gameplay, .{ .inbound_ready = frame });
    applyGameplaySelectResult(&gameplay, .{ .message_ready = {} });
    applyGameplaySelectResult(&gameplay, .{ .gameplay_deadline = {} });
    try std.testing.expect(gameplay.inbound_ready != null);
    try std.testing.expect(gameplay.message_ready);
    try std.testing.expect(gameplay.gameplay_deadline);
    try std.testing.expect(!gameplay.closed);
}

test "canceled waits do not become wake reasons" {
    var transport: TransportWake = .{};
    applyTransportSelectResult(&transport, .{ .packet_ready = error.Canceled });
    applyTransportSelectResult(&transport, .{ .application_ready = error.Canceled });
    applyTransportSelectResult(&transport, .{ .outbound_ready = error.Canceled });
    applyTransportSelectResult(&transport, .{ .kcp_deadline = error.Canceled });
    applyTransportSelectResult(&transport, .{ .idle_timeout = error.Canceled });
    applyTransportSelectResult(&transport, .{ .closed = error.Canceled });

    try std.testing.expect(transport.packet_ready == null);
    try std.testing.expect(!transport.application_ready);
    try std.testing.expect(transport.outbound_ready == null);
    try std.testing.expect(!transport.kcp_deadline);
    try std.testing.expect(!transport.idle_timeout);
    try std.testing.expect(!transport.closed);

    var gameplay: GameplayWake = .{};
    applyGameplaySelectResult(&gameplay, .{ .inbound_ready = error.Canceled });
    applyGameplaySelectResult(&gameplay, .{ .message_ready = error.Canceled });
    applyGameplaySelectResult(&gameplay, .{ .gameplay_deadline = error.Canceled });
    applyGameplaySelectResult(&gameplay, .{ .closed = error.Canceled });
    try std.testing.expect(gameplay.inbound_ready == null);
    try std.testing.expect(!gameplay.message_ready);
    try std.testing.expect(!gameplay.gameplay_deadline);
    try std.testing.expect(!gameplay.closed);
}

test "queue and explicit closure produce the terminal wake reason" {
    var queue_closed: TransportWake = .{};
    applyTransportSelectResult(&queue_closed, .{ .packet_ready = error.Closed });
    try std.testing.expect(queue_closed.closed);

    var event_closed: GameplayWake = .{};
    applyGameplaySelectResult(&event_closed, .{ .closed = {} });
    try std.testing.expect(event_closed.closed);
}

test "wake lanes keep KCP and gameplay work independent" {
    var gameplay_only: GameplayWake = .{};
    applyGameplaySelectResult(&gameplay_only, .{ .gameplay_deadline = {} });
    try std.testing.expect(gameplay_only.gameplay_deadline);

    var kcp_only: TransportWake = .{};
    applyTransportSelectResult(&kcp_only, .{ .kcp_deadline = {} });
    try std.testing.expect(kcp_only.kcp_deadline);

    try std.testing.expect(needsFinalKcpFlush(true, false, false));
    try std.testing.expect(!needsFinalKcpFlush(true, true, false));
    try std.testing.expect(!needsFinalKcpFlush(true, true, true));
}

test "idle retirement rechecks the latest valid input" {
    const timeout_ms = session_idle_timeout_ms;
    try std.testing.expect(idleExpired(timeout_ms, 0));
    try std.testing.expect(!idleExpired(timeout_ms, timeout_ms - 1));
    try std.testing.expectEqual(timeout_ms - 1, idleWakeDelayMs(timeout_ms, timeout_ms - 1));
}

test "inbound messages preserve additional frames for later passes" {
    var first: ?[]u8 = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 1, .rpc_id = 10, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer if (first) |bytes| std.testing.allocator.free(bytes);
    var second: ?[]u8 = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 2, .rpc_id = 20, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer if (second) |bytes| std.testing.allocator.free(bytes);

    var storage: [4096]u8 = undefined;
    var reader = InboundMessageReader.init(std.testing.allocator, &storage);
    defer reader.deinit();
    try reader.appendBytes(first.?);
    try reader.appendBytes(second.?);
    std.testing.allocator.free(first.?);
    std.testing.allocator.free(second.?);
    first = null;
    second = null;

    const first_message = (try reader.consumeBuffered()).?;
    try std.testing.expectEqual(@as(u32, 1), first_message.header.getSeqNo());
    try std.testing.expect(reader.hasCompleteBufferedMessage());

    const second_message = (try reader.consumeBuffered()).?;
    try std.testing.expectEqual(@as(u32, 2), second_message.header.getSeqNo());
    try std.testing.expect(!reader.hasCompleteBufferedMessage());
}

test "inbound messages preserve partial frames until complete" {
    var encoded: ?[]u8 = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 3, .rpc_id = 30, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer if (encoded) |bytes| std.testing.allocator.free(bytes);

    var storage: [4096]u8 = undefined;
    var reader = InboundMessageReader.init(std.testing.allocator, &storage);
    defer reader.deinit();

    try reader.appendBytes(encoded.?[0..2]);
    try std.testing.expect((try reader.consumeBuffered()) == null);
    try std.testing.expect(!reader.hasCompleteBufferedMessage());

    try reader.appendBytes(encoded.?[2..]);
    std.testing.allocator.free(encoded.?);
    encoded = null;
    try std.testing.expect(reader.hasCompleteBufferedMessage());
    const message = (try reader.consumeBuffered()).?;
    try std.testing.expectEqual(@as(u32, 3), message.header.getSeqNo());
}

test "gameplay budget always starts one chain and then enforces both limits" {
    var timed = GameplayBudget.init(100);
    try std.testing.expect(timed.canStart(100 + gameplay_time_limit_ns));
    timed.complete();
    try std.testing.expect(timed.canStart(100 + gameplay_time_limit_ns - 1));
    try std.testing.expect(!timed.canStart(100 + gameplay_time_limit_ns));

    var counted = GameplayBudget.init(0);
    while (counted.completed_events < gameplay_event_limit) counted.complete();
    try std.testing.expect(!counted.canStart(0));
}

test "overdue gameplay schedules an immediate continuation" {
    try std.testing.expectEqual(@as(?i64, 0), gameplayWakeDelayMs(50, 30_000, true));
    try std.testing.expectEqual(@as(?i64, 25), gameplayWakeDelayMs(50, 25, false));
    try std.testing.expectEqual(@as(?i64, 50), gameplayWakeDelayMs(50, null, false));
    try std.testing.expect(gameplayWakeDelayMs(null, null, false) == null);
}
