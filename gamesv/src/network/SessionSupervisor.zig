const std = @import("std");
const common = @import("common");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const Assets = @import("../data/Assets.zig");
const FileSystem = common.FileSystem;
const network = @import("../network.zig");
const Connection = @import("Connection.zig");
const ConnectionHandle = network.ConnectionHandle;
const KcpTransport = @import("KcpTransport.zig");
const OwnedFrame = network.OwnedFrame;
const OwnedMessage = network.OwnedMessage;
const SessionManager = network.SessionManager;

const OwnerContext = struct {
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
    gameplay: *Connection.GameplayState,
    owner_stopped: *Io.Event,
};

pub fn run(
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
) void {
    var gameplay_state = Connection.GameplayState.init(handle, gpa);
    var owner_stopped: Io.Event = .unset;
    const context: OwnerContext = .{
        .handle = handle,
        .session_manager = session_manager,
        .gpa = gpa,
        .fs = fs,
        .assets = assets,
        .gameplay = &gameplay_state,
        .owner_stopped = &owner_stopped,
    };

    const transport_args = .{context};
    var transport = handle.io.concurrent(runTransport, transport_args) catch
        handle.io.async(runTransport, transport_args);

    const gameplay_args = .{context};
    var gameplay = handle.io.concurrent(runGameplay, gameplay_args) catch
        handle.io.async(runGameplay, gameplay_args);

    stopOnOwnerExit(handle, &owner_stopped);

    gameplay.await(handle.io);
    cleanupGameplay(&gameplay_state, session_manager, handle, fs);

    transport.await(handle.io);
    drainOwnedMessages(gpa, handle.io, &handle.inbound);
    drainOwnedFrames(gpa, handle.io, &handle.outbound);
}

fn stopOnOwnerExit(handle: *ConnectionHandle, owner_stopped: *Io.Event) void {
    owner_stopped.wait(handle.io) catch {};
    handle.close();
}

fn runTransport(context: OwnerContext) void {
    defer context.owner_stopped.set(context.handle.io);
    KcpTransport.run(context.handle, context.gpa);
}

fn runGameplay(context: OwnerContext) void {
    defer context.owner_stopped.set(context.handle.io);
    Connection.runGameplay(
        context.handle,
        context.session_manager,
        context.gpa,
        context.fs,
        context.assets,
        context.gameplay,
    );
}

fn cleanupGameplay(
    gameplay: *Connection.GameplayState,
    session_manager: *SessionManager,
    handle: *ConnectionHandle,
    fs: *FileSystem,
) void {
    if (gameplay.state) |*state| {
        state.deinit(fs);
        gameplay.state = null;
    }

    if (gameplay.claimed_player_id) |player_id| {
        session_manager.release(handle, player_id);
        gameplay.claimed_player_id = null;
    }
}

fn drainOwnedFrames(gpa: Allocator, io: Io, queue: *Io.Queue(OwnedFrame)) void {
    var frames: [32]OwnedFrame = undefined;
    while (true) {
        const count = queue.get(io, &frames, 0) catch return;
        if (count == 0) return;
        for (frames[0..count]) |frame| gpa.free(frame.bytes);
    }
}

fn drainOwnedMessages(gpa: Allocator, io: Io, queue: *Io.Queue(OwnedMessage)) void {
    var messages: [32]OwnedMessage = undefined;
    while (true) {
        const count = queue.get(io, &messages, 0) catch return;
        if (count == 0) return;
        for (messages[0..count]) |message| gpa.free(message.bytes);
    }
}

fn initTestHandle(handle: *ConnectionHandle) void {
    handle.io = std.testing.io;
    handle.queue = Io.Queue(network.RawPacket).init(&handle.queue_buf);
    handle.inbound = Io.Queue(OwnedMessage).init(&handle.inbound_buf);
    handle.outbound = Io.Queue(OwnedFrame).init(&handle.outbound_buf);
    handle.closed_event = .unset;
}

test "closed session queues drain owned inbound and outbound storage" {
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle);

    try handle.inbound.putOne(std.testing.io, .{
        .bytes = try std.testing.allocator.dupe(u8, "inbound"),
    });
    try handle.outbound.putOne(std.testing.io, .{
        .bytes = try std.testing.allocator.dupe(u8, "outbound"),
    });

    handle.close();
    drainOwnedMessages(std.testing.allocator, std.testing.io, &handle.inbound);
    drainOwnedFrames(std.testing.allocator, std.testing.io, &handle.outbound);
}

test "same-player replacement waits for the old claim to be released" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var old_handle: ConnectionHandle = undefined;
    initTestHandle(&old_handle);
    var replacement_handle: ConnectionHandle = undefined;
    initTestHandle(&replacement_handle);

    try manager.acquire(std.testing.allocator, &old_handle, 1);

    const AcquireContext = struct {
        fn run(
            session_manager: *SessionManager,
            handle: *ConnectionHandle,
        ) !void {
            try session_manager.acquire(std.testing.allocator, handle, 1);
        }
    };
    const args = .{ &manager, &replacement_handle };
    var replacement = std.testing.io.concurrent(AcquireContext.run, args) catch
        std.testing.io.async(AcquireContext.run, args);

    try old_handle.closed_event.wait(std.testing.io);
    try std.testing.expect(manager.sessions.get(1) == &old_handle);

    manager.release(&old_handle, 1);
    try replacement.await(std.testing.io);
    try std.testing.expect(manager.sessions.get(1) == &replacement_handle);

    manager.release(&replacement_handle, 1);
}

test "missing player claims require no cleanup release" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle);
    var gameplay = Connection.GameplayState.init(&handle, std.testing.allocator);

    cleanupGameplay(&gameplay, &manager, &handle, undefined);
    try std.testing.expectEqual(@as(usize, 0), manager.sessions.count());
}

test "acquired player claims are released during supervisor cleanup" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle);
    try manager.acquire(std.testing.allocator, &handle, 1);

    var gameplay = Connection.GameplayState.init(&handle, std.testing.allocator);
    gameplay.claimed_player_id = 1;
    cleanupGameplay(&gameplay, &manager, &handle, undefined);

    try std.testing.expect(manager.sessions.get(1) == null);
    try std.testing.expect(gameplay.claimed_player_id == null);
}

fn waitForInbound(handle: *ConnectionHandle) !void {
    _ = try handle.inbound.getOne(handle.io);
}

fn waitForPacket(handle: *ConnectionHandle) !void {
    _ = try handle.queue.getOne(handle.io);
}

fn signalOwnerStopped(event: *Io.Event, io: Io) void {
    event.set(io);
}

test "transport-first shutdown closes and joins the gameplay lane" {
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle);
    var owner_stopped: Io.Event = .unset;

    const gameplay_args = .{&handle};
    var gameplay = std.testing.io.concurrent(waitForInbound, gameplay_args) catch
        std.testing.io.async(waitForInbound, gameplay_args);
    const transport_args = .{ &owner_stopped, std.testing.io };
    var transport = std.testing.io.concurrent(signalOwnerStopped, transport_args) catch
        std.testing.io.async(signalOwnerStopped, transport_args);

    stopOnOwnerExit(&handle, &owner_stopped);
    transport.await(std.testing.io);
    try std.testing.expectError(error.Closed, gameplay.await(std.testing.io));
}

test "gameplay-first shutdown closes and joins the transport lane" {
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle);
    var owner_stopped: Io.Event = .unset;

    const transport_args = .{&handle};
    var transport = std.testing.io.concurrent(waitForPacket, transport_args) catch
        std.testing.io.async(waitForPacket, transport_args);
    const gameplay_args = .{ &owner_stopped, std.testing.io };
    var gameplay = std.testing.io.concurrent(signalOwnerStopped, gameplay_args) catch
        std.testing.io.async(signalOwnerStopped, gameplay_args);

    stopOnOwnerExit(&handle, &owner_stopped);
    gameplay.await(std.testing.io);
    try std.testing.expectError(error.Closed, transport.await(std.testing.io));
}
