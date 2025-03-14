pub const math = @import("math.zig");
pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const renderer = @import("renderer.zig");
pub const audio = @import("audio.zig");

const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;
const LinearColor = math.LinearColor;

pub const ZoParams = struct {
    const Callbacks = struct {
        update: fn(f32) void,
        init: ?fn() void,
        deinit: ?fn() void,
    };

    const WindowParams = struct {
        title: []const u8,
        pos: Vec2i,
        size: Dim2i,
        background: LinearColor = .{ .r = 0.25, .g = 0.25, .b = 0.25 },
    };


    window: WindowParams,
    callbacks: Callbacks,
    resolution: ?Dim2i = null,
};

var is_running = false;

pub fn run(p: ZoParams) !void {
    try window.create(
        p.window.title,
        p.window.pos.x,
        p.window.pos.y,
        p.window.size.w,
        p.window.size.h
    );
    const game_resolution: Dim2i = p.resolution orelse p.window.size;
    try renderer.init(game_resolution.w, game_resolution.h);
    defer renderer.deinit();
    try audio.init();
    defer audio.deinit();

    is_running = true;

    if (p.callbacks.init) |init_func| {
        init_func();
    }

    while (window.isActive() and is_running) {
        window.clear(.{ .r = 0.25, .g = 0.25, .b = 0.25 });
        input.new_frame();
        window.update();

        p.callbacks.update(0.1);

        window.swap();
    }

    if (p.callbacks.deinit) |deinit_func| {
        deinit_func();
    }
}

pub fn quit() void {
    is_running = false;
}
