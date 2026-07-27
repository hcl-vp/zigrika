const std = @import("std");
const Kcp = @import("kcp.zig").Kcp;

const Io = std.Io;
const Allocator = std.mem.Allocator;
const network = @import("../network.zig");
const ConnectionHandle = network.ConnectionHandle;
const OwnedFrame = network.OwnedFrame;
const OwnedMessage = network.OwnedMessage;
const RawPacket = network.RawPacket;

const session_idle_timeout_ms = 60_000;
const send_failure_limit = 3;

const StreamAssembler = struct {
    gpa: Allocator,
    length_prefix: [3]u8 = undefined,
    length_prefix_len: usize = 0,
    body: ?[]u8 = null,
    body_len: usize = 0,

    const ConsumeResult = struct {
        consumed: usize,
        message: ?OwnedMessage = null,
    };

    fn init(gpa: Allocator) StreamAssembler {
        return .{ .gpa = gpa };
    }

    fn deinit(assembler: *StreamAssembler) void {
        assembler.reset();
    }

    fn reset(assembler: *StreamAssembler) void {
        if (assembler.body) |body| assembler.gpa.free(body);
        assembler.body = null;
        assembler.body_len = 0;
        assembler.length_prefix_len = 0;
    }

    fn consume(assembler: *StreamAssembler, input: []const u8) !ConsumeResult {
        var consumed: usize = 0;

        while (consumed < input.len) {
            if (assembler.body == null) {
                const prefix_needed = assembler.length_prefix.len - assembler.length_prefix_len;
                const prefix_count = @min(prefix_needed, input.len - consumed);
                @memcpy(
                    assembler.length_prefix[assembler.length_prefix_len..][0..prefix_count],
                    input[consumed..][0..prefix_count],
                );
                assembler.length_prefix_len += prefix_count;
                consumed += prefix_count;

                if (assembler.length_prefix_len != assembler.length_prefix.len) break;

                const body_len = std.mem.readInt(u24, &assembler.length_prefix, .little);
                assembler.length_prefix_len = 0;
                assembler.body = try assembler.gpa.alloc(u8, body_len);
                assembler.body_len = 0;

                if (body_len == 0) {
                    const body = assembler.body.?;
                    assembler.body = null;
                    return .{
                        .consumed = consumed,
                        .message = .{ .bytes = body },
                    };
                }
            }

            const body = assembler.body.?;
            const body_needed = body.len - assembler.body_len;
            const body_count = @min(body_needed, input.len - consumed);
            @memcpy(
                body[assembler.body_len..][0..body_count],
                input[consumed..][0..body_count],
            );
            assembler.body_len += body_count;
            consumed += body_count;

            if (assembler.body_len == body.len) {
                assembler.body = null;
                assembler.body_len = 0;
                return .{
                    .consumed = consumed,
                    .message = .{ .bytes = body },
                };
            }
        }

        return .{ .consumed = consumed };
    }
};

const ApplicationInput = struct {
    gpa: Allocator,
    bytes: ?[]u8 = null,
    offset: usize = 0,

    fn deinit(input: *ApplicationInput) void {
        if (input.bytes) |bytes| input.gpa.free(bytes);
    }

    fn receive(input: *ApplicationInput, kcp: *Kcp) !bool {
        std.debug.assert(input.bytes == null);
        const size = kcp.peekSize() catch return false;
        const bytes = try input.gpa.alloc(u8, size);
        errdefer input.gpa.free(bytes);
        const received = try kcp.recv(bytes, false);
        std.debug.assert(received == size);
        input.bytes = bytes;
        input.offset = 0;
        return true;
    }

    fn consume(input: *ApplicationInput, assembler: *StreamAssembler) !?OwnedMessage {
        const bytes = input.bytes orelse return null;
        const result = try assembler.consume(bytes[input.offset..]);
        input.offset += result.consumed;
        if (input.offset == bytes.len) {
            input.gpa.free(bytes);
            input.bytes = null;
            input.offset = 0;
        }
        return result.message;
    }
};

const OutputContext = struct {
    handle: *ConnectionHandle,
    consecutive_send_failures: u8 = 0,
};

const Wake = struct {
    packet_ready: ?RawPacket = null,
    inbound_forwarded: bool = false,
    outbound_ready: ?OwnedFrame = null,
    kcp_deadline: bool = false,
    idle_timeout: bool = false,
    closed: bool = false,
};

const SelectResult = union(enum) {
    packet_ready: anyerror!RawPacket,
    inbound_forwarded: anyerror!void,
    outbound_ready: anyerror!OwnedFrame,
    kcp_deadline: anyerror!void,
    idle_timeout: anyerror!void,
    closed: anyerror!void,
};

fn waitForPacket(handle: *ConnectionHandle) anyerror!RawPacket {
    return handle.queue.getOne(handle.io);
}

fn forwardInbound(handle: *ConnectionHandle, message: OwnedMessage) anyerror!void {
    try handle.inbound.putOne(handle.io, message);
}

fn waitForOutbound(handle: *ConnectionHandle) anyerror!OwnedFrame {
    return handle.outbound.getOne(handle.io);
}

fn waitForDeadline(io: Io, delay_ms: i64) anyerror!void {
    try io.sleep(.fromMilliseconds(@max(delay_ms, 0)), .awake);
}

fn waitForClosed(handle: *ConnectionHandle) anyerror!void {
    try handle.closed_event.wait(handle.io);
}

fn applySelectResult(wake: *Wake, result: SelectResult) void {
    switch (result) {
        .packet_ready => |packet_result| {
            wake.packet_ready = packet_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
        },
        .inbound_forwarded => |forward_result| {
            forward_result catch |err| switch (err) {
                error.Canceled => return,
                else => {
                    wake.closed = true;
                    return;
                },
            };
            wake.inbound_forwarded = true;
        },
        .outbound_ready => |frame_result| {
            wake.outbound_ready = frame_result catch |err| switch (err) {
                error.Canceled => return,
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

fn waitForWake(
    handle: *ConnectionHandle,
    pending_inbound: ?OwnedMessage,
    kcp_delay_ms: i64,
    idle_delay_ms: i64,
) ?Wake {
    var buffer: [6]SelectResult = undefined;
    var select: Io.Select(SelectResult) = .init(handle.io, &buffer);

    select.async(.packet_ready, waitForPacket, .{handle});
    if (pending_inbound) |message| {
        select.async(.inbound_forwarded, forwardInbound, .{ handle, message });
    }
    select.async(.outbound_ready, waitForOutbound, .{handle});
    select.async(.kcp_deadline, waitForDeadline, .{ handle.io, kcp_delay_ms });
    select.async(.idle_timeout, waitForDeadline, .{ handle.io, idle_delay_ms });
    select.async(.closed, waitForClosed, .{handle});

    const first = select.await() catch {
        select.cancelDiscard();
        return null;
    };

    var wake: Wake = .{};
    applySelectResult(&wake, first);
    while (select.cancel()) |extra| {
        applySelectResult(&wake, extra);
    }
    return wake;
}

fn pumpApplicationData(
    kcp: *Kcp,
    assembler: *StreamAssembler,
    application: *ApplicationInput,
) !?OwnedMessage {
    while (true) {
        if (application.bytes == null and !try application.receive(kcp)) return null;
        if (try application.consume(assembler)) |message| return message;
    }
}

fn idleWakeDelayMs(now_ms: i64, last_receive_time_ms: i64) i64 {
    return @max(session_idle_timeout_ms - (now_ms - last_receive_time_ms), 0);
}

fn idleExpired(now_ms: i64, last_receive_time_ms: i64) bool {
    return now_ms - last_receive_time_ms >= session_idle_timeout_ms;
}

fn needsFinalFlush(packet_output: bool, kcp_updated: bool, outbound_output: bool) bool {
    return (packet_output or outbound_output) and !kcp_updated;
}

fn checkTransportHealth(kcp: *Kcp, output: *const OutputContext) !void {
    try validateTransportHealth(kcp.isDead(), output.consecutive_send_failures);
}

fn validateTransportHealth(dead_link: bool, consecutive_send_failures: u8) !void {
    if (dead_link) return error.KcpDeadLink;
    if (consecutive_send_failures >= send_failure_limit) return error.SendFailed;
}

pub fn run(handle: *ConnectionHandle, gpa: Allocator) void {
    runInner(handle, gpa) catch |err| {
        std.log.scoped(.kcp_transport).err("transport failed: {t}, disconnecting", .{err});
    };
}

fn runInner(handle: *ConnectionHandle, gpa: Allocator) !void {
    const clock: Io.Clock = .awake;
    const init_time = clock.now(handle.io).toMilliseconds();

    var output_context: OutputContext = .{ .handle = handle };
    var kcp = try Kcp.init(gpa, handle.conv_id, @intFromPtr(&output_context));
    defer kcp.deinit();
    kcp.setOutput(kcpOutput);

    var assembler = StreamAssembler.init(gpa);
    defer assembler.deinit();
    var application: ApplicationInput = .{ .gpa = gpa };
    defer application.deinit();
    var pending_inbound: ?OwnedMessage = null;
    defer if (pending_inbound) |message| gpa.free(message.bytes);

    var last_receive_time_ms = init_time;

    while (true) {
        if (pending_inbound == null) {
            pending_inbound = try pumpApplicationData(&kcp, &assembler, &application);
        }

        const wait_now_ms = clock.now(handle.io).toMilliseconds();
        const elapsed_ms: u32 = @intCast(wait_now_ms - init_time);
        const wake = waitForWake(
            handle,
            pending_inbound,
            kcp.nextUpdateDelay(elapsed_ms),
            idleWakeDelayMs(wait_now_ms, last_receive_time_ms),
        ) orelse return;

        if (wake.inbound_forwarded) pending_inbound = null;

        if (wake.closed) {
            if (wake.outbound_ready) |frame| gpa.free(frame.bytes);
            return;
        }

        var packet_output = false;
        var outbound_output = false;
        var kcp_updated = false;

        if (wake.packet_ready) |packet| {
            _ = try kcp.input(packet.buf[0..packet.len]);
            last_receive_time_ms = clock.now(handle.io).toMilliseconds();
            packet_output = true;
        }

        if (wake.outbound_ready) |frame| {
            defer gpa.free(frame.bytes);
            _ = try kcp.send(frame.bytes);
            outbound_output = true;
        }

        const now_ms = clock.now(handle.io).toMilliseconds();
        if (wake.idle_timeout and idleExpired(now_ms, last_receive_time_ms)) {
            return error.IdleTimeout;
        }

        if (wake.kcp_deadline) {
            try kcp.update(@intCast(now_ms - init_time));
            try checkTransportHealth(&kcp, &output_context);
            kcp_updated = true;
        }

        if (needsFinalFlush(packet_output, kcp_updated, outbound_output)) {
            try kcp.flush();
            try checkTransportHealth(&kcp, &output_context);
        }
    }
}

fn kcpOutput(buf: []const u8, kcp: *Kcp, user: ?usize) usize {
    const output: *OutputContext = @ptrFromInt(user.?);
    const handle = output.handle;
    if (handle.socket.send(handle.io, &handle.address, buf)) {
        output.consecutive_send_failures = 0;
        return buf.len;
    } else |err| {
        output.consecutive_send_failures +|= 1;
        std.log.debug(
            "send failed, conv: {d}, end_point: {f}, data_len: {d}, error: {t}",
            .{ kcp.conv, handle.address, buf.len, err },
        );
        return 0;
    }
}

fn appendFramed(list: *std.ArrayList(u8), body: []const u8) !void {
    var prefix: [3]u8 = undefined;
    std.mem.writeInt(u24, &prefix, @intCast(body.len), .little);
    try list.appendSlice(std.testing.allocator, &prefix);
    try list.appendSlice(std.testing.allocator, body);
}

test "stream assembler accepts a split length prefix" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    const body = "prefix";
    var framed: std.ArrayList(u8) = .empty;
    defer framed.deinit(std.testing.allocator);
    try appendFramed(&framed, body);

    try std.testing.expect((try assembler.consume(framed.items[0..2])).message == null);
    const result = try assembler.consume(framed.items[2..]);
    defer std.testing.allocator.free(result.message.?.bytes);
    try std.testing.expectEqualStrings(body, result.message.?.bytes);
}

test "stream assembler accepts a split body" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    const body = "split-body";
    var framed: std.ArrayList(u8) = .empty;
    defer framed.deinit(std.testing.allocator);
    try appendFramed(&framed, body);

    try std.testing.expect((try assembler.consume(framed.items[0..6])).message == null);
    const result = try assembler.consume(framed.items[6..]);
    defer std.testing.allocator.free(result.message.?.bytes);
    try std.testing.expectEqualStrings(body, result.message.?.bytes);
}

test "stream assembler preserves several messages in one payload" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    var framed: std.ArrayList(u8) = .empty;
    defer framed.deinit(std.testing.allocator);
    try appendFramed(&framed, "one");
    try appendFramed(&framed, "two");

    const first = try assembler.consume(framed.items);
    defer std.testing.allocator.free(first.message.?.bytes);
    try std.testing.expectEqualStrings("one", first.message.?.bytes);

    const second = try assembler.consume(framed.items[first.consumed..]);
    defer std.testing.allocator.free(second.message.?.bytes);
    try std.testing.expectEqualStrings("two", second.message.?.bytes);
    try std.testing.expectEqual(framed.items.len, first.consumed + second.consumed);
}

test "stream assembler completes exactly at an input boundary" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    var framed: std.ArrayList(u8) = .empty;
    defer framed.deinit(std.testing.allocator);
    try appendFramed(&framed, "boundary");

    const result = try assembler.consume(framed.items);
    defer std.testing.allocator.free(result.message.?.bytes);
    try std.testing.expectEqual(framed.items.len, result.consumed);
    try std.testing.expectEqualStrings("boundary", result.message.?.bytes);
}

test "stream assembler accepts the maximum wire length prefix" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 0,
    });
    var limited = StreamAssembler.init(failing.allocator());
    defer limited.deinit();
    const prefix: [3]u8 = @splat(0xff);
    try std.testing.expectError(error.OutOfMemory, limited.consume(&prefix));
    try std.testing.expectEqual(@as(usize, 0), limited.length_prefix_len);
}

test "stream assembler frees truncated storage on reset and deinit" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    const framed = [_]u8{ 5, 0, 0, 1, 2 };
    try std.testing.expect((try assembler.consume(&framed)).message == null);
    assembler.reset();
    try std.testing.expect(assembler.body == null);
    try std.testing.expectEqual(@as(usize, 0), assembler.length_prefix_len);
    assembler.deinit();
}

test "transport wake preserves simultaneous completions" {
    var wake: Wake = .{};
    const packet: RawPacket = .{ .buf = undefined, .len = 0 };
    const frame: OwnedFrame = .{ .bytes = undefined };
    applySelectResult(&wake, .{ .packet_ready = packet });
    applySelectResult(&wake, .{ .inbound_forwarded = {} });
    applySelectResult(&wake, .{ .outbound_ready = frame });
    applySelectResult(&wake, .{ .kcp_deadline = {} });
    applySelectResult(&wake, .{ .idle_timeout = {} });

    try std.testing.expect(wake.packet_ready != null);
    try std.testing.expect(wake.inbound_forwarded);
    try std.testing.expect(wake.outbound_ready != null);
    try std.testing.expect(wake.kcp_deadline);
    try std.testing.expect(wake.idle_timeout);
    try std.testing.expect(!wake.closed);
}

test "canceled transport waits do not become wake reasons" {
    var wake: Wake = .{};
    applySelectResult(&wake, .{ .packet_ready = error.Canceled });
    applySelectResult(&wake, .{ .inbound_forwarded = error.Canceled });
    applySelectResult(&wake, .{ .outbound_ready = error.Canceled });
    applySelectResult(&wake, .{ .kcp_deadline = error.Canceled });
    applySelectResult(&wake, .{ .idle_timeout = error.Canceled });
    applySelectResult(&wake, .{ .closed = error.Canceled });

    try std.testing.expect(wake.packet_ready == null);
    try std.testing.expect(!wake.inbound_forwarded);
    try std.testing.expect(wake.outbound_ready == null);
    try std.testing.expect(!wake.kcp_deadline);
    try std.testing.expect(!wake.idle_timeout);
    try std.testing.expect(!wake.closed);
}

test "full inbound queue retains transport responsiveness" {
    var packet_buffer: [1]RawPacket = undefined;
    var inbound_buffer: [1]OwnedMessage = undefined;
    var outbound_buffer: [1]OwnedFrame = undefined;
    var handle: ConnectionHandle = undefined;
    handle.io = std.testing.io;
    handle.queue = Io.Queue(RawPacket).init(&packet_buffer);
    handle.inbound = Io.Queue(OwnedMessage).init(&inbound_buffer);
    handle.outbound = Io.Queue(OwnedFrame).init(&outbound_buffer);
    handle.closed_event = .unset;

    const occupied: OwnedMessage = .{ .bytes = undefined };
    const pending: OwnedMessage = .{ .bytes = undefined };
    const outbound: OwnedFrame = .{ .bytes = undefined };
    const packet: RawPacket = .{ .buf = undefined, .len = 0 };
    try handle.inbound.putOne(std.testing.io, occupied);
    try handle.queue.putOne(std.testing.io, packet);

    const packet_wake = waitForWake(&handle, pending, 60_000, 60_000).?;
    try std.testing.expect(packet_wake.packet_ready != null);
    try std.testing.expect(!packet_wake.inbound_forwarded);

    try handle.outbound.putOne(std.testing.io, outbound);
    const outbound_wake = waitForWake(&handle, pending, 60_000, 60_000).?;
    try std.testing.expect(outbound_wake.outbound_ready != null);
    try std.testing.expect(!outbound_wake.inbound_forwarded);

    const deadline_wake = waitForWake(&handle, pending, 0, 60_000).?;
    try std.testing.expect(deadline_wake.kcp_deadline);
    try std.testing.expect(!deadline_wake.inbound_forwarded);

    _ = try handle.inbound.getOne(std.testing.io);
    const inbound_wake = waitForWake(&handle, pending, 60_000, 60_000).?;
    try std.testing.expect(inbound_wake.inbound_forwarded);
    _ = try handle.inbound.getOne(std.testing.io);
}

test "transport health detects dead links and repeated send failures" {
    try std.testing.expectError(error.KcpDeadLink, validateTransportHealth(true, 0));
    try std.testing.expectError(error.SendFailed, validateTransportHealth(false, send_failure_limit));
    try validateTransportHealth(false, send_failure_limit - 1);
}

test "transport flush decision avoids duplicate work" {
    try std.testing.expect(needsFinalFlush(true, false, false));
    try std.testing.expect(!needsFinalFlush(true, true, false));
    try std.testing.expect(!needsFinalFlush(true, true, true));
}
