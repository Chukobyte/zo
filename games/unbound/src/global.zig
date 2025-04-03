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
const ColorRectComponent = component_systems.ColorRectComponent;
const UIEventComponent = component_systems.UIEventComponent;
const SpriteRenderingSystem = component_systems.SpriteRenderingSystem;
const TextRenderingSystem = component_systems.TextRenderingSystem;
const UIEventSystem = component_systems.UIEventSystem;
const ColorRectSystem = component_systems.ColorRectSystem;

pub const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{
        game.InitEntity, game.MainMenuEntity, game.NewGameEntity, game.ExistingCharacterEntity, game.NewCharacterEntity,
        game.LocationEntity, game.MapEntity, game.CharacterViewEntity, game.EndTurnMapEntity, game.DiscoverEntity,
        game.MilitaryEntity, game.InteractEntity, game.BattleEntity,
    },
    .components = &.{ Transform2DComponent, SpriteComponent, TextLabelComponent, ColorRectComponent, UIEventComponent },
    .systems = &.{ SpriteRenderingSystem, TextRenderingSystem, UIEventSystem, ColorRectSystem },
    .archetypes = @as([]const []const type, &.{
        &.{ Transform2DComponent, SpriteComponent },
        &.{ Transform2DComponent, TextLabelComponent },
        &.{ Transform2DComponent, UIEventComponent },
        &.{ Transform2DComponent,  ColorRectComponent },
    }),
});

pub const SceneSystem = World.SceneSystem(.{ .definitions = &.{
    game.InitSceneDefinition, game.MainMenuSceneDefinition, game.NewGameSceneDefinition, game.ExistingCharacterSceneDefinition,
    game.NewCharacterSceneDefinition, game.LocationSceneDefinition, game.MapSceneDefinition, game.CharacterViewSceneDefinition,
    game.DiscoverSceneDefinition, game.InteractSceneDefinition, game.MilitarySceneDefinition, game.BattleSceneDefinition, game.EndTurnMapSceneDefinition,
} });

pub const AssetManager = struct {

    textures: struct {
        map: Texture,
    },

    fonts: struct {
        pixeloid_16: Font,
        pixeloid_32: Font,
    },

    audio: struct {
        click: AudioSource,
        invalid_click: AudioSource,
    },


    pub fn init() !@This() {
        var asset_manager = @This(){
            .textures = .{
                .map = try Texture.initFromMemory2(allocator, static_assets.map_texture, true),
            },
            .fonts = .{
                .pixeloid_16 = try Font.initFromMemory2(static_assets.default_font, 16, true),
                .pixeloid_32 = try Font.initFromMemory2(static_assets.default_font, 32, true),
            },
            .audio = .{
                .click = try AudioSource.initWavFromMemory2(static_assets.click_audio),
                .invalid_click = try AudioSource.initWavFromMemory2(static_assets.invalid_click_audio),
            },
        };
        // TODO: Temp manual adjustments, fix later...
        asset_manager.fonts.pixeloid_16.text_height -= 7.0;
        asset_manager.fonts.pixeloid_32.text_height -= 7.0;
        return asset_manager;
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
    try world.postInit();
}

pub fn deinit() void {
    scene_system.deinit();
    world.deinit();
    assets.deinit();
}
