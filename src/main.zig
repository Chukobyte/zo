const std = @import("std");

const static_assets = @import("static_assets");

const renderer = @import("renderer.zig");
const zo = @import("zo.zig");
const window = zo.window;
const input = zo.input;
const math = zo.math;

const Vec2 = math.Vec2;
const Texture = renderer.Texture;

const GameConfig = struct {
    name: []const u8 = "Test Game",
    window_pos: Vec2 = .{ .x = 300, .y = 300 },
    window_width: i32 = 800,
    window_height: i32 = 600,
};

const config: GameConfig = .{};

pub fn main() !void {
    window.create(config.name, config.window_pos.x, config.window_pos.y, config.window_width, config.window_height);
    // try renderer.init(config.window_width, config.window_height);
    // defer renderer.deinit();

    // var test_texture: Texture = try Texture.initFromMemory(std.heap.page_allocator, static_assets.seika_idle_texture.ptr, static_assets.seika_idle_texture.len, true);
    // defer test_texture.deinit();

    var is_running = true;

    while (window.is_active() and is_running) {
        window.clear(.{ .r = 0.25, .g = 0.25, .b = 0.25 });

        input.new_frame();
        window.update();

        if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
            std.debug.print("a pressed!\n", .{});
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            is_running = false;
        }

        window.swap();
    }
}
