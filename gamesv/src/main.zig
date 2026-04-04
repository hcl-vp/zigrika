const std = @import("std");
const common = @import("common");
const network = @import("network.zig");
const Assets = @import("data/Assets.zig");

const Io = std.Io;
const Allocator = std.mem.Allocator;

const FileSystem = common.FileSystem;
const zigaction = common.zigaction;

const Args = struct {
    state_dir: []const u8 = "state",
    bind_address: []const u8 = "127.0.0.1:13100",
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

    var assets = Assets.init(gpa, io) catch |err| {
        log.err("failed to load assets: {t}", .{err});
        return 1;
    };

    defer assets.deinit();

    const bind_address = Io.net.IpAddress.parseLiteral(args.bind_address) catch |err| {
        log.err("invalid bind address specified: {t}", .{err});
        return 1;
    };

    var fs = FileSystem.init(gpa, io, args.state_dir) catch |err| {
        log.err("failed to open filesystem at '{s}': {t}", .{ args.state_dir, err });
        return 1;
    };

    defer fs.deinit();

    var net_future = network.bind(io, gpa, &fs, &assets, bind_address) catch return 1; // TODO: retry with a timeout?
    defer net_future.cancel(io);

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
    log.info("game server is listening at {f}", .{bind_address});

    var sigint = zigaction.Handler(.INT).wait(io);
    sigint.await(io);

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
