const std = @import("std");

const math = @import("math.zig");

const Delegate = @import("delegate.zig").Delegate;
const Vec2i = math.Vec2i;

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

    pub fn is_keyboard_key(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.keyboard_tab) and @intFromEnum(self) <= @intFromEnum(InputKey.keyboard_app_back);
    }

    pub fn is_mouse_key(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.mouse_button_left) and @intFromEnum(self) <= @intFromEnum(InputKey.mouse_button_middle);
    }

    pub fn is_gamepad_key(self: InputKey) bool {
        return @intFromEnum(self) >= @intFromEnum(InputKey.gamepad_dpad_down) and @intFromEnum(self) <= @intFromEnum(InputKey.gamepad_right_analog_down);
    }
};

pub const Mouse = struct {
    position: Vec2i = Vec2i.Zero,
};

pub const InputEvent = struct {
    source: InputSource,
    interaction_status: InteractionStatus,
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

pub const RegisteredInputDelegate = Delegate(fn(*const RegisterInputParams) void);

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

const key_state_x = 1;
const key_state_y = @typeInfo(InputKey).@"enum".fields.len;

const InputState = struct {
    // Initialize key state to default values
    key_state: [key_state_x][key_state_y]InputKeyState = [key_state_x][key_state_y]InputKeyState{[_]InputKeyState{.{}} ** key_state_y} ** key_state_x,
    mouse: Mouse = .{},
    cleanup_keys_state: CleanupKeysState = .{},

    fn add_pressed_cleanup(self: *InputState, key: InputKey, device_index: u32) void {
        self.cleanup_keys_state.pressed_cleanup_keys[self.cleanup_keys_state.pressed_cleanup_keys_count] = .{
            .key = key,
            .device_index = device_index,
        };
        self.cleanup_keys_state.pressed_cleanup_keys_count += 1;
    }

    fn add_released_cleanup(self: *InputState, key: InputKey, device_index: u32) void {
        self.cleanup_keys_state.released_cleanup_keys[self.cleanup_keys_state.released_cleanup_keys_count] = .{
            .key = key,
            .device_index = device_index,
        };
        self.cleanup_keys_state.released_cleanup_keys_count += 1;
    }

    fn cleanup_keys(self: *InputState) void {
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

pub fn register_mouse_move_event(new_position: Vec2i) void {
    state.mouse.position = new_position;
}

pub fn register_input_event(event_params: RegisterInputParams) void {
    var key_state: *InputKeyState = &state.key_state[event_params.device_index][@intFromEnum(event_params.key)];
    switch (event_params.trigger) {
        .pressed =>  {
            if (!key_state.is_pressed) {
                key_state.is_just_pressed = true;
                state.add_pressed_cleanup(event_params.key, event_params.device_index);
            } else {
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
                state.add_released_cleanup(event_params.key, event_params.device_index);
            }
        },
        else => {}
    }
    registered_input_delegate.broadcast(.{ &event_params });
}

pub fn new_frame() void {
    state.cleanup_keys();
}

pub fn is_key_pressed(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_pressed;
}

pub fn is_key_just_pressed(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_just_pressed;
}

pub fn is_key_just_released(params: InputQueryParams) bool {
    return state.key_state[params.device_index][@intFromEnum(params.key)].is_just_released;
}

pub fn get_key_strength(params: InputQueryParams) f32 {
    return state.key_state[params.device_index][@intFromEnum(params.key)].strength;
}
