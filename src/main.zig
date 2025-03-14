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

var seika_textue: Texture = undefined;
var verdana_font: Font = undefined;
var rainbow_orb_audio: AudioSource = undefined;

fn init() void {
    seika_textue = Texture.initFromMemory2(std.heap.page_allocator, static_assets.seika_idle_texture, true) catch { zo.quit(); return undefined; };
    verdana_font = Font.initFromMemory2(static_assets.default_font, 32, true) catch { zo.quit(); return undefined; };
    rainbow_orb_audio = AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio) catch { zo.quit(); return undefined; };
}

fn deinit() void {
    seika_textue.deinit();
    verdana_font.deinit();
    rainbow_orb_audio.deinit();
}

fn update(_: f32) void {
    if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
        std.debug.print("a pressed!\n", .{});
    }

    if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
        rainbow_orb_audio.play(false) catch {} ;
    }

    if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
        zo.quit();
    }

    renderer.drawSprite(&.{
        .texture = &seika_textue,
        .source_rect = .{ .x = 0.0, .y = 0.0, .w = 32.0, .h = 32.0 },
        .dest_size = .{ .x = 32.0, .y = 32.0 },
        .transform = .{
            .position = .{ .x = 200.0, .y = 200.0 },
            .scale = .{ .x = 5.0, .y = 5.0 },
        }
    });

    renderer.drawText(&.{
        .text = "Zo Test",
        .font = &verdana_font,
        .position = .{ .x = 200.0, .y = 400.0 },
    });
}


pub fn main() !void {
    try zo.run(.{
        .callbacks = .{
            .update = update,
            .init = init,
            .deinit = deinit,
        },
        .window = .{
            .title = "Test Game",
            .pos = .{ .x = 100.0, .y = 100.0 },
            .size = .{ .w = 800, .h = 600 },
        }
    });
}
