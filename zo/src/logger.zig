const std = @import("std");

pub const LogLevel = enum(u8) {
    debug,
    info,
    warn,
    critical,
    message,
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
    if (@intFromEnum(global_logger.level) > @intFromEnum(level)) {
        // std.debug.print("NO LOG - global_logger.level = '{}', level = '{}'\n", .{ global_logger.level, level });
        return;
    }

    const level_str: []const u8 = switch (level) {
        .debug => "[DEBUG] ",
        .info => "[INFO] ",
        .warn => "[WARN] ",
        .critical => "[CRITICAL] ",
        .message => "",
    };
    std.debug.print("{s}", .{ level_str });
    std.debug.print(fmt, args);
    std.debug.print("\n", .{});
}
