const std = @import("std");

const static_assets = @import("static_assets");

const zo = @import("zo");

const game = @import("game.zig");

const ecs = zo.ecs;
const renderer = zo.renderer;
const audio = zo.audio;
const window = zo.window;
const input = zo.input;
const math = zo.math;

const Vec2 = math.Vec2;
const Texture = renderer.Texture;
const Font = renderer.Font;

const AudioSource = audio.AudioSource;

const log = zo.log;

const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{ MainEntity },
});
// const SceneSystem = World.SceneSystem(.{ .definitions = &.{ .name = "Default", .node_interface = MainEntity, } });
const SceneSystem = World.SceneSystem(.{ .definitions = &[_]ecs.SceneDefinition{ .{ .name = "Default", .node_interface = MainEntity, } } });

const allocator: std.mem.Allocator = std.heap.page_allocator;
var map_textue: Texture = undefined;
var verdana_font: Font = undefined;
var rainbow_orb_audio: AudioSource = undefined;

const MainEntity = struct {
    pub fn init(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world; _ = entity;
        log(.debug, "init", .{});
    }
    pub fn deinit(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
        log(.debug, "deinit", .{});
    }
    pub fn update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
        if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
            std.debug.print("a pressed!\n", .{});
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            try rainbow_orb_audio.play(false);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }

        renderer.drawSprite(&.{
            .texture = &map_textue,
            .source_rect = .{ .x = 0.0, .y = 0.0, .w = 640.0, .h = 360.0 },
        });

        renderer.drawText(&.{
            .text = "Colonial America",
            .font = &verdana_font,
            .position = .{ .x = 200.0, .y = 200.0 },
        });

        renderer.drawText(&.{
            .text = "Virginia",
            .font = &verdana_font,
            .position = .{ .x = 100.0, .y = 340.0 },
        });
    }
    pub fn fixed_update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
    }
};

const GameMain = struct {
    var world: World = undefined;
    var scene_system: SceneSystem = undefined;

    pub fn init() !void {
        world = try World.init(allocator);
        scene_system = SceneSystem.init(&world);
        scene_system.changeScene("Default");
        map_textue = try Texture.initFromMemory2(std.heap.page_allocator, static_assets.map_texture, true);
        verdana_font = try Font.initFromMemory2(static_assets.default_font, 16, true);
        rainbow_orb_audio = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio);
    }

    pub fn deinit() void {
        map_textue.deinit();
        verdana_font.deinit();
        rainbow_orb_audio.deinit();
        world.deinit();
    }

    pub fn update(delta_seconds: f32) !void {
        try scene_system.newFrame();
        try world.update(delta_seconds);
    }

    pub fn fixedUpdate(delta_seconds: f32) !void {
        try world.fixedUpdate(delta_seconds);
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
