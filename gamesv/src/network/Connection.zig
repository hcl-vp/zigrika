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

const SessionWake = struct {
    packet_ready: ?RawPacket = null,
    message_ready: bool = false,
    kcp_deadline: bool = false,
    gameplay_deadline: bool = false,
    idle_timeout: bool = false,
    closed: bool = false,
};

const SessionSelectResult = union(enum) {
    packet_ready: anyerror!RawPacket,
    message_ready: anyerror!void,
    kcp_deadline: anyerror!void,
    gameplay_deadline: anyerror!void,
    idle_timeout: anyerror!void,
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

    fn nextMessage(reader: *InboundMessageReader, kcp: *Kcp) !?Message {
        while (true) {
            if (try reader.consumeBuffered()) |message| return message;

            const size = kcp.peekSize() catch return null;
            try reader.prepareAppend(size);
            reader.end += try kcp.recv(reader.buffer[reader.end..][0..size], false);
        }
    }

    fn hasBufferedMessageInput(reader: *InboundMessageReader, kcp: *Kcp) bool {
        if (reader.hasCompleteBufferedMessage()) return true;
        _ = kcp.peekSize() catch return false;
        return true;
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

fn waitForDeadline(io: Io, delay_ms: i64) anyerror!void {
    const sleep_ms = if (delay_ms > 0) delay_ms else 0;
    try io.sleep(.fromMilliseconds(sleep_ms), .awake);
}

fn waitForClosed(handle: *ConnectionHandle) anyerror!void {
    try handle.closed_event.wait(handle.io);
}

fn applySessionSelectResult(wake: *SessionWake, result: SessionSelectResult) void {
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

fn waitSessionWake(
    handle: *ConnectionHandle,
    message_ready: bool,
    kcp_delay_ms: i64,
    gameplay_delay_ms: ?i64,
    idle_delay_ms: i64,
) ?SessionWake {
    var buffer: [6]SessionSelectResult = undefined;
    var select: Io.Select(SessionSelectResult) = .init(handle.io, &buffer);

    select.async(.packet_ready, waitForPacket, .{handle});
    if (message_ready) {
        select.async(.message_ready, waitForDeadline, .{ handle.io, 0 });
    }
    select.async(.kcp_deadline, waitForDeadline, .{ handle.io, kcp_delay_ms });
    if (gameplay_delay_ms) |delay_ms| {
        select.async(.gameplay_deadline, waitForDeadline, .{ handle.io, delay_ms });
    }
    select.async(.idle_timeout, waitForDeadline, .{ handle.io, idle_delay_ms });
    select.async(.closed, waitForClosed, .{handle});

    const first = select.await() catch {
        select.cancelDiscard();
        return null;
    };

    var wake: SessionWake = .{};
    applySessionSelectResult(&wake, first);
    while (select.cancel()) |extra| {
        applySessionSelectResult(&wake, extra);
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

fn needsFinalKcpFlush(packet_output: bool, kcp_updated: bool, gameplay_output: bool) bool {
    return gameplay_output or (packet_output and !kcp_updated);
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

    const read_buffer = gpa.alloc(u8, 16384) catch {
        log.err("failed to allocate read buffer, disconnecting", .{});
        return;
    };

    defer gpa.free(read_buffer);

    var inbound_messages = InboundMessageReader.init(gpa, read_buffer);
    defer inbound_messages.deinit();

    var connection: Connection = .{ .kcp = &kcp };

    var player_id: ?i32 = null;
    var enter: bool = false;
    var claimed_player_id: ?i32 = null;
    defer if (claimed_player_id) |id| session_manager.release(handle, id);

    var state: ?State = null;
    defer if (state) |*s| s.deinit(fs);

    var last_receive_time_ms = init_time;

    while (true) {
        const wait_now_ms = clock.now(handle.io).toMilliseconds();
        const elapsed_ms: u32 = @intCast(wait_now_ms - init_time);
        const state_ptr: ?*const State = if (state) |*s| s else null;
        const wake = waitSessionWake(
            handle,
            inbound_messages.hasBufferedMessageInput(&kcp),
            kcp.nextUpdateDelay(elapsed_ms),
            nextGameplayWakeDelayMs(state_ptr, wait_now_ms),
            idleWakeDelayMs(wait_now_ms, last_receive_time_ms),
        ) orelse break;

        if (wake.closed) return;

        var input_output = false;
        var kcp_updated = false;
        var gameplay_output = false;

        if (wake.packet_ready) |packet| {
            const time = clock.now(handle.io);
            input_output = true;

            _ = kcp.input(packet.buf[0..packet.len]) catch |err| {
                log.err("failed to input data into kcp state: {t}, disconnecting", .{err});
                return;
            };
            last_receive_time_ms = time.toMilliseconds();
        }

        if (wake.packet_ready != null or wake.message_ready) {
            var message = inbound_messages.nextMessage(&kcp) catch |err| {
                log.err("failed to read application message: {t}, disconnecting", .{err});
                return;
            };
            if (message) |*ready_message| {
                input_output = true;
                if (connection.session_key) |key| ready_message.decrypt(key);

                if (state) |*s| {
                    net_handlers.dispatchMessage(s, ready_message.*) catch |err| switch (err) {
                        error.HandlerNotFound => {
                            if (std.meta.activeTag(ready_message.header) == .request) {
                                if (request_response_table[ready_message.header.getMessageId()]) |response_id| {
                                    const header: Message.Header.Response = .{
                                        .seq_no = connection.nextSeqNo(),
                                        .rpc_id = ready_message.header.request.rpc_id,
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

                            const msg_id = ready_message.header.getMessageId();
                            if (msg_id_name_table[msg_id]) |name| {
                                log.warn("no handler for {s} (msg_id: {d})", .{ name, msg_id });
                            } else {
                                log.warn("no handler for unknown message (msg_id: {d})", .{msg_id});
                            }
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

        if (wake.gameplay_deadline) {
            if (state) |*s| {
                gameplay_output = drainScheduledLogicForSession(s, now_ms);
            }
        }

        if (needsFinalKcpFlush(input_output, kcp_updated, gameplay_output)) {
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

test "session wake reasons preserve simultaneous completions" {
    var wake: SessionWake = .{};
    const packet: RawPacket = .{ .buf = undefined, .len = 0 };

    applySessionSelectResult(&wake, .{ .packet_ready = packet });
    applySessionSelectResult(&wake, .{ .message_ready = {} });
    applySessionSelectResult(&wake, .{ .kcp_deadline = {} });
    applySessionSelectResult(&wake, .{ .gameplay_deadline = {} });
    applySessionSelectResult(&wake, .{ .idle_timeout = {} });

    try std.testing.expect(wake.packet_ready != null);
    try std.testing.expect(wake.message_ready);
    try std.testing.expect(wake.kcp_deadline);
    try std.testing.expect(wake.gameplay_deadline);
    try std.testing.expect(wake.idle_timeout);
    try std.testing.expect(!wake.closed);
}

test "canceled waits do not become wake reasons" {
    var wake: SessionWake = .{};

    applySessionSelectResult(&wake, .{ .packet_ready = error.Canceled });
    applySessionSelectResult(&wake, .{ .message_ready = error.Canceled });
    applySessionSelectResult(&wake, .{ .kcp_deadline = error.Canceled });
    applySessionSelectResult(&wake, .{ .gameplay_deadline = error.Canceled });
    applySessionSelectResult(&wake, .{ .idle_timeout = error.Canceled });
    applySessionSelectResult(&wake, .{ .closed = error.Canceled });

    try std.testing.expect(wake.packet_ready == null);
    try std.testing.expect(!wake.message_ready);
    try std.testing.expect(!wake.kcp_deadline);
    try std.testing.expect(!wake.gameplay_deadline);
    try std.testing.expect(!wake.idle_timeout);
    try std.testing.expect(!wake.closed);
}

test "queue and explicit closure produce the terminal wake reason" {
    var queue_closed: SessionWake = .{};
    applySessionSelectResult(&queue_closed, .{ .packet_ready = error.Closed });
    try std.testing.expect(queue_closed.closed);

    var event_closed: SessionWake = .{};
    applySessionSelectResult(&event_closed, .{ .closed = {} });
    try std.testing.expect(event_closed.closed);
}

test "wake lanes keep KCP and gameplay work independent" {
    var gameplay_only: SessionWake = .{};
    applySessionSelectResult(&gameplay_only, .{ .gameplay_deadline = {} });
    try std.testing.expect(gameplay_only.gameplay_deadline);
    try std.testing.expect(!gameplay_only.kcp_deadline);

    var kcp_only: SessionWake = .{};
    applySessionSelectResult(&kcp_only, .{ .kcp_deadline = {} });
    try std.testing.expect(kcp_only.kcp_deadline);
    try std.testing.expect(!kcp_only.gameplay_deadline);

    try std.testing.expect(needsFinalKcpFlush(true, false, false));
    try std.testing.expect(!needsFinalKcpFlush(true, true, false));
    try std.testing.expect(needsFinalKcpFlush(true, true, true));
}

test "idle retirement rechecks the latest valid input" {
    const timeout_ms = session_idle_timeout_ms;
    try std.testing.expect(idleExpired(timeout_ms, 0));
    try std.testing.expect(!idleExpired(timeout_ms, timeout_ms - 1));
    try std.testing.expectEqual(timeout_ms - 1, idleWakeDelayMs(timeout_ms, timeout_ms - 1));
}

test "inbound messages preserve additional frames for later passes" {
    const first = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 1, .rpc_id = 10, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer std.testing.allocator.free(first);
    const second = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 2, .rpc_id = 20, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer std.testing.allocator.free(second);

    var storage: [4096]u8 = undefined;
    var reader = InboundMessageReader.init(std.testing.allocator, &storage);
    defer reader.deinit();
    try reader.appendBytes(first);
    try reader.appendBytes(second);

    const first_message = (try reader.consumeBuffered()).?;
    try std.testing.expectEqual(@as(u32, 1), first_message.header.getSeqNo());
    try std.testing.expect(reader.hasCompleteBufferedMessage());

    const second_message = (try reader.consumeBuffered()).?;
    try std.testing.expectEqual(@as(u32, 2), second_message.header.getSeqNo());
    try std.testing.expect(!reader.hasCompleteBufferedMessage());
}

test "inbound messages preserve partial frames until complete" {
    const encoded = try Message.encodeAlloc(
        .{ .request = .{ .seq_no = 3, .rpc_id = 30, .msg_id = proto.pb_desc.HeartbeatRequest.msg_id } },
        proto.pb.HeartbeatRequest{},
        std.testing.allocator,
        null,
    );
    defer std.testing.allocator.free(encoded);

    var storage: [4096]u8 = undefined;
    var reader = InboundMessageReader.init(std.testing.allocator, &storage);
    defer reader.deinit();

    try reader.appendBytes(encoded[0..2]);
    try std.testing.expect((try reader.consumeBuffered()) == null);
    try std.testing.expect(!reader.hasCompleteBufferedMessage());

    try reader.appendBytes(encoded[2..]);
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
