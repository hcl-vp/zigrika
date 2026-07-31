const std = @import("std");
const common = @import("common");
const Assets = @import("data/Assets.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;
const SessionSupervisor = @import("network/SessionSupervisor.zig");
const KcpTransport = @import("network/KcpTransport.zig");

const udp_receive_capacity: usize = 1500;
const krkcp_syn: u8 = 0xED;
const krkcp_ack: u8 = 0xEE;
const kcp_overhead = KcpTransport.overhead;

pub const OwnedMessage = struct {
    bytes: []u8,
};
pub const OwnedFrame = struct {
    bytes: []u8,
};

pub const CloseReason = enum(u8) {
    active,
    replaced,
    gameplay_exit,
    invalid_kcp_packet,
    transport_error,
    kcp_dead_link,
    send_failed,
    pre_auth_timeout,
    idle_timeout,
    shutdown,
};

pub fn bind(io: Io, gpa: Allocator, fs: *FileSystem, assets: *const Assets, address: Io.net.IpAddress) !Io.Future(void) {
    const log = std.log.scoped(.net_bind);

    const socket = address.bind(io, .{ .mode = .dgram }) catch |err| {
        log.err("failed to bind at {f}: {t}", .{ address, err });
        if (err == error.AddressInUse) log.err("another instance of this server might be already running", .{});
        return err;
    };

    const recv_args = .{ io, gpa, fs, assets, socket };
    return io.concurrent(receiveLoop, recv_args) catch io.async(receiveLoop, recv_args);
}

pub const ConnectionHandle = struct {
    conv_id: u32,
    io: Io,
    socket: *const Io.net.Socket,
    address: Io.net.IpAddress,
    inbound_buf: [128]OwnedMessage,
    inbound: Io.Queue(OwnedMessage),
    outbound_buf: [512]OwnedFrame,
    outbound: Io.Queue(OwnedFrame),
    closed_event: Io.Event,
    transport_work: *Io.Event,
    gameplay_completions: *Io.Queue(*ConnectionHandle),
    gameplay_future: Io.Future(*ConnectionHandle),
    close_reason: std.atomic.Value(CloseReason),
    authenticated: std.atomic.Value(bool),

    pub fn init(
        handle: *ConnectionHandle,
        io: Io,
        socket: *const Io.net.Socket,
        address: Io.net.IpAddress,
        conv_id: u32,
        transport_work: *Io.Event,
        gameplay_completions: *Io.Queue(*ConnectionHandle),
    ) void {
        handle.io = io;
        handle.socket = socket;
        handle.address = address;
        handle.conv_id = conv_id;
        handle.inbound = Io.Queue(OwnedMessage).init(handle.inbound_buf[0..]);
        handle.outbound = Io.Queue(OwnedFrame).init(handle.outbound_buf[0..]);
        handle.closed_event = .unset;
        handle.transport_work = transport_work;
        handle.gameplay_completions = gameplay_completions;
        handle.gameplay_future = undefined;
        handle.close_reason = .init(.active);
        handle.authenticated = .init(false);
    }

    pub fn close(handle: *ConnectionHandle, reason: CloseReason) void {
        _ = handle.close_reason.cmpxchgStrong(.active, reason, .acq_rel, .acquire);
        handle.closed_event.set(handle.io);
        handle.inbound.close(handle.io);
        handle.outbound.close(handle.io);
        handle.signalTransportWork();
    }

    pub fn closeReason(handle: *const ConnectionHandle) CloseReason {
        return handle.close_reason.load(.acquire);
    }

    pub fn markAuthenticated(handle: *ConnectionHandle) void {
        handle.authenticated.store(true, .release);
        handle.signalTransportWork();
    }

    pub fn isAuthenticated(handle: *const ConnectionHandle) bool {
        return handle.authenticated.load(.acquire);
    }

    pub fn signalTransportWork(handle: *ConnectionHandle) void {
        handle.transport_work.set(handle.io);
    }
};

pub const SessionManager = struct {
    mutex: Io.Mutex = .init,
    sessions: std.AutoHashMapUnmanaged(i32, *ConnectionHandle) = .empty,

    const replacement_timeout_ms = 5_000;
    const replacement_poll_ms = 10;

    pub fn deinit(manager: *SessionManager, gpa: Allocator) void {
        manager.sessions.deinit(gpa);
    }

    pub fn acquire(
        manager: *SessionManager,
        gpa: Allocator,
        handle: *ConnectionHandle,
        player_id: i32,
    ) !void {
        const clock: Io.Clock = .awake;
        const deadline_ms = clock.now(handle.io).toMilliseconds() + replacement_timeout_ms;
        var replacement_requested: ?*ConnectionHandle = null;

        while (true) {
            try manager.mutex.lock(handle.io);
            {
                defer manager.mutex.unlock(handle.io);

                if (manager.sessions.get(player_id)) |existing| {
                    if (existing == handle) return;

                    if (replacement_requested != existing) {
                        existing.close(.replaced);
                        replacement_requested = existing;
                    }
                } else {
                    try manager.sessions.put(gpa, player_id, handle);
                    return;
                }
            }

            if (clock.now(handle.io).toMilliseconds() >= deadline_ms) {
                return error.SessionReplacementTimedOut;
            }
            try handle.io.sleep(.fromMilliseconds(replacement_poll_ms), .awake);
        }
    }

    pub fn release(manager: *SessionManager, handle: *ConnectionHandle, player_id: i32) void {
        manager.mutex.lockUncancelable(handle.io);
        defer manager.mutex.unlock(handle.io);

        if (manager.sessions.get(player_id) == handle) {
            _ = manager.sessions.remove(player_id);
        }
    }
};

const Wake = struct {
    packet: ?Io.net.Socket.ReceiveError!Io.net.IncomingMessage = null,
    gameplay_done: ?*ConnectionHandle = null,
    transport_ready: bool = false,
};

const SelectResult = union(enum) {
    packet: Io.net.Socket.ReceiveError!Io.net.IncomingMessage,
    gameplay_done: (Io.QueueClosedError || Io.Cancelable)!*ConnectionHandle,
    transport_ready: Io.Cancelable!void,
};

fn waitForTransportWork(event: *Io.Event, io: Io, deadline_delay_ms: ?i64) Io.Cancelable!void {
    if (deadline_delay_ms) |delay_ms| {
        event.waitTimeout(io, .{ .duration = .{
            .clock = .awake,
            .raw = .fromMilliseconds(@max(delay_ms, 0)),
        } }) catch |err| switch (err) {
            error.Timeout => return,
            error.Canceled => |e| return e,
        };
        return;
    }
    try event.wait(io);
}

fn applySelectResult(wake: *Wake, result: SelectResult) void {
    switch (result) {
        .packet => |packet_result| {
            wake.packet = packet_result catch |err| switch (err) {
                error.Canceled => return,
                else => err,
            };
        },
        .gameplay_done => |done| wake.gameplay_done = done catch |err| switch (err) {
            error.Canceled, error.Closed => return,
        },
        .transport_ready => |work| {
            work catch |err| switch (err) {
                error.Canceled => return,
            };
            wake.transport_ready = true;
        },
    }
}

fn waitForWake(
    io: Io,
    socket: *const Io.net.Socket,
    recv_buffer: []u8,
    transport_work: *Io.Event,
    gameplay_completions: *Io.Queue(*ConnectionHandle),
    deadline_delay_ms: ?i64,
) (Io.ConcurrentError || Io.Cancelable)!Wake {
    var results: [3]SelectResult = undefined;
    var select: Io.Select(SelectResult) = .init(io, &results);
    errdefer select.cancelDiscard();

    try select.concurrent(.packet, Io.net.Socket.receive, .{ socket, io, recv_buffer });
    try select.concurrent(.gameplay_done, Io.Queue(*ConnectionHandle).getOne, .{ gameplay_completions, io });
    try select.concurrent(.transport_ready, waitForTransportWork, .{ transport_work, io, deadline_delay_ms });

    const first = try select.await();

    var wake: Wake = .{};
    applySelectResult(&wake, first);
    while (select.cancel()) |extra| applySelectResult(&wake, extra);
    return wake;
}

fn startSession(
    io: Io,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
    socket: *const Io.net.Socket,
    from: Io.net.IpAddress,
    transport_work: *Io.Event,
    gameplay_completions: *Io.Queue(*ConnectionHandle),
    session_manager: *SessionManager,
    registry: *KcpTransport.Registry,
    now_ms: i64,
) !*ConnectionHandle {
    const handle = try gpa.create(ConnectionHandle);
    errdefer gpa.destroy(handle);

    const conv_id = try registry.allocateConvId();
    handle.init(io, socket, from, conv_id, transport_work, gameplay_completions);
    try registry.create(handle, now_ms);
    errdefer {
        handle.close(.transport_error);
        registry.finalize(handle, now_ms);
    }

    const args = .{ handle, session_manager, gpa, fs, assets };
    handle.gameplay_future = io.concurrent(SessionSupervisor.run, args) catch
        io.async(SessionSupervisor.run, args);
    return handle;
}

fn receiveLoop(io: Io, gpa: Allocator, fs: *FileSystem, assets: *const Assets, socket: Io.net.Socket) void {
    const log = std.log.scoped(.net_recv);
    defer socket.close(io);

    var session_manager: SessionManager = .{};
    defer session_manager.deinit(gpa);

    var registry = KcpTransport.Registry.init(gpa);
    defer registry.deinit();

    var transport_work: Io.Event = .unset;
    var completion_buffer: [128]*ConnectionHandle = undefined;
    var gameplay_completions = Io.Queue(*ConnectionHandle).init(&completion_buffer);
    var recv_buffer: [udp_receive_capacity]u8 = undefined;

    while (true) {
        transport_work.reset();
        const before_wait_ms = Io.Clock.awake.now(io).toMilliseconds();
        if (registry.drainReady(io, before_wait_ms)) continue;

        const wake = waitForWake(
            io,
            &socket,
            &recv_buffer,
            &transport_work,
            &gameplay_completions,
            registry.nextWakeDelayMs(before_wait_ms),
        ) catch |err| {
            log.err("failed to wait for transport work: {t}", .{err});
            break;
        };

        const now_ms = Io.Clock.awake.now(io).toMilliseconds();
        if (wake.packet) |packet_result| {
            if (packet_result) |message| {
                if (message.flags.trunc) {
                    log.warn("discarding truncated UDP datagram from {f}", .{message.from});
                } else if (message.data.len == 35 and message.data[0] == krkcp_syn) {
                    if (startSession(
                        io,
                        gpa,
                        fs,
                        assets,
                        &socket,
                        message.from,
                        &transport_work,
                        &gameplay_completions,
                        &session_manager,
                        &registry,
                        now_ms,
                    )) |handle| {
                        var ack: [5]u8 = undefined;
                        ack[0] = krkcp_ack;
                        std.mem.writeInt(u32, ack[1..5], handle.conv_id, .little);
                        socket.send(io, &message.from, ack[0..]) catch {};
                    } else |err| {
                        log.err("failed to initialize session: {t}", .{err});
                    }
                } else if (message.data.len >= kcp_overhead) {
                    const conv_id = std.mem.readInt(u32, message.data[0..4], .little);
                    _ = registry.input(conv_id, &message.from, message.data, now_ms);
                }
            } else |err| {
                if (err == error.PortUnreachable) {
                    log.debug("discarding ICMP port unreachable report", .{});
                } else {
                    log.err("UDP receive failed: {t}", .{err});
                }
            }
        }

        if (wake.gameplay_done) |handle| {
            _ = handle.gameplay_future.await(io);
            registry.finalize(handle, now_ms);
            gpa.destroy(handle);
        }

        if (registry.drainReady(io, now_ms)) transport_work.set(io);
    }

    const previous_cancel_protection = io.swapCancelProtection(.blocked);
    defer _ = io.swapCancelProtection(previous_cancel_protection);

    registry.closeAll(.shutdown);
    while (registry.sessionCount() != 0) {
        const handle = gameplay_completions.getOneUncancelable(io) catch |err| switch (err) {
            error.Closed => break,
        };
        _ = handle.gameplay_future.await(io);
        registry.finalize(handle, Io.Clock.awake.now(io).toMilliseconds());
        gpa.destroy(handle);
    }
}

test "central wake preserves simultaneous completions" {
    var packet_bytes = [_]u8{1};
    const from = try Io.net.IpAddress.parseLiteral("127.0.0.1:7777");
    const packet: Io.net.IncomingMessage = .{
        .from = from,
        .data = &packet_bytes,
        .control = &.{},
        .flags = .{
            .eor = false,
            .trunc = false,
            .ctrunc = false,
            .oob = false,
            .errqueue = false,
        },
    };
    var handle: ConnectionHandle = undefined;
    var wake: Wake = .{};

    applySelectResult(&wake, .{ .packet = packet });
    applySelectResult(&wake, .{ .gameplay_done = &handle });
    applySelectResult(&wake, .{ .transport_ready = {} });

    try std.testing.expect(wake.packet != null);
    try std.testing.expect(wake.gameplay_done == &handle);
    try std.testing.expect(wake.transport_ready);
}

test "canceled central waits do not become wake reasons" {
    var wake: Wake = .{};
    applySelectResult(&wake, .{ .packet = error.Canceled });
    applySelectResult(&wake, .{ .gameplay_done = error.Canceled });
    applySelectResult(&wake, .{ .transport_ready = error.Canceled });

    try std.testing.expect(wake.packet == null);
    try std.testing.expect(wake.gameplay_done == null);
    try std.testing.expect(!wake.transport_ready);
}

test "transport work waits for either an event or its deadline" {
    var event: Io.Event = .unset;

    event.set(std.testing.io);
    try waitForTransportWork(&event, std.testing.io, null);

    event.reset();
    try waitForTransportWork(&event, std.testing.io, 0);
}
