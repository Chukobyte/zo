//! All logic related specifically to the game prototype

const std = @import("std");
const zo = @import("zo");
const component_systems = @import("component_systems.zig");
const object = @import("object.zig");
const global = @import("global.zig");

const ecs = zo.ecs;
const audio = zo.audio;
const input = zo.input;
const math = zo.math;

const Dim2 = math.Dim2;
const World = global.World;
const Node = World.Node;
const GameObject = object.GameObject;

const log = zo.log;

// Scenes

// INIT
pub const InitSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return InitEntity;
    }
};

pub const InitEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        global.scene_system.changeScene(MainMenuSceneDefinition);
    }
};

// MAIN MENU
pub const MainMenuSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MainMenuEntity;
    }
};

pub const MainMenuEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        const title_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Test Game", .font = &global.assets.fonts.verdana_32, .transform = .{ .position = .{ .x = 200.0, .y = 100.0 } }, },
            null,
            null
        );
        const instructions_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Press Space to Play", .font = &global.assets.fonts.verdana_16, .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );
        _ = title_text; _ = instructions_text;
    }
    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            global.scene_system.changeScene(MapSceneDefinition);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }
    }
};

// LOCATION
pub const LocationSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return LocationEntity;
    }
};

pub const LocationEntity = struct {};

// MAP
pub const MapSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MapEntity;
    }
};

pub const MapEntity = struct {
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
            .{ .text = "Virginia", .font = &global.assets.fonts.verdana_16, .transform = .{ .position = .{ .x = 100.0, .y = 340.0 } }, .z_index = 2 },
            main_node,
            null
        );
        colonial_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Colonial America", .font = &global.assets.fonts.verdana_16, .transform = .{ .position = .{ .x = 200.0, .y = 200.0 } }, .z_index = 1 },
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
