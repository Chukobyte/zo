const std = @import("std");
const builtin = @import("builtin");

const math = @import("math.zig");
const input = @import("input.zig");

pub const win = @cImport({
    @cInclude("windows.h");
});

pub const WINAPI: std.builtin.CallingConvention = .winapi;
pub const HINSTANCE = win.HINSTANCE;
pub const HWND = win.HWND;
pub const HDC = win.HDC;
pub const WPARAM = win.WPARAM;
pub const LPARAM = win.LPARAM;
pub const LRESULT = win.LRESULT;
pub const INT = win.INT;
const Vec2i = math.Vec2i;
const InputKey = input.InputKey;

const Window = struct {
    title: []const u8,
    position: Vec2i,
    width: i32,
    height: i32,
};

const Win32Data = struct {
    h_instance: HINSTANCE = undefined,
    hwnd: HWND = undefined,
    hdc: HDC = undefined,
    cmd_show: i32 = undefined,
};

const main_window: Window = {};
var w32_data: Win32Data = .{};
const class_name: []const u8 = "My window class";

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
        else => return InputKey.invalid
    }
}

fn win_proc(
    hwnd: HWND,
    msg: u32,
    w_param: WPARAM,
    l_param: LPARAM,
) callconv(WINAPI) LRESULT {
    switch (msg) {
        win.WM_DESTROY => {
            win.PostQuitMessage(0);
            return 0;
        },
        win.WM_SIZE => {
            return 0;
        },
        win.WM_KEYDOWN => {
            const vk_code: u32 = @intCast(w_param);
            const key: InputKey = convert_vkcode_to_key(vk_code);
            _ = key;
            return 0;
        },
        win.WM_KEYUP => {
            return 0;
        },
        win.WM_LBUTTONDOWN => {
            return 0;
        },
        win.WM_LBUTTONUP => {
            return 0;
        },
        win.WM_RBUTTONDOWN => {
            return 0;
        },
        win.WM_RBUTTONUP => {
            return 0;
        },
        win.WM_MBUTTONDOWN => {
            return 0;
        },
        win.WM_MBUTTONUP => {
            return 0;
        },
        win.WM_MOUSEMOVE => {
            const param: c_longlong = @as(c_longlong, l_param);
            const mask: c_longlong = @as(c_longlong, 0xffff);
            const x_u16: u16 = @intCast(param & mask);
            const y_u16: u16 = @intCast((param >> 16) & mask);
            const x_i16: i16 = @bitCast(x_u16);
            const y_i16: i16 = @bitCast(y_u16);
            // Promote to i32, which will sign-extend correctly.
            const x_pos: i32 = x_i16;
            const y_pos: i32 = y_i16;
            input.register_mouse_move_event(.{ .x = x_pos, .y = y_pos });
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
        .lpfnWndProc = win_proc,
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

pub fn create_window(title: []const u8, pos_x: i32, pos_y: i32, width: i32, height: i32) void {
    _ = pos_x; _ = pos_y; _ = title;
    const style = win.WS_OVERLAPPEDWINDOW;

    w32_data.hwnd = win.CreateWindowExW(
        0,
        std.unicode.utf8ToUtf16LeStringLiteral(class_name),
        // std.unicode.utf8ToUtf16LeStringLiteral(title),
        std.unicode.utf8ToUtf16LeStringLiteral("Test Window"),
        style,
        win.CW_USEDEFAULT,
        win.CW_USEDEFAULT,
        width,
        height,
        null,
        null,
        w32_data.h_instance,
        null,
    );

    if (w32_data.hwnd == null) {
        _ = win.MessageBoxA(null, "Window Creation Failed!", "Error", win.MB_ICONEXCLAMATION | win.MB_OK);
        unreachable;
    }

    _ = win.ShowWindow(w32_data.hwnd, w32_data.cmd_show);
}
