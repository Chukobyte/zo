const std = @import("std");
const builtin = @import("builtin");

const math = @import("math.zig");
const input = @import("input.zig");

pub const win = @cImport({
    @cInclude("windows.h");
});

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

const log = @import("logger.zig").log;

const LinearColor = math.LinearColor;

pub const WINAPI: std.builtin.CallingConvention = .winapi;
pub const HINSTANCE = win.HINSTANCE;
pub const HWND = win.HWND;
pub const HDC = win.HDC;
pub const WPARAM = win.WPARAM;
pub const LPARAM = win.LPARAM;
pub const LRESULT = win.LRESULT;
pub const INT = win.INT;

const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;

const InputKey = input.InputKey;

// OpenGL Stuff
pub const WGL_CONTEXT_MAJOR_VERSION_ARB: u32 = 0x2091;
pub const WGL_CONTEXT_MINOR_VERSION_ARB: u32 = 0x2092;
pub const WGL_CONTEXT_FLAGS_ARB: u32 = 0x2094;
pub const WGL_CONTEXT_COREPROFILE_BIT_ARB: u32 = 0x00000001;
pub const WGL_CONTEXT_PROFILE_MASK_ARB: u32 = 0x9126;
// Define the function pointer types using the winapi calling convention:
const PFNWGLGETEXTENSIONSSTRINGEXTPROC = *fn() callconv(WINAPI) [*c]const u8;
const PFNWGLSWAPINTERVALEXTPROC = *fn(interval: i32) callconv(WINAPI) bool;
const PFNWGLGETSWAPINTERVALEXTPROC = *fn() callconv(WINAPI) i32;
const PFNWGLCREATECONTEXTATTRIBSARBPROC = *fn(hdc: win.HDC, hShareContext: win.HGLRC, attribList: [*]const i32) callconv(WINAPI) win.HGLRC;

const Window = struct {
    size: Dim2i,
    is_active: bool = false,
};

const Win32Data = struct {
    h_instance: HINSTANCE = undefined,
    hwnd: HWND = undefined,
    hdc: HDC = undefined,
    cmd_show: i32 = undefined,
};

const InitializeError = error {
    Win32Window,
    OpenGL,
};

var main_window: Window = undefined;
var w32_data: Win32Data = .{};
const class_name: []const u8 = "My window class";
var is_opengl_initialized = false;

fn convert_vkcode_to_key(vk_code: u32) InputKey {
    // First letters
    if (vk_code >= 'A' and vk_code <= 'Z') {
        const key: u32 = @intFromEnum(InputKey.keyboard_a) + (vk_code - 'A');
        return @enumFromInt(key);
    }
    // Numbers
    if (vk_code >= '0' and vk_code <= '9') {
        const key: u32 = @intFromEnum(InputKey.keyboard_num_0) + (vk_code - '0');
        return @enumFromInt(key);
    }
    // Everything else
    switch (vk_code) {
        win.VK_TAB => return InputKey.keyboard_tab,
        win.VK_LEFT => return InputKey.keyboard_left,
        win.VK_RIGHT => return InputKey.keyboard_right,
        win.VK_UP => return InputKey.keyboard_up,
        win.VK_DOWN => return InputKey.keyboard_down,
        win.VK_NEXT => return InputKey.keyboard_page_down,
        win.VK_PRIOR => return InputKey.keyboard_page_up,
        win.VK_HOME => return InputKey.keyboard_home,
        win.VK_END => return InputKey.keyboard_end,
        win.VK_INSERT => return InputKey.keyboard_insert,
        win.VK_DELETE => return InputKey.keyboard_delete,
        win.VK_BACK => return InputKey.keyboard_backspace,
        win.VK_SPACE => return InputKey.keyboard_space,
        win.VK_RETURN => return InputKey.keyboard_return,
        win.VK_ESCAPE => return InputKey.keyboard_escape,
        win.VK_OEM_7 => return InputKey.keyboard_quote,
        win.VK_OEM_COMMA => return InputKey.keyboard_comma,
        win.VK_OEM_MINUS => return InputKey.keyboard_minus,
        win.VK_OEM_2 => return InputKey.keyboard_period,
        win.VK_OEM_1 => return InputKey.keyboard_slash,
        win.VK_OEM_PLUS => return InputKey.keyboard_semicolon,
        win.VK_OEM_4 => return InputKey.keyboard_left_bracket,
        win.VK_OEM_6 => return InputKey.keyboard_right_bracket,
        win.VK_OEM_5 => return InputKey.keyboard_backslash,
        win.VK_OEM_3 => return InputKey.keyboard_backquote,
        win.VK_CAPITAL => return InputKey.keyboard_caps_lock,
        win.VK_SCROLL => return InputKey.keyboard_scroll_lock,
        win.VK_NUMLOCK => return InputKey.keyboard_num_lock_clear,
        win.VK_SNAPSHOT => return InputKey.keyboard_print_screen,
        win.VK_PAUSE => return InputKey.keyboard_pause,
        win.VK_NUMPAD0 => return InputKey.keyboard_keypad_0,
        win.VK_NUMPAD1 => return InputKey.keyboard_keypad_1,
        win.VK_NUMPAD2 => return InputKey.keyboard_keypad_2,
        win.VK_NUMPAD3 => return InputKey.keyboard_keypad_3,
        win.VK_NUMPAD4 => return InputKey.keyboard_keypad_4,
        win.VK_NUMPAD5 => return InputKey.keyboard_keypad_5,
        win.VK_NUMPAD6 => return InputKey.keyboard_keypad_6,
        win.VK_NUMPAD7 => return InputKey.keyboard_keypad_7,
        win.VK_NUMPAD8 => return InputKey.keyboard_keypad_8,
        win.VK_NUMPAD9 => return InputKey.keyboard_keypad_9,
        win.VK_DECIMAL => return InputKey.keyboard_keypad_period,
        win.VK_DIVIDE => return InputKey.keyboard_keypad_divide,
        win.VK_MULTIPLY => return InputKey.keyboard_keypad_multiply,
        win.VK_SUBTRACT => return InputKey.keyboard_keypad_minus,
        win.VK_ADD => return InputKey.keyboard_keypad_plus,
        // TODO: Properly handle left and right shift (only left is registered on tested keyboard)
        win.VK_LSHIFT => return InputKey.keyboard_left_shift,
        win.VK_RSHIFT => return InputKey.keyboard_right_shift,
        win.VK_SHIFT => return InputKey.keyboard_right_shift,
        win.VK_LCONTROL => return InputKey.keyboard_left_control,
        win.VK_RCONTROL => return InputKey.keyboard_right_control,
        win.VK_LMENU => return InputKey.keyboard_left_alt,
        win.VK_RMENU => return InputKey.keyboard_right_alt,
        win.VK_LWIN => return InputKey.keyboard_left_gui,
        win.VK_RWIN => return InputKey.keyboard_right_gui,
        win.VK_APPS => return InputKey.keyboard_application,
        win.VK_BROWSER_FORWARD => return InputKey.keyboard_app_forward,
        win.VK_BROWSER_BACK => return InputKey.keyboard_app_back,
        win.VK_F1 => return InputKey.keyboard_f1,
        win.VK_F2 => return InputKey.keyboard_f2,
        win.VK_F3 => return InputKey.keyboard_f3,
        win.VK_F4 => return InputKey.keyboard_f4,
        win.VK_F5 => return InputKey.keyboard_f5,
        win.VK_F6 => return InputKey.keyboard_f6,
        win.VK_F7 => return InputKey.keyboard_f7,
        win.VK_F8 => return InputKey.keyboard_f8,
        win.VK_F9 => return InputKey.keyboard_f9,
        win.VK_F10 => return InputKey.keyboard_f10,
        win.VK_F11 => return InputKey.keyboard_f11,
        win.VK_F12 => return InputKey.keyboard_f12,
        win.VK_F13 => return InputKey.keyboard_f13,
        win.VK_F14 => return InputKey.keyboard_f14,
        win.VK_F15 => return InputKey.keyboard_f15,
        win.VK_F16 => return InputKey.keyboard_f16,
        win.VK_F17 => return InputKey.keyboard_f17,
        win.VK_F18 => return InputKey.keyboard_f18,
        win.VK_F19 => return InputKey.keyboard_f19,
        win.VK_F20 => return InputKey.keyboard_f20,
        win.VK_F21 => return InputKey.keyboard_f21,
        win.VK_F22 => return InputKey.keyboard_f22,
        win.VK_F23 => return InputKey.keyboard_f23,
        win.VK_F24 => return InputKey.keyboard_f24,
        else => return InputKey.invalid
    }
}

fn cStringToSlice(cstr: [*c]const u8) []const u8 {
    var len: usize = 0;
    // Loop until we encounter the null terminator (0)
    while (cstr[len] != 0) : (len += 1) {}
    return cstr[0..len];
}

pub fn openglInit(hwnd: HWND) !void {
    // Setup PIXELFORMATDESCRIPTOR (zero-initialize if needed)
    var pfd: win.PIXELFORMATDESCRIPTOR = undefined;
    pfd.nSize = @intCast(@sizeOf(win.PIXELFORMATDESCRIPTOR));
    pfd.nVersion = 1;
    pfd.dwFlags = win.PFD_SUPPORT_OPENGL | win.PFD_DRAW_TO_WINDOW | win.PFD_DOUBLEBUFFER;
    pfd.iPixelType = win.PFD_TYPE_RGBA;
    pfd.cColorBits = 24;
    pfd.cDepthBits = 32;
    pfd.cStencilBits = 8;

    // Get the device context from the window handle
    const hdc = win.GetDC(hwnd);
    w32_data.hdc = hdc;
    const pixelFormat = win.ChoosePixelFormat(hdc, &pfd);
    _ = win.SetPixelFormat(hdc, pixelFormat, &pfd);

    // Create a temporary context to load WGL extension functions.
    const tempRC = win.wglCreateContext(hdc);
    _ = win.wglMakeCurrent(hdc, tempRC);

    // Get the pointer to wglCreateContextAttribsARB
    const ptr = win.wglGetProcAddress("wglCreateContextAttribsARB");
    const wglCreateContextAttribsARB: PFNWGLCREATECONTEXTATTRIBSARBPROC = @constCast(@ptrCast(ptr));

    // Set attributes for an OpenGL 3.3 core profile context.
    const attribList = [_]i32{
        @intCast(WGL_CONTEXT_MAJOR_VERSION_ARB), 3,
        @intCast(WGL_CONTEXT_MINOR_VERSION_ARB), 3,
        @intCast(WGL_CONTEXT_FLAGS_ARB), 0,
        @intCast(WGL_CONTEXT_PROFILE_MASK_ARB),
        @intCast(WGL_CONTEXT_COREPROFILE_BIT_ARB),
        0, // terminator
    };

    // Create the actual OpenGL context.
    const hglrc = wglCreateContextAttribsARB(hdc, null, &attribList);
    _ = win.wglMakeCurrent(null, null);
    _ = win.wglDeleteContext(tempRC);
    _ = win.wglMakeCurrent(hdc, hglrc);

    // Load OpenGL function pointers with GLAD.
    if (glad.gladLoadGL() == 0) {
        log(.critical, "Glad failed to load!  Error = {}", .{glad.glGetError()});
        return InitializeError.OpenGL;
    } else {
        log(.debug, "OpenGL Version {d}", .{glad.GLVersion.major});
    }

    // Enable VSync if supported.
    const extPtr = win.wglGetProcAddress("wglGetExtensionsStringEXT");
    const wglGetExtensionsStringEXT: PFNWGLGETEXTENSIONSSTRINGEXTPROC = @constCast(@ptrCast(extPtr));
    const extStr = wglGetExtensionsStringEXT();
    if (std.mem.indexOf(u8, cStringToSlice(extStr), "WGL_EXT_swap_control") != null) {
        if (win.wglGetProcAddress("wglSwapIntervalEXT")) |swapFuncPtr| {
            const wglSwapIntervalEXT: PFNWGLSWAPINTERVALEXTPROC = @constCast(@ptrCast(swapFuncPtr));
            if (wglSwapIntervalEXT(1)) {
                log(.debug, "VSync enabled", .{});
            } else {
                log(.critical, "Could not enable vsync", .{});
            }
        } else {
            log(.critical, "wglSwapIntervalEXT not found", .{});
        }
    } else {
        log(.critical, "WGL_EXT_swap_control not supported", .{});
    }

    is_opengl_initialized = true;
}

fn winProc(
    hwnd: HWND,
    msg: u32,
    w_param: WPARAM,
    l_param: LPARAM,
) callconv(WINAPI) LRESULT {
    const Local = struct {
        fn extractLoHiWord(in_param: LPARAM) Vec2i {
            const param: c_longlong = @as(c_longlong, in_param);
            const mask: c_longlong = @as(c_longlong, 0xffff);
            const x_u16: u16 = @intCast(param & mask);
            const y_u16: u16 = @intCast((param >> 16) & mask);
            const x_i16: i16 = @bitCast(x_u16);
            const y_i16: i16 = @bitCast(y_u16);
            return Vec2i{ .x = x_i16, .y = y_i16 };
        }
    };

    switch (msg) {
        win.WM_DESTROY => {
            win.PostQuitMessage(0);
            main_window.is_active = false;
            return 0;
        },
        win.WM_SIZE => {
            const new_size: Vec2i = Local.extractLoHiWord(l_param);
            updateWindowSize(Dim2i.fromVec2(new_size));
            return 0;
        },
        win.WM_KEYDOWN => {
            const vk_code: u32 = @intCast(w_param);
            const key: InputKey = convert_vkcode_to_key(vk_code);
            input.registerInputEvent(.{ .source = .keyboard, .key = key, .trigger = .pressed });
            return 0;
        },
        win.WM_KEYUP => {
            const vk_code: u32 = @intCast(w_param);
            const key: InputKey = convert_vkcode_to_key(vk_code);
            input.registerInputEvent(.{ .source = .keyboard, .key = key, .trigger = .released });
            return 0;
        },
        win.WM_LBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_left, .trigger = .pressed });
            return 0;
        },
        win.WM_LBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_left, .trigger = .released });
            return 0;
        },
        win.WM_RBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .pressed });
            return 0;
        },
        win.WM_RBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .released });
            return 0;
        },
        win.WM_MBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_middle, .trigger = .pressed });
            return 0;
        },
        win.WM_MBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .released });
            return 0;
        },
        win.WM_MOUSEMOVE => {
            const new_position: Vec2i = Local.extractLoHiWord(l_param);
            input.registerMouseMoveEvent(new_position);
            return 0;
        },
        else => {
            return win.DefWindowProcW(hwnd, msg, w_param, l_param);
        },
    }
}

pub fn init(h_instance: HINSTANCE, h_prev_instance: HINSTANCE, cmd_line: [*c]u8, cmd_show: i32) !void {
    _ = h_prev_instance; _ = cmd_line;

    w32_data.h_instance = h_instance;
    w32_data.cmd_show = cmd_show;

    const window_class = win.WNDCLASSW{
        .lpfnWndProc = winProc,
        .hInstance = h_instance,
        .hCursor = null,
        .hIcon = null,
        .hbrBackground = null,
        .lpszClassName = std.unicode.utf8ToUtf16LeStringLiteral(class_name),
        .lpszMenuName = null,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
    };

    _ = win.RegisterClassW(&window_class);
}

// Window interface

pub fn createWindow(comptime title: []const u8, position: Vec2i, size: Dim2i) !void {
    w32_data.hwnd = win.CreateWindowExW(
        0,
        std.unicode.utf8ToUtf16LeStringLiteral(class_name),
        std.unicode.utf8ToUtf16LeStringLiteral(title),
        win.WS_OVERLAPPEDWINDOW,
        @intCast(position.x),
        @intCast(position.y),
        size.w,
        size.h,
        null,
        null,
        w32_data.h_instance,
        null,
    );

    if (w32_data.hwnd == null) {
        _ = win.MessageBoxA(null, "Window Creation Failed!", "Error", win.MB_ICONEXCLAMATION | win.MB_OK);
        return InitializeError.Win32Window;
    }

    _ = win.ShowWindow(w32_data.hwnd, w32_data.cmd_show);

    try openglInit(w32_data.hwnd);
    main_window.is_active = true;
    updateWindowSize(main_window.size);

}

pub fn updateWindow() void {
    var msg: win.MSG = .{};
    while (win.PeekMessageW(&msg, null, 0, 0, win.PM_REMOVE) > 0) {
        _ = win.TranslateMessage(&msg);
        _ = win.DispatchMessageW(&msg);
    }
}

pub fn updateWindowSize(size: Dim2i) void {
    main_window.size = size;
    if (main_window.is_active) {
        glad.glViewport(0, 0, main_window.size.w, main_window.size.h);
    }
}

pub fn clearWindow(color: LinearColor) void {
    glad.glClearColor(color.r, color.g, color.b, color.a);
    glad.glClear(glad.GL_COLOR_BUFFER_BIT | glad.GL_DEPTH_BUFFER_BIT);
}

pub fn swapWindow() void {
    _ = win.SwapBuffers(w32_data.hdc);
}

pub fn isWindowActive() bool {
    return main_window.is_active;
}
