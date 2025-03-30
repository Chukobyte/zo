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
const String = zo.string.HeapString;
const Entity = ecs.Entity;
const World = global.World;
const Node = World.Node;
const GameObject = object.GameObject;
const GameObjectSystem = object.GameObjectSystem;
const Location = state.Location;
const TextLabelComponent = component_systems.TextLabelComponent;
const ColorRectComponent = component_systems.ColorRectComponent;
const UIEventSystem = component_systems.UIEventSystem;
const InputKey = input.InputKey;
const InputEvent = input.InputEvent;
const InputAction = input.InputAction;
const Character = state.Character;
const EthnicityProfile = state.EthnicityProfile;
const SubscriberHandle = delegate.SubscriberHandle;
const SpriteClass = object.SpriteClass;
const TextLabelClass = object.TextLabelClass;
const TextBoxClass = object.TextBoxClass;
const TextButtonClass = object.TextButtonClass;

const log = zo.log;

var move_left_input_handle: InputAction.Handle = 0;
var move_right_input_handle: InputAction.Handle = 0;
var move_up_input_handle: InputAction.Handle = 0;
var move_down_input_handle: InputAction.Handle = 0;

const ButtonUtils = struct {
    on_hover: ?*const fn(Entity) void = null,
    on_unhover: ?*const fn(Entity) void = null,
    on_click: ?*const fn(Entity) void = null,

    pub fn createConfirmButton(on_click: ?*const fn(Entity) void) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Confirm", .on_click = on_click, .transform = .{ .position = .{ .x = 500.0, .y = 300.0 } } },
            null,
            null
        );
    }
    pub fn createBackButton(on_click: ?*const fn(Entity) void) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "Back", .on_click = on_click, .transform = .{ .position = .{ .x = 40.0, .y = 300.0 } } },
            null,
            null
        );
    }

    pub fn createValueChangeButton(symbol: []const u8, position: Vec2, on_click: ?*const fn(Entity) void) !*GameObject {
        return try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 15.0, .h = 15.0 }, .font = &global.assets.fonts.pixeloid_16, .text = symbol, .on_click = on_click, .transform = .{ .position = position } },
            null,
            null
        );
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
        _ = try GameObject.initInScene(
            TextButtonClass,
            .{ .collision = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 25.0 }, .font = &global.assets.fonts.pixeloid_16, .text = "New Game", .on_click = onClick, .transform = .{ .position = .{ .x = 240.0, .y = 220.0 } } },
            null,
            null
        );
    }

    pub fn onClick(_: Entity) void {
        global.scene_system.changeScene(NewGameSceneDefinition);
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
            .{ .font = &global.assets.fonts.pixeloid_16, .text = "Select Character to Play", .transform = .{ .position = .{ .x = 210.0, .y = 180.0 } }, },
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
    }

    pub fn onClick(clicked_entity: Entity) void {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.new_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewCharacterSceneDefinition);
            } else if (self.existing_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(ExistingCharacterSceneDefinition);
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
    back_button: *GameObject = undefined,
    confirm_button: *GameObject = undefined,

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        _ = try GameObject.initInScene(
            TextLabelClass,
            .{ .font = &global.assets.fonts.pixeloid_16, .text = "Existing Character", .transform = .{ .position = .{ .x = 210.0, .y = 220.0 } }, },
            null,
            null
        );
        self.back_button = try ButtonUtils.createBackButton(onClick);
        self.confirm_button = try ButtonUtils.createConfirmButton(onClick);
    }

    pub fn onClick(clicked_entity: Entity) void {
        if (global.world.findEntityScriptInstance(@This())) |self| {
            if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewGameSceneDefinition);
            } else if (self.confirm_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(MapSceneDefinition);
            }
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
    const minimum_name_text = "Name: ";
    const default_name = "Samuel";
    const initial_name_text = minimum_name_text ++ default_name;
    const ethnicity_selections: [3]EthnicityProfile = .{ EthnicityProfile.Black, EthnicityProfile.Indigenous, EthnicityProfile.White };

    /// Takes in keyboard input and updates a TextLabelComponent
    const InputText = struct {
        var handle: ?delegate.SubscriberHandle = null;
        var name_object: ?*GameObject = null;
        pub fn subscribeToInput(name_obj: *GameObject) !void {
            name_object = name_obj;
            handle = try input.registered_input_delegate.subscribe(onRegisteredInput);
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

    character: Character = .{
        .name = undefined,
        .role = .free_man,
        .ethnicity = EthnicityProfile.Black,
        .starting_location = &state.map_locations[9],
    },
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

    pub fn onEnterScene(self: *@This(), _: *World, _: ecs.Entity) !void {
        self.character.name = try String.initAndSetRaw(global.allocator, default_name);
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
            .{ .font = &global.assets.fonts.pixeloid_16, .size = .{ .w = 200, .h = 400 }, .text = try self.getCharacterDetailsString(), .line_spacing = 5.0, .transform = .{ .position = .{ .x = 250.0, .y = 110.0 } }, },
            null,
            null
        );
        self.confirm_button = try ButtonUtils.createConfirmButton(onClick);
        self.back_button = try ButtonUtils.createBackButton(onClick);

        const base_left_x: f32 = 200.0;
        const base_right_x: f32 = 460.0;
        var base_y: f32 = 130.0;
        const y_increment: f32 = 20.0;

        self.ethnicity_left_button = try ButtonUtils.createValueChangeButton("<", .{ .x = base_left_x, .y = base_y }, onClick);
        self.ethnicity_right_button = try ButtonUtils.createValueChangeButton(">", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_lead_button = try ButtonUtils.createValueChangeButton("-", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_lead_button = try ButtonUtils.createValueChangeButton("+", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_military_button = try ButtonUtils.createValueChangeButton("-", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_military_button = try ButtonUtils.createValueChangeButton("+", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_charisma_button = try ButtonUtils.createValueChangeButton("-", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_charisma_button = try ButtonUtils.createValueChangeButton("+", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_intelligence_button = try ButtonUtils.createValueChangeButton("-", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_intelligence_button = try ButtonUtils.createValueChangeButton("+", .{ .x = base_right_x, .y = base_y }, onClick);
        base_y += y_increment;
        self.sub_politics_button = try ButtonUtils.createValueChangeButton("-", .{ .x = base_left_x, .y = base_y }, onClick);
        self.add_politics_button = try ButtonUtils.createValueChangeButton("+", .{ .x = base_right_x, .y = base_y }, onClick);
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
    }

    pub fn update(self: *@This(), world: *World, _: ecs.Entity, _: f32) !void {
        if (input.isKeyJustPressed(.{ .key = .keyboard_return }) and self.is_typing_name) {
            const text_label_comp = world.getComponent(self.name_object.node.entity, TextLabelComponent).?;
            try self.setIsTypingName(!self.is_typing_name, text_label_comp); // Toggle
            InputText.unsubscribeFromInput();
        }
    }

    pub fn onClick(clicked_entity: Entity) void {
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
                self.character.ethnicity = ethnicity_selections[self.ethnicity_index];
                self.refreshCharacterDetails();
            } else if (self.ethnicity_right_button.node.entity == clicked_entity) {
                if (self.ethnicity_index + 1 >= ethnicity_selections.len) {
                    self.ethnicity_index = 0;
                } else {
                    self.ethnicity_index += 1;
                }
                self.character.ethnicity = ethnicity_selections[self.ethnicity_index];
                self.refreshCharacterDetails();
            } else if (self.add_lead_button.node.entity == clicked_entity) {
                self.addToProperty(&self.character.lead);
            } else if (self.sub_lead_button.node.entity == clicked_entity) {
                self.subFromProperty(&self.character.lead);
            } else if (self.add_military_button.node.entity == clicked_entity) {
                self.addToProperty(&self.character.military);
            } else if (self.sub_military_button.node.entity == clicked_entity) {
                self.subFromProperty(&self.character.military);
            } else if (self.add_charisma_button.node.entity == clicked_entity) {
                self.addToProperty(&self.character.charisma);
            } else if (self.sub_charisma_button.node.entity == clicked_entity) {
                self.subFromProperty(&self.character.charisma);
            } else if (self.add_intelligence_button.node.entity == clicked_entity) {
                self.addToProperty(&self.character.intelligence);
            } else if (self.sub_intelligence_button.node.entity == clicked_entity) {
                self.subFromProperty(&self.character.intelligence);
            } else if (self.add_politics_button.node.entity == clicked_entity) {
                self.addToProperty(&self.character.politics);
            } else if (self.sub_politics_button.node.entity == clicked_entity) {
                self.subFromProperty(&self.character.politics);
            } else if (self.location_left_button.node.entity == clicked_entity) {
                self.location_selector.decrease();
                self.character.starting_location = self.location_selector.getLocation();
                self.refreshCharacterDetails();
            } else if (self.location_right_button.node.entity == clicked_entity) {
                self.location_selector.increase();
                self.character.starting_location = self.location_selector.getLocation();
                self.refreshCharacterDetails();
            } else if (self.back_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(NewGameSceneDefinition);
            } else if (self.confirm_button.node.entity == clicked_entity) {
                global.scene_system.changeScene(MapSceneDefinition);
            }
        }
    }

    fn addToProperty(self: *@This(), value: *u32) void {
        if (self.skill_points == 0) { return; }
        value.* += 1;
        self.skill_points -= 1;
        self.refreshSkillPoints();
        self.refreshCharacterDetails();
    }

    fn subFromProperty(self: *@This(), value: *u32) void {
        if (value.* == 0) { return; }
        value.* -= 1;
        self.skill_points += 1;
        self.refreshSkillPoints();
        self.refreshCharacterDetails();
    }

    fn refreshSkillPoints(self: *@This()) void {
        if (global.world.getComponent(self.skill_points_object.node.entity, TextLabelComponent)) |text_label_comp| {
            text_label_comp.class.label.text.set("Skill Points: {d}", .{ self.skill_points }) catch { unreachable; };
        }
    }

    fn refreshCharacterDetails(self: *@This()) void {
        const text_label_comp = global.world.getComponent(self.details_object.node.entity, TextLabelComponent).?;
        const character_details: []const u8 = self.getCharacterDetailsString() catch { unreachable; };
        text_label_comp.class.text_box.setText(text_label_comp.font, character_details, 1.0) catch { unreachable; };
    }

    fn setIsTypingName(self: *@This(), is_typing_name: bool, text_label_comp: *TextLabelComponent) !void {
        self.is_typing_name = is_typing_name;
        if (is_typing_name) {
            text_label_comp.color = math.LinearColor.Red;
            if (global.world.getComponent(self.edit_name_button.class.text_button.text_box.node.entity, TextLabelComponent)) |button_text_label_comp| {
                try button_text_label_comp.class.text_box.setText(button_text_label_comp.font, "Done", 1.0);
            }
            try InputText.subscribeToInput(self.name_object);
        } else {
            text_label_comp.color = math.LinearColor.White;
            InputText.unsubscribeFromInput();
            if (global.world.getComponent(self.edit_name_button.class.text_button.text_box.node.entity, TextLabelComponent)) |button_text_label_comp| {
                try button_text_label_comp.class.text_box.setText(button_text_label_comp.font, "Edit", 1.0);
            }
        }
        self.edit_name_button.class.text_button.refreshTextAlignment();
    }

    fn getCharacterDetailsString(self: *@This()) ![]const u8 {
        const Local = struct {
            var buffer: [256]u8 = undefined;
        };
        const character: *Character = &self.character;
        return try std.fmt.bufPrint(
            &Local.buffer,
            // "Role: {s}\nEthnicity: {s}\nLead: {d}\nMilitary: {d}\nCharisma: {d}\nIntelligence: {d}\nPolitics: {d}\nAbilities: {s}",
            // .{ character.role.toString(), character.ethnicity.toString(), character.lead, character.military, character.charisma, character.intelligence, character.politics, character.abilities.toString(), }
            "Role: {s}\nEthnicity: {s}\nLead: {d}\nMilitary: {d}\nCharisma: {d}\nIntelligence: {d}\nPolitics: {d}\nLocation: {s}",
            .{ character.role.toString(), character.ethnicity.toString(), character.lead, character.military, character.charisma, character.intelligence, character.politics, character.starting_location.?.name, }
        );
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
    selected_location_cursor: *GameObject = undefined,
    selected_location_name: *GameObject = undefined,
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

        const intitial_location = self.location_selector.getLocation();
        self.selected_location_cursor = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = "{}", .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = intitial_location.map_position }, },
            null,
            null
        );
        self.selected_location_name = try GameObject.initInScene(
            TextLabelClass,
            .{ .text = intitial_location.name, .font = &global.assets.fonts.pixeloid_16, .transform = .{ .position = .{ .x = 100.0, .y = 340.0 } }, },
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
            self.location_selector.increase();
            return self.location_selector.getLocation();
        } else if (input.isActionJustPressed(move_up_input_handle)) {
            self.location_selector.decrease();
            return self.location_selector.getLocation();
        }
        return null;
    }
};
