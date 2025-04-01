const std = @import("std");
const builtin = @import("builtin");

const math = @import("math.zig");
const input = @import("input.zig");

pub const win = @import("win32");

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

const log = @import("logger.zig").log;

const LinearColor = math.LinearColor;

pub const WINAPI: std.builtin.CallingConvention = .winapi;
pub const HINSTANCE = win.foundation.HINSTANCE;
pub const HWND = win.foundation.HWND;
pub const HDC = win.graphics.gdi.HDC;
pub const HGLRC = win.graphics.open_gl.HGLRC;
pub const WPARAM = win.foundation.WPARAM;
pub const LPARAM = win.foundation.LPARAM;
pub const LRESULT = win.foundation.LRESULT;
pub const INT = i32;

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
const PFNWGLCREATECONTEXTATTRIBSARBPROC = *fn(hdc: HDC, hShareContext: ?*HGLRC, attribList: [*]const i32) callconv(WINAPI) HGLRC;

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

fn convert_vkcode_to_key(vk_code: win.ui.input.keyboard_and_mouse.VIRTUAL_KEY) InputKey {
    const vk_code_num = @intFromEnum(vk_code);
    // First letters
    if (vk_code_num >= 'A' and vk_code_num <= 'Z') {
        const key: u32 = @intFromEnum(InputKey.keyboard_a) + (vk_code_num - 'A');
        return @enumFromInt(key);
    }
    // Numbers
    if (vk_code_num >= '0' and vk_code_num <= '9') {
        const key: u32 = @intFromEnum(InputKey.keyboard_num_0) + (vk_code_num - '0');
        return @enumFromInt(key);
    }
    // Everything else
    switch (vk_code) {
        win.ui.input.keyboard_and_mouse.VK_TAB => return InputKey.keyboard_tab,
        win.ui.input.keyboard_and_mouse.VK_LEFT => return InputKey.keyboard_left,
        win.ui.input.keyboard_and_mouse.VK_RIGHT => return InputKey.keyboard_right,
        win.ui.input.keyboard_and_mouse.VK_UP => return InputKey.keyboard_up,
        win.ui.input.keyboard_and_mouse.VK_DOWN => return InputKey.keyboard_down,
        win.ui.input.keyboard_and_mouse.VK_NEXT => return InputKey.keyboard_page_down,
        win.ui.input.keyboard_and_mouse.VK_PRIOR => return InputKey.keyboard_page_up,
        win.ui.input.keyboard_and_mouse.VK_HOME => return InputKey.keyboard_home,
        win.ui.input.keyboard_and_mouse.VK_END => return InputKey.keyboard_end,
        win.ui.input.keyboard_and_mouse.VK_INSERT => return InputKey.keyboard_insert,
        win.ui.input.keyboard_and_mouse.VK_DELETE => return InputKey.keyboard_delete,
        win.ui.input.keyboard_and_mouse.VK_BACK => return InputKey.keyboard_backspace,
        win.ui.input.keyboard_and_mouse.VK_SPACE => return InputKey.keyboard_space,
        win.ui.input.keyboard_and_mouse.VK_RETURN => return InputKey.keyboard_return,
        win.ui.input.keyboard_and_mouse.VK_ESCAPE => return InputKey.keyboard_escape,
        win.ui.input.keyboard_and_mouse.VK_OEM_7 => return InputKey.keyboard_quote,
        win.ui.input.keyboard_and_mouse.VK_OEM_COMMA => return InputKey.keyboard_comma,
        win.ui.input.keyboard_and_mouse.VK_OEM_MINUS => return InputKey.keyboard_minus,
        win.ui.input.keyboard_and_mouse.VK_OEM_2 => return InputKey.keyboard_period,
        win.ui.input.keyboard_and_mouse.VK_OEM_1 => return InputKey.keyboard_slash,
        win.ui.input.keyboard_and_mouse.VK_OEM_PLUS => return InputKey.keyboard_semicolon,
        win.ui.input.keyboard_and_mouse.VK_OEM_4 => return InputKey.keyboard_left_bracket,
        win.ui.input.keyboard_and_mouse.VK_OEM_6 => return InputKey.keyboard_right_bracket,
        win.ui.input.keyboard_and_mouse.VK_OEM_5 => return InputKey.keyboard_backslash,
        win.ui.input.keyboard_and_mouse.VK_OEM_3 => return InputKey.keyboard_backquote,
        win.ui.input.keyboard_and_mouse.VK_CAPITAL => return InputKey.keyboard_caps_lock,
        win.ui.input.keyboard_and_mouse.VK_SCROLL => return InputKey.keyboard_scroll_lock,
        win.ui.input.keyboard_and_mouse.VK_NUMLOCK => return InputKey.keyboard_num_lock_clear,
        win.ui.input.keyboard_and_mouse.VK_SNAPSHOT => return InputKey.keyboard_print_screen,
        win.ui.input.keyboard_and_mouse.VK_PAUSE => return InputKey.keyboard_pause,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD0 => return InputKey.keyboard_keypad_0,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD1 => return InputKey.keyboard_keypad_1,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD2 => return InputKey.keyboard_keypad_2,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD3 => return InputKey.keyboard_keypad_3,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD4 => return InputKey.keyboard_keypad_4,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD5 => return InputKey.keyboard_keypad_5,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD6 => return InputKey.keyboard_keypad_6,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD7 => return InputKey.keyboard_keypad_7,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD8 => return InputKey.keyboard_keypad_8,
        win.ui.input.keyboard_and_mouse.VK_NUMPAD9 => return InputKey.keyboard_keypad_9,
        win.ui.input.keyboard_and_mouse.VK_DECIMAL => return InputKey.keyboard_keypad_period,
        win.ui.input.keyboard_and_mouse.VK_DIVIDE => return InputKey.keyboard_keypad_divide,
        win.ui.input.keyboard_and_mouse.VK_MULTIPLY => return InputKey.keyboard_keypad_multiply,
        win.ui.input.keyboard_and_mouse.VK_SUBTRACT => return InputKey.keyboard_keypad_minus,
        win.ui.input.keyboard_and_mouse.VK_ADD => return InputKey.keyboard_keypad_plus,
        // TODO: Properly handle left and right shift (only left is registered on tested keyboard)
        win.ui.input.keyboard_and_mouse.VK_LSHIFT => return InputKey.keyboard_left_shift,
        win.ui.input.keyboard_and_mouse.VK_RSHIFT => return InputKey.keyboard_right_shift,
        win.ui.input.keyboard_and_mouse.VK_SHIFT => return InputKey.keyboard_right_shift,
        win.ui.input.keyboard_and_mouse.VK_LCONTROL => return InputKey.keyboard_left_control,
        win.ui.input.keyboard_and_mouse.VK_RCONTROL => return InputKey.keyboard_right_control,
        win.ui.input.keyboard_and_mouse.VK_LMENU => return InputKey.keyboard_left_alt,
        win.ui.input.keyboard_and_mouse.VK_RMENU => return InputKey.keyboard_right_alt,
        win.ui.input.keyboard_and_mouse.VK_LWIN => return InputKey.keyboard_left_gui,
        win.ui.input.keyboard_and_mouse.VK_RWIN => return InputKey.keyboard_right_gui,
        win.ui.input.keyboard_and_mouse.VK_APPS => return InputKey.keyboard_application,
        win.ui.input.keyboard_and_mouse.VK_BROWSER_FORWARD => return InputKey.keyboard_app_forward,
        win.ui.input.keyboard_and_mouse.VK_BROWSER_BACK => return InputKey.keyboard_app_back,
        win.ui.input.keyboard_and_mouse.VK_F1 => return InputKey.keyboard_f1,
        win.ui.input.keyboard_and_mouse.VK_F2 => return InputKey.keyboard_f2,
        win.ui.input.keyboard_and_mouse.VK_F3 => return InputKey.keyboard_f3,
        win.ui.input.keyboard_and_mouse.VK_F4 => return InputKey.keyboard_f4,
        win.ui.input.keyboard_and_mouse.VK_F5 => return InputKey.keyboard_f5,
        win.ui.input.keyboard_and_mouse.VK_F6 => return InputKey.keyboard_f6,
        win.ui.input.keyboard_and_mouse.VK_F7 => return InputKey.keyboard_f7,
        win.ui.input.keyboard_and_mouse.VK_F8 => return InputKey.keyboard_f8,
        win.ui.input.keyboard_and_mouse.VK_F9 => return InputKey.keyboard_f9,
        win.ui.input.keyboard_and_mouse.VK_F10 => return InputKey.keyboard_f10,
        win.ui.input.keyboard_and_mouse.VK_F11 => return InputKey.keyboard_f11,
        win.ui.input.keyboard_and_mouse.VK_F12 => return InputKey.keyboard_f12,
        win.ui.input.keyboard_and_mouse.VK_F13 => return InputKey.keyboard_f13,
        win.ui.input.keyboard_and_mouse.VK_F14 => return InputKey.keyboard_f14,
        win.ui.input.keyboard_and_mouse.VK_F15 => return InputKey.keyboard_f15,
        win.ui.input.keyboard_and_mouse.VK_F16 => return InputKey.keyboard_f16,
        win.ui.input.keyboard_and_mouse.VK_F17 => return InputKey.keyboard_f17,
        win.ui.input.keyboard_and_mouse.VK_F18 => return InputKey.keyboard_f18,
        win.ui.input.keyboard_and_mouse.VK_F19 => return InputKey.keyboard_f19,
        win.ui.input.keyboard_and_mouse.VK_F20 => return InputKey.keyboard_f20,
        win.ui.input.keyboard_and_mouse.VK_F21 => return InputKey.keyboard_f21,
        win.ui.input.keyboard_and_mouse.VK_F22 => return InputKey.keyboard_f22,
        win.ui.input.keyboard_and_mouse.VK_F23 => return InputKey.keyboard_f23,
        win.ui.input.keyboard_and_mouse.VK_F24 => return InputKey.keyboard_f24,
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
    var pfd: win.graphics.open_gl.PIXELFORMATDESCRIPTOR = undefined;
    pfd.nSize = @intCast(@sizeOf(win.graphics.open_gl.PIXELFORMATDESCRIPTOR));
    pfd.nVersion = 1;
    // pfd.dwFlags = win.graphics.open_gl.PFD_SUPPORT_OPENGL | win.graphics.open_gl.PFD_DRAW_TO_WINDOW | win.graphics.open_gl.PFD_DOUBLEBUFFER;
    pfd.dwFlags = win.graphics.open_gl.PFD_FLAGS{ .SUPPORT_OPENGL = 1, .DRAW_TO_WINDOW = 1, .DOUBLEBUFFER = 1 };
    // pfd.iPixelType = win.graphics.open_gl.PFD_TYPE_RGBA;
    pfd.iPixelType = win.graphics.open_gl.PFD_TYPE_RGBA;
    pfd.cColorBits = 24;
    pfd.cDepthBits = 32;
    pfd.cStencilBits = 8;

    // Get the device context from the window handle
    const hdc: HDC = win.graphics.gdi.GetDC(hwnd) orelse { log(.critical, "Failed to get hdc!", .{}); return InitializeError.Win32Window; };
    w32_data.hdc = hdc;
    const pixelFormat = win.graphics.open_gl.ChoosePixelFormat(hdc, &pfd);
    _ = win.graphics.open_gl.SetPixelFormat(hdc, pixelFormat, &pfd);

    // Create a temporary context to load WGL extension functions.
    const tempRC = win.graphics.open_gl.wglCreateContext(hdc);
    _ = win.graphics.open_gl.wglMakeCurrent(hdc, tempRC);

    // Get the pointer to wglCreateContextAttribsARB
    const ptr = win.graphics.open_gl.wglGetProcAddress("wglCreateContextAttribsARB");
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
    const share_context: ?*HGLRC = null;
    const hglrc: HGLRC = wglCreateContextAttribsARB(hdc, share_context, &attribList);
    _ = win.graphics.open_gl.wglMakeCurrent(null, null);
    _ = win.graphics.open_gl.wglDeleteContext(tempRC);
    _ = win.graphics.open_gl.wglMakeCurrent(hdc, hglrc);
    // TODO: Get error here
    // log(.critical, "Failed to create opengl context!", .{});
    // return InitializeError.OpenGL;

    // Load OpenGL function pointers with GLAD.
    if (glad.gladLoadGL() == 0) {
        log(.critical, "Glad failed to load!  Error = {}", .{ glad.glGetError() });
        return InitializeError.OpenGL;
    } else {
        log(.debug, "OpenGL Version {d}", .{glad.GLVersion.major});
    }

    // Enable VSync if supported.
    const extPtr = win.graphics.open_gl.wglGetProcAddress("wglGetExtensionsStringEXT");
    const wglGetExtensionsStringEXT: PFNWGLGETEXTENSIONSSTRINGEXTPROC = @constCast(@ptrCast(extPtr));
    const extStr = wglGetExtensionsStringEXT();
    if (std.mem.indexOf(u8, cStringToSlice(extStr), "WGL_EXT_swap_control") != null) {
        if (win.graphics.open_gl.wglGetProcAddress("wglSwapIntervalEXT")) |swapFuncPtr| {
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
        win.ui.windows_and_messaging.WM_DESTROY => {
            win.ui.windows_and_messaging.PostQuitMessage(0);
            main_window.is_active = false;
            return 0;
        },
        win.ui.windows_and_messaging.WM_SIZE => {
            const new_size: Vec2i = Local.extractLoHiWord(l_param);
            updateWindowSize(Dim2i.fromVec2(new_size));
            return 0;
        },
        win.ui.windows_and_messaging.WM_KEYDOWN => {
            const vk_code: u16 = @intCast(w_param);
            const key: InputKey = convert_vkcode_to_key(@enumFromInt(vk_code));
            input.registerInputEvent(.{ .source = .keyboard, .key = key, .trigger = .pressed });
            return 0;
        },
        win.ui.windows_and_messaging.WM_KEYUP => {
            const vk_code: u16 = @intCast(w_param);
            const key: InputKey = convert_vkcode_to_key(@enumFromInt(vk_code));
            input.registerInputEvent(.{ .source = .keyboard, .key = key, .trigger = .released });
            return 0;
        },
        win.ui.windows_and_messaging.WM_LBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_left, .trigger = .pressed });
            return 0;
        },
        win.ui.windows_and_messaging.WM_LBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_left, .trigger = .released });
            return 0;
        },
        win.ui.windows_and_messaging.WM_RBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .pressed });
            return 0;
        },
        win.ui.windows_and_messaging.WM_RBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .released });
            return 0;
        },
        win.ui.windows_and_messaging.WM_MBUTTONDOWN => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_middle, .trigger = .pressed });
            return 0;
        },
        win.ui.windows_and_messaging.WM_MBUTTONUP => {
            input.registerInputEvent(.{ .source = .mouse, .key = .mouse_button_right, .trigger = .released });
            return 0;
        },
        win.ui.windows_and_messaging.WM_MOUSEMOVE => {
            const new_position: Vec2i = Local.extractLoHiWord(l_param);
            input.registerMouseMoveEvent(new_position);
            return 0;
        },
        else => {
            return win.ui.windows_and_messaging.DefWindowProcW(hwnd, msg, w_param, l_param);
        },
    }
}

pub fn init(h_instance: HINSTANCE, h_prev_instance: HINSTANCE, cmd_line: [*c]u8, cmd_show: i32) !void {
    _ = h_prev_instance; _ = cmd_line;

    w32_data.h_instance = h_instance;
    w32_data.cmd_show = cmd_show;

    const window_class = win.ui.windows_and_messaging.WNDCLASSW{
        .style = win.ui.windows_and_messaging.WNDCLASS_STYLES{},
        .lpfnWndProc = winProc,
        .hInstance = h_instance,
        .hCursor = win.ui.windows_and_messaging.LoadCursorW(null, win.ui.windows_and_messaging.IDC_ARROW),
        .hIcon = win.ui.windows_and_messaging.LoadIconW(null, win.ui.windows_and_messaging.IDI_APPLICATION),
        .hbrBackground = null,
        .lpszClassName = std.unicode.utf8ToUtf16LeStringLiteral(class_name),
        .lpszMenuName = null,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
    };

    if (win.ui.windows_and_messaging.RegisterClassW(&window_class) == 0) {
        log(.critical, "Failed to register window class", .{});
        return InitializeError.Win32Window;
    }
}

// Window interface

pub fn createWindow(comptime title: []const u8, position: Vec2i, size: Dim2i) !void {
    const potential_hwnd = win.ui.windows_and_messaging.CreateWindowExW(
        win.ui.windows_and_messaging.WINDOW_EX_STYLE{},
        try std.unicode.utf8ToUtf16LeAllocZ(std.heap.page_allocator, class_name),
        try std.unicode.utf8ToUtf16LeAllocZ(std.heap.page_allocator, title),
        win.ui.windows_and_messaging.WS_OVERLAPPEDWINDOW,
        @intCast(position.x),
        @intCast(position.y),
        size.w,
        size.h,
        null,
        null,
        w32_data.h_instance,
        null,
    );
    if (potential_hwnd) |hwnd| {
        w32_data.hwnd = hwnd;
    } else {
        _ = win.ui.windows_and_messaging.MessageBoxA(null, "Window Creation Failed!", "Error", win.ui.windows_and_messaging.MESSAGEBOX_STYLE{ .ICONHAND = 1, .ICONQUESTION = 1,  });
        return InitializeError.Win32Window;
    }
    _ = win.ui.windows_and_messaging.ShowWindow(w32_data.hwnd, win.ui.windows_and_messaging.SW_SHOW);
    _ = win.graphics.gdi.UpdateWindow(w32_data.hwnd);

    try openglInit(w32_data.hwnd);
    main_window.is_active = true;
    updateWindowSize(main_window.size);

}

pub fn updateWindow() void {
    var msg: win.ui.windows_and_messaging.MSG = undefined;
    while (win.ui.windows_and_messaging.PeekMessageW(&msg, null, 0, 0, win.ui.windows_and_messaging.PM_REMOVE) > 0) {
        _ = win.ui.windows_and_messaging.TranslateMessage(&msg);
        _ = win.ui.windows_and_messaging.DispatchMessageW(&msg);
    }
}

pub fn updateWindowSize(size: Dim2i) void {
    main_window.size = size;
    if (main_window.is_active) {
        glad.glViewport(0, 0, main_window.size.w, main_window.size.h);
    }
}

pub inline fn getWindowSize() Dim2i {
    return main_window.size;
}

pub fn clearWindow(color: LinearColor) void {
    glad.glClearColor(color.r, color.g, color.b, color.a);
    glad.glClear(glad.GL_COLOR_BUFFER_BIT | glad.GL_DEPTH_BUFFER_BIT);
}

pub fn swapWindow() void {
    _ = win.graphics.open_gl.SwapBuffers(w32_data.hdc);
}

pub fn isWindowActive() bool {
    return main_window.is_active;
}
