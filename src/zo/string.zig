const std = @import("std");

pub fn DynamicString(stack_buffer_size: comptime_int, comptime auto_free_heap: bool) type {
    return struct {

        const Mode = enum {
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

        pub fn deinit(self: *const @This()) void {
            if (self.heap_buffer) |buffer| {
                self.allocator.free(buffer);
            }
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

        pub inline fn get(self: *const @This()) []const u8 {
            return self.buffer[0..self.len];
        }

        pub inline fn getCString(self: *@This()) [:0]const u8 {
            return self.buffer;
        }

        pub inline fn isEmpty(self: *const @This()) bool {
            return self.len == 0;
        }
    };
}

pub const String8 = DynamicString(8, false);
pub const String16 = DynamicString(16, false);
pub const String32 = DynamicString(32, false);
pub const String64 = DynamicString(64, false);
pub const String128 = DynamicString(128, false);
pub const String256 = DynamicString(256, false);

pub const String = String32;
