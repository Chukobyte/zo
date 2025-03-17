const std = @import("std");

pub const math = @import("math.zig");
pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const renderer = @import("renderer.zig");
pub const audio = @import("audio.zig");
pub const ecs = @import("ecs.zig");
pub const logger = @import("logger.zig");
pub const misc = @import("misc.zig");

pub const log = logger.log;

pub const StaticAsset = @import("static_asset.zig").StaticAsset;

const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;
const LinearColor = math.LinearColor;
const ECSWorldParams = ecs.ECSWorldParams;

const Tick = @import("tick.zig").Tick;

pub const ZoParams = struct {
    const WindowParams = struct {
        title: []const u8,
        pos: Vec2i,
        size: Dim2i,
        background: LinearColor = .{ .r = 0.25, .g = 0.25, .b = 0.25 },
    };

    window: WindowParams,
    target_fps: u32,
    ecs_params: ?ECSWorldParams = null,
    fixed_target_fps: ?u32 = null,
    resolution: ?Dim2i = null,
};

var is_running = false;

pub fn Runner(comptime p: ZoParams) type {
    return struct {
        pub const World = if (p.ecs_params)|ecs_params| ecs.ECSWorld(ecs_params) else undefined;

        pub fn run() !void {
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

            var tick: Tick = undefined;

            if (p.ecs_params != null) {
                const allocator = std.heap.page_allocator;
                var world = try World.init(allocator);
                tick = Tick.init(.{
                    .target_fps = p.target_fps,
                    .fixed_target_fps = p.fixed_target_fps,
                });

                // TODO: Initialize this in another place
                _ = try world.initEntity(.{ .interface = p.ecs_params.?.entity_interfaces[0], });
            }

            is_running = true;

            while (window.isActive() and is_running) {
                window.clear(.{ .r = 0.25, .g = 0.25, .b = 0.25 });
                input.new_frame();
                window.update();

                // Call user define update and fixed_update functions
                if (p.ecs_params != null) {
                    try tick.update(World.Static);
                }

                window.swap();
            }
        }
    };
}

pub fn quit() void {
    is_running = false;
}
