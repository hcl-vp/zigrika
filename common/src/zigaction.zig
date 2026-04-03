const std = @import("std");
const posix = std.posix;
const Io = std.Io;

pub fn Handler(comptime sig: posix.SIG) type {
    return struct {
        var awaiter_io: Io = undefined;
        var awaiter_cond: Io.Event = .unset;

        pub fn wait(io: Io) Io.Future(void) {
            awaiter_io = io;

            // this isn't crossplatform but fuck windows anyway so who cares
            posix.sigaction(sig, &.{
                .handler = .{ .handler = sigHandler },
                .mask = @splat(0),
                .flags = 0,
            }, null);

            const wait_args = .{ &awaiter_cond, awaiter_io };
            return io.concurrent(Io.Event.waitUncancelable, wait_args) catch
                io.async(Io.Event.waitUncancelable, wait_args);
        }

        fn sigHandler(_: posix.SIG) callconv(.c) void {
            awaiter_cond.set(awaiter_io);
        }
    };
}
