///! Miscellaneous things that don't fit into one particular box.

const std = @import("std");

pub fn FixedArrayList(comptime T: type, capacity: comptime_int) type {
    return struct {
        items: [capacity]T,
        len: usize,

        pub fn init() @This() {
            return FixedArrayList{ .items = undefined, .len = 0 };
        }

        pub fn append(self: *@This(), item: u8) FixedArrayListError!void {
            if (self.len >= self.items.len) return .OutOfCapacity;
            self.items[self.len] = item;
            self.len += 1;
        }

        pub fn pop(self: *@This()) !T {
            if (self.len == 0) return .IndexOutOfBounds;
            self.len -= 1;
            return self.items[self.len];
        }

        pub fn swapRemove(self: *@This(), i: usize) FixedArrayListError!T {
            if (self.len == 0 or i >= self.len) return .IndexOutOfBounds;
            if (i == self.len - 1) {
                return self.pop();
            }
            const removed = self.items[i];
            // Replace the element at i with the last element.
            self.items[i] = try self.pop();
            return removed;
        }

        pub fn findIndexByValue(self: *@This(), value: *const T) ?usize {
            for (self.items, 0..self.len) |*item, i| {
                if (std.mem.eql(u8, std.mem.asBytes(item), std.mem.asBytes(value))) {
                    return i;
                }
            }
            return null;
        }

        pub fn removeByValue(self: *@This(), value: *const T) FixedArrayListError!?T {
            if (self.findIndexByValue(value)) |i| {
                return try self.swapRemove(i);
            }
            return null;
        }

        pub fn asSlice(self: *const FixedArrayList) []const u8 {
            return self.items[0 .. self.len];
        }
    };
}

pub const ArrayListUtils = struct {
    pub fn findIndexByValue(comptime T: type, list: *std.ArrayList(T), value: *const T) ?usize {
        for (list.items, 0..list.items.len) |*item, i| {
            if (std.mem.eql(u8, std.mem.asBytes(item), std.mem.asBytes(value))) {
                return i;
            }
        }
        return null;
    }

    pub fn findIndexByPred(comptime T: type, list: *std.ArrayList(T), value: *const T, pred: *const fn(*const T, *const T) bool) ?usize {
        for (list.items, 0..list.items.len) |*item, i| {
            if (pred(value, item)) {
                return i;
            }
        }
        return null;
    }

    pub fn findIndexByPred2(comptime T: type, comptime T2: type, list: *std.ArrayList(T), value: *const T2, pred: *const fn(*const T2, *const T) bool) ?usize {
        for (list.items, 0..list.items.len) |*item, i| {
            if (pred(value, item)) {
                return i;
            }
        }
        return null;
    }

    pub fn removeByValue(comptime T: type, list: *std.ArrayList(T), value: *const T) void {
        if (findIndexByValue(T, list, value)) |i| {
            _ = list.swapRemove(i);
        }
    }

    pub fn removeByPred(comptime T: type, list: *std.ArrayList(T), value: *const T, pred: *const fn(*const T, *const T) bool) void {
        if (findIndexByPred(T, list, value, pred)) |i| {
            _ = list.swapRemove(i);
        }
    }

    pub fn removeByPred2(comptime T: type, comptime T2: type, list: *std.ArrayList(T), value: *const T2, pred: *const fn(*const T2, *const T) bool) void {
        if (findIndexByPred2(T, T2, list, value, pred)) |i| {
            _ = list.swapRemove(i);
        }
    }
};

pub fn TagList(max_tags: comptime_int) type {
    return struct {
        tags: [max_tags][]const u8 = undefined,
        tag_count: usize = 0,

        pub fn initFromSlice(tags: []const []const u8) @This() {
            var tag_list = @This(){};
            for (tags) |tag| {
                tag_list.addTag(tag) catch { std.debug.print("Skipping adding tag due to being at the limit '{d}'", .{ max_tags }); break; };
            }
            return tag_list;
        }

        pub fn addTag(self: *@This(), tag: []const u8) !void {
            if (self.tag_count >= max_tags) {
                return error.OutOfTagSpace;
            }
            self.tags[self.tag_count] = tag;
            self.tag_count += 1;
        }

        pub fn getTags(self: *const @This()) [][]const u8 {
            return self.tags[0..self.tag_count];
        }

        pub fn hasTag(self: *const @This(), tag: []const u8) bool {
            for (self.tags) |current_tag| {
                if (std.mem.eql(u8, tag, current_tag)) {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn TypeList(comptime types: []const type) type {
    return struct {
        pub const len = types.len;

        pub fn getType(index: comptime_int) type {
            if (index < 0 or index >= types.len) {
                @compileError("Passed in index is out of range");
            }
            return types[index];
        }

        pub fn getIndex(comptime T: type) comptime_int {
            inline for (types, 0..types.len) |t, i| {
                if (t == T) {
                    return i;
                }
            }
            @compileError("No index found for type!");
        }

        pub fn getFlag(comptime T: type) usize {
            return @as(usize, 1) << @as(u6, @intCast(getIndex(T)));
        }

        pub fn getFlags(comptime flag_types: []const type) usize {
            var flags: usize = 0;
            inline for (flag_types) |flag_type| {
                flags |= getFlag(flag_type);
            }
            return flags;
        }

        pub fn hasType(comptime T: type) bool {
            inline for (types) |OtherT| {
                if (T == OtherT) {
                    return true;
                }
            }
            return false;
        }
    };
}

pub fn FlagUtils(comptime T: type) type {
    return struct {
        pub inline fn hasFlag(flags: T, flag: T) bool {
            return (flags & flag) != 0;
        }

        pub inline fn containsFlags(flags: T, required_flags: T) bool {
            return (flags & required_flags) == required_flags;
        }

        pub inline fn setFlag(flags: *T, flag: T) void {
            flags.* = flags.* | flag;
        }

        pub inline fn removeFlag(flags: *T, flag: T) void {
            flags.* = flags.* & ~flag;
        }

        pub inline fn clearFlags(flags: *T) void {
            flags = @as(T, 0);
        }
    };
}

pub fn TypeBitMask(comptime types: []const type) type {
    const MaskType = usize;
    const size = types.len;
    if (size > @bitSizeOf(MaskType)) {
        @compileLog("Doesn't support bit masks higher than usize (for now), size = {d}, usize = {d}", .{ size, @bitSizeOf(MaskType) });
    }

    const flag_utils = FlagUtils(MaskType);
    const type_list = TypeList(types);

    return struct {
        enabled_mask: MaskType = @as(MaskType, 0),
        mask: MaskType = @as(MaskType, 0),

        pub inline fn set(self: *@This(), comptime T: type) void {
            flag_utils.setFlag(&self.mask, type_list.getFlag(T));
            self.setEnabled(T, true);
        }

        pub inline fn setFlagsFromTypes(self: *@This(), comptime types_to_set: []const type) void {
            self.unsetAll();
            inline for (types_to_set) |T| {
                self.set(T);
            }
        }

        pub inline fn unset(self: *@This(), comptime T: type) void {
            flag_utils.removeFlag(&self.mask, type_list.getFlag(T));
            self.setEnabled(T, false);
        }

        pub inline fn unsetAll(self: *@This()) void {
            self.enabled_mask = @as(MaskType, 0);
            self.mask = @as(MaskType, 0);
        }

        pub inline fn eql(self: *const @This(), other: *const @This()) bool {
            return self.mask == other.mask;
        }

        pub inline fn eqlFlags(self: *const @This(), other: MaskType) bool {
            return self.mask == other;
        }

        pub inline fn contains(self: *const @This(), other: *const @This()) bool {
            return flag_utils.containsFlags(self.mask, other.mask);
        }

        pub inline fn setEnabled(self: *@This(), comptime T: type, enabled: bool) void {
            if (enabled) {
                flag_utils.setFlag(&self.enabled_mask, type_list.getFlag(T));
            } else {
                flag_utils.removeFlag(&self.enabled_mask, type_list.getFlag(T));
            }
        }

        pub inline fn isEnabled(self: *const @This(), comptime T: type) bool {
            return flag_utils.hasFlag(self.enabled_mask, type_list.getFlag(T));
        }

        pub inline fn enabledEql(self: *@This(), other: *@This()) bool {
            return self.enabled_mask == other.enabled_mask;
        }
    };
}

pub const FixedArrayListError = error{
    IndexOutOfBounds,
    OutOfCapacity,
};

pub fn assertUnsigned(comptime T: type) void {
    const info = @typeInfo(T);
    switch (info) {
        .Int => {
            if (info.Int.signedness != .Unsigned) {
                @compileError("Type must be an unsigned integer.");
            }
        },
        else => @compileError("Type must be an unsigned integer."),
    }
}
