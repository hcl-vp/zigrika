const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const common = b.createModule(.{ .root_source_file = b.path("common/src/root.zig") });

    const proto_gen = b.addExecutable(.{
        .name = "yoshunko-protogen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("proto/gen/src/main.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    var update_src = b.addUpdateSourceFiles();

    if (std.Io.Dir.cwd().access(b.graph.io, "proto/pb/Molniya.proto", .{})) {
        const run_proto_gen = b.addRunArtifact(proto_gen);
        run_proto_gen.expectExitCode(0);
        run_proto_gen.setStdIn(.{ .lazy_path = b.path("proto/pb/Molniya.proto") });
        const pb_gen = run_proto_gen.captureStdOut(.{ .basename = "aki_generated.zig" });
        update_src.addCopyFileToSource(pb_gen, "proto/src/aki_generated.zig");
    } else |_| {}

    const proto = b.createModule(.{
        .root_source_file = b.path("proto/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const cfgsv = b.addExecutable(.{
        .name = "molniya-cfgsv",
        .root_module = b.createModule(.{
            .root_source_file = b.path("cfgsv/src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "common", .module = common }},
        }),
    });

    const loginsv = b.addExecutable(.{
        .name = "molniya-loginsv",
        .root_module = b.createModule(.{
            .root_source_file = b.path("loginsv/src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "common", .module = common }},
        }),
    });

    const gamesv = b.addExecutable(.{
        .name = "molniya-gamesv",
        .root_module = b.createModule(.{
            .root_source_file = b.path("gamesv/src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "common", .module = common },
                .{ .name = "proto", .module = proto },
            },
        }),
    });

    b.step(
        "run-cfgsv",
        "compile and run the config server",
    ).dependOn(&b.addRunArtifact(cfgsv).step);

    b.step(
        "run-loginsv",
        "compile and run the login server",
    ).dependOn(&b.addRunArtifact(loginsv).step);

    const run_gamesv = b.addRunArtifact(gamesv);
    run_gamesv.step.dependOn(&update_src.step);

    b.step(
        "run-gamesv",
        "run the game server",
    ).dependOn(&run_gamesv.step);

    b.installArtifact(cfgsv);
    b.installArtifact(gamesv);
}
