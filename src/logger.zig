const std = @import("std");

pub const LogLevel = enum {
    message,
    debug,
    info,
    warn,
    critical,
};

const LoggerInstance = struct {
    level: LogLevel = .debug,
};

var global_logger: LoggerInstance = .{};

pub fn set_level(level: LogLevel) void {
    global_logger.level = level;
}

pub fn get_level() LogLevel {
    return global_logger.level;
}

pub fn log(level: LogLevel, comptime fmt: []const u8, args: anytype) void {
    // if (@intFromEnum(level) <= @intFromEnum(global_logger.level)) {
    //     return;
    // }

    const level_str: []const u8 = switch (level) {
        .message => "",
        .debug => "[DEBUG] ",
        .info => "[INFO] ",
        .warn => "[WARN] ",
        .critical => "[CRITICAL] ",
    };
    std.debug.print("{s}", .{ level_str });
    std.debug.print(fmt, args);
    std.debug.print("\n", .{});
}
