const std = @import("std");
const common = @import("common");

const Io = std.Io;
const Allocator = std.mem.Allocator;
const Assets = @import("../data/Assets.zig");
const FileSystem = common.FileSystem;
const network = @import("../network.zig");
const Connection = @import("Connection.zig");
const ConnectionHandle = network.ConnectionHandle;
const SessionManager = network.SessionManager;

pub fn run(
    handle: *ConnectionHandle,
    session_manager: *SessionManager,
    gpa: Allocator,
    fs: *FileSystem,
    assets: *const Assets,
) *ConnectionHandle {
    var gameplay = Connection.GameplayState.init(handle, gpa);
    Connection.runGameplay(
        handle,
        session_manager,
        gpa,
        fs,
        assets,
        &gameplay,
    );

    handle.close(.gameplay_exit);
    cleanupGameplay(&gameplay, session_manager, handle, fs);
    handle.gameplay_completions.putOneUncancelable(handle.io, handle) catch unreachable;
    handle.signalTransportWork();
    return handle;
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

const TestHandleContext = struct {
    work: Io.Event = .unset,
    completions_buf: [2]*ConnectionHandle = undefined,
    completions: Io.Queue(*ConnectionHandle),

    fn init(context: *TestHandleContext) void {
        context.work = .unset;
        context.completions = Io.Queue(*ConnectionHandle).init(&context.completions_buf);
    }
};

fn initTestHandle(handle: *ConnectionHandle, context: *TestHandleContext) void {
    context.init();
    handle.io = std.testing.io;
    handle.inbound = Io.Queue(network.OwnedMessage).init(&handle.inbound_buf);
    handle.outbound = Io.Queue(network.OwnedFrame).init(&handle.outbound_buf);
    handle.closed_event = .unset;
    handle.transport_work = &context.work;
    handle.gameplay_completions = &context.completions;
    handle.close_reason = .init(.active);
    handle.authenticated = .init(false);
}

test "same-player replacement waits for the old claim to be released" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var old_context: TestHandleContext = undefined;
    var old_handle: ConnectionHandle = undefined;
    initTestHandle(&old_handle, &old_context);
    var replacement_context: TestHandleContext = undefined;
    var replacement_handle: ConnectionHandle = undefined;
    initTestHandle(&replacement_handle, &replacement_context);

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
    try std.testing.expectEqual(network.CloseReason.replaced, old_handle.closeReason());
    try std.testing.expect(manager.sessions.get(1) == &old_handle);

    manager.release(&old_handle, 1);
    try replacement.await(std.testing.io);
    try std.testing.expect(manager.sessions.get(1) == &replacement_handle);

    manager.release(&replacement_handle, 1);
}

test "missing player claims require no cleanup release" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var context: TestHandleContext = undefined;
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle, &context);
    var gameplay = Connection.GameplayState.init(&handle, std.testing.allocator);

    cleanupGameplay(&gameplay, &manager, &handle, undefined);
    try std.testing.expectEqual(@as(usize, 0), manager.sessions.count());
}

test "acquired player claims are released during supervisor cleanup" {
    var manager: SessionManager = .{};
    defer manager.deinit(std.testing.allocator);

    var context: TestHandleContext = undefined;
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle, &context);
    try manager.acquire(std.testing.allocator, &handle, 1);

    var gameplay = Connection.GameplayState.init(&handle, std.testing.allocator);
    gameplay.claimed_player_id = 1;
    cleanupGameplay(&gameplay, &manager, &handle, undefined);

    try std.testing.expect(manager.sessions.get(1) == null);
    try std.testing.expect(gameplay.claimed_player_id == null);
}

test "session closure retains the first terminal reason" {
    var context: TestHandleContext = undefined;
    var handle: ConnectionHandle = undefined;
    initTestHandle(&handle, &context);

    handle.close(.kcp_dead_link);
    handle.close(.gameplay_exit);
    try std.testing.expectEqual(network.CloseReason.kcp_dead_link, handle.closeReason());
}
