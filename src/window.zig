const std = @import("std");
const builtin = @import("builtin");

const native_window = switch (builtin.os.tag) {
    .windows => @import("win32_window.zig"),
    else     => @compileError("Unsupported OS"),
};

pub fn create(title: []const u8, pos_x: i32, pos_y: i32, width: i32, height: i32) void {
    native_window.create_window(title, pos_x, pos_y, width, height);
}
