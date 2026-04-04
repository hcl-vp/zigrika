const std = @import("std");
const common = @import("common");
const serve = @import("serve.zig");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const FileSystem = common.FileSystem;
const zigaction = common.zigaction;

const Args = struct {
    state_dir: []const u8 = "state",
    listen_address: []const u8 = "127.0.0.1:5500",
};

fn init(gpa: Allocator, io: Io, cmd_args: std.process.Args) u8 {
    const log = std.log.scoped(.init);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const sliced_args = cmd_args.toSlice(arena.allocator()) catch |err| {
        log.err("failed to slice args: {t}", .{err});
        return 1;
    };

    const args = common.args.parse(Args, sliced_args[1..]) orelse {
        common.args.printUsage(Args, sliced_args[0]);
        return 1;
    };

    const address = Io.net.IpAddress.parseLiteral(args.listen_address) catch |err| {
        log.err("invalid listen address specified: {t}", .{err});
        return 1;
    };

    var fs = FileSystem.init(gpa, io, args.state_dir) catch |err| {
        log.err("failed to open filesystem at '{s}': {t}", .{ args.state_dir, err });
        return 1;
    };

    defer fs.deinit();

    var server = address.listen(io, .{ .reuse_address = true }) catch |err| {
        log.err("failed to listen at {f}: {t}", .{ address, err });
        if (err == error.AddressInUse) log.err("another instance of this server might be already running", .{});
        return 1;
    };

    defer server.deinit(io);

    std.debug.print(
        \\ ______ _            _
        \\|___  /( )  __      ( )|    __
        \\   / /  |  /  \ |__  | |  //  \
        \\  / /   | | () ||  \ | | /| () |
        \\ / /__  |  \__/ |    | | \ \__/
        \\/_____|(_)    |     (_)|  \   \
        \\           \__/
        \\
    , .{});
    log.info("config server is listening at {f}", .{address});

    var sigint = zigaction.Handler(.INT).wait(io);

    const SelectEvent = union(enum) {
        accept: Io.net.Server.AcceptError!Io.net.Stream,
        shutdown: void,
    };

    var select_buf: [2]SelectEvent = undefined;
    var select = Io.Select(SelectEvent).init(io, select_buf[0..]);
    defer select.cancelDiscard();
    select.concurrent(.shutdown, Io.Future(void).await, .{ &sigint, io }) catch {
        select.async(.shutdown, Io.Future(void).await, .{ &sigint, io });
    };

    while (true) {
        io.checkCancel() catch break;
        select.concurrent(.accept, Io.net.Server.accept, .{ &server, io }) catch {
            select.async(.accept, Io.net.Server.accept, .{ &server, io });
        };

        switch (select.await() catch break) {
            .accept => |completion| {
                if (completion) |stream| {
                    // start the client processing task
                    const client_args = .{ gpa, io, &fs, stream };
                    select.group.concurrent(io, serve.processConnection, client_args) catch {
                        // if concurrency is not available, we can handle 1 client at a time.
                        var future = io.async(serve.processConnection, client_args);
                        future.await(io);
                    };
                } else |err| switch (err) {
                    error.ProcessFdQuotaExceeded, error.SystemFdQuotaExceeded, error.SystemResources => {
                        // wait 1 second instead of retrying and overloading an already busy system
                        io.sleep(.fromSeconds(1), .awake) catch {
                            break; // shutdown on cancellation
                        };
                    },
                    else => log.err("accept failed: {t}", .{err}),
                }
            },
            .shutdown => {
                if (select.cancel()) |event| {
                    if (event == .accept) {
                        if (event.accept) |stream| stream.close(io) else |_| {}
                    }
                }
                break;
            },
        }
    }

    log.info("shutting down...", .{});
    return 0;
}

pub fn main(minimal: std.process.Init.Minimal) u8 {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer std.debug.assert(debug_allocator.deinit() == .ok);

    var threaded: Io.Threaded = .init(debug_allocator.allocator(), .{
        .environ = minimal.environ,
    });
    defer threaded.deinit();

    return init(debug_allocator.allocator(), threaded.io(), minimal.args);
}
