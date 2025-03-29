const std = @import("std");

const math = @import("math.zig");

const Delegate = @import("delegate.zig").Delegate;
const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;

pub const InputSource = enum {
    invalid,
    keyboard,
    gamepad,
    mouse,
};

pub const InputTrigger = enum {
    invalid,
    pressed,
    released,
    axis_in_motion,
    axis_stopped_motion,
    device_added,
    device_removed,
};

pub const InteractionStatus = enum {
    pressed,
    just_pressed,
    just_released,
    axis_started_in_motion,
    axis_in_motion,
    axis_stopped_motion,
};

pub const Axis = enum {
    left,
    right,
};

pub const InputKey = enum(c_uint) {
    invalid,
    // Gamepad
    gamepad_dpad_down,
    gamepad_dpad_up,
    gamepad_dpad_left,
    gamepad_dpad_right,
    gamepad_face_button_north,  // xbox y
    gamepad_face_button_south,  // xbox a
    gamepad_face_button_east,   // xbox b
    gamepad_face_button_west,   // xbox x
    gamepad_start,
    gamepad_back,
    gamepad_left_shoulder,      // ps l1
    gamepad_left_trigger,       // ps l2
    gamepad_left_analog_button, // ps l3
    gamepad_left_analog_2d_axis_x,
    gamepad_left_analog_2d_axis_y,
    gamepad_right_shoulder,      // ps r1
    gamepad_right_trigger,       // ps r2
    gamepad_right_analog_button, // ps r3
    gamepad_right_analog_2d_axis_x,
    gamepad_right_analog_2d_axis_y,
    gamepad_left_analog_left,
    gamepad_left_analog_right,
    gamepad_left_analog_up,
    gamepad_left_analog_down,
    gamepad_right_analog_left,
    gamepad_right_analog_right,
    gamepad_right_analog_up,
    gamepad_right_analog_down,
    // Keyboard
    keyboard_tab,
    keyboard_left,
    keyboard_right,
    keyboard_up,
    keyboard_down,
    keyboard_page_down,
    keyboard_page_up,
    keyboard_home,
    keyboard_end,
    keyboard_insert,
    keyboard_delete,
    keyboard_backspace,
    keyboard_space,
    keyboard_return,
    keyboard_escape,
    keyboard_quote,
    keyboard_comma,
    keyboard_minus,
    keyboard_period,
    keyboard_slash,
    keyboard_semicolon,
    keyboard_equals,
    keyboard_left_bracket,
    keyboard_right_bracket,
    keyboard_backslash,
    keyboard_backquote,
    keyboard_caps_lock,
    keyboard_scroll_lock,
    keyboard_num_lock_clear,
    keyboard_print_screen,
    keyboard_pause,
    keyboard_keypad_0,
    keyboard_keypad_1,
    keyboard_keypad_2,
    keyboard_keypad_3,
    keyboard_keypad_4,
    keyboard_keypad_5,
    keyboard_keypad_6,
    keyboard_keypad_7,
    keyboard_keypad_8,
    keyboard_keypad_9,
    keyboard_keypad_period,
    keyboard_keypad_divide,
    keyboard_keypad_multiply,
    keyboard_keypad_minus,
    keyboard_keypad_plus,
    keyboard_keypad_enter,
    keyboard_keypad_equals,
    keyboard_left_control,
    keyboard_left_shift,
    keyboard_left_alt,
    keyboard_left_gui,
    keyboard_right_control,
    keyboard_right_shift,
    keyboard_right_alt,
    keyboard_right_gui,
    keyboard_application,
    keyboard_num_0,
    keyboard_num_1,
    keyboard_num_2,
    keyboard_num_3,
    keyboard_num_4,
    keyboard_num_5,
    keyboard_num_6,
    keyboard_num_7,
    keyboard_num_8,
    keyboard_num_9,
    keyboard_a,
    keyboard_b,
    keyboard_c,
    keyboard_d,
    keyboard_e,
    keyboard_f,
    keyboard_g,
    keyboard_h,
    keyboard_i,
    keyboard_j,
    keyboard_k,
    keyboard_l,
    keyboard_m,
    keyboard_n,
    keyboard_o,
    keyboard_p,
    keyboard_q,
    keyboard_r,
    keyboard_s,
    keyboard_t,
    keyboard_u,
    keyboard_v,
    keyboard_w,
    keyboard_x,
    keyboard_y,
    keyboard_z,
    keyboard_f1,
    keyboard_f2,
    keyboard_f3,
    keyboard_f4,
    keyboard_f5,
    keyboard_f6,
    keyboard_f7,
    keyboard_f8,
    keyboard_f9,
    keyboard_f10,
    keyboard_f11,
    keyboard_f12,
    keyboard_f13,
    keyboard_f14,
    keyboard_f15,
    keyboard_f16,
    keyboard_f17,
    keyboard_f18,
    keyboard_f19,
    keyboard_f20,
    keyboard_f21,
    keyboard_f22,
    keyboard_f23,
    keyboard_f24,
    keyboard_app_forward,
    keyboard_app_back,
    // mouse
    mouse_button_left,
    mouse_button_right,
    mouse_button_middle,

    pub inline fn isKeyboardKey(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.keyboard_tab) and @intFromEnum(self) <= @intFromEnum(InputKey.keyboard_app_back);
    }

    pub inline fn isMouseKey(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.mouse_button_left) and @intFromEnum(self) <= @intFromEnum(InputKey.mouse_button_middle);
    }

    pub inline fn isGamepadKey(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.gamepad_dpad_down) and @intFromEnum(self) <= @intFromEnum(InputKey.gamepad_right_analog_down);
    }

    pub inline fn isLetter(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.keyboard_a) and @intFromEnum(self) <= @intFromEnum(InputKey.keyboard_z);
    }

    pub inline fn isNumber(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.keyboard_num_0) and @intFromEnum(self) <= @intFromEnum(InputKey.keyboard_num_9);
    }

    pub inline fn isAlphanumeric(self: InputKey) bool {
        const int_enum = @intFromEnum(self);
        return (int_enum >= @intFromEnum(InputKey.keyboard_a) and int_enum <= @intFromEnum(InputKey.keyboard_z)) // isLetter
            or (int_enum >= @intFromEnum(InputKey.keyboard_num_0) and int_enum <= @intFromEnum(InputKey.keyboard_num_9)); // isNumber
    }
};

pub const Mouse = struct {
    position: Vec2i = Vec2i.Zero,
};

pub const InputEvent = struct {
    source: InputSource,
    status: InteractionStatus,
    key: InputKey,
    device_index: u32 = 0,
};

pub const RegisterInputParams = struct {
    source: InputSource,
    key: InputKey,
    trigger: InputTrigger,
    device_index: u32 = 0,
    gamepad_axis_value: f32 = 0.0,
};

pub const RegisteredInputDelegate = Delegate(fn(*const InputEvent) void);

pub const InputQueryParams = struct {
    key: InputKey,
    device_index: u32 = 0,
};

const InputKeyState = struct {
    is_pressed: bool = false,
    is_just_pressed: bool = false,
    is_just_released: bool = false,
    strength: f32 = 0.0,
};

const CleanupKeys = struct {
    key: InputKey = .invalid,
    device_index: u32 = 0,
};

const CleanupKeysState = struct {
    pressed_cleanup_keys: [8]CleanupKeys = @splat(CleanupKeys{}),
    pressed_cleanup_keys_count: u32 = 0,
    released_cleanup_keys: [8]CleanupKeys = @splat(CleanupKeys{}),
    released_cleanup_keys_count: u32 = 0,
};

const InputActionError = error {
    BeyondMaxValue,
};

pub const InputAction = struct {
    pub const Handle = u32;
    const max_values = 8;

    const Values = struct {
        keys: [max_values]InputKey,
        len: usize = 0,

        fn add(self: *@This(), key: InputKey) !void {
            if (self.len + 1 >= max_values) {
                return InputActionError.BeyondMaxValue;
            }
            self.keys[self.len] = key;
            self.len += 1;
        }
    };

    handle: Handle = 0,
    values: Values = .{ .keys = .{ .invalid } ** max_values },
    device_index: u32 = 0,
};

pub const InputActionCreateParams = struct {
    keys: []const InputKey,
    device_index: u32 = 0,
};

const max_input_devices = 1;
const num_of_keys = @typeInfo(InputKey).@"enum".fields.len;
const max_input_actions = 16;

const InputState = struct {
    // Initialize key state to default values
    key_state: [max_input_devices][num_of_keys]InputKeyState = [max_input_devices][num_of_keys]InputKeyState{[_]InputKeyState{.{}} ** num_of_keys} ** max_input_devices,
    input_action_state: [max_input_devices][max_input_actions]InputAction = [max_input_devices][max_input_actions]InputAction{[_]InputAction{.{}} ** max_input_actions} ** max_input_devices,
    mouse: Mouse = .{},
    cleanup_keys_state: CleanupKeysState = .{},

    fn addPressedCleanup(self: *InputState, key: InputKey, device_index: u32) void {
        self.cleanup_keys_state.pressed_cleanup_keys[self.cleanup_keys_state.pressed_cleanup_keys_count] = .{
            .key = key,
            .device_index = device_index,
        };
        self.cleanup_keys_state.pressed_cleanup_keys_count += 1;
    }

    fn addReleasedCleanup(self: *InputState, key: InputKey, device_index: u32) void {
        self.cleanup_keys_state.released_cleanup_keys[self.cleanup_keys_state.released_cleanup_keys_count] = .{
            .key = key,
            .device_index = device_index,
        };
        self.cleanup_keys_state.released_cleanup_keys_count += 1;
    }

    fn cleanupKeys(self: *InputState) void {
        // Just pressed
        for (0..self.cleanup_keys_state.pressed_cleanup_keys_count) |i| {
            const cleanup_key: *CleanupKeys = &self.cleanup_keys_state.pressed_cleanup_keys[i];
            self.key_state[cleanup_key.device_index][@intFromEnum(cleanup_key.key)].is_just_pressed = false;
        }
        self.cleanup_keys_state.pressed_cleanup_keys_count = 0;
        // Just released
        for (0..self.cleanup_keys_state.released_cleanup_keys_count) |i| {
            const cleanup_key: *CleanupKeys = &self.cleanup_keys_state.released_cleanup_keys[i];
            self.key_state[cleanup_key.device_index][@intFromEnum(cleanup_key.key)].is_just_released = false;
        }
        self.cleanup_keys_state.released_cleanup_keys_count = 0;
    }
};

pub var registered_input_delegate: RegisteredInputDelegate = undefined;
var state: InputState = .{};

pub fn init(allocator: std.mem.Allocator) !void {
    registered_input_delegate = RegisteredInputDelegate.init(allocator);
}

pub fn deinit() void {}

pub fn registerMouseMoveEvent(new_position: Vec2i) void {
    state.mouse.position = new_position;
}

pub fn registerInputEvent(event_params: RegisterInputParams) void {
    var key_state: *InputKeyState = &state.key_state[event_params.device_index][@intFromEnum(event_params.key)];
    var interaction_status: InteractionStatus = undefined;
    switch (event_params.trigger) {
        .pressed =>  {
            if (!key_state.is_pressed) {
                key_state.is_just_pressed = true;
                interaction_status = .just_pressed;
                state.addPressedCleanup(event_params.key, event_params.device_index);
            } else {
                interaction_status = .pressed;
                key_state.is_just_pressed = false;
            }
            key_state.is_pressed = true;
            key_state.is_just_released = false;
            key_state.strength = 1.0;
        },
        .released => {
            if (!key_state.is_just_released) {
                key_state.is_pressed = false;
                key_state.is_just_pressed = false;
                key_state.is_just_released = true;
                key_state.strength = 0.0;
                interaction_status = .just_released;
                state.addReleasedCleanup(event_params.key, event_params.device_index);
            }
        },
        else => {}
    }
    const input_event: InputEvent = .{ .source = event_params.source, .status = interaction_status, .key = event_params.key, .device_index = event_params.device_index };
    registered_input_delegate.broadcast(.{ &input_event });
}

pub fn newFrame() void {
    state.cleanupKeys();
}

pub fn isKeyPressed(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_pressed;
}

pub fn isKeyJustPressed(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_just_pressed;
}

pub fn isKeyJustReleased(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_just_released;
}

pub fn getKeyStrength(params: InputQueryParams) f32 {
    return state.key_state[params.device_index][@intFromEnum(params.key)].strength;
}

pub inline fn getMousePosition() Vec2i {
    return state.mouse.position;
}

/// Maps screen mouse position from window size to render resolution for world mouse position
pub fn getWorldMousePosition(window_size: Dim2i, render_resolution: Dim2i) Vec2i {
    const mouse_pos: Vec2 = .{ .x = @floatFromInt(getMousePosition().x), .y = @floatFromInt(getMousePosition().y) };
    const win_size: Vec2 = .{ .x = @floatFromInt(window_size.w), .y = @floatFromInt(window_size.h) };
    const resolution: Vec2 = .{ .x = @floatFromInt(render_resolution.w), .y = @floatFromInt(render_resolution.h) };
    const global_mouse_position: Vec2 = .{
        .x = math.mapToRange(f32, mouse_pos.x, 0.0, win_size.x, 0.0, resolution.x),
        .y = math.mapToRange(f32, mouse_pos.y, 0.0, win_size.y, 0.0, resolution.y)
    };
    // TODO: Look into abnormal values in 'global_mouse_position', for now we clamp
    // const global_mouse_pos: Vec2i = .{ .x = @intFromFloat(global_mouse_position.x), .y = @intFromFloat(global_mouse_position.y) };
    const min_val: f32 = @floatFromInt(std.math.minInt(i32));
    const max_val: f32 = @floatFromInt(std.math.maxInt(i32));
    const clamped_x: f32 = math.clamp(f32, global_mouse_position.x, min_val, max_val);
    const clamped_y: f32 = math.clamp(f32, global_mouse_position.y, min_val, max_val);

    const global_mouse_pos: Vec2i = .{ .x = @intFromFloat(clamped_x), .y = @intFromFloat(clamped_y) };
    return global_mouse_pos;
}

// Input Action

pub fn addAction(params: InputActionCreateParams) !InputAction.Handle {
    // TODO: This is temp as I currently don't plan to remove input actions
    const State = struct {
        var handle_index: InputAction.Handle = 0;
    };
    const new_handle = State.handle_index;
    State.handle_index += 1;

    var new_action = &state.input_action_state[params.device_index][new_handle];
    new_action.handle = new_handle;
    for (params.keys) |key| {
        try new_action.values.add(key);
    }
    new_action.device_index = params.device_index;
    return new_handle;
}

const default_device_index = 0; // TODO: Get another way

pub fn isActionPressed(handle: InputAction.Handle) bool {
    const action = &state.input_action_state[default_device_index][handle];
    for (0..action.values.len) |i| {
        if (isKeyPressed(.{ .key = action.values.keys[i], .device_index = default_device_index })) {
            return true;
        }
    }
    return false;
}

pub fn isActionJustPressed(handle: InputAction.Handle) bool {
    const action = &state.input_action_state[default_device_index][handle];
    for (0..action.values.len) |i| {
        if (isKeyJustPressed(.{ .key = action.values.keys[i], .device_index = default_device_index })) {
            return true;
        }
    }
    return false;
}

pub fn isActionJustReleased(handle: InputAction.Handle) bool {
    const action = &state.input_action_state[default_device_index][handle];
    for (0..action.values.len) |i| {
        if (isKeyJustReleased(.{ .key = action.values.keys[i], .device_index = default_device_index })) {
            return true;
        }
    }
    return false;
}
