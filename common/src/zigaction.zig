const std = @import("std");
const builtin = @import("builtin");
const posix = std.posix;
const Io = std.Io;
const windows = std.os.windows;

pub const HANDLER_ROUTINE = *const fn (dwCtrlType: windows.DWORD) callconv(.winapi) windows.BOOL;

extern "kernel32" fn SetConsoleCtrlHandler(
    HandlerRoutine: ?HANDLER_ROUTINE,
    Add: windows.BOOL,
) callconv(.winapi) windows.BOOL;

pub fn Handler(comptime sig: posix.SIG) type {
    return struct {
        var awaiter_io: Io = undefined;
        var awaiter_cond: Io.Event = .unset;

        pub fn wait(io: Io) Io.Future(void) {
            awaiter_io = io;
            switch (builtin.target.os.tag) {
                .windows => {
                    _ = SetConsoleCtrlHandler(ctrlHandler, .TRUE);
                },
                else => {
                    posix.sigaction(sig, &.{
                        .handler = .{ .handler = sigHandler },
                        .mask = @splat(0),
                        .flags = 0,
                    }, null);
                },
            }
            const wait_args = .{ &awaiter_cond, awaiter_io };
            return io.concurrent(Io.Event.waitUncancelable, wait_args) catch
                io.async(Io.Event.waitUncancelable, wait_args);
        }

        fn sigHandler(_: posix.SIG) callconv(.c) void {
            awaiter_cond.set(awaiter_io);
        }

        fn ctrlHandler(ctrl_type: windows.DWORD) callconv(.winapi) windows.BOOL {
            const wanted: windows.DWORD = switch (sig) {
                .INT => 0,
                .BREAK => 1,
                else => return .FALSE,
            };
            if (ctrl_type != wanted) return .FALSE;
            awaiter_cond.set(awaiter_io);
            return .TRUE;
        }
    };
}
