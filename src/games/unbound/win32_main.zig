const std = @import("std");
const builtin = @import("builtin");

const zo = @import("zo");

const win32 = zo.window.native_window;

const zo_main = @import("main.zig").main;

pub export fn WinMain(hInstance: win32.HINSTANCE, hPrevInstance: win32.HINSTANCE, pCmdLine: [*c]u8, nCmdShow: i32) callconv(win32.WINAPI) win32.INT {
    return wWinMain(hInstance, hPrevInstance, pCmdLine, nCmdShow);
}

pub export fn wWinMain(hInstance: win32.HINSTANCE, hPrevInstance: win32.HINSTANCE, pCmdLine: [*c]u8, nCmdShow: i32) callconv(win32.WINAPI) win32.INT {
    win32.init(hInstance, hPrevInstance, pCmdLine, nCmdShow) catch { return 1; };
    zo_main() catch { return 1; };
    return 0;
}
