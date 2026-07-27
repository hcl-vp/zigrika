const std = @import("std");
const kcp_module = @import("kcp.zig");
const Kcp = kcp_module.Kcp;

const Io = std.Io;
const Allocator = std.mem.Allocator;
const network = @import("../network.zig");
const ConnectionHandle = network.ConnectionHandle;
const OwnedFrame = network.OwnedFrame;
const OwnedMessage = network.OwnedMessage;

pub const pre_auth_idle_timeout_ms: i64 = 10_000;
pub const authenticated_idle_timeout_ms: i64 = 5 * 60_000;
pub const overhead = kcp_module.overhead;
const send_failure_limit = 3;
const action_limit = 64;
const time_limit_ns = 2 * std.time.ns_per_ms;

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

const Phase = enum(u1) {
    pre_auth,
    authenticated,
};

const Session = struct {
    handle: *ConnectionHandle,
    kcp: Kcp,
    output: OutputContext,
    assembler: StreamAssembler,
    application: ApplicationInput,
    pending_inbound: ?OwnedMessage = null,
    init_time_ms: i64,
    last_receive_time_ms: i64,
    phase: Phase = .pre_auth,

    fn init(session: *Session, gpa: Allocator, handle: *ConnectionHandle, now_ms: i64) !void {
        session.* = .{
            .handle = handle,
            .kcp = undefined,
            .output = .{ .handle = handle },
            .assembler = StreamAssembler.init(gpa),
            .application = .{ .gpa = gpa },
            .init_time_ms = now_ms,
            .last_receive_time_ms = now_ms,
        };
        session.kcp = try Kcp.init(gpa, handle.conv_id, @intFromPtr(&session.output));
        errdefer session.assembler.deinit();
        session.kcp.setOutput(kcpOutput);
    }

    fn deinit(session: *Session, gpa: Allocator) void {
        if (session.pending_inbound) |message| gpa.free(message.bytes);
        session.application.deinit();
        session.assembler.deinit();
        session.kcp.deinit();
    }

    fn elapsedMs(session: *const Session, now_ms: i64) u32 {
        const elapsed: u64 = @intCast(@max(now_ms - session.init_time_ms, 0));
        return @truncate(elapsed);
    }

    fn idleTimeoutMs(session: *const Session) i64 {
        return switch (session.phase) {
            .pre_auth => pre_auth_idle_timeout_ms,
            .authenticated => authenticated_idle_timeout_ms,
        };
    }

    fn idleDeadlineMs(session: *const Session) i64 {
        return saturatingAdd(session.last_receive_time_ms, session.idleTimeoutMs());
    }
};

const DeadlineKind = enum(u1) {
    kcp_update,
    idle,
};

const DeadlineEntry = struct {
    conv_id: u32,
    kind: DeadlineKind,
    due_ms: i64,
};

const DeadlineHeap = struct {
    heap: std.ArrayListUnmanaged(DeadlineEntry) = .empty,
    positions: std.AutoHashMapUnmanaged(u64, usize) = .empty,

    fn deinit(deadlines: *DeadlineHeap, gpa: Allocator) void {
        deadlines.heap.deinit(gpa);
        deadlines.positions.deinit(gpa);
    }

    fn upsert(deadlines: *DeadlineHeap, gpa: Allocator, entry: DeadlineEntry) !void {
        const entry_key = deadlineKey(entry.conv_id, entry.kind);
        if (deadlines.positions.get(entry_key)) |index| {
            const previous = deadlines.heap.items[index];
            deadlines.heap.items[index] = entry;
            if (deadlineLess(entry, previous)) {
                deadlines.siftUp(index);
            } else if (deadlineLess(previous, entry)) {
                deadlines.siftDown(index);
            }
            return;
        }

        const index = deadlines.heap.items.len;
        try deadlines.heap.append(gpa, entry);
        errdefer _ = deadlines.heap.pop();
        try deadlines.positions.put(gpa, entry_key, index);
        deadlines.siftUp(index);
    }

    fn cancel(deadlines: *DeadlineHeap, conv_id: u32, kind: DeadlineKind) void {
        const index = deadlines.positions.get(deadlineKey(conv_id, kind)) orelse return;
        _ = deadlines.removeAt(index);
    }

    fn cancelSession(deadlines: *DeadlineHeap, conv_id: u32) void {
        deadlines.cancel(conv_id, .kcp_update);
        deadlines.cancel(conv_id, .idle);
    }

    fn peekDueMs(deadlines: *const DeadlineHeap) ?i64 {
        return if (deadlines.heap.items.len == 0) null else deadlines.heap.items[0].due_ms;
    }

    fn popDue(deadlines: *DeadlineHeap, now_ms: i64) ?DeadlineEntry {
        if (deadlines.heap.items.len == 0 or deadlines.heap.items[0].due_ms > now_ms) return null;
        return deadlines.removeAt(0);
    }

    fn removeAt(deadlines: *DeadlineHeap, index: usize) DeadlineEntry {
        const removed = deadlines.heap.items[index];
        _ = deadlines.positions.remove(deadlineKey(removed.conv_id, removed.kind));

        const last_index = deadlines.heap.items.len - 1;
        if (index == last_index) {
            _ = deadlines.heap.pop();
            return removed;
        }

        deadlines.heap.items[index] = deadlines.heap.items[last_index];
        _ = deadlines.heap.pop();
        deadlines.positions.getPtr(deadlineKey(
            deadlines.heap.items[index].conv_id,
            deadlines.heap.items[index].kind,
        )).?.* = index;

        if (index > 0 and deadlineLess(
            deadlines.heap.items[index],
            deadlines.heap.items[(index - 1) / 2],
        )) {
            deadlines.siftUp(index);
        } else {
            deadlines.siftDown(index);
        }
        return removed;
    }

    fn siftUp(deadlines: *DeadlineHeap, start_index: usize) void {
        var index = start_index;
        while (index > 0) {
            const parent = (index - 1) / 2;
            if (!deadlineLess(deadlines.heap.items[index], deadlines.heap.items[parent])) break;
            deadlines.swapEntries(index, parent);
            index = parent;
        }
    }

    fn siftDown(deadlines: *DeadlineHeap, start_index: usize) void {
        var index = start_index;
        while (true) {
            const left = index * 2 + 1;
            if (left >= deadlines.heap.items.len) return;
            const right = left + 1;
            const child = if (right < deadlines.heap.items.len and
                deadlineLess(deadlines.heap.items[right], deadlines.heap.items[left])) right else left;
            if (!deadlineLess(deadlines.heap.items[child], deadlines.heap.items[index])) return;
            deadlines.swapEntries(index, child);
            index = child;
        }
    }

    fn swapEntries(deadlines: *DeadlineHeap, a: usize, b: usize) void {
        std.mem.swap(DeadlineEntry, &deadlines.heap.items[a], &deadlines.heap.items[b]);
        deadlines.positions.getPtr(deadlineKey(
            deadlines.heap.items[a].conv_id,
            deadlines.heap.items[a].kind,
        )).?.* = a;
        deadlines.positions.getPtr(deadlineKey(
            deadlines.heap.items[b].conv_id,
            deadlines.heap.items[b].kind,
        )).?.* = b;
    }
};

const WorkBudget = struct {
    started_ns: i96,
    actions: usize = 0,

    fn canStart(budget: WorkBudget, now_ns: i96) bool {
        if (budget.actions == 0) return true;
        return budget.actions < action_limit and now_ns - budget.started_ns < time_limit_ns;
    }

    fn complete(budget: *WorkBudget) void {
        budget.actions += 1;
    }
};

const ActionClass = enum(u2) {
    inbound,
    outbound,
    deadline,
};

pub const Registry = struct {
    gpa: Allocator,
    active: std.AutoHashMapUnmanaged(u32, *Session) = .empty,
    all: std.AutoHashMapUnmanaged(u32, *Session) = .empty,
    issued_ids: std.AutoHashMapUnmanaged(u32, void) = .empty,
    order: std.ArrayListUnmanaged(u32) = .empty,
    deadlines: DeadlineHeap = .{},
    next_conv_id: u32 = 1,
    inbound_cursor: usize = 0,
    outbound_cursor: usize = 0,
    next_action_class: ActionClass = .inbound,

    pub fn init(gpa: Allocator) Registry {
        return .{ .gpa = gpa };
    }

    pub fn deinit(registry: *Registry) void {
        for (registry.order.items) |conv_id| {
            const session = registry.all.get(conv_id) orelse continue;
            session.deinit(registry.gpa);
            registry.gpa.destroy(session);
        }
        registry.active.deinit(registry.gpa);
        registry.all.deinit(registry.gpa);
        registry.issued_ids.deinit(registry.gpa);
        registry.order.deinit(registry.gpa);
        registry.deadlines.deinit(registry.gpa);
    }

    pub fn allocateConvId(registry: *Registry) !u32 {
        const first = registry.next_conv_id;
        while (true) {
            const candidate = registry.next_conv_id;
            registry.next_conv_id +%= 1;
            if (registry.next_conv_id == 0) registry.next_conv_id = 1;
            if (!registry.issued_ids.contains(candidate)) {
                try registry.issued_ids.put(registry.gpa, candidate, {});
                return candidate;
            }
            if (registry.next_conv_id == first) return error.ConversationIdsExhausted;
        }
    }

    pub fn create(
        registry: *Registry,
        handle: *ConnectionHandle,
        now_ms: i64,
    ) !void {
        const session = try registry.gpa.create(Session);
        errdefer registry.gpa.destroy(session);
        try session.init(registry.gpa, handle, now_ms);
        errdefer session.deinit(registry.gpa);

        try registry.all.put(registry.gpa, handle.conv_id, session);
        errdefer _ = registry.all.remove(handle.conv_id);
        try registry.active.put(registry.gpa, handle.conv_id, session);
        errdefer _ = registry.active.remove(handle.conv_id);
        try registry.order.append(registry.gpa, handle.conv_id);
        errdefer _ = registry.order.pop();

        try registry.scheduleSession(session, now_ms);
    }

    pub fn containsActive(registry: *const Registry, conv_id: u32) bool {
        return registry.active.contains(conv_id);
    }

    pub fn sessionCount(registry: *const Registry) usize {
        return registry.all.count();
    }

    pub fn closeAll(registry: *Registry, reason: network.CloseReason) void {
        for (registry.order.items) |conv_id| {
            const session = registry.all.get(conv_id) orelse continue;
            registry.markClosing(session, reason);
        }
    }

    pub fn input(
        registry: *Registry,
        conv_id: u32,
        from: *const Io.net.IpAddress,
        bytes: []const u8,
        now_ms: i64,
    ) bool {
        const session = registry.active.get(conv_id) orelse return false;
        const close_reason = session.handle.closeReason();
        if (close_reason != .active) {
            registry.markClosing(session, close_reason);
            return false;
        }
        if (!registeredEndpointMatches(&session.handle.address, from)) return false;

        _ = session.kcp.input(bytes) catch {
            registry.markClosing(session, .invalid_kcp_packet);
            return false;
        };
        session.last_receive_time_ms = now_ms;
        session.kcp.flush() catch {
            registry.markClosing(session, .send_failed);
            return false;
        };
        if (session.output.consecutive_send_failures >= send_failure_limit) {
            registry.markClosing(session, .send_failed);
            return false;
        }
        registry.scheduleSession(session, now_ms) catch {
            registry.markClosing(session, .transport_error);
            return false;
        };
        return true;
    }

    pub fn nextWakeDelayMs(registry: *const Registry, now_ms: i64) ?i64 {
        const due_ms = registry.deadlines.peekDueMs() orelse return null;
        return @max(due_ms - now_ms, 0);
    }

    pub fn drainReady(registry: *Registry, io: Io, now_ms: i64) bool {
        var budget: WorkBudget = .{
            .started_ns = Io.Clock.awake.now(io).toNanoseconds(),
        };
        registry.syncSharedState(now_ms);

        var empty_classes: u2 = 0;
        while (budget.canStart(Io.Clock.awake.now(io).toNanoseconds()) and empty_classes < 3) {
            const progressed = switch (registry.next_action_class) {
                .inbound => registry.forwardNext(),
                .outbound => registry.sendNext(now_ms),
                .deadline => registry.processNextDeadline(now_ms),
            };
            registry.next_action_class = switch (registry.next_action_class) {
                .inbound => .outbound,
                .outbound => .deadline,
                .deadline => .inbound,
            };

            if (progressed) {
                budget.complete();
                empty_classes = 0;
            } else {
                empty_classes += 1;
            }
        }

        return !budget.canStart(Io.Clock.awake.now(io).toNanoseconds());
    }

    pub fn markClosingByHandle(
        registry: *Registry,
        handle: *ConnectionHandle,
        reason: network.CloseReason,
    ) void {
        const session = registry.all.get(handle.conv_id) orelse return;
        registry.markClosing(session, reason);
    }

    pub fn finalize(registry: *Registry, handle: *ConnectionHandle, now_ms: i64) void {
        const session = registry.all.get(handle.conv_id) orelse return;
        registry.markClosing(session, handle.closeReason());

        const inbound_depth = handle.inbound.type_erased.len / @sizeOf(OwnedMessage);
        const outbound_depth = handle.outbound.type_erased.len / @sizeOf(OwnedFrame);
        std.log.scoped(.kcp_transport).info(
            "session ended, conv: {d}, endpoint: {f}, phase: {t}, reason: {t}, last_input_age_ms: {d}, send_failures: {d}, inbound_depth: {d}, outbound_depth: {d}",
            .{
                handle.conv_id,
                handle.address,
                session.phase,
                handle.closeReason(),
                @max(now_ms - session.last_receive_time_ms, 0),
                session.output.consecutive_send_failures,
                inbound_depth,
                outbound_depth,
            },
        );

        drainOwnedMessages(registry.gpa, handle.io, &handle.inbound);
        drainOwnedFrames(registry.gpa, handle.io, &handle.outbound);

        _ = registry.active.remove(handle.conv_id);
        _ = registry.all.remove(handle.conv_id);
        registry.deadlines.cancelSession(handle.conv_id);
        for (registry.order.items, 0..) |conv_id, index| {
            if (conv_id == handle.conv_id) {
                _ = registry.order.orderedRemove(index);
                if (registry.order.items.len == 0) {
                    registry.inbound_cursor = 0;
                    registry.outbound_cursor = 0;
                } else {
                    if (registry.inbound_cursor >= registry.order.items.len) registry.inbound_cursor = 0;
                    if (registry.outbound_cursor >= registry.order.items.len) registry.outbound_cursor = 0;
                }
                break;
            }
        }

        session.deinit(registry.gpa);
        registry.gpa.destroy(session);
    }

    fn syncSharedState(registry: *Registry, now_ms: i64) void {
        for (registry.order.items) |conv_id| {
            const session = registry.active.get(conv_id) orelse continue;
            const close_reason = session.handle.closeReason();
            if (close_reason != .active) {
                registry.markClosing(session, close_reason);
                continue;
            }

            if (session.phase == .pre_auth and session.handle.isAuthenticated()) {
                session.phase = .authenticated;
                registry.scheduleIdle(session) catch {
                    registry.markClosing(session, .transport_error);
                };
            }
        }
        _ = now_ms;
    }

    fn forwardNext(registry: *Registry) bool {
        var visited: usize = 0;
        while (visited < registry.order.items.len) : (visited += 1) {
            registry.inbound_cursor %= registry.order.items.len;
            const conv_id = registry.order.items[registry.inbound_cursor];
            registry.inbound_cursor = (registry.inbound_cursor + 1) % registry.order.items.len;
            const session = registry.active.get(conv_id) orelse continue;
            if (registry.forwardOne(session)) return true;
        }
        return false;
    }

    fn sendNext(registry: *Registry, now_ms: i64) bool {
        var visited: usize = 0;
        while (visited < registry.order.items.len) : (visited += 1) {
            registry.outbound_cursor %= registry.order.items.len;
            const conv_id = registry.order.items[registry.outbound_cursor];
            registry.outbound_cursor = (registry.outbound_cursor + 1) % registry.order.items.len;
            const session = registry.active.get(conv_id) orelse continue;
            if (registry.sendOne(session, now_ms)) return true;
        }
        return false;
    }

    fn processNextDeadline(registry: *Registry, now_ms: i64) bool {
        while (registry.deadlines.popDue(now_ms)) |entry| {
            const session = registry.active.get(entry.conv_id) orelse continue;
            registry.processDeadline(session, entry.kind, now_ms);
            return true;
        }
        return false;
    }

    fn forwardOne(registry: *Registry, session: *Session) bool {
        if (session.pending_inbound == null) {
            session.pending_inbound = pumpApplicationData(
                &session.kcp,
                &session.assembler,
                &session.application,
            ) catch {
                registry.markClosing(session, .transport_error);
                return false;
            };
        }

        const message = session.pending_inbound orelse return false;
        const count = session.handle.inbound.put(session.handle.io, &.{message}, 0) catch {
            registry.markClosing(session, .gameplay_exit);
            return false;
        };
        if (count == 0) return false;
        session.pending_inbound = null;
        return true;
    }

    fn sendOne(registry: *Registry, session: *Session, now_ms: i64) bool {
        var frames: [1]OwnedFrame = undefined;
        const count = session.handle.outbound.get(session.handle.io, &frames, 0) catch |err| switch (err) {
            error.Closed => return false,
            else => {
                registry.markClosing(session, .transport_error);
                return false;
            },
        };
        if (count == 0) return false;

        const frame = frames[0];
        defer registry.gpa.free(frame.bytes);
        _ = session.kcp.send(frame.bytes) catch {
            registry.markClosing(session, .transport_error);
            return true;
        };
        session.kcp.flush() catch {
            registry.markClosing(session, .send_failed);
            return true;
        };
        if (session.output.consecutive_send_failures >= send_failure_limit) {
            registry.markClosing(session, .send_failed);
            return true;
        }
        registry.scheduleKcp(session, now_ms) catch {
            registry.markClosing(session, .transport_error);
        };
        return true;
    }

    fn processDeadline(
        registry: *Registry,
        session: *Session,
        kind: DeadlineKind,
        now_ms: i64,
    ) void {
        switch (kind) {
            .kcp_update => {
                session.kcp.update(session.elapsedMs(now_ms)) catch {
                    registry.markClosing(session, .transport_error);
                    return;
                };
                if (session.kcp.isDead()) {
                    registry.markClosing(session, .kcp_dead_link);
                    return;
                }
                if (session.output.consecutive_send_failures >= send_failure_limit) {
                    registry.markClosing(session, .send_failed);
                    return;
                }
                registry.scheduleKcp(session, now_ms) catch {
                    registry.markClosing(session, .transport_error);
                };
            },
            .idle => {
                const due_ms = session.idleDeadlineMs();
                if (now_ms >= due_ms) {
                    registry.markClosing(
                        session,
                        if (session.phase == .pre_auth) .pre_auth_timeout else .idle_timeout,
                    );
                } else {
                    registry.deadlines.upsert(registry.gpa, .{
                        .conv_id = session.handle.conv_id,
                        .kind = .idle,
                        .due_ms = due_ms,
                    }) catch {
                        registry.markClosing(session, .transport_error);
                    };
                }
            },
        }
    }

    fn scheduleSession(registry: *Registry, session: *Session, now_ms: i64) !void {
        try registry.scheduleKcp(session, now_ms);
        try registry.scheduleIdle(session);
    }

    fn scheduleKcp(registry: *Registry, session: *Session, now_ms: i64) !void {
        try registry.deadlines.upsert(registry.gpa, .{
            .conv_id = session.handle.conv_id,
            .kind = .kcp_update,
            .due_ms = saturatingAdd(
                now_ms,
                session.kcp.nextUpdateDelay(session.elapsedMs(now_ms)),
            ),
        });
    }

    fn scheduleIdle(registry: *Registry, session: *Session) !void {
        try registry.deadlines.upsert(registry.gpa, .{
            .conv_id = session.handle.conv_id,
            .kind = .idle,
            .due_ms = session.idleDeadlineMs(),
        });
    }

    fn markClosing(
        registry: *Registry,
        session: *Session,
        reason: network.CloseReason,
    ) void {
        _ = registry.active.remove(session.handle.conv_id);
        registry.deadlines.cancelSession(session.handle.conv_id);
        session.handle.close(reason);
    }
};

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

fn kcpOutput(buf: []const u8, kcp: *Kcp, user: ?usize) usize {
    const output: *OutputContext = @ptrFromInt(user.?);
    const handle = output.handle;
    if (handle.socket.send(handle.io, &handle.address, buf)) {
        output.consecutive_send_failures = 0;
        return buf.len;
    } else |err| {
        output.consecutive_send_failures +|= 1;
        std.log.debug(
            "send failed, conv: {d}, endpoint: {f}, data_len: {d}, error: {t}",
            .{ kcp.conv, handle.address, buf.len, err },
        );
        return 0;
    }
}

fn deadlineKey(conv_id: u32, kind: DeadlineKind) u64 {
    return (@as(u64, conv_id) << 1) | @intFromEnum(kind);
}

fn deadlineLess(a: DeadlineEntry, b: DeadlineEntry) bool {
    if (a.due_ms != b.due_ms) return a.due_ms < b.due_ms;
    if (a.conv_id != b.conv_id) return a.conv_id < b.conv_id;
    return @intFromEnum(a.kind) < @intFromEnum(b.kind);
}

fn saturatingAdd(base: i64, delta: anytype) i64 {
    const delta_i64: i64 = @intCast(delta);
    return std.math.add(i64, base, delta_i64) catch std.math.maxInt(i64);
}

fn registeredEndpointMatches(
    expected: *const Io.net.IpAddress,
    actual: *const Io.net.IpAddress,
) bool {
    return expected.eql(actual);
}

fn appendFramed(list: *std.ArrayList(u8), body: []const u8) !void {
    var prefix: [3]u8 = undefined;
    std.mem.writeInt(u24, &prefix, @intCast(body.len), .little);
    try list.appendSlice(std.testing.allocator, &prefix);
    try list.appendSlice(std.testing.allocator, body);
}

test "stream assembler accepts split prefixes bodies and multiple messages" {
    var assembler = StreamAssembler.init(std.testing.allocator);
    defer assembler.deinit();

    var framed: std.ArrayList(u8) = .empty;
    defer framed.deinit(std.testing.allocator);
    try appendFramed(&framed, "one");
    try appendFramed(&framed, "split-body");

    try std.testing.expect((try assembler.consume(framed.items[0..2])).message == null);
    const first = try assembler.consume(framed.items[2..6]);
    defer std.testing.allocator.free(first.message.?.bytes);
    try std.testing.expectEqualStrings("one", first.message.?.bytes);

    const second_start = 2 + first.consumed;
    try std.testing.expect((try assembler.consume(framed.items[second_start..10])).message == null);
    const second = try assembler.consume(framed.items[10..]);
    defer std.testing.allocator.free(second.message.?.bytes);
    try std.testing.expectEqualStrings("split-body", second.message.?.bytes);
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

test "stream assembler accepts the maximum prefix and recovers from allocation failure" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 0,
    });
    var assembler = StreamAssembler.init(failing.allocator());
    defer assembler.deinit();

    const maximum_prefix: [3]u8 = @splat(0xff);
    try std.testing.expectError(error.OutOfMemory, assembler.consume(&maximum_prefix));
    try std.testing.expectEqual(@as(usize, 0), assembler.length_prefix_len);
    try std.testing.expect(assembler.body == null);
}

test "KCP rejects malformed and truncated packet input" {
    var kcp = try Kcp.init(std.testing.allocator, 1, 0);
    defer kcp.deinit();

    try std.testing.expectError(error.input1, kcp.input(&[_]u8{0} ** 23));
    try std.testing.expectError(error.input2, kcp.input(&[_]u8{0} ** 24));
}

test "indexed transport deadlines update and order deterministically" {
    var deadlines: DeadlineHeap = .{};
    defer deadlines.deinit(std.testing.allocator);

    try deadlines.upsert(std.testing.allocator, .{
        .conv_id = 2,
        .kind = .idle,
        .due_ms = 100,
    });
    try deadlines.upsert(std.testing.allocator, .{
        .conv_id = 1,
        .kind = .idle,
        .due_ms = 100,
    });
    try deadlines.upsert(std.testing.allocator, .{
        .conv_id = 1,
        .kind = .kcp_update,
        .due_ms = 100,
    });
    try deadlines.upsert(std.testing.allocator, .{
        .conv_id = 2,
        .kind = .idle,
        .due_ms = 50,
    });

    try std.testing.expectEqual(@as(i64, 50), deadlines.peekDueMs().?);
    try std.testing.expectEqual(@as(u32, 2), deadlines.popDue(50).?.conv_id);
    const first_tie = deadlines.popDue(100).?;
    try std.testing.expectEqual(@as(u32, 1), first_tie.conv_id);
    try std.testing.expectEqual(DeadlineKind.kcp_update, first_tie.kind);
    deadlines.cancelSession(1);
    try std.testing.expect(deadlines.popDue(100) == null);
}

test "conversation IDs are monotonic and skip active values after wrap" {
    var registry = Registry.init(std.testing.allocator);
    defer registry.deinit();

    try std.testing.expectEqual(@as(u32, 1), try registry.allocateConvId());
    try std.testing.expectEqual(@as(u32, 2), try registry.allocateConvId());

    registry.next_conv_id = std.math.maxInt(u32);
    try std.testing.expectEqual(std.math.maxInt(u32), try registry.allocateConvId());
    try std.testing.expectEqual(@as(u32, 3), try registry.allocateConvId());
}

test "two phase idle deadlines use selected policy" {
    var session: Session = undefined;
    session.last_receive_time_ms = 1_000;
    session.phase = .pre_auth;
    try std.testing.expectEqual(pre_auth_idle_timeout_ms, session.idleTimeoutMs());
    try std.testing.expectEqual(@as(i64, 11_000), session.idleDeadlineMs());

    session.last_receive_time_ms = 2_000;
    session.phase = .authenticated;
    try std.testing.expectEqual(authenticated_idle_timeout_ms, session.idleTimeoutMs());
    try std.testing.expectEqual(
        @as(i64, 2_000 + authenticated_idle_timeout_ms),
        session.idleDeadlineMs(),
    );
}

test "deadline arithmetic clamps without wrapping" {
    try std.testing.expectEqual(
        std.math.maxInt(i64),
        saturatingAdd(std.math.maxInt(i64) - 1, 10),
    );
}

test "packet routing matches the complete registered endpoint" {
    const expected = try Io.net.IpAddress.parseLiteral("127.0.0.1:7777");
    const same = try Io.net.IpAddress.parseLiteral("127.0.0.1:7777");
    const other_port = try Io.net.IpAddress.parseLiteral("127.0.0.1:7778");
    const other_address = try Io.net.IpAddress.parseLiteral("127.0.0.2:7777");

    try std.testing.expect(registeredEndpointMatches(&expected, &same));
    try std.testing.expect(!registeredEndpointMatches(&expected, &other_port));
    try std.testing.expect(!registeredEndpointMatches(&expected, &other_address));
}

test "closed conversation IDs leave active packet routing immediately" {
    var registry = Registry.init(std.testing.allocator);
    defer registry.deinit();
    var placeholder: Session = undefined;

    try registry.active.put(std.testing.allocator, 41, &placeholder);
    try std.testing.expect(registry.containsActive(41));
    _ = registry.active.remove(41);
    try std.testing.expect(!registry.containsActive(41));
}

test "transport work budget enforces action and time limits after one action" {
    var budget: WorkBudget = .{ .started_ns = 100 };
    try std.testing.expect(budget.canStart(std.math.maxInt(i96)));
    budget.complete();
    try std.testing.expect(!budget.canStart(100 + time_limit_ns));

    budget = .{ .started_ns = 100 };
    while (budget.actions < action_limit) budget.complete();
    try std.testing.expect(!budget.canStart(100));
}
