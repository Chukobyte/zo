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

    const glad_lib: *std.Build.Step.Compile = try add_glad(b, target, optimize);
    const stb_image_lib: *std.Build.Step.Compile = try add_stb_image(b, target, optimize);
    exe.linkLibrary(glad_lib);
    exe.linkLibrary(stb_image_lib);
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("opengl32");

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_exe.step);
}

fn add_glad(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const glad_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "glad",
        .target = target,
        .optimize = optimize,
    });

    const glad_src_path = "thirdparty/glad";
    const glad_include_path = "thirdparty";

    glad_lib.addIncludePath(b.path(glad_include_path));
    glad_lib.addCSourceFile(.{ .file = b.path(glad_src_path ++ "/glad.c") });

    glad_lib.linkLibC();

    glad_lib.installHeader(b.path(glad_include_path ++ "/glad/glad.h"), "glad/glad.h");
    b.installArtifact(glad_lib);

    return glad_lib;
}

fn add_stb_image(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const stb_image_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "stb_image",
        .target = target,
        .optimize = optimize,
    });

    const stb_image_src_path = "thirdparty/stb_image";
    const stb_image_include_path = "thirdparty/stb_image";

    stb_image_lib.addIncludePath(b.path(stb_image_include_path));
    stb_image_lib.addCSourceFile(.{ .file = b.path(stb_image_src_path ++ "/stb_image.c"), .flags = &.{ "-std=c99", "-fno-sanitize=undefined" } });

    stb_image_lib.linkLibC();

    stb_image_lib.installHeader(b.path(stb_image_include_path ++ "/stb_image.h"), "stb_image/stb_image.h");
    b.installArtifact(stb_image_lib);

    return stb_image_lib;
}
