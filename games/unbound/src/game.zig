//! All logic related specifically to the game prototype

const std = @import("std");
const zo = @import("zo");
const component_systems = @import("component_systems.zig");
const object = @import("object.zig");
const global = @import("global.zig");
const state = @import("state.zig");

const ecs = zo.ecs;
const window = zo.window;
const renderer = zo.renderer;
const audio = zo.audio;
const input = zo.input;
const math = zo.math;
const delegate = zo.delegate;

const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Rect2 = math.Rect2;
const Dim2 = math.Dim2;
const Dim2i = math.Dim2i;
const Dim2u = math.Dim2u;
const Transform2D = math.Transform2D;
const LinearColor = math.LinearColor;
const Texture = renderer.Texture;
const String = zo.string.HeapString;
const Entity = ecs.Entity;
const World = global.World;
const Node = World.Node;
const GameObject = object.GameObject;
const GameObjectSystem = object.GameObjectSystem;
const Location = state.Location;
const TextLabelComponent = component_systems.TextLabelComponent;
const ColorRectComponent = component_systems.ColorRectComponent;
const UIEventComponent = component_systems.UIEventComponent;
const UIEventSystem = component_systems.UIEventSystem;
const OnUIChangedResponse = component_systems.OnUIChangedResponse;
const NavigationElement = component_systems.NavigationElement;
const InputKey = input.InputKey;
const InputEvent = input.InputEvent;
const InputAction = input.InputAction;
const Character = state.Character;
const Date = state.Date;
const EthnicityProfile = state.EthnicityProfile;
const SubscriberHandle = delegate.SubscriberHandle;
const SpriteClass = object.SpriteClass;
const TextLabelClass = object.TextLabelClass;
const TextBoxClass = object.TextBoxClass;
const TextButtonClass = object.TextButtonClass;

const log = zo.log;

var player_character: *Character = &state.game_state.player_character;
var game_date: *Date = &state.game_state.date;
var move_left_input_handle: InputAction.Handle = 0;
var move_right_input_handle: InputAction.Handle = 0;
var move_up_input_handle: InputAction.Handle = 0;
var move_down_input_handle: InputAction.Handle = 0;

const ButtonUtils = struct {
    on_hover: ?*const fn(Entity) void = null,
    on_unhover: ?*const fn(Entity) void = null,
    on_click: ?*const fn(Entity) void = null,

    pub fn createConfirmButton(on_click: ?*const fn(Entity) OnUIChangedResponse) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Confirm", .on_click = on_click, .transform = .{ .position = .{ .x = 500.0, .y = 300.0 } } },
            null,
            null
        );
    }
    pub fn createBackButton(on_click: ?*const fn(Entity) OnUIChangedResponse) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Back", .on_click = on_click, .transform = .{ .position = .{ .x = 40.0, .y = 300.0 } }, .z_index = 1 },
            null,
            null
        );
    }

    pub fn createValueChangeButton(symbol: []const u8, position: Vec2, on_click: ?*const fn(Entity) OnUIChangedResponse) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 15.0, .h = 15.0 }, .font = &global.assets.fonts.pixeloid_16, .text = symbol, .on_click = on_click, .transform = .{ .position = position } },
            null,
            null
        );
    }

    pub fn setupNavElement(button_object: *GameObject, on_pressed: ?*const fn(Entity) OnUIChangedResponse) !*NavigationElement {
        var ui_event_system = global.world.getSystemInstance(UIEventSystem);
        const ui_event_comp = global.world.getComponent(button_object.getEntity(), UIEventComponent).?;
        const border_thickness: f32 = 2.0;
        const container_size: Dim2 = .{ .w = ui_event_comp.collider.w + border_thickness, .h = ui_event_comp.collider.h + border_thickness };
        const border_position: Vec2 = .{ .x = button_object.getLocalPosition().x - border_thickness, .y = button_object.getLocalPosition().y - border_thickness };
        var new_game_button_element = try ui_event_system.generateNavElement(border_position, container_size, button_object.getEntity());
        new_game_button_element.on_pressed = on_pressed;
        return new_game_button_element;
    }
};

const LocationSelector = struct {
    location_index: usize = 9, // Starts on virginia

    pub fn getLocation(self: *const @This()) *const Location {
        return &state.map_locations[self.location_index];
    }
    pub fn increase(self: *@This()) void {
        if (self.location_index + 1 >= state.map_locations.len) {
            self.location_index = 0;
        } else {
            self.location_index += 1;
        }
    }
    pub fn decrease(self: *@This()) void {
        if (self.location_index == 0) {
            self.location_index = state.map_locations.len - 1;
        } else {
            self.location_index -= 1;
        }
    }

    pub fn setIndexByLocation(self: *@This(), location: *const Location) void {
        for (0..state.map_locations.len) |i| {
            if (location == &state.map_locations[i]) {
                self.location_index = i;
                break;
            }
        }
    }
};

// Scenes

// INIT
pub const InitSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return InitEntity;
    }
};

pub const InitEntity = struct {
    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObjectSystem.init(global.allocator);
        player_character.name = String.init(global.allocator);
        move_left_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_left, .keyboard_a } } );
        move_right_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_right, .keyboard_d } } );
        move_up_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_up, .keyboard_w } } );
        move_down_input_handle = try input.addAction(.{ .keys = &.{ .keyboard_down, .keyboard_d } } );
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
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_32, .text = "Unbound", .transform = .{ .position = .{ .x = 225.0, .y = 100.0 } }, },
            null,
            null
        );
        const new_game_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "New Game", .on_click = onClick, .transform = .{ .position = .{ .x = 240.0, .y = 220.0 } } },
            null,
            null
        );
        _ = try ButtonUtils.setupNavElement(new_game_button, onPressed);
    }

    pub fn onClick(_: Entity) OnUIChangedResponse {
        global.scene_system.changeScene(NewGameSceneDefinition);
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
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

    character_mode_text: *GameObject = undefined,
    character_mode: CharacterMode = .new,
    new_button: *GameObject = undefined,
    existing_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .text = "Select character", .transform = .{ .position = .{ .x = 210.0, .y = 180.0 } }, },
            null,
            null
        );

        self.new_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "New", .on_click = onClick, .transform = .{ .position = .{ .x = 240.0, .y = 200.0 } } },
            null,
            null
        );
        self.existing_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Existing", .on_click = onClick, .transform = .{ .position = .{ .x = 240.0, .y = 230.0 } } },
            null,
            null
        );
        var new_button_element = try ButtonUtils.setupNavElement(self.new_button, onPressed);
        var existing_button_element = try ButtonUtils.setupNavElement(self.existing_button, onPressed);
        new_button_element.up = existing_button_element;
        new_button_element.down = existing_button_element;
        existing_button_element.up = new_button_element;
        existing_button_element.down = new_button_element;
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.new_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewCharacterSceneDefinition);
            } else if (self.existing_button.node.entity == clicked_entity) {
                // TODO: Will add this once this is fully implemented
                // global.scene_system.changeScene(ExistingCharacterSceneDefinition);
                return .invalid;
            }
        }
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
    }
};

// EXISTING CHARACTER
pub const ExistingCharacterSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return ExistingCharacterEntity;
    }
};

pub const ExistingCharacterEntity = struct {
    back_button: *GameObject = undefined,
    confirm_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), _: *World, _: Entity) !void {
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .text = "Existing Character (WIP)", .transform = .{ .position = .{ .x = 210.0, .y = 120.0 } }, },
            null,
            null
        );
        self.back_button = try ButtonUtils.createBackButton(onClick);
        self.confirm_button = try ButtonUtils.createConfirmButton(onClick);
    }

    pub fn update(_: *@This(), _: *World, _: Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_escape })) {
            try global.assets.audio.click.play(false);
            global.scene_system.changeScene(NewGameSceneDefinition);
        }
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewGameSceneDefinition);
            } else if (self.confirm_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(LocationSceneDefinition);
            }
        }
        return .success;
    }
};

// NEW CHARACTER
pub const NewCharacterSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return NewCharacterEntity;
    }
};

pub const NewCharacterEntity = struct {
    const minimum_name_text = "Name: ";
    const default_name = "Samuel";
    const initial_name_text = minimum_name_text ++ default_name;
    const ethnicity_selections: [3]EthnicityProfile = .{ EthnicityProfile.Black, EthnicityProfile.Indigenous, EthnicityProfile.White };

    /// Takes in keyboard input and updates a TextLabelComponent
    const InputText = struct {
        var handle: ?delegate.SubscriberHandle = null;
        var name_object: ?*GameObject = null;
        var disable_nav_movement_token: ?*zo.misc.Token = null;

        pub fn subscribeToInput(name_obj: *GameObject) !void {
            name_object = name_obj;
            handle = try input.registered_input_delegate.subscribe(onRegisteredInput);
            const ui_event_system = global.world.getSystemInstance(UIEventSystem);
            disable_nav_movement_token = try ui_event_system.pause_navigation_movement_tokens.takeToken();
        }
        pub fn unsubscribeFromInput() void {
            if (handle) |h| {
                input.registered_input_delegate.unsubscribe(h);
                handle = null;
            }
            name_object = null;
            if (disable_nav_movement_token) |token| {
                const ui_event_system = global.world.getSystemInstance(UIEventSystem);
                ui_event_system.pause_navigation_movement_tokens.returnToken(token);
                disable_nav_movement_token = null;
                log(.debug, "disable ui elements token", .{});
            }
        }
        pub fn onRegisteredInput(event: *const InputEvent) void {
            // Filter out event first
            if (event.status != .just_pressed or event.source != .keyboard) { return; }

            // Delete the last char in array
            if (event.key == .keyboard_backspace) {
                if (name_object) |name_obj| {
                    var text_label_comp = global.world.getComponent(name_obj.node.entity, TextLabelComponent).?;
                    var text_label = text_label_comp.class.label;
                    // Don't process backspace if at beginning
                    if (std.mem.eql(u8, text_label.text.get(), minimum_name_text)) { return; }
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
            if (key.isLetter()) {
                const isShiftPressed = input.isKeyPressed(.{ .key = .keyboard_left_shift }) or input.isKeyPressed(.{ .key = .keyboard_right_shift });
                const offset: u8 = @as(u8, @intCast(@intFromEnum(key))) - @as(u8, @intCast(@intFromEnum(InputKey.keyboard_a)));
                return if(isShiftPressed) @as(u8, 'A' + offset) else @as(u8, 'a' + offset);
            } else if (key.isNumber()) {
                const offset: u8 = @as(u8, @intCast(@intFromEnum(key))) - @as(u8, @intCast(@intFromEnum(InputKey.keyboard_num_0)));
                return '0' + offset;
            } else if (key == .keyboard_space) {
                return ' ';
            }
            return null;
        }
    };

    skill_points: u32 = 100,
    name_object: *GameObject = undefined,
    edit_name_button: *GameObject = undefined,
    details_object: *GameObject = undefined,
    name_collision_rect: Rect2 = .{ .x = 250.0, .y = 70.0, .w = 200, .h = 30 },
    is_typing_name: bool = false,
    location_selector: LocationSelector = .{},
    ethnicity_index: usize = 0,
    confirm_button: *GameObject = undefined,
    back_button: *GameObject = undefined,
    ethnicity_left_button: *GameObject = undefined,
    ethnicity_right_button: *GameObject = undefined,
    add_lead_button: *GameObject = undefined,
    sub_lead_button: *GameObject = undefined,
    add_military_button: *GameObject = undefined,
    sub_military_button: *GameObject = undefined,
    add_charisma_button: *GameObject = undefined,
    sub_charisma_button: *GameObject = undefined,
    add_intelligence_button: *GameObject = undefined,
    sub_intelligence_button: *GameObject = undefined,
    add_politics_button: *GameObject = undefined,
    sub_politics_button: *GameObject = undefined,
    location_left_button: *GameObject = undefined,
    location_right_button: *GameObject = undefined,
    skill_points_object: *GameObject = undefined,
    ethnicity_nav_element: *NavigationElement = undefined,
    lead_nav_element: *NavigationElement = undefined,
    military_nav_element: *NavigationElement = undefined,
    charisma_nav_element: *NavigationElement = undefined,
    intelligence_nav_element: *NavigationElement = undefined,
    politics_nav_element: *NavigationElement = undefined,
    location_nav_element: *NavigationElement = undefined,
    on_nav_dir_changed_handle: SubscriberHandle = undefined,

    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        try self.resetPlayerCharacter();
        self.name_object = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .text = initial_name_text, .transform = .{ .position = .{ .x = 250.0, .y = 70.0 } }, },
            null,
            null
        );
        self.edit_name_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 75.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Edit", .on_click = onClick, .transform = .{ .position = .{ .x = 150.0, .y = 62.0 } } },
            null,
            null
        );
        self.details_object = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 200, .h = 400 }, .text = try player_character.toString(.create_character), .line_spacing = 10.0, .transform = .{ .position = .{ .x = 250.0, .y = 110.0 } }, },
            null,
            null
        );
        self.confirm_button = try ButtonUtils.createConfirmButton(onClick);
        self.back_button = try ButtonUtils.createBackButton(onClick);
        var edit_name_button_element = try ButtonUtils.setupNavElement(self.edit_name_button, onPressed);
        var confirm_button_element = try ButtonUtils.setupNavElement(self.confirm_button, onPressed);
        var back_button_element = try ButtonUtils.setupNavElement(self.back_button, onPressed);

        const Local = struct {
            pub fn setupValueChangedNavElement(owner_entity: Entity, pos: Vec2) !*NavigationElement {
                var ui_event_system = global.world.getSystemInstance(UIEventSystem);
                const border_thickness: f32 = 2.0;
                const container_size: Dim2 = .{ .w = 325 + border_thickness, .h = 26 + border_thickness };
                const border_position = pos.sub(&.{ .x = border_thickness, .y = border_thickness });
                const new_value_changed_element = try ui_event_system.generateNavElement(border_position, container_size, owner_entity);
                return new_value_changed_element;
            }
        };
        var base_value_changed_pos: Vec2 = .{ .x = 175.0, .y = 130.0 };
        const base_value_changed_y_increment: f32 = 24.0;
        self.ethnicity_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.lead_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.military_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.charisma_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.intelligence_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.politics_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);
        base_value_changed_pos.y += base_value_changed_y_increment;
        self.location_nav_element = try Local.setupValueChangedNavElement(entity, base_value_changed_pos);

        edit_name_button_element.up = back_button_element;
        edit_name_button_element.down = self.ethnicity_nav_element;
        edit_name_button_element.left = back_button_element;
        edit_name_button_element.right = confirm_button_element;
        confirm_button_element.right = back_button_element;
        confirm_button_element.left = back_button_element;
        confirm_button_element.up = self.location_nav_element;
        confirm_button_element.down = edit_name_button_element;
        back_button_element.right = confirm_button_element;
        back_button_element.left = confirm_button_element;
        back_button_element.up = self.location_nav_element;
        back_button_element.down = edit_name_button_element;
        self.ethnicity_nav_element.up = edit_name_button_element;
        self.ethnicity_nav_element.down = self.lead_nav_element;
        self.lead_nav_element.up = self.ethnicity_nav_element;
        self.lead_nav_element.down = self.military_nav_element;
        self.military_nav_element.up = self.lead_nav_element;
        self.military_nav_element.down = self.charisma_nav_element;
        self.charisma_nav_element.up = self.military_nav_element;
        self.charisma_nav_element.down = self.intelligence_nav_element;
        self.intelligence_nav_element.up = self.charisma_nav_element;
        self.intelligence_nav_element.down = self.politics_nav_element;
        self.politics_nav_element.up = self.intelligence_nav_element;
        self.politics_nav_element.down = self.location_nav_element;
        self.location_nav_element.up = self.politics_nav_element;
        self.location_nav_element.down = back_button_element;

        const base_left_x: f32 = 200.0;
        const base_right_x: f32 = 460.0;
        var base_y: f32 = 135.0;
        const y_increment: f32 = 24.0;

        self.ethnicity_left_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.ethnicity_right_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_lead_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_lead_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_military_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_military_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_charisma_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_charisma_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_intelligence_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_intelligence_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_politics_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_politics_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.location_left_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.location_right_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);

        self.skill_points_object = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = "", .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 230.0, .y = 320.0 } }, },
            null,
            null
        );
        self.refreshSkillPoints();

        var ui_event_system = world.getSystemInstance(UIEventSystem);
        self.on_nav_dir_changed_handle = try ui_event_system.on_nav_direction_changed.subscribe(onNavElementDirectionChanged);
    }

    pub fn onExitScene(self: *@This(), world: *World, _: Entity) void {
        var ui_event_system = world.getSystemInstance(UIEventSystem);
        ui_event_system.on_nav_direction_changed.unsubscribe(self.on_nav_dir_changed_handle);
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_escape })) {
            try global.assets.audio.click.play(false);
            if (self.is_typing_name) {
                const text_label_comp = world.getComponent(self.name_object.node.entity, TextLabelComponent).?;
                try self.setIsTypingName(false, text_label_comp);
                InputText.unsubscribeFromInput();
            } else {
                global.scene_system.changeScene(NewGameSceneDefinition);
            }
        }
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.edit_name_button.node.entity == clicked_entity) {
                const text_label_comp = global.world.getComponent(self.name_object.node.entity, TextLabelComponent).?;
                self.setIsTypingName(!self.is_typing_name, text_label_comp) catch { unreachable; }; // Toggle
            } else if (self.ethnicity_left_button.node.entity == clicked_entity) {
                if (self.ethnicity_index == 0) {
                    self.ethnicity_index = ethnicity_selections.len - 1;
                } else {
                    self.ethnicity_index -= 1;
                }
                player_character.ethnicity = ethnicity_selections[self.ethnicity_index];
                self.refreshCharacterDetails();
            } else if (self.ethnicity_right_button.node.entity == clicked_entity) {
                if (self.ethnicity_index + 1 >= ethnicity_selections.len) {
                    self.ethnicity_index = 0;
                } else {
                    self.ethnicity_index += 1;
                }
                player_character.ethnicity = ethnicity_selections[self.ethnicity_index];
                self.refreshCharacterDetails();
            } else if (self.add_lead_button.node.entity == clicked_entity) {
                if (!self.addToProperty(&player_character.lead)) { return .invalid; }
            } else if (self.sub_lead_button.node.entity == clicked_entity) {
                if (!self.subFromProperty(&player_character.lead)) { return .invalid; }
            } else if (self.add_military_button.node.entity == clicked_entity) {
                if (!self.addToProperty(&player_character.military)) { return .invalid; }
            } else if (self.sub_military_button.node.entity == clicked_entity) {
                if (!self.subFromProperty(&player_character.military)) { return .invalid; }
            } else if (self.add_charisma_button.node.entity == clicked_entity) {
                if (!self.addToProperty(&player_character.charisma)) { return .invalid; }
            } else if (self.sub_charisma_button.node.entity == clicked_entity) {
                if (!self.subFromProperty(&player_character.charisma)) { return .invalid; }
            } else if (self.add_intelligence_button.node.entity == clicked_entity) {
                if (!self.addToProperty(&player_character.intelligence)) { return .invalid; }
            } else if (self.sub_intelligence_button.node.entity == clicked_entity) {
                if (!self.subFromProperty(&player_character.intelligence)) { return .invalid; }
            } else if (self.add_politics_button.node.entity == clicked_entity) {
                if (!self.addToProperty(&player_character.politics)) { return .invalid; }
            } else if (self.sub_politics_button.node.entity == clicked_entity) {
                if (!self.subFromProperty(&player_character.politics)) { return .invalid; }
            } else if (self.location_left_button.node.entity == clicked_entity) {
                self.location_selector.decrease();
                player_character.location = self.location_selector.getLocation();
                self.refreshCharacterDetails();
            } else if (self.location_right_button.node.entity == clicked_entity) {
                self.location_selector.increase();
                player_character.location = self.location_selector.getLocation();
                self.refreshCharacterDetails();
            } else if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewGameSceneDefinition);
            } else if (self.confirm_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(LocationSceneDefinition);
            }
        }
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
    }

    pub fn onNavElementDirectionChanged(element: *NavigationElement, dir: Vec2i) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.getButtonFromElementDirectionChanged(element, dir)) |button| {
                const ui_event_system = global.world.getSystemInstance(UIEventSystem);
                const click_response = onClick(button.node.entity);
                ui_event_system.triggerUIClick(button.node.entity, click_response);
                return .none;
            }
        }
        return .success;
    }

    fn getButtonFromElementDirectionChanged(self: *@This(), element: *NavigationElement, dir: Vec2i) ?*GameObject {
        if (element == self.ethnicity_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.ethnicity_left_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.ethnicity_right_button; }
        } else if (element == self.lead_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.sub_lead_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.add_lead_button; }
        } else if (element == self.military_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.sub_military_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.add_military_button; }
        } else if (element == self.charisma_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.sub_charisma_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.add_charisma_button; }
        } else if (element == self.intelligence_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.sub_intelligence_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.add_intelligence_button; }
        } else if (element == self.politics_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.sub_politics_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.add_politics_button; }
        } else if (element == self.location_nav_element) {
            if (dir.equals(&Vec2i.Left)) { return self.location_left_button; }
            else if (dir.equals(&Vec2i.Right)) { return self.location_right_button; }
        }
        return null;
    }

    fn addToProperty(self: *@This(), value: *u32) bool {
        if (self.skill_points == 0 or value.* >= 90) { return false; }
        value.* += 10;
        self.skill_points -= 10;
        self.refreshSkillPoints();
        self.refreshCharacterDetails();
        return true;
    }

    fn subFromProperty(self: *@This(), value: *u32) bool {
        if (value.* == 0) { return false; }
        value.* -= 10;
        self.skill_points += 10;
        self.refreshSkillPoints();
        self.refreshCharacterDetails();
        return true;
    }

    fn refreshSkillPoints(self: *@This()) void {
        if (global.world.getComponent(self.skill_points_object.node.entity, TextLabelComponent)) |text_label_comp| {
            text_label_comp.class.label.text.set("Skill Points: {d}", .{ self.skill_points }) catch { unreachable; };
        }
    }

    fn refreshCharacterDetails(self: *@This()) void {
        const text_label_comp = global.world.getComponent(self.details_object.node.entity, TextLabelComponent).?;
        const character_details: []const u8 = player_character.toString( .create_character) catch { unreachable; };
        text_label_comp.class.text_box.setText(text_label_comp.font, character_details, 1.0) catch { unreachable; };
    }

    fn setIsTypingName(self: *@This(), is_typing_name: bool, text_label_comp: *TextLabelComponent) !void {
        self.is_typing_name = is_typing_name;
        if (is_typing_name) {
            text_label_comp.color = LinearColor.Red;
            if (global.world.getComponent(self.edit_name_button.class.text_button.text_box.node.entity, TextLabelComponent)) |button_text_label_comp| {
                try button_text_label_comp.class.text_box.setText(button_text_label_comp.font, "Done", 1.0);
            }
            try InputText.subscribeToInput(self.name_object);
        } else {
            text_label_comp.color = LinearColor.White;
            InputText.unsubscribeFromInput();
            if (global.world.getComponent(self.edit_name_button.class.text_button.text_box.node.entity, TextLabelComponent)) |button_text_label_comp| {
                try button_text_label_comp.class.text_box.setText(button_text_label_comp.font, "Edit", 1.0);
            }
        }
        self.edit_name_button.class.text_button.refreshTextAlignment();
    }

    /// Resets the player character to default values
    fn resetPlayerCharacter(self: *@This()) !void {
        try player_character.name.setRaw(default_name);
        player_character.role = .free_man;
        player_character.lead = 40;
        player_character.military = 40;
        player_character.charisma = 40;
        player_character.intelligence = 40;
        player_character.politics = 40;
        player_character.abilities = .none;
        player_character.location = self.location_selector.getLocation();
        player_character.action_points.setToMax();
    }
};

// LOCATION
pub const LocationSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return LocationEntity;
    }
};

pub const LocationEntity = struct {
    character_name_text: *GameObject = undefined,
    action_points_text: *GameObject = undefined,
    discover_button: *GameObject = undefined,
    interact_button: *GameObject = undefined,
    military_button: *GameObject = undefined,
    travel_button: *GameObject = undefined,
    character_button: *GameObject = undefined,
    end_turn_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = player_character.location.?.name, .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 150.0, .y = 100.0 } }, },
            null,
            null
        );
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = game_date.toString(), .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 150.0, .y = 60.0 } }, },
            null,
            null
        );

        self.character_name_text = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = player_character.name.get(), .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 400.0, .y = 60.0 } }, },
            null,
            null
        );
        self.action_points_text = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 400.0, .y = 100.0 } }, },
            null,
            null
        );
        try self.refreshActionPointsText();

        var base_pos: Vec2 = .{ .x = 60.0, .y = 250.0 };
        const x_increment: f32 = 105.0;
        self.discover_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Discover", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        base_pos.x += x_increment;
        self.interact_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Interact", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        base_pos.x += x_increment;
        self.military_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Military", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        base_pos.x += x_increment;
        self.travel_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Travel", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        base_pos.x += x_increment;
        self.character_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Character", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        self.end_turn_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "End Turn", .on_click = onClick, .transform = .{ .position = .{ .x = 270.0, .y = 290.0 } } },
            null,
            null
        );

        var discover_button_element = try ButtonUtils.setupNavElement(self.discover_button, onPressed);
        var interact_button_element = try ButtonUtils.setupNavElement(self.interact_button, onPressed);
        var military_button_element = try ButtonUtils.setupNavElement(self.military_button, onPressed);
        var character_button_element = try ButtonUtils.setupNavElement(self.character_button, onPressed);
        var travel_button_element = try ButtonUtils.setupNavElement(self.travel_button, onPressed);
        var end_turn_button_element = try ButtonUtils.setupNavElement(self.end_turn_button, onPressed);
        discover_button_element.right = interact_button_element;
        discover_button_element.left = character_button_element;
        discover_button_element.up = end_turn_button_element;
        discover_button_element.down = end_turn_button_element;
        interact_button_element.right = military_button_element;
        interact_button_element.left = discover_button_element;
        interact_button_element.up = end_turn_button_element;
        interact_button_element.down = end_turn_button_element;
        military_button_element.right = travel_button_element;
        military_button_element.left = interact_button_element;
        military_button_element.up = end_turn_button_element;
        military_button_element.down = end_turn_button_element;
        travel_button_element.right = character_button_element;
        travel_button_element.left = military_button_element;
        travel_button_element.up = end_turn_button_element;
        travel_button_element.down = end_turn_button_element;
        character_button_element.right = discover_button_element;
        character_button_element.left = travel_button_element;
        character_button_element.up = end_turn_button_element;
        character_button_element.down = end_turn_button_element;
        end_turn_button_element.left = interact_button_element;
        end_turn_button_element.right = travel_button_element;
        end_turn_button_element.up = military_button_element;
        end_turn_button_element.down = military_button_element;
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.discover_button.node.entity == clicked_entity) {
                if (player_character.action_points.value == 0) { return .invalid; }
                player_character.action_points.value -= 1;
                global.scene_system.changeScene(DiscoverSceneDefinition);
            } else if (self.interact_button.node.entity == clicked_entity) {
                if (player_character.action_points.value == 0) { return .invalid; }
                player_character.action_points.value -= 1;
                global.scene_system.changeScene(InteractSceneDefinition);
            } else if (self.military_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(MilitarySceneDefinition);
            } else if (self.travel_button.node.entity == clicked_entity) {
                if (player_character.action_points.value == 0) { return .invalid; }
                global.scene_system.changeScene(MapSceneDefinition);
                // Resetting key state so return doesn't trigger completion in the next menu, need a cleaner approach
                input.resetKeyState(.{ .key = .keyboard_return });
            } else if (self.character_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(CharacterViewSceneDefinition);
            } else if (self.end_turn_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(EndTurnMapSceneDefinition);
            }
        }
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
    }

    fn refreshActionPointsText(self: *@This()) !void {
        if (global.world.getComponent(self.action_points_text.node.entity, TextLabelComponent)) |text_label_comp| {
            try text_label_comp.class.label.text.set("AP: {d}", .{ player_character.action_points.value });
        }
    }
};

// MAP
pub const MapSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MapEntity;
    }
};

pub const MapEntity = struct {
    selected_location_cursor: *GameObject = undefined,
    selected_location_name: *GameObject = undefined,
    confirm_button: *GameObject = undefined,
    back_button: *GameObject = undefined,
    location_selector: LocationSelector = .{},

    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = world; _ = entity;
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        _ = try GameObject.initInScene(
            SpriteClass,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            null,
            null
        );

        self.location_selector.setIndexByLocation(player_character.location.?);
        const intitial_location = self.location_selector.getLocation();
        self.selected_location_cursor = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = "{}", .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = intitial_location.map_position }, },
            null,
            null
        );
        self.selected_location_name = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = intitial_location.name, .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 160.0, .y = 330.0 } }, },
            null,
            null
        );
        self.back_button = try ButtonUtils.createBackButton(onClick);
        self.confirm_button = try ButtonUtils.createConfirmButton(onClick);
    }

    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (self.checkForLocationChange()) |new_location| {
            self.selected_location_cursor.setLocalPosition(new_location.map_position);
            var text_label_comp = world.getComponent(self.selected_location_name.node.entity, TextLabelComponent);
            try text_label_comp.?.class.label.text.setRaw(new_location.name);
        }

        if (input.isKeyJustPressed(.{ .key = .keyboard_return })) {
            self.confirmLocation();
            global.scene_system.changeScene(LocationSceneDefinition);
        }

        if (input.isKeyJustPressed(.{ .key = .keyboard_escape })) {
            try global.assets.audio.click.play(false);
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.confirm_button.node.entity == clicked_entity) {
                self.confirmLocation();
                global.scene_system.changeScene(LocationSceneDefinition);
            } else if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(LocationSceneDefinition);
            }
        }
        return .success;
    }

    fn confirmLocation(self: *@This()) void {
        if (player_character.location != self.location_selector.getLocation()) {
            player_character.action_points.value -= 1;
            player_character.location = self.location_selector.getLocation();
        }
    }

    fn checkForLocationChange(self: *@This()) ?*const Location {
        if (input.isActionJustPressed(move_down_input_handle)) {
            self.location_selector.increase();
            return self.location_selector.getLocation();
        } else if (input.isActionJustPressed(move_up_input_handle)) {
            self.location_selector.decrease();
            return self.location_selector.getLocation();
        }
        return null;
    }
};

// CHARACTER VIEW
pub const CharacterViewSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return CharacterViewEntity;
    }
};

pub const CharacterViewEntity = struct {
    details_object: *GameObject = undefined,
    back_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = world; _ = entity;

        self.details_object = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 200, .h = 400 }, .text = try player_character.toString(.location_view_character), .line_spacing = 5.0, .transform = .{ .position = .{ .x = 250.0, .y = 110.0 } }, },
            null,
            null
        );
        self.back_button = try ButtonUtils.createBackButton(onClick);
        _ = try ButtonUtils.setupNavElement(self.back_button, onPressed);
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_escape })) {
            try global.assets.audio.click.play(false);
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(LocationSceneDefinition);
            }
        }
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
    }
};

// TODO: Move this somewhere else
const Timer = struct {
    duration: f32,
    time: f32 = 0.0,

    pub inline fn update(self: *@This(), delta_time_seconds: f32) void {
        self.time += delta_time_seconds;
    }

    pub inline fn hasTimedOut(self: *const @This()) bool {
        return self.time >= self.duration;
    }
};

pub const DiscoverSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return DiscoverEntity;
    }
};

pub const DiscoverEntity = struct {
    timer: Timer = .{ .duration = 5.0 },

    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        const event_text = "Random events will be implemented here in the future!";
        _ = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 400, .h = 60 }, .text = event_text, .line_spacing = 5.0, .use_background = true, .transform = .{ .position = .{ .x = 120.0, .y = 290.0 } }, .z_index = 1 },
            null,
            null
        );
    }

    pub fn update(self: *@This(), _: *World, _: ecs.Entity, delta_time_seconds: f32) !void {
        self.timer.update(delta_time_seconds);
        if (self.timer.hasTimedOut()) {
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }
};

pub const InteractSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return InteractEntity;
    }
};

pub const InteractEntity = struct {
    timer: Timer = .{ .duration = 5.0 },

    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        const event_text = "Here you will be able to interact with people you've met!";
        _ = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 400, .h = 60 }, .text = event_text, .line_spacing = 5.0, .use_background = true, .transform = .{ .position = .{ .x = 120.0, .y = 290.0 } }, .z_index = 1 },
            null,
            null
        );
    }

    pub fn update(self: *@This(), _: *World, _: ecs.Entity, delta_time_seconds: f32) !void {
        self.timer.update(delta_time_seconds);
        if (self.timer.hasTimedOut()) {
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }
};

pub const MilitarySceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MilitaryEntity;
    }
};

pub const MilitaryEntity = struct {
    troop_text: *GameObject = undefined,
    action_points_text: *GameObject = undefined,
    recruit_button: *GameObject = undefined,
    battle_button: *GameObject = undefined,
    back_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        self.troop_text = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 210.0, .y = 180.0 } }, },
            null,
            null
        );
        try self.refreshTroopCount();
        self.action_points_text = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 400.0, .y = 100.0 } }, },
            null,
            null
        );
        try self.refreshActionPointsText();
        var base_pos: Vec2 = .{ .x = 240.0, .y = 220.0 };
        const x_increment: f32 = 105.0;
        self.recruit_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Recruit", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        base_pos.x += x_increment;
        self.battle_button = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Battle", .on_click = onClick, .transform = .{ .position = base_pos } },
            null,
            null
        );
        self.back_button = try ButtonUtils.createBackButton(onClick);

        var recruit_button_element = try ButtonUtils.setupNavElement(self.recruit_button, onPressed);
        var battle_button_element = try ButtonUtils.setupNavElement(self.battle_button, onPressed);
        var back_button_element = try ButtonUtils.setupNavElement(self.back_button, onPressed);
        recruit_button_element.right = battle_button_element;
        recruit_button_element.left = back_button_element;
        recruit_button_element.down = back_button_element;
        recruit_button_element.up = back_button_element;
        battle_button_element.left = recruit_button_element;
        battle_button_element.right = back_button_element;
        battle_button_element.down = back_button_element;
        battle_button_element.up = back_button_element;
        back_button_element.up = recruit_button_element;
        back_button_element.down = recruit_button_element;
        back_button_element.right = recruit_button_element;
        back_button_element.left = battle_button_element;
    }

    pub fn update(_: *@This(), _: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_escape })) {
            try global.assets.audio.click.play(false);
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }

    pub fn onClick(clicked_entity: Entity) OnUIChangedResponse {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.recruit_button.node.entity == clicked_entity) {
                if (player_character.action_points.value == 0) { return .invalid; }
                player_character.troop.active += 1000;
                player_character.action_points.value -= 1;
                self.refreshTroopCount() catch unreachable;
                self.refreshActionPointsText() catch unreachable;
            } else if (self.battle_button.node.entity == clicked_entity) {
                if (player_character.action_points.value == 0 or player_character.troop.active == 0) { return .invalid; }
                player_character.action_points.value -= 1;
                global.scene_system.changeScene(BattleSceneDefinition);
            } else if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(LocationSceneDefinition);
            }
        }
        return .success;
    }

    pub fn onPressed(entity: Entity) OnUIChangedResponse {
        return onClick(entity);
    }

    fn refreshTroopCount(self: *@This()) !void {
        if (global.world.getComponent(self.troop_text.node.entity, TextLabelComponent)) |text_label_comp| {
            try text_label_comp.class.label.text.set("Troops: {d}", .{ player_character.troop.active });
        }
    }

    fn refreshActionPointsText(self: *@This()) !void {
        if (global.world.getComponent(self.action_points_text.node.entity, TextLabelComponent)) |text_label_comp| {
            try text_label_comp.class.label.text.set("AP: {d}", .{ player_character.action_points.value });
        }
    }
};

pub const BattleSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return BattleEntity;
    }
};

pub const BattleEntity = struct {
    timer: Timer = .{ .duration = 5.0 },

    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        _ = try GameObject.initInScene(
            SpriteClass,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            null,
            null
        );
        const event_text = "A battle has taken place...you've won and lost 0 troops!";
        _ = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 400, .h = 60 }, .text = event_text, .line_spacing = 5.0, .use_background = true, .transform = .{ .position = .{ .x = 120.0, .y = 290.0 } }, .z_index = 1 },
            null,
            null
        );
    }

    pub fn update(self: *@This(), _: *World, _: ecs.Entity, delta_time_seconds: f32) !void {
        self.timer.update(delta_time_seconds);
        if (self.timer.hasTimedOut()) {
            global.scene_system.changeScene(MilitarySceneDefinition);
        }

        // Temp grid drawing
        const Local = struct {
            var texture : Texture = undefined;
            var initialized = false;
        };
        if (!Local.initialized) {
            Local.initialized = true;
            Local.texture = try Texture.initWhiteSquare(global.allocator, true, .{ .w = 1, .h = 1 });
        }
        const base_pos: Vec2 = .{ .x = 10, .y = 10 };
        const grid_size: Dim2i = .{ .w = 15, .h = 10 };
        const cell_size: Dim2i = .{ .w = 32, .h = 32 };
        const grid_color: LinearColor = .{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 0.5 };
        const draw_source: Rect2 = .{ .x = 0, .y = 0, .w = 1.0, .h = 1.0 };
        const z_index: i32 = 11;
        var param_list = zo.misc.FixedArrayList(renderer.DrawSpriteParams, grid_size.w * grid_size.h).init();
        for (0..grid_size.h) |y| {
        for (0..grid_size.w) |x| {
            const cell_pos: Vec2 = .{ .x = @floatFromInt(x * cell_size.w), .y = @floatFromInt(y * cell_size.h) };
            const transform: Transform2D = .{ .position = base_pos.add(&cell_pos) };
            try param_list.append(.{
                .texture = &Local.texture,
                .source_rect = draw_source,
                .global_matrix = transform.toMat4(),
                .dest_size = .{ .w = @floatFromInt(cell_size.w), .h = @floatFromInt(cell_size.h) },
                .modulate = grid_color,
                .z_index = z_index,
            });
        }}
        try renderer.queueSpriteDraws(param_list.asSlice());
    }
};

pub const EndTurnMapSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return EndTurnMapEntity;
    }
};

pub const EndTurnMapEntity = struct {
    timer: Timer = .{ .duration = 5.0 },

    pub fn onEnterScene(_: *@This(), _: *World, _: ecs.Entity) !void {
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        _ = try GameObject.initInScene(
            SpriteClass,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            null,
            null
        );
        const event_text = "Real events with descriptions and other mechanics will soon be present here!";
        _ = try GameObject.initInScene(
            TextBoxClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 400, .h = 60 }, .text = event_text, .line_spacing = 5.0, .use_background = true, .transform = .{ .position = .{ .x = 120.0, .y = 290.0 } }, .z_index = 1 },
            null,
            null
        );
    }

    pub fn update(self: *@This(), _: *World, _: ecs.Entity, delta_time_seconds: f32) !void {
        self.timer.update(delta_time_seconds);
        if (self.timer.hasTimedOut()) {
            game_date.incrementMonth();
            player_character.action_points.setToMax();
            global.scene_system.changeScene(LocationSceneDefinition);
        }
    }
};
