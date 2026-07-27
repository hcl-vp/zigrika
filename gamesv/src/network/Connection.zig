const Connection = @This();
const std = @import("std");
const proto = @import("proto");
const common = @import("common");
const auth = @import("handlers/auth.zig");
const net_handlers = @import("handlers.zig");
const logic_handlers = @import("../logic/handlers.zig");

const Io = std.Io;
const State = @import("State.zig");
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;
const Message = @import("Message.zig");
const Assets = @import("../data/Assets.zig");
const EventQueue = @import("../logic/EventQueue.zig");
const OwnedMessage = @import("../network.zig").OwnedMessage;
const OwnedFrame = @import("../network.zig").OwnedFrame;
const ConnectionHandle = @import("../network.zig").ConnectionHandle;
const SessionManager = @import("../network.zig").SessionManager;
const PlayerComponentStorage = @import("../logic/component/player/PlayerComponentStorage.zig");

io: Io,
gpa: Allocator,
outbound: *Io.Queue(OwnedFrame),
transport_work: *Io.Event,
session_key: ?[32]u8 = null,
seq: u32 = 0,

pub const GameplayState = struct {
    connection: Connection,
    state: ?State = null,
    claimed_player_id: ?i32 = null,

    pub fn init(handle: *ConnectionHandle, gpa: Allocator) GameplayState {
        return .{
            .connection = .{
                .io = handle.io,
                .gpa = gpa,
                .outbound = &handle.outbound,
                .transport_work = handle.transport_work,
            },
        };
    }
};

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

const GameplayWake = struct {
    inbound_ready: ?OwnedMessage = null,
    gameplay_deadline: bool = false,
    closed: bool = false,
};

const GameplaySelectResult = union(enum) {
    inbound_ready: anyerror!OwnedMessage,
    gameplay_deadline: anyerror!void,
    closed: anyerror!void,
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

fn waitForInbound(handle: *ConnectionHandle) anyerror!OwnedMessage {
    const message = try handle.inbound.getOne(handle.io);
    handle.signalTransportWork();
    return message;
}

fn waitForDeadline(io: Io, delay_ms: i64) anyerror!void {
    const sleep_ms = if (delay_ms > 0) delay_ms else 0;
    try io.sleep(.fromMilliseconds(sleep_ms), .awake);
}

fn waitForClosed(handle: *ConnectionHandle) anyerror!void {
    try handle.closed_event.wait(handle.io);
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
    gameplay_delay_ms: ?i64,
) ?GameplayWake {
    var buffer: [3]GameplaySelectResult = undefined;
    var select: Io.Select(GameplaySelectResult) = .init(handle.io, &buffer);

    select.async(.inbound_ready, waitForInbound, .{handle});
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

pub fn runGameplay(
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
    gameplay: *GameplayState,
) void {
    const log = std.log.scoped(.connection);

    var player_id: ?i32 = null;
    var enter: bool = false;
    var pending_reconnect: ?auth.PendingReconnect = null;

    while (true) {
        const wait_now_ms = (Io.Clock.awake).now(handle.io).toMilliseconds();
        const state_ptr: ?*const State = if (gameplay.state) |*s| s else null;
        const wake = waitGameplayWake(
            handle,
            nextGameplayWakeDelayMs(state_ptr, wait_now_ms),
        ) orelse break;

        if (wake.closed) {
            if (wake.inbound_ready) |message| gpa.free(message.bytes);
            return;
        }

        if (wake.inbound_ready) |owned_message| {
            defer gpa.free(owned_message.bytes);

            var reader = Io.Reader.fixed(owned_message.bytes);
            var ready_message = Message.decode(&reader) catch |err| {
                log.err("failed to decode application message: {t}, disconnecting", .{err});
                return;
            };
            if (gameplay.connection.session_key) |key| ready_message.decrypt(key);

            if (gameplay.state) |*s| {
                net_handlers.dispatchMessage(s, ready_message) catch |err| switch (err) {
                    error.HandlerNotFound => {
                        if (std.meta.activeTag(ready_message.header) == .request) {
                            if (request_response_table[ready_message.header.getMessageId()]) |response_id| {
                                gameplay.connection.respondWithMessageId(
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
                auth.handleAuthGroupRequest(
                    ready_message,
                    &gameplay.connection,
                    fs,
                    gpa,
                    &player_id,
                    &enter,
                    &pending_reconnect,
                ) catch |err| {
                    log.err("failed to handle auth request: {t}, disconnecting", .{err});
                    return;
                };

                if (enter) if (player_id) |id| { // Auth step finished. Initialize the state.
                    session_manager.acquire(gpa, handle, id) catch |err| {
                        log.err("failed to acquire player session: {t}, disconnecting", .{err});
                        return;
                    };
                    gameplay.claimed_player_id = id;
                    handle.markAuthenticated();

                    if (pending_reconnect) |reconnect| {
                        gameplay.connection.respond(reconnect.rpc_id, proto.pb.ReconnectResponse{
                            .ErrorCode = .Success,
                            .LastRecvSeqNo = reconnect.last_server_seq_no,
                            .Timestamp = Io.Clock.real.now(fs.io).toMilliseconds(),
                        }) catch |err| {
                            log.err("failed to send reconnect response: {t}, disconnecting", .{err});
                            return;
                        };
                        pending_reconnect = null;
                    }

                    const player_components = PlayerComponentStorage.init(gpa, fs, assets, id) catch |err| {
                        log.err("failed to init player component storage: {t}, disconnecting", .{err});
                        return;
                    };

                    gameplay.state = .init(
                        gpa,
                        handle.io,
                        fs,
                        &gameplay.connection,
                        assets,
                        player_components,
                        id,
                    );

                    var event_queue: EventQueue = .{ .arena = gameplay.state.?.arena.allocator() };
                    event_queue.enqueue(.enter_game, .{}) catch |err| {
                        log.err("failed to enqueue enter game event: {t}, disconnecting", .{err});
                        return;
                    };

                    logic_handlers.drainEventQueue(&event_queue, &gameplay.state.?) catch |err| {
                        log.err("failed to execute initial event chain: {t}, disconnecting", .{err});
                        return;
                    };
                    _ = gameplay.state.?.arena.reset(.free_all);
                };
            }
        }

        if (wake.gameplay_deadline) {
            if (gameplay.state) |*s| {
                _ = drainScheduledLogicForSession(s, (Io.Clock.awake).now(handle.io).toMilliseconds());
            }
        }
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
    conn.transport_work.set(conn.io);
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

fn decodeOwnedFrame(frame: OwnedFrame, key: ?[32]u8) !Message {
    var reader = Io.Reader.fixed(frame.bytes[3..]);
    var message = try Message.decode(&reader);
    if (key) |session_key| message.decrypt(session_key);
    return message;
}

test "connection queues owned push and response frames in sequence order" {
    var outbound_buffer: [4]OwnedFrame = undefined;
    var outbound = Io.Queue(OwnedFrame).init(&outbound_buffer);
    var transport_work: Io.Event = .unset;
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
        .transport_work = &transport_work,
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
    var transport_work: Io.Event = .unset;
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
        .transport_work = &transport_work,
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
    var transport_work: Io.Event = .unset;
    var conn: Connection = .{
        .io = std.testing.io,
        .gpa = std.testing.allocator,
        .outbound = &outbound,
        .transport_work = &transport_work,
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

test "gameplay wake preserves simultaneous completions" {
    var gameplay: GameplayWake = .{};
    const message: OwnedMessage = .{ .bytes = undefined };
    applyGameplaySelectResult(&gameplay, .{ .inbound_ready = message });
    applyGameplaySelectResult(&gameplay, .{ .gameplay_deadline = {} });
    try std.testing.expect(gameplay.inbound_ready != null);
    try std.testing.expect(gameplay.gameplay_deadline);
    try std.testing.expect(!gameplay.closed);
}

test "canceled gameplay waits do not become wake reasons" {
    var gameplay: GameplayWake = .{};
    applyGameplaySelectResult(&gameplay, .{ .inbound_ready = error.Canceled });
    applyGameplaySelectResult(&gameplay, .{ .gameplay_deadline = error.Canceled });
    applyGameplaySelectResult(&gameplay, .{ .closed = error.Canceled });
    try std.testing.expect(gameplay.inbound_ready == null);
    try std.testing.expect(!gameplay.gameplay_deadline);
    try std.testing.expect(!gameplay.closed);
}

test "gameplay queue and explicit closure are terminal" {
    var queue_closed: GameplayWake = .{};
    applyGameplaySelectResult(&queue_closed, .{ .inbound_ready = error.Closed });
    try std.testing.expect(queue_closed.closed);
    var event_closed: GameplayWake = .{};
    applyGameplaySelectResult(&event_closed, .{ .closed = {} });
    try std.testing.expect(event_closed.closed);
}

test "gameplay deadline remains independent from inbound messages" {
    var gameplay_only: GameplayWake = .{};
    applyGameplaySelectResult(&gameplay_only, .{ .gameplay_deadline = {} });
    try std.testing.expect(gameplay_only.gameplay_deadline);
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
