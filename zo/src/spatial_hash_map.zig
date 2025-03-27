const std = @import("std");
const math = @import("math.zig");
const misc = @import("misc.zig");

const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Rect2 = math.Rect2;
const ArrayListUtils = misc.ArrayListUtils;

pub const SpatialHashMapParams = struct {
    KeyT: type,
    DataT: type,
    cell_size: usize = 32,
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

pub fn SpatialHashMapT(comptime ObjectT: type) type {
    return struct {

        const ObjectList = std.ArrayList(ObjectT);

        const Cell = struct {
            objects: ObjectList,
            pub fn addUniqueObject(self: *@This(), object: ObjectT) !bool {
                for (self.objects.items) |v| {
                    if (v == object) {
                        return false;
                    }
                }
                try self.objects.append(object);
                return true;
            }
            pub fn removeObject(self: *@This(), object: ObjectT) void {
                ArrayListUtils.removeByValue(ObjectT, &self.objects, &object);
            }
        };
        const CellList = struct {
            items: [4]*Cell = undefined,
            len: usize = 0,
            pub fn addUniqueCell(self: *@This(), cell: *Cell) bool {
                for (0..self.len) |i| {
                    if (self.items[i] == cell) {
                        return false;
                    }
                }
                self.items[self.len] = cell;
                self.len += 1;
                return true;
            }
        };
        const HashMapT = std.AutoHashMap(Vec2i, Cell);
        const ObjectToCellMap = std.AutoHashMap(ObjectT, CellList);

        map: HashMapT,
        object_to_cells_map: ObjectToCellMap,
        cell_size: usize,

        pub fn init(allocator: std.mem.Allocator, cell_size: usize) !@This() {
            return @This(){
                .map = HashMapT.init(allocator),
                .object_to_cells_map = ObjectToCellMap.init(allocator),
                .cell_size = cell_size,
            };
        }

        pub fn deinit(self: *@This()) void {
            self.map.deinit();
        }

        pub fn updateObjectPosition(self: *@This(), object: ObjectT, collision: Rect2) !void {
            const grid_positions: [4]Vec2i = .{
                // top left
                self.toGridPos(collision.x, collision.y),
                // top right
                self.toGridPos(collision.x + collision.w, collision.y),
                // bottom left
                self.toGridPos(collision.x, collision.y + collision.h),
                // bottom right
                self.toGridPos(collision.x + collision.w, collision.y + collision.h),
            };
            var new_cell_list: CellList = .{};
            for (grid_positions) |grid_pos| {
                if (self.addObjectToCell(grid_pos, object)) |cell| {
                    new_cell_list.addUniqueCell(cell);
                }
            }
            self.object_to_cells_map.remove(object);
            self.object_to_cells_map.put(object, new_cell_list);
        }

        pub fn getCellObjects(self: *@This(), pos: Vec2) []ObjectT {
            const grid_pos = self.toGridPos(pos.x, pos.y);
            if (self.map.get(grid_pos)) |*found_cell| {
                return found_cell.objects.items[0..found_cell.objects.items.len];
            }
            return .{};
        }

        pub fn removeObject(self: *@This(), object: ObjectT) void {
            if (self.object_to_cells_map.get(object)) |*cell_list| {
                for (0..cell_list.len) |i| {
                    cell_list.items[i].removeObject(object);
                }
                self.object_to_cells_map.remove(object);
            }
        }

        inline fn toGridPos(self: *@This(), x: f32, y: f32) Vec2i {
            const cell_size: i32 = @intCast(self.cell_size);
            return .{ .x = @as(i32, @intFromFloat(x)) / cell_size, .y = @as(i32, @intFromFloat(y)) / cell_size };
        }

        fn addObjectToCell(self: *@This(), pos: Vec2, object: ObjectT) !?*Cell {
            const cell_size: i32 = @intCast(self.cell_size);
            const grid_pos: Vec2i = .{ .x = @as(i32, @intFromFloat(pos.x)) / cell_size, .y = @as(i32, @intFromFloat(pos.y)) / cell_size };
            var cell: *Cell = undefined;
            if (self.map.get(grid_pos)) |*found_cell| {
                cell = found_cell;
            } else {
                const get_put_obj = try self.map.getOrPut(pos);
                cell = get_put_obj.value_ptr;
                cell.objects = ObjectList.init(self.map.allocator);
            }
            if (cell.addUniqueObject(object)) {
                return cell;
            }
            return null;
        }
    };
}
