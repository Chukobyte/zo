const std = @import("std");
const zo = @import("zo");
const global = @import("global.zig");

const InitSceneDefinition = @import("game.zig").InitSceneDefinition;

pub const GameMain = struct {
    pub fn init() !void {
        try global.init(global.allocator);
        global.scene_system.changeScene(InitSceneDefinition);
    }

    pub fn deinit() void {
        global.deinit();
    }

    pub fn preTick() !void {
        try global.world.preTick();
    }

    pub fn update(delta_seconds: f32) !void {
        try global.scene_system.newFrame();
        try global.world.update(delta_seconds);
    }

    pub fn fixedUpdate(delta_seconds: f32) !void {
        try global.world.fixedUpdate(delta_seconds);
    }

    pub fn postTick() !void {
        try global.world.postTick();
    }
};

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
