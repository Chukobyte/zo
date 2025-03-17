const std = @import("std");
const builtin = @import("builtin");

const math = @import("math.zig");

const Vec2i = math.Vec2i;
const Dim2i = math.Dim2i;

pub const native_window = switch (builtin.os.tag) {
    .windows => @import("win32_window.zig"),
    else     => @compileError("Unsupported OS"),
};

const LinearColor = @import("math.zig").LinearColor;

pub inline fn create(comptime title: []const u8, position: Vec2i, size: Dim2i) !void {
    try native_window.createWindow(title, position, size);
}

pub inline fn update() void {
    native_window.updateWindow();
}

pub inline fn updateSize(size: Dim2i) void {
    native_window.updateWindowSize(size);
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
