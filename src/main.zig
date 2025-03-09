const std = @import("std");

const zo = @import("zo.zig");
const window = @import("window.zig");

pub fn main() !void {
    zo.init();

    window.create("General", 200, 200, 600, 800);

    std.time.sleep(2_000_000_000);

    zo.deinit();
}
