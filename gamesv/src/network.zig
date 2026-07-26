const std = @import("std");
const mem = @import("mem.zig");
const proto = @import("proto");
const common = @import("common");
const Assets = @import("data/Assets.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const FileSystem = common.FileSystem;
const Connection = @import("network/Connection.zig");

const mtu: usize = 1000;
const krkcp_syn: u8 = 0xED;
const krkcp_ack: u8 = 0xEE;
const kcp_overhead = @import("network/kcp.zig").overhead;

pub const RawPacket = mem.FixedBuffer(mtu);

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
    consecutive_send_failures: u8,
    queue_buf: [16]RawPacket,
    queue: Io.Queue(RawPacket),

    pub fn init(handle: *ConnectionHandle, io: Io, socket: *const Io.net.Socket, address: Io.net.IpAddress, conv_id: u32) void {
        handle.io = io;
        handle.socket = socket;
        handle.address = address;
        handle.conv_id = conv_id;
        handle.consecutive_send_failures = 0;
        handle.queue = Io.Queue(RawPacket).init(handle.queue_buf[0..]);
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

            if (manager.sessions.get(player_id)) |existing| {
                if (existing == handle) {
                    manager.mutex.unlock(handle.io);
                    return;
                }

                if (replacement_requested != existing) {
                    existing.queue.close(existing.io);
                    replacement_requested = existing;
                }
                manager.mutex.unlock(handle.io);
            } else {
                manager.sessions.put(gpa, player_id, handle) catch |err| {
                    manager.mutex.unlock(handle.io);
                    return err;
                };
                manager.mutex.unlock(handle.io);
                return;
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

const NetworkSlot = struct {
    future: *Io.AnyFuture,
    task: union(enum) {
        udp_recv: void,
        client: *ConnectionHandle,
    },
};

fn getFreeIndex(comptime T: type, list: []const ?T) ?usize {
    for (list, 0..) |free, i| {
        if (free == null) return i;
    } else return null;
}

fn receiveLoop(io: Io, gpa: Allocator, fs: *FileSystem, assets: *const Assets, socket: Io.net.Socket) void {
    const log = std.log.scoped(.net_recv);
    defer socket.close(io);

    var session_manager: SessionManager = .{};
    defer session_manager.deinit(gpa);

    var connections: std.ArrayList(?*ConnectionHandle) = .empty;
    defer connections.deinit(gpa);
    defer for (connections.items) |maybe| if (maybe) |handle| {
        gpa.destroy(handle);
    };

    // a lot of this is taking "inspiration" from eileen-sr xD
    const Completion = union(enum) {
        udp_recv: Io.net.Socket.ReceiveError!Io.net.IncomingMessage,
        client: *ConnectionHandle,
    };

    var completions_buffer: [16]Completion = undefined;
    var select: Io.Select(Completion) = .init(io, &completions_buffer);
    defer select.cancelDiscard();

    var recv_buffer: [mtu]u8 = undefined;

    select.concurrent(.udp_recv, Io.net.Socket.receive, .{ &socket, io, recv_buffer[0..] }) catch {
        log.err("failed to initialize receive", .{});
        return;
    };

    while (true) switch (select.await() catch return) {
        .udp_recv => |result| {
            defer select.concurrent(.udp_recv, Io.net.Socket.receive, .{ &socket, io, recv_buffer[0..] }) catch {
                log.debug("concurrency is not available, using async instead", .{});
                select.async(.udp_recv, Io.net.Socket.receive, .{ &socket, io, recv_buffer[0..] });
            };

            const message = result catch |err| {
                if (err == error.PortUnreachable) {
                    log.debug("discarding ICMP port unreachable report", .{});
                    continue;
                }
                log.err("something went horribly wrong: {t}", .{err});
                continue;
            };

            if (message.data.len == 35 and message.data[0] == krkcp_syn) {
                log.debug("handshake received from {f}", .{message.from});

                const conv_id = if (getFreeIndex(*ConnectionHandle, connections.items)) |i| i + 1 else no_free_index: {
                    _ = connections.addOne(gpa) catch {
                        log.err("couldn't add a connection", .{});
                        continue;
                    };
                    break :no_free_index connections.items.len;
                };

                connections.items[conv_id - 1] = gpa.create(ConnectionHandle) catch {
                    log.err("couldn't allocate connection handle", .{});
                    continue;
                };

                const handle = connections.items[conv_id - 1].?;
                handle.init(io, &socket, message.from, @intCast(conv_id));

                const ClientContext = struct {
                    handle: *ConnectionHandle,
                    session_manager: *SessionManager,
                    gpa: Allocator,
                    fs: *FileSystem,
                    assets: *const Assets,

                    fn run(ctx: @This()) *ConnectionHandle {
                        Connection.process(ctx.handle, ctx.session_manager, ctx.gpa, ctx.fs, ctx.assets);
                        return ctx.handle;
                    }
                };
                select.concurrent(.client, ClientContext.run, .{.{
                    .handle = handle,
                    .session_manager = &session_manager,
                    .gpa = gpa,
                    .fs = fs,
                    .assets = assets,
                }}) catch {
                    log.debug("concurrency is not available, using async instead", .{});
                    select.async(.client, ClientContext.run, .{.{
                        .handle = handle,
                        .session_manager = &session_manager,
                        .gpa = gpa,
                        .fs = fs,
                        .assets = assets,
                    }});
                };

                var ack: [5]u8 = undefined;
                ack[0] = krkcp_ack;
                std.mem.writeInt(u32, ack[1..5], @intCast(conv_id), .little);
                socket.send(io, &message.from, ack[0..]) catch {};
            } else if (message.data.len >= kcp_overhead) {
                const conv_id = std.mem.readInt(u32, message.data[0..4], .little);
                if (conv_id > connections.items.len) continue;
                const handle = connections.items[conv_id - 1] orelse continue;

                handle.queue.putOne(io, .{
                    .buf = recv_buffer,
                    .len = message.data.len,
                }) catch continue;
            }
        },
        .client => |handle| {
            connections.items[handle.conv_id - 1] = null;
            gpa.destroy(handle);
        },
    };
}
