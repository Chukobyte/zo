const std = @import("std");

const log = @import("logger.zig").log;

pub fn DynamicString(stack_buffer_size: comptime_int, comptime auto_free_heap: bool) type {
    return struct {

        pub const Mode = enum {
            stack,
            heap,
        };

        allocator: std.mem.Allocator,
        mode: Mode = .stack,
        stack_buffer: [stack_buffer_size]u8 = undefined,
        heap_buffer: ?[]u8 = null,
        buffer: [:0]u8 = undefined,
        len: usize = 0,

        pub fn init(allocator: std.mem.Allocator) @This() {
            var new_string = @This(){ .allocator = allocator };
            new_string.set("", .{}) catch { unreachable; };
            return new_string;
        }

        pub inline fn initAndSet(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !@This() {
            var new_string = @This(){ .allocator = allocator };
            try new_string.set(fmt, args);
            return new_string;
        }

        pub inline fn initAndSetRaw(allocator: std.mem.Allocator, input: []const u8) !@This() {
            var new_string = @This(){ .allocator = allocator };
            try new_string.setRaw(input);
            return new_string;
        }

        pub fn deinit(self: *@This()) void {
            self.freeHeap();
        }

        pub fn set(self: *@This(), comptime fmt: []const u8, args: anytype) !void {
            const string_length = std.fmt.count(fmt, args) + 1;
            if (string_length > stack_buffer_size) {
                self.mode = .heap;
                if (self.heap_buffer == null) {
                    self.heap_buffer = try self.allocator.alloc(u8, string_length);
                } else if (self.heap_buffer.?.len < string_length){
                    if (!self.allocator.resize(self.heap_buffer.?, string_length)) {
                        self.allocator.free(self.heap_buffer.?);
                        self.heap_buffer = try self.allocator.alloc(u8, string_length);
                    }
                }
                self.buffer = try std.fmt.bufPrintZ(self.heap_buffer.?, fmt, args);
            } else {
                self.mode = .stack;
                self.buffer = try std.fmt.bufPrintZ(&self.stack_buffer, fmt, args);
                if (auto_free_heap) {
                    self.freeHeap();
                }
            }
            self.len = string_length - 1;
        }

        pub fn setRaw(self: *@This(), input: []const u8) !void {
            const string_length = input.len + 1; // +1 for null terminator

            if (string_length > stack_buffer_size) {
                self.mode = .heap;
                if (self.heap_buffer == null or self.heap_buffer.?.len < string_length) {
                    if (self.heap_buffer) |buffer| {
                        self.allocator.free(buffer);
                    }
                    self.heap_buffer = try self.allocator.alloc(u8, string_length);
                }
                @memcpy(self.heap_buffer.?[0..input.len], input);
                self.heap_buffer.?[input.len] = 0; // Null terminator
                self.buffer = self.heap_buffer.?[0..input.len :0];
            } else {
                self.mode = .stack;
                @memcpy(self.stack_buffer[0..input.len], input);
                self.stack_buffer[input.len] = 0; // Null terminator
                self.buffer = self.stack_buffer[0..input.len :0];

                if (auto_free_heap) {
                    self.freeHeap();
                }
            }

            self.len = input.len;
        }

        /// Will free heap if no longer being used
        pub fn freeHeap(self: *@This()) void {
            if (self.mode == .stack) {
                return;
            }
            if (self.heap_buffer) |buffer| {
                self.allocator.free(buffer);
                self.heap_buffer = null;
            }
        }

        pub fn get(self: *const @This()) []const u8 {
            return self.getCString()[0..self.len];
        }

        pub fn getCString(self: *const @This()) [:0]const u8 {
            return self.buffer;
        }

        pub inline fn isEmpty(self: *const @This()) bool {
            return self.len == 0;
        }

        pub inline fn equal(self: *const @This(), other: *const @This()) bool {
            return std.mem.eql(u8, self.get(), other.get());
        }

        /// Performs a deep copy
        pub inline fn copy(self: *const @This()) !@This() {
            return @This().initAndSetRaw(self.allocator, self.get());
        }
    };
}

pub const HeapString = DynamicString(1, false);
pub const String4 = DynamicString(4, false);
pub const String8 = DynamicString(8, false);
pub const String16 = DynamicString(16, false);
pub const String32 = DynamicString(32, false);
pub const String64 = DynamicString(64, false);
pub const String128 = DynamicString(128, false);
pub const String256 = DynamicString(256, false);

pub const String = String32;



pub fn DynamicMultiLineString(comptime StringT: type) type {
    return struct {
        allocator: std.mem.Allocator,
        lines: std.ArrayList(StringT),

        pub fn init(allocator: std.mem.Allocator) !@This() {
            return @This(){
                .allocator = allocator,
                .lines = try std.ArrayList(StringT).init(allocator),
            };
        }

        pub fn deinit(self: *@This()) void {
            for (self.lines.items) |*line| {
                line.deinit();
            }
            self.lines.deinit();
        }

        pub fn addLine(self: *@This(), line_text: []const u8) !void {
            var new_line = StringT.init(self.allocator);
            try new_line.setRaw(line_text);
            try self.lines.append(new_line);
        }

        /// Returns the line at the specified index.
        pub fn getLine(self: *const @This(), index: usize) ![]const u8 {
            if (index >= self.lines.items.len) {
                return error.IndexOutOfBounds;
            }
            return self.lines.items[index].get();
        }

        /// Returns the number of lines stored.
        pub inline fn lineCount(self: *const @This()) usize {
            return self.lines.items.len;
        }

        pub inline fn clear(self: *@This()) void {
            self.lines.clearRetainingCapacity();
        }
    };
}

pub const MultiLineString = DynamicMultiLineString(String);
pub const HeapMultiLineString = DynamicMultiLineString(HeapString);
