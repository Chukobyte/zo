const std = @import("std");

const zo = @import("zo");

const GameMain = @import("game.zig").GameMain;

pub fn main() !void {
    try zo.run(.{
        .window = .{
            .title = "Test Game",
            .pos = .{ .x = 100.0, .y = 100.0 },
            .size = .{ .w = 640, .h = 360 },
        },
        .game = GameMain,
        .target_fps = 60,
    });
}
