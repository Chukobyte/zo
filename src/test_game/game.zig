//! All logic related specifically to the game prototype

const std = @import("std");
const zo = @import("zo");
const game = @import("game.zig");
const component_systems = @import("component_systems.zig");
const object = @import("object.zig");
const global = @import("global.zig");

const ecs = zo.ecs;
const renderer = zo.renderer;
const audio = zo.audio;
const window = zo.window;
const input = zo.input;
const math = zo.math;

const Vec2 = math.Vec2;
const Rect2 = math.Rect2;
const Transform2D = math.Transform2D;
const Dim2 = math.Dim2;
const Dim2i = math.Dim2i;
const Mat4 = math.Mat4;
const LinearColor = math.LinearColor;
const Texture = renderer.Texture;
const Font = renderer.Font;
const AudioSource = audio.AudioSource;
const String = zo.string.String4;
const World = global.World;
const SceneSystem = global.SceneSystem;
const Node = World.Node;
const Transform2DComponent = component_systems.Transform2DComponent;
const SpriteComponent = component_systems.SpriteComponent;
const TextLabelComponent = component_systems.TextLabelComponent;
const NodeMatrixInterface = component_systems.NodeMatrixInterface;
const GameObject = object.GameObject;

const log = zo.log;

pub const MainSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MainEntity;
    }
};

pub const MainEntity = struct {
    var main_object: GameObject = undefined;
    var virginia_text: GameObject = undefined;
    var colonial_text: GameObject = undefined;

    pub fn init(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world; _ = entity;
    }
    pub fn deinit(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world;
        // Setup main entity
        const main_node = global.scene_system.getNode(entity).?;
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        main_object = try GameObject.initFromNode(
            .sprite,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            main_node
        );
        virginia_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Virginia", .font = &global.assets.fonts.verdana, .transform = .{ .position = .{ .x = 100.0, .y = 340.0 } }, .z_index = 2 },
            main_node,
            null
        );
        colonial_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Colonial America", .font = &global.assets.fonts.verdana, .transform = .{ .position = .{ .x = 200.0, .y = 200.0 } }, .z_index = 1 },
            main_node,
            null
        );
    }
    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            try global.assets.audio.rainbow_orb.play(false);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }
    }
    pub fn fixedUpdate(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity;
        const move_speed: f32 = 100;
        if (input.is_key_pressed(.{ .key = .keyboard_a })) {
            main_object.updateLocalPosition(.{ .x = -move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_d })) {
            main_object.updateLocalPosition(.{ .x = move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_s })) {
            main_object.updateLocalPosition(.{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_w })) {
            main_object.updateLocalPosition(.{ .x = 0.0, .y = -move_speed * delta_seconds });
        }

        if (input.is_key_pressed(.{ .key = .keyboard_l })) {
            virginia_text.updateGlobalPosition(.{ .x = move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_j })) {
            virginia_text.updateGlobalPosition(.{ .x = -move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_k })) {
            virginia_text.updateGlobalPosition(.{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_i })) {
            virginia_text.updateGlobalPosition(.{ .x = 0.0, .y = -move_speed * delta_seconds });
        }
    }
};

pub const GameMain = struct {

    pub fn init() !void {
        try global.init(global.allocator);
        global.scene_system.changeScene(MainSceneDefinition);
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
