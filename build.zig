const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var root_source_file: []const u8 = undefined;
    if (target.result.os.tag == .windows) {
        root_source_file = "src/win32_main.zig";
    } else {
        root_source_file = "src/main.zig";
    }

    const exe = b.addExecutable(.{
        .name = "zo",
        .root_source_file = b.path(root_source_file),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();

    if (target.result.os.tag == .windows) {
        exe.subsystem = .Windows;
    } else {
        exe.entry = .disabled;
        exe.rdynamic = true;
        exe.import_memory = true;
    }

    // exe.addCSourceFile(.{ .file = b.path("src/c/window.c") });
    // exe.addIncludePath(b.path("."));
    // exe.addIncludePath(b.path("src/c/"));

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_exe.step);
}
