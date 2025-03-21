//! All logic related specifically to the game prototype

const std = @import("std");
const zo = @import("zo");
const component_systems = @import("component_systems.zig");
const object = @import("object.zig");
const global = @import("global.zig");
const state = @import("state.zig");

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
    selected_location_cursor: GameObject = undefined,
    location_index: usize = 0,

    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = world; _ = entity;
        const intitial_map_pos = state.map_locations[self.location_index].map_position;
        self.selected_location_cursor = try GameObject.initInScene(
            .text_label,
            .{ .text = "{}", .font = &global.assets.fonts.verdana_16, .transform = .{ .position = intitial_map_pos }, },
            null,
            null
        );
    }

    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }
    }

    pub fn fixedUpdate(self: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        const InputMoveDirection = enum {
            none,
            up,
            down
        };
        var move_direction: InputMoveDirection = .none;
        if (input.is_key_pressed(.{ .key = .keyboard_left }) or input.is_key_pressed(.{ .key = .keyboard_a })) {

        } else if (input.is_key_pressed(.{ .key = .keyboard_right }) or input.is_key_pressed(.{ .key = .keyboard_d })) {

        } else if (input.is_key_pressed(.{ .key = .keyboard_down }) or input.is_key_pressed(.{ .key = .keyboard_s })) {
            move_direction = .down;
        } else if (input.is_key_pressed(.{ .key = .keyboard_up }) or input.is_key_pressed(.{ .key = .keyboard_w })) {
            move_direction = .up;
        }

        switch (move_direction) {
            .none => {},
            .up => {
                if (self.location_index + 1 >= state.map_locations.len) {
                    self.location_index = 0;
                } else {
                    self.location_index += 1;
                }
                const new_location = state.map_locations[self.location_index].map_position;
                self.selected_location_cursor.setLocalPosition(new_location);
            },
            .down => {
                if (self.location_index == 0) {
                    self.location_index = state.map_locations.len - 1;
                } else {
                    self.location_index -= 1;
                }
                const new_location = state.map_locations[self.location_index].map_position;
                self.selected_location_cursor.setLocalPosition(new_location);
            },
        }
    }
};
