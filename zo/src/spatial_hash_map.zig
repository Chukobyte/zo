const std = @import("std");

pub const SpatialHashMapParams = struct {
    KeyT: type,
    DataT: type,
};

pub fn SpatialHashMap(comptime p: SpatialHashMapParams) type {
    const KeyT = p.KeyT;
    const DataT = p.DataT;

    return struct {

        const Cell = struct {
            data: DataT,
        };
        const HashMapT = std.AutoHashMap(KeyT, Cell);

        map: HashMapT,
        cell_size: u32,

        pub fn init(allocator: std.mem.Allocator, cell_size: u32) !@This() {
            return @This(){
                .map = HashMapT.init(allocator),
                .cell_size = cell_size,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.map.deinit();
        }

        pub fn getOrPutCell(self: *@This(), pos: KeyT) !*Cell {
            const entry = try self.map.getOrPut(pos);
            if (!entry.found_existing) {
                // Assumes DataT can default initialize
                switch (@typeInfo(DataT)) {
                    .int, .float => entry.value_ptr.data = @as(DataT, 0),
                    else => entry.value_ptr.data = @as(DataT, .{}),
                }
            }
            return entry.value_ptr;
        }

        pub fn getCell(self: *@This(), pos: KeyT) !?*Cell {
            const entry = try self.map.getOrPut(pos);
            if (entry.found_existing) {
                return entry.value_ptr;
            }
            return null;
        }

        pub inline fn hasCell(self: *@This(), pos: KeyT) bool {
            return self.getCell(pos) catch { return null; } != null;
        }
    };
}
