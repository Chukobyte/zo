pub const std = @import("std");
pub const math = @import("math.zig");
pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const renderer = @import("renderer.zig");
pub const audio = @import("audio.zig");
pub const ecs = @import("ecs.zig");
pub const logger = @import("logger.zig");
pub const string = @import("string.zig");
pub const spatial_hash_map = @import("spatial_hash_map.zig");
pub const delegate = @import("delegate.zig");
pub const misc = @import("misc.zig");

pub const log = logger.log;

pub const StaticAsset = @import("static_asset.zig").StaticAsset;

const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;
const LinearColor = math.LinearColor;

const Tick = @import("tick.zig").Tick;

pub const ZoParams = struct {
    const WindowParams = struct {
        title: []const u8,
        pos: Vec2i,
        size: Dim2i,
        background: LinearColor = .{ .r = 0.25, .g = 0.25, .b = 0.25 },
    };

    window: WindowParams,
    game: type,
    target_fps: u32,
    fixed_target_fps: ?u32 = null,
    resolution: ?Dim2i = null,
    allocator: std.mem.Allocator = std.heap.page_allocator,
};

var is_running = false;

pub fn run(comptime p: ZoParams) !void {
    try window.create(
        p.window.title,
        p.window.pos,
        p.window.size,
    );
    const game_resolution: Dim2i = p.resolution orelse p.window.size;
    try renderer.init(game_resolution);
    defer renderer.deinit();
    try audio.init();
    defer audio.deinit();
    try input.init(p.allocator);
    defer input.deinit();

    const GameTick = Tick(p.game);

    var tick = GameTick.init(.{
        .interface = p.game,
        .target_fps = p.target_fps,
        .fixed_target_fps = p.fixed_target_fps,
    });

    is_running = true;

    const T: type = p.game;
    if (@hasDecl(T, "init")) {
        try T.init();
    }

    while (window.isActive() and is_running) {
        window.clear(.{ .r = 0.25, .g = 0.25, .b = 0.25 });
        input.newFrame();
        window.update();

        // Call user define update and fixed_update functions
        try tick.update();

        renderer.processQueuedDrawCalls();
        window.swap();
    }

    if (@hasDecl(T, "deinit")) {
        T.deinit();
    }
}

pub fn quit() void {
    is_running = false;
}
