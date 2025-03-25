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
const delegate = zo.delegate;

const Rect2 = math.Rect2;
const Dim2 = math.Dim2;
const String = zo.string.HeapString;
const World = global.World;
const Node = World.Node;
const GameObject = object.GameObject;
const Location = state.Location;
const TextLabelComponent = component_systems.TextLabelComponent;
const InputAction = input.InputAction;
const InputKey = input.InputKey;
const InputEvent = input.InputEvent;
const Character = state.Character;
const EthnicityProfile = state.EthnicityProfile;
const SubscriberHandle = delegate.SubscriberHandle;

const log = zo.log;

var move_left_input_handle: InputAction.Handle = 0;
var move_right_input_handle: InputAction.Handle = 0;
var move_up_input_handle: InputAction.Handle = 0;
var move_down_input_handle: InputAction.Handle = 0;

// Scenes

// INIT
pub const InitSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return InitEntity;
    }
};

pub const InitEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        move_left_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_left, .keyboard_a  } } );
        move_right_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_right, .keyboard_d  } } );
        move_up_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_up, .keyboard_w  } } );
        move_down_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_down, .keyboard_d  } } );
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
            .{ .font = &global.assets.fonts.verdana_16, .text = "Enter for New Game", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
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
    }

    pub fn onExitScene(_: *@This(), _: *World, _: ecs.Entity) void {
        // input.registered_input_delegate.clearAndFree();
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_return })) {
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
        new,
        existing,
    };
    const new_text = "New";
    const existing_text = "Existing";

    character_mode_text: GameObject = undefined,
    character_mode: CharacterMode = .new,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = "Select Character to Play", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );

        self.character_mode_text = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = new_text, .transform = .{ .position = .{ .x = 270.0, .y = 260.0 } }, },
            null,
            null
        );
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_return })) {
            if (self.character_mode == .existing) {
                global.scene_system.changeScene(ExistingCharacterSceneDefinition);
            } else {
                global.scene_system.changeScene(NewCharacterSceneDefinition);
            }
        }

        if (input.isActionJustPressed(move_up_input_handle) or input.isActionJustPressed(move_down_input_handle)) {
            self.character_mode = if (self.character_mode == .existing) .new else .existing;
            if (world.getComponent(self.character_mode_text.node.entity, TextLabelComponent)) |text_label_comp| {
                const modeText: []const u8 = if (self.character_mode == .existing) existing_text else new_text;
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
        if (input.isKeyJustPressed(.{ .key = .keyboard_return })) {
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
    const initial_name_text = "Name: ";
    character: Character = .{ .name = undefined, .role = .free_man, .ethnicity = EthnicityProfile.Black },
    skill_points: u32 = 100,
    name_object: GameObject = undefined,
    name_collision_rect: Rect2 = .{ .x = 200.0, .y = 80.0, .w = 200, .h = 100 },
    is_typing_name: bool = false,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        self.character.name = String.init(global.allocator);
        self.name_object = try GameObject.initInScene(
            .text_label,
            .{ .font = &global.assets.fonts.verdana_16, .text = initial_name_text, .transform = .{ .position = .{ .x = 200.0, .y = 100.0 } }, },
            null,
            null
        );
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        const LocalInput = struct {
            var handle: ?delegate.SubscriberHandle = null;
            var name_object: ?*GameObject = null;
            pub fn subscribeToInput(name_obj: *GameObject) void {
                name_object = name_obj;
                handle = input.registered_input_delegate.subscribe(onRegisteredInput);
            }
            pub fn unsubscribeFromInput() void {
                if (handle) |h| {
                    input.registered_input_delegate.unsubscribe(h);
                    handle = null;
                }
                name_object = null;
            }
            pub fn onRegisteredInput(event: *const InputEvent) void {
                // Filter out event first
                if (event.status != .just_pressed or event.source != .keyboard) { return; }

                // Delete the last char in array
                if (event.key == .keyboard_backspace) {
                    if (name_object) |name_obj| {
                        var text_label_comp = global.world.getComponent(name_obj.node.entity, TextLabelComponent).?;
                        var text_label = text_label_comp.class.label;
                        // Don't process backspace ic
                        if (std.mem.eql(u8, text_label.text.get(), initial_name_text)) { return; }
                        text_label_comp.class.label.text.popChar();
                    }
                }

                if (getValidTypedChar(event.key)) |ch| {
                    if (name_object) |name_obj| {
                        var text_label_comp = global.world.getComponent(name_obj.node.entity, TextLabelComponent).?;
                        text_label_comp.class.label.text.appendChar(ch) catch {unreachable;};
                    }
                }
            }
            fn getValidTypedChar(key: InputKey) ?u8 {
                // Early outs if space or non alphanumeric characters
                if (key == .keyboard_space) { return ' '; }
                if (!key.isAlphanumeric()) { return null; }
                // Now that we're here we know it's a letter or number
                const isShiftPressed = input.isKeyPressed(.{ .key = .keyboard_left_shift }) or input.isKeyPressed(.{ .key = .keyboard_right_shift });
                // Compute the offset from keyboard_a
                // const offset: u8 = @as(u8, @bitCast(@intFromEnum(key))) - @as(u8, @bitCast(@intFromEnum(InputKey.keyboard_a)));
                const offset: u8 = @as(u8, @intCast(@intFromEnum(key))) - @as(u8, @intCast(@intFromEnum(InputKey.keyboard_a)));
                // Return uppercase if shift is pressed, otherwise lowercase
                const ch: u8 = if(isShiftPressed) @as(u8, 'A' + offset) else @as(u8, 'a' + offset);
                return ch;
            }
        };

        if (input.isKeyJustPressed(.{ .key = .keyboard_return })) {
            LocalInput.unsubscribeFromInput();
            global.scene_system.changeScene(MapSceneDefinition);
        }

        if (input.isKeyJustPressed(.{ .key = .mouse_button_left })) {
            const mouse_pos = input.getMousePosition();
            if (self.name_collision_rect.doesPointOverlap(&.{ .x = @floatFromInt(mouse_pos.x), .y = @floatFromInt(mouse_pos.y) })) {
                var text_label_comp = world.getComponent(self.name_object.node.entity, TextLabelComponent).?;
                if (!self.is_typing_name) {
                    text_label_comp.color = math.LinearColor.Red;
                    LocalInput.subscribeToInput(&self.name_object);
                } else {
                    text_label_comp.color = math.LinearColor.White;
                    LocalInput.unsubscribeFromInput();
                }
                self.is_typing_name = !self.is_typing_name;
            }
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
        if (input.isActionJustPressed(move_down_input_handle)) {
            if (self.location_index + 1 >= state.map_locations.len) {
                self.location_index = 0;
            } else {
                self.location_index += 1;
            }
            return &state.map_locations[self.location_index];
        } else if (input.isActionJustPressed(move_up_input_handle)) {
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
