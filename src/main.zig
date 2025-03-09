const std = @import("std");

const zo = @import("zo.zig");
const window = @import("window.zig");
const input = @import("input.zig");

pub fn main() !void {
    zo.init();
    defer zo.deinit();

    window.create("Test Game", 300, 300, 800, 600);

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
