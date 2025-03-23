const std = @import("std");

const thirdparty_path = "thirdparty";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zo_module = try buildZoModule(b, target, optimize);
    const static_assets_module = b.addModule("static_assets", .{
        .root_source_file = b.path("static_assets.zig"),
    });
    static_assets_module.addImport("zo", zo_module);

    buildUnboundaGame(b, target, optimize, zo_module, static_assets_module);
    buildTest(b, target, optimize, zo_module, static_assets_module);
}

fn buildUnboundaGame(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, zo_module: *std.Build.Module, static_assets_module: *std.Build.Module) void {
    var root_source_file: []const u8 = undefined;
    if (target.result.os.tag == .windows) {
        root_source_file = "src/games/unbound/win32_main.zig";
    } else {
        root_source_file = "src/games/unbound/main.zig";
    }

    const exe = b.addExecutable(.{
        .name = "unbound",
        .root_source_file = b.path(root_source_file),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.os.tag == .windows) {
        exe.subsystem = .Windows;
    } else {
        exe.entry = .disabled;
        exe.rdynamic = true;
        exe.import_memory = true;
    }

    exe.root_module.addImport("zo", zo_module);
    exe.root_module.addImport("static_assets",static_assets_module);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run unbound game");
    run_step.dependOn(&run_exe.step);
}

fn buildZoModule(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Module {
    const glad_lib: *std.Build.Step.Compile = try add_glad(b, target, optimize);
    const stb_image_lib: *std.Build.Step.Compile = try add_stb_image(b, target, optimize);
    const freetype_lib: *std.Build.Step.Compile = try add_freetype(b, target, optimize);
    const zo_audio_lib: *std.Build.Step.Compile = try add_zo_audio(b, target, optimize);

    const zo_module = b.addModule("zo", .{
        .root_source_file = b.path("src/zo/zo.zig"),
        .target = target,
        .optimize = optimize,
    });
    zo_module.link_libc = true;
    zo_module.linkSystemLibrary("gdi32", .{});
    zo_module.linkSystemLibrary("user32", .{});
    zo_module.linkSystemLibrary("opengl32", .{});
    zo_module.linkLibrary(glad_lib);
    zo_module.linkLibrary(stb_image_lib);
    zo_module.linkLibrary(freetype_lib);
    zo_module.linkLibrary(zo_audio_lib);

    return zo_module;
}

fn add_glad(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const glad_path = thirdparty_path ++ "/glad";
    const glad_include_path = thirdparty_path;

    const glad_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "glad",
        .target = target,
        .optimize = optimize,
    });

    glad_lib.addIncludePath(b.path(glad_include_path));
    glad_lib.addCSourceFile(.{ .file = b.path(glad_path ++ "/glad.c") });

    glad_lib.linkLibC();

    glad_lib.installHeader(b.path(glad_include_path ++ "/glad/glad.h"), "glad/glad.h");
    b.installArtifact(glad_lib);

    return glad_lib;
}

fn add_stb_image(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const stb_image_path = thirdparty_path ++ "/stb_image";
    const stb_image_include_path = thirdparty_path ++ "/stb_image";

    const stb_image_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "stb_image",
        .target = target,
        .optimize = optimize,
    });

    stb_image_lib.addIncludePath(b.path(stb_image_include_path));
    stb_image_lib.addCSourceFile(.{ .file = b.path(stb_image_path ++ "/stb_image.c"), .flags = &.{ "-std=c99", "-fno-sanitize=undefined" } });

    stb_image_lib.linkLibC();

    stb_image_lib.installHeader(b.path(stb_image_include_path ++ "/stb_image.h"), "stb_image/stb_image.h");
    b.installArtifact(stb_image_lib);

    return stb_image_lib;
}

fn add_freetype(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const ft_path = thirdparty_path ++ "/freetype-VER-2-13-2";
    const ft_include_path = ft_path ++ "/include";
    const ft_srcs = [_][]const u8 {
        ft_path ++ "/src/autofit/autofit.c",
        ft_path ++ "/src/base/ftbase.c",
        ft_path ++ "/src/base/ftbbox.c",
        ft_path ++ "/src/base/ftbdf.c",
        ft_path ++ "/src/base/ftbitmap.c",
        ft_path ++ "/src/base/ftcid.c",
        ft_path ++ "/src/base/ftfstype.c",
        ft_path ++ "/src/base/ftgasp.c",
        ft_path ++ "/src/base/ftglyph.c",
        ft_path ++ "/src/base/ftgxval.c",
        ft_path ++ "/src/base/ftinit.c",
        ft_path ++ "/src/base/ftmm.c",
        ft_path ++ "/src/base/ftotval.c",
        ft_path ++ "/src/base/ftpatent.c",
        ft_path ++ "/src/base/ftpfr.c",
        ft_path ++ "/src/base/ftstroke.c",
        ft_path ++ "/src/base/ftsynth.c",
        ft_path ++ "/src/base/fttype1.c",
        ft_path ++ "/src/base/ftwinfnt.c",
        ft_path ++ "/src/bdf/bdf.c",
        ft_path ++ "/src/bzip2/ftbzip2.c",
        ft_path ++ "/src/cache/ftcache.c",
        ft_path ++ "/src/cff/cff.c",
        ft_path ++ "/src/cid/type1cid.c",
        ft_path ++ "/src/gzip/ftgzip.c",
        ft_path ++ "/src/lzw/ftlzw.c",
        ft_path ++ "/src/pcf/pcf.c",
        ft_path ++ "/src/pfr/pfr.c",
        ft_path ++ "/src/psaux/psaux.c",
        ft_path ++ "/src/pshinter/pshinter.c",
        ft_path ++ "/src/psnames/psnames.c",
        ft_path ++ "/src/raster/raster.c",
        ft_path ++ "/src/sdf/sdf.c",
        ft_path ++ "/src/sfnt/sfnt.c",
        ft_path ++ "/src/smooth/smooth.c",
        ft_path ++ "/src/svg/svg.c",
        ft_path ++ "/src/truetype/truetype.c",
        ft_path ++ "/src/type1/type1.c",
        ft_path ++ "/src/type42/type42.c",
        ft_path ++ "/src/winfonts/winfnt.c",
    };

    const ft_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "freetype",
        .target = target,
        .optimize = optimize,
    });

    ft_lib.linkLibC();
    if (target.result.os.tag == std.Target.Os.Tag.linux) {
        ft_lib.linkSystemLibrary("m");
    }
    const zlib_lib = try add_zlib(b, target, optimize);
    const libpng_lib = try add_libpng(b, target, optimize, zlib_lib);
    ft_lib.linkLibrary(zlib_lib);
    ft_lib.linkLibrary(libpng_lib);

    ft_lib.addIncludePath(b.path(ft_include_path));
    ft_lib.root_module.addCMacro("FT_BUILD_LIBRARY", "1");

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        "-DFT2_BUILD_LIBRARY",

        "-DFT_CONFIG_OPTION_SYSTEM_ZLIB=1",

        "-DHAVE_UNISTD_H",
        "-DHAVE_FCNTL_H",

        "-fno-sanitize=undefined",

        "-DFT_CONFIG_OPTION_USE_PNG=1",
    });

    const ft_build_path = ft_path ++ "/builds";
    switch (target.result.os.tag) {
        .windows => {
            ft_lib.addCSourceFile(.{ .file = b.path(ft_path ++ "/src/base/fterrors.c"), .flags = flags.items });
            ft_lib.addCSourceFile(.{ .file = b.path(ft_build_path ++ "/windows/ftdebug.c"), .flags = flags.items });
            ft_lib.addCSourceFile(.{ .file = b.path(ft_build_path ++ "/windows/ftsystem.c"), .flags = flags.items });
            ft_lib.addWin32ResourceFile(.{ .file = b.path(ft_path ++ "/src/base/ftver.rc") });

        },
        .linux => {
            ft_lib.addCSourceFile(.{ .file = b.path(ft_build_path ++ "/unix/ftsystem.c"), .flags = flags.items });
            ft_lib.addCSourceFile(.{ .file = b.path(ft_path ++ "/src/base/ftdebug.c"), .flags = flags.items });
        },
        else => {
            ft_lib.addCSourceFile(.{ .file = b.path(ft_path ++ "/src/base/ftsystem.c"), .flags = flags.items });
            ft_lib.addCSourceFile(.{ .file = b.path(ft_path ++ "/src/base/ftdebug.c"), .flags = flags.items });
        },
    }

    ft_lib.addCSourceFiles(.{ .files = &ft_srcs, .flags = flags.items });

    ft_lib.installHeadersDirectory(b.path(ft_include_path), ".", .{});
    b.installArtifact(ft_lib);

    return ft_lib;
}

fn add_zlib(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const zlib_path = thirdparty_path ++ "/zlib";
    const zlib_src_path = zlib_path ++ "/src";
    const zlib_srcs = [_][]const u8 {
        zlib_src_path ++ "/adler32.c",
        zlib_src_path ++ "/compress.c",
        zlib_src_path ++ "/crc32.c",
        zlib_src_path ++ "/deflate.c",
        zlib_src_path ++ "/gzclose.c",
        zlib_src_path ++ "/gzlib.c",
        zlib_src_path ++ "/gzread.c",
        zlib_src_path ++ "/gzwrite.c",
        zlib_src_path ++ "/inflate.c",
        zlib_src_path ++ "/infback.c",
        zlib_src_path ++ "/inftrees.c",
        zlib_src_path ++ "/inffast.c",
        zlib_src_path ++ "/trees.c",
        zlib_src_path ++ "/uncompr.c",
        zlib_src_path ++ "/zutil.c",
    };

    const zlib_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "z",
        .target = target,
        .optimize = optimize,
    });
    zlib_lib.linkLibC();
    zlib_lib.addIncludePath(b.path(zlib_src_path));

    zlib_lib.installHeadersDirectory(b.path(zlib_src_path), ".", .{ .exclude_extensions = &.{ ".c", ".in", ".txt" } });

    var zlib_flags = std.ArrayList([]const u8).init(b.allocator);
    defer zlib_flags.deinit();
    try zlib_flags.appendSlice(&.{
        "-DHAVE_SYS_TYPES_H",
        "-DHAVE_STDINT_H",
        "-DHAVE_STDDEF_H",
        "-DZ_HAVE_UNISTD_H",
    });
    zlib_lib.addCSourceFiles(.{ .files = &zlib_srcs, .flags = zlib_flags.items });

    b.installArtifact(zlib_lib);

    return zlib_lib;
}

fn add_libpng(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, zlib_lib: *std.Build.Step.Compile) !*std.Build.Step.Compile {
    const libpng_path = thirdparty_path ++ "/libpng";
    const libpng_headers = [_][]const u8 {
        "png.h",
        "pngconf.h",
        "pngdebug.h",
        "pnginfo.h",
        "pngpriv.h",
        "pngstruct.h",
    };
    const libpng_srcs = [_][]const u8 {
        libpng_path ++ "/src/png.c",
        libpng_path ++ "/src/png.c",
        libpng_path ++ "/src/pngerror.c",
        libpng_path ++ "/src/pngget.c",
        libpng_path ++ "/src/pngmem.c",
        libpng_path ++ "/src/pngpread.c",
        libpng_path ++ "/src/pngread.c",
        libpng_path ++ "/src/pngrio.c",
        libpng_path ++ "/src/pngrtran.c",
        libpng_path ++ "/src/pngrutil.c",
        libpng_path ++ "/src/pngset.c",
        libpng_path ++ "/src/pngtrans.c",
        libpng_path ++ "/src/pngwio.c",
        libpng_path ++ "/src/pngwrite.c",
        libpng_path ++ "/src/pngwtran.c",
        libpng_path ++ "/src/pngwutil.c",
    };

    const libpng_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "png",
        .target = target,
        .optimize = optimize,
    });
    libpng_lib.linkLibC();
    if (target.result.os.tag == std.Target.Os.Tag.linux) {
        libpng_lib.linkSystemLibrary("m");
    }

    libpng_lib.linkLibrary(zlib_lib);
    libpng_lib.addIncludePath(b.path(libpng_path ++ "/include"));
    libpng_lib.addIncludePath(b.path(libpng_path ++ "/src"));

    var libpng_flags = std.ArrayList([]const u8).init(b.allocator);
    defer libpng_flags.deinit();
    try libpng_flags.appendSlice(&.{
        "-DPNG_ARM_NEON_OPT=0",
        "-DPNG_POWERPC_VSX_OPT=0",
        "-DPNG_INTEL_SSE_OPT=0",
        "-DPNG_MIPS_MSA_OPT=0",
    });
    libpng_lib.addCSourceFiles(.{ .files = &libpng_srcs, .flags = libpng_flags.items });

    libpng_lib.installHeader(b.path(libpng_path ++ "/include/pnglibconf.h"), "pnglibconf.h");
    inline for (libpng_headers) |header| {
        libpng_lib.installHeader(b.path(libpng_path ++ "/src/" ++ header), header);
    }

    b.installArtifact(libpng_lib);

    return libpng_lib;
}

fn add_zo_audio(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !*std.Build.Step.Compile {
    const c_src = "src/c";
    const miniaudio_path = thirdparty_path ++ "/miniaudio";

    const audio_lib: *std.Build.Step.Compile = b.addStaticLibrary(.{
        .name = "zo_audio",
        .target = target,
        .optimize = optimize,
    });
    audio_lib.linkLibC();
    // Add miniaudio directory to be included
    audio_lib.addIncludePath(b.path(c_src));
    audio_lib.addIncludePath(b.path(miniaudio_path));
    audio_lib.addCSourceFile(.{.file = b.path("src/c/zo_audio.c")});
    
    audio_lib.installHeadersDirectory(b.path(c_src), ".", .{});


    b.installArtifact(audio_lib);

    return audio_lib;
}

fn buildTest(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, zo_module: *std.Build.Module, static_assets_module: *std.Build.Module) void {
    const test_exe = b.addTest(.{
        .root_source_file = b.path("src/test/unit_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_exe.root_module.addImport("zo", zo_module);
    test_exe.root_module.addImport("static_assets", static_assets_module);

    const run_test = b.addRunArtifact(test_exe);
    run_test.has_side_effects = true;

    const test_step = b.step("test", "Run unit tests for zo");
    test_step.dependOn(&run_test.step);
}
