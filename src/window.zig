const std = @import("std");
const builtin = @import("builtin");

const native_window = switch (builtin.os.tag) {
    .windows => @import("win32_window.zig"),
    else     => @compileError("Unsupported OS"),
};

const LinearColor = @import("math.zig").LinearColor;

pub fn create(comptime title: []const u8, pos_x: i32, pos_y: i32, width: i32, height: i32) void {
    native_window.create_window(title, pos_x, pos_y, width, height);
}

pub fn update() void {
    native_window.update_window();
}

pub fn clear(color: LinearColor) void {
    native_window.clear_window(color);
}

pub fn swap() void {
    native_window.swap_window();
}

pub fn is_active() bool  {
    return native_window.is_window_active();
}
