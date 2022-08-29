const std = @import("std");
const Builder = std.build.Builder;
const ScanProtocolsStep = @import("deps/waq/deps/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const scanner = ScanProtocolsStep.create(b);
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");
    scanner.addProtocolPath("deps/waq/protocol/wlr-layer-shell-unstable-v1.xml");

    scanner.generate("wl_compositor", 1);
    scanner.generate("wl_shm", 1);
    scanner.generate("wl_seat", 7);
    scanner.generate("wl_output", 4);
    scanner.generate("xdg_wm_base", 2);
    scanner.generate("zwlr_layer_shell_v1", 4);

    const wayland = std.build.Pkg{
        .name = "wayland",
        .source = .{ .generated = &scanner.result },
    };
    const waq = std.build.Pkg{
        .name = "waq",
        .source = .{ .path = "./deps/waq/src/lib.zig" },
        .dependencies = &[_]std.build.Pkg{wayland},
    };

    const exe = b.addExecutable("waqbar", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.step.dependOn(&scanner.step);
    exe.addPackage(waq);

    exe.linkLibC();
    exe.linkSystemLibrary("wayland-client");

    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(exe);

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
