const std = @import("std");
const builtin = @import("builtin");

const native_window = switch (builtin.os.tag) {
    .windows => @import("win32_window.zig"),
    else     => @compileError("Unsupported OS"),
};

const LinearColor = @import("math.zig").LinearColor;

pub inline fn create(comptime title: []const u8, pos_x: i32, pos_y: i32, width: i32, height: i32) !void {
    try native_window.createWindow(title, pos_x, pos_y, width, height);
}

pub inline fn update() void {
    native_window.updateWindow();
}

pub inline fn updateSize(width: i32, height: i32) void {
    native_window.updateWindowSize(width, height);
}

pub inline fn clear(color: LinearColor) void {
    native_window.clearWindow(color);
}

pub inline fn swap() void {
    native_window.swapWindow();
}

pub inline fn isActive() bool  {
    return native_window.isWindowActive();
}
