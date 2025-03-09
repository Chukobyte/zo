const std = @import("std");

pub fn init() void {
    std.debug.print("Hey\n", .{});
}

pub fn deinit() void {
    std.debug.print("Bye\n", .{});
}
