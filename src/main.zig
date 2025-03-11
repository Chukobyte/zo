const std = @import("std");

const zo = @import("zo.zig");
const window = zo.window;
const input = zo.input;
const math = zo.math;
const logger = @import("logger.zig");

const Vec2 = math.Vec2;

const GameConfig = struct {
    name: []const u8 = "Test Game",
    window_pos: Vec2 = .{ .x = 300, .y = 300 },
    window_width: i32 = 800,
    window_height: i32 = 600,
};

const config: GameConfig = .{};

pub fn main() !void {
    window.create(config.name, config.window_pos.x, config.window_pos.y, config.window_width, config.window_height);

    var is_running = true;
    logger.log(.debug, "Is running!", .{});

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
