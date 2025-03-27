///! World and scene related stuff

const std = @import("std");
const zo = @import("zo");
const static_assets = @import("static_assets");
const game = @import("game.zig");
const component_systems = @import("component_systems.zig");
const ecs = zo.ecs;
const renderer = zo.renderer;
const audio = zo.audio;

const Texture = renderer.Texture;
const Font = renderer.Font;
const AudioSource = audio.AudioSource;
const Transform2DComponent = component_systems.Transform2DComponent;
const SpriteComponent = component_systems.SpriteComponent;
const TextLabelComponent = component_systems.TextLabelComponent;
const ClickableComponent = component_systems.ClickableComponent;
const ColorRectComponent = component_systems.ColorRectComponent;
const SpriteRenderingSystem = component_systems.SpriteRenderingSystem;
const TextRenderingSystem = component_systems.TextRenderingSystem;
const UIClickingSystem = component_systems.UIClickingSystem;
const ColorRectSystem = component_systems.ColorRectSystem;

pub const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{
        game.InitEntity, game.MainMenuEntity, game.NewGameEntity, game.ExistingCharacterEntity, game.NewCharacterEntity, game.LocationEntity, game.MapEntity
    },
    .components = &.{ Transform2DComponent, SpriteComponent, TextLabelComponent, ClickableComponent, ColorRectComponent },
    .systems = &.{ SpriteRenderingSystem, TextRenderingSystem, UIClickingSystem, ColorRectSystem },
    .archetypes = @as([]const []const type, &.{
        &.{ Transform2DComponent, SpriteComponent },
        &.{ Transform2DComponent, TextLabelComponent },
        &.{ Transform2DComponent, ClickableComponent },
        &.{ Transform2DComponent,  ColorRectComponent },
    }),
});

pub const SceneSystem = World.SceneSystem(.{ .definitions = &.{
    game.InitSceneDefinition, game.MainMenuSceneDefinition, game.NewGameSceneDefinition, game.ExistingCharacterSceneDefinition,
    game.NewCharacterSceneDefinition, game.LocationSceneDefinition, game.MapSceneDefinition,
} });

pub const AssetManager = struct {

    textures: struct {
        map: Texture,
    },

    fonts: struct {
        verdana_16: Font,
        verdana_32: Font,
    },

    audio: struct {
        rainbow_orb: AudioSource,
    },


    pub fn init() !@This() {
        return @This(){
            .textures = .{
                .map = try Texture.initFromMemory2(allocator, static_assets.map_texture, true),
            },
            .fonts = .{
                .verdana_16 = try Font.initFromMemory2(static_assets.default_font, 16, true),
                .verdana_32 = try Font.initFromMemory2(static_assets.default_font, 32, true),
            },
            .audio = .{
                .rainbow_orb = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio),
            },
        };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }
};

pub var allocator: std.mem.Allocator = std.heap.page_allocator;

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
