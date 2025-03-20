///! World and scene related stuff

const std = @import("std");
const zo = @import("zo");

const static_assets = @import("static_assets");

const game = @import("game.zig");

const ecs = zo.ecs;
const renderer = zo.renderer;
const audio = zo.audio;

const Texture = renderer.Texture;
const Font = renderer.Font;
const AudioSource = audio.AudioSource;

pub const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{ game.MainEntity },
    .components = &.{ game.Transform2DComponent, game.SpriteComponent, game.TextLabelComponent },
    .systems = &.{ game.SpriteRenderingSystem, game.TextRenderingSystem },
    .archetypes = @as([]const []const type, &.{
        &.{ game.Transform2DComponent, game.SpriteComponent },
        &.{ game.Transform2DComponent, game.TextLabelComponent },
    }),
});

pub const SceneSystem = World.SceneSystem(.{ .definitions = &.{
    game.MainSceneDefinition,
} });

pub const AssetManager = struct {

    textures: struct {
        map: Texture,
    },

    fonts: struct {
        verdana: Font,
    },

    audio: struct {
        rainbow_orb: AudioSource,
    },


    pub fn init() !@This() {
        return @This(){
            .textures = .{ .map = try Texture.initFromMemory2(allocator, static_assets.map_texture, true) },
            .fonts = .{ .verdana = try Font.initFromMemory2(static_assets.default_font, 16, true) },
            .audio = .{ .rainbow_orb = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio) },
        };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }
};

var allocator: std.mem.Allocator = undefined;

pub var world: World = undefined;
pub var scene_system: SceneSystem = undefined;
pub var assets: AssetManager = undefined;

pub fn init(alloc: std.mem.Allocator) !void {
    allocator = alloc;
    world = try World.init(allocator);
    scene_system = SceneSystem.init(&world);
    assets = try AssetManager.init();
}

pub fn deinit() void {
    scene_system.deinit();
    world.deinit();
    assets.deinit();
}
