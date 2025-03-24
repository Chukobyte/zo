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
const Location = state.Location;
const TextLabelComponent = component_systems.TextLabelComponent;

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
            .{ .font = &global.assets.fonts.verdana_32, .text = "Unbound", .transform = .{ .position = .{ .x = 225.0, .y = 100.0 } }, },
            null,
            null
        );
        const instructions_text = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "Space for New Game", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );
        _ = title_text; _ = instructions_text;
        // TODO: Test text boxes
        // _ = try GameObject.initInScene(
        //     .text_box,
        // .{ .font = &global.assets.fonts.verdana_16, .size = .{ .w = 75, .h = 50 }, .text = "Testing this long string of text to try it out!", .transform = .{ .position = .{ .x = 200.0, .y = 280.0 } }, },
        //     null,
        //     null
        // );
        // TODO: Testing subscribing to event delegates, will remove later
        // const Local = struct {
        //     pub fn onRegisteredInput(event: *const input.InputEvent) void {
        //         log(.debug, "key = {any}, status = {any}", .{ event.key, event.status });
        //     }
        // };
        // _ = input.registered_input_delegate.subscribe(Local.onRegisteredInput);
    }

    pub fn onExitScene(_: *@This(), _: *World, _: ecs.Entity) void {
        // input.registered_input_delegate.clearAndFree();
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_space })) {
            global.scene_system.changeScene(NewGameSceneDefinition);
        }
    }
};

// NEW GAME
pub const NewGameSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return NewGameEntity;
    }
};

pub const NewGameEntity = struct {
    const CharacterMode = enum {
        existing,
        new,
    };

    character_mode_text: GameObject = undefined,
    character_mode: CharacterMode = .existing,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "Select Character to Play", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );

        self.character_mode_text = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "Existing", .transform = .{ .position = .{ .x = 270.0, .y = 260.0 } }, },
            null,
            null
        );
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_space })) {
            if (self.character_mode == .existing) {
                global.scene_system.changeScene(ExistingCharacterSceneDefinition);
            } else {
                global.scene_system.changeScene(NewCharacterSceneDefinition);
            }
        }

        if (input.isKeyJustPressed(.{ .key = .keyboard_down }) or input.isKeyJustPressed(.{ .key = .keyboard_s })) {
            self.character_mode = if (self.character_mode == .existing) .new else .existing;
            if (world.getComponent(self.character_mode_text.node.entity, TextLabelComponent)) |text_label_comp| {
                const modeText: []const u8 = if (self.character_mode == .existing) "Existing" else "New";
                try text_label_comp.class.label.text.setRaw(modeText);
            }
        } else if (input.isKeyJustPressed(.{ .key = .keyboard_up }) or input.isKeyJustPressed(.{ .key = .keyboard_w })) {
            self.character_mode = if (self.character_mode == .existing) .new else .existing;
            if (world.getComponent(self.character_mode_text.node.entity, TextLabelComponent)) |text_label_comp| {
                const modeText: []const u8 = if (self.character_mode == .existing) "Existing" else "New";
                try text_label_comp.class.label.text.setRaw(modeText);
            }
        }
    }
};

// EXISTING CHARACTER
pub const ExistingCharacterSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return ExistingCharacterEntity;
    }
};

pub const ExistingCharacterEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "Existing", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_space })) {
            global.scene_system.changeScene(MapSceneDefinition);
        }
    }
};

// NEW CHARACTER
pub const NewCharacterSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return NewCharacterEntity;
    }
};

pub const NewCharacterEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "New", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_space })) {
            global.scene_system.changeScene(MapSceneDefinition);
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
    selected_location_name: GameObject = undefined,
    location_index: usize = 9,

    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = world; _ = entity;
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        _ = try GameObject.initInScene(
            .sprite,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            null,
            null
        );

        const intitial_location = &state.map_locations[self.location_index];
        self.selected_location_cursor = try GameObject.initInScene(
            .text_label,
            .{ .text = "{}", .font = &global.assets.fonts.verdana_16, .transform = .{ .position = intitial_location.map_position }, },
            null,
            null
        );
        self.selected_location_name = try GameObject.initInScene(
            .text_label,
            .{ .text = intitial_location.name, .font = &global.assets.fonts.verdana_16, .transform = .{ .position = .{ .x = 100.0, .y = 340.0 } }, },
            null,
            null
        );
    }

    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }

    pub fn fixedUpdate(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (self.checkForLocationChange()) |new_location| {
            self.selected_location_cursor.setLocalPosition(new_location.map_position);
            var text_label_comp = world.getComponent(self.selected_location_name.node.entity, TextLabelComponent);
            try text_label_comp.?.class.label.text.setRaw(new_location.name);
        }
    }

    fn checkForLocationChange(self: *@This()) ?*const Location {
        if (input.isKeyJustPressed(.{ .key = .keyboard_down }) or input.isKeyJustPressed(.{ .key = .keyboard_s })) {
            if (self.location_index + 1 >= state.map_locations.len) {
                self.location_index = 0;
            } else {
                self.location_index += 1;
            }
            return &state.map_locations[self.location_index];
        } else if (input.isKeyJustPressed(.{ .key = .keyboard_up }) or input.isKeyJustPressed(.{ .key = .keyboard_w })) {
            if (self.location_index == 0) {
                self.location_index = state.map_locations.len - 1;
            } else {
                self.location_index -= 1;
            }
            return &state.map_locations[self.location_index];
        }
        return null;
    }
};
