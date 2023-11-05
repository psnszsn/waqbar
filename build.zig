const std = @import("std");
const Builder = std.build.Builder;
const ScanProtocolsStep = @import("deps/waq/deps/zig-wayland/build.zig").ScanProtocolsStep;
const Scanner = @import("deps/waq/deps/zig-wayland/build.zig").Scanner;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const scanner = Scanner.create(b, .{});
    const wayland = b.createModule(.{ .source_file = scanner.result });

    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");
    scanner.addCustomProtocol("deps/waq/protocol/wlr-layer-shell-unstable-v1.xml");

    scanner.generate("wl_compositor", 1);
    scanner.generate("wl_shm", 1);
    scanner.generate("wl_seat", 7);
    scanner.generate("wl_output", 4);
    scanner.generate("xdg_wm_base", 2);
    scanner.generate("zwlr_layer_shell_v1", 4);

    const waq = b.createModule(.{
        .source_file = .{ .path = "./deps/waq/src/lib.zig" },
        .dependencies = &.{.{ .name = "wayland", .module = wayland }},
    });

    const exe = b.addExecutable(.{
        .name = "waqbar",
        .root_source_file = .{ .path = "./src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("waq", waq);
    scanner.addCSource(exe);
    exe.linkLibC();
    exe.linkSystemLibrary("wayland-client");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
