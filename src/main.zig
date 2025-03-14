const std = @import("std");

const static_assets = @import("static_assets");

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

const GameConfig = struct {
    name: []const u8 = "Test Game",
    window_pos: Vec2 = .{ .x = 100, .y = 100 },
    window_width: i32 = 800,
    window_height: i32 = 600,
};

const config: GameConfig = .{};

pub fn main() !void {
    try window.create(config.name, config.window_pos.x, config.window_pos.y, config.window_width, config.window_height);
    try renderer.init(config.window_width, config.window_height);
    defer renderer.deinit();
    try audio.init();
    defer audio.deinit();

    var test_texture: Texture = try Texture.initFromMemory2(std.heap.page_allocator, static_assets.seika_idle_texture, true);
    defer test_texture.deinit();

    var test_font: Font = try Font.initFromMemory2(static_assets.default_font, 32, true);
    defer test_font.deinit();

    var test_audio_source: AudioSource = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio);
    defer test_audio_source.deinit();

    var is_running = true;

    while (window.isActive() and is_running) {
        window.clear(.{ .r = 0.25, .g = 0.25, .b = 0.25 });

        input.new_frame();
        window.update();

        if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
            std.debug.print("a pressed!\n", .{});
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            try test_audio_source.play(false);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            is_running = false;
        }

        renderer.drawSprite(&.{
            .texture = &test_texture,
            .source_rect = .{ .x = 0.0, .y = 0.0, .w = 32.0, .h = 32.0 },
            .dest_size = .{ .x = 32.0, .y = 32.0 },
            .transform = .{
                .position = .{ .x = 200.0, .y = 200.0 },
                .scale = .{ .x = 5.0, .y = 5.0 },
            }
        });

        renderer.drawText(&.{
            .text = "Zo Test",
            .font = &test_font,
            .position = .{ .x = 200.0, .y = 400.0 },
        });

        window.swap();
    }
}
