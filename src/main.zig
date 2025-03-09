const std = @import("std");

const zo = @import("zo.zig");
const window = @import("window.zig");
const input = @import("input.zig");

pub fn main() !void {
    zo.init();
    defer zo.deinit();

    window.create("General", 200, 200, 600, 800);

    var is_running = true;

    while (window.is_active() and is_running) {
        input.new_frame();
        window.update();

        if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
            std.debug.print("a pressed!\n", .{});
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            is_running = false;
        }
    }
}
