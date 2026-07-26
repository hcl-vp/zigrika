const std = @import("std");
const State = @import("../network/State.zig");
const EventQueue = @import("../logic/EventQueue.zig");

const logic_namespaces: []const type = &.{
    @import("handlers/player.zig"),
    @import("handlers/weapon.zig"),
    @import("handlers/role.zig"),
    @import("handlers/misc.zig"),
    @import("handlers/scene.zig"),
    @import("handlers/phase.zig"),
    @import("handlers/save.zig"),
    @import("handlers/debugger.zig"),
    @import("handlers/buff.zig"),
    @import("handlers/tags.zig"),
    @import("handlers/chat.zig"),
    @import("handlers/time.zig"),
};

pub fn drainEventQueue(event_queue: *EventQueue, state: *State) !void {
    while (event_queue.deque.popFront()) |event| {
        try dispatchLogicEvent(event_queue, event, state);
    }
}

fn dispatchLogicEvent(q: *EventQueue, e: EventQueue.Event, state: *State) !void {
    switch (e) {
        inline else => |event, tag| {
            inline for (logic_namespaces) |namespace| {
                inline for (comptime std.meta.declarations(namespace)) |decl| {
                    switch (@typeInfo(@TypeOf(@field(namespace, decl.name)))) {
                        .@"fn" => |fn_info| {
                            if (fn_info.params.len == 0) continue;

                            const EventDequeue = fn_info.params[0].type.?;
                            if (!@hasDecl(EventDequeue, "dequeue_event_tag")) continue;

                            if (EventDequeue.dequeue_event_tag != tag) continue;
                            try invokeEventHandler(q, event, state, @field(namespace, decl.name));
                        },
                        else => {},
                    }
                }
            }
        },
    }
}

fn invokeEventHandler(q: *EventQueue, e: anytype, state: *State, handler: anytype) !void {
    const Args = std.meta.ArgsTuple(@TypeOf(handler));

    var args: Args = undefined;
    args[0] = .{ .data = &e };

    inline for (comptime std.meta.fields(Args)[1..], 1..) |param, i| {
        if (param.type == *EventQueue)
            args[i] = q
        else
            args[i] = state.extract(param.type) catch return;
    }

    try @call(.auto, handler, args);
}
