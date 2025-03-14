const std = @import("std");

const static_assets = @import("static_assets");

const game = @import("game.zig");
const renderer = @import("renderer.zig");
const audio = @import("audio.zig");
const zo = @import("zo.zig");
const window = zo.window;
const input = zo.input;
const math = zo.math;

const Vec2 = math.Vec2;
const Texture = renderer.Texture;
const Font = renderer.Font;

const AudioSource = audio.AudioSource;

const GameMain = struct {
    var map_textue: Texture = undefined;
    var verdana_font: Font = undefined;
    var rainbow_orb_audio: AudioSource = undefined;

    pub fn init() !void {
        map_textue = try Texture.initFromMemory2(std.heap.page_allocator, static_assets.map_texture, true);
        verdana_font = try Font.initFromMemory2(static_assets.default_font, 16, true);
        rainbow_orb_audio = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio);
    }

    pub fn deinit() void {
        map_textue.deinit();
        verdana_font.deinit();
        rainbow_orb_audio.deinit();
    }

    pub fn update(_: f32) !void {
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
