const std = @import("std");
const math = @import("math.zig");
const misc = @import("misc.zig");

const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Rect2 = math.Rect2;
const ArrayListUtils = misc.ArrayListUtils;

const SpatialHashMapError = error {
    FailedToAddToCell,
};

pub fn SpatialHashMap(comptime ObjectT: type) type {
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
        const ObjectData = struct {
            collider: Rect2,
            cell_list: CellList = .{},
        };
        const HashMapT = std.AutoHashMap(Vec2i, Cell);
        const ObjectToDataMap = std.AutoHashMap(ObjectT, ObjectData);

        map: HashMapT,
        object_to_data_map: ObjectToDataMap,
        cell_size: usize,
        collided_objects_result: ObjectList,

        pub fn init(allocator: std.mem.Allocator, cell_size: usize) !@This() {
            return @This(){
                .map = HashMapT.init(allocator),
                .object_to_data_map = ObjectToDataMap.init(allocator),
                .cell_size = cell_size,
                .collided_objects_result = ObjectList.init(allocator),
            };
        }

        pub fn deinit(self: *@This()) void {
            var iterator = self.map.valueIterator();
            while (iterator.next()) |iter| {
                iter.objects.deinit();
            }
            self.map.deinit();
            self.object_to_data_map.deinit();
            self.collided_objects_result.deinit();
        }

        pub fn updateObjectPosition(self: *@This(), object: ObjectT, collision: Rect2) !void {
            // Remove object to clear old data before updating
            self.removeObject(object);
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
            var object_data: ObjectData = .{ .collider = collision };
            for (grid_positions) |grid_pos| {
                if (try self.addObjectToCell(grid_pos, object)) |cell| {
                    _ = object_data.cell_list.addUniqueCell(cell);
                }
            }
            _ = self.object_to_data_map.remove(object);
            try self.object_to_data_map.put(object, object_data);
        }

        pub fn getObjects(self: *@This(), pos: Vec2) []ObjectT {
            const grid_pos = self.toGridPos(pos.x, pos.y);
            if (self.map.get(grid_pos)) |*found_cell| {
                return found_cell.objects.items[0..found_cell.objects.items.len];
            }
            return &[_]ObjectT{};
        }

        pub fn getCollidedObjects(self: *@This(), object: ObjectT) ![]ObjectT {
            self.collided_objects_result.clearRetainingCapacity();
            if (self.object_to_data_map.getPtr(object)) |object_data| {
                const collider = &object_data.collider;
                for (0..object_data.cell_list.len) |i| {
                    const cell: *Cell = object_data.cell_list.items[i];
                    for (cell.objects.items) |other_object| {
                        if (object == other_object) { continue; }
                        const other_collider = &self.object_to_data_map.get(other_object).?.collider;
                        if (collider.doesOverlap(other_collider)) {
                            try self.collided_objects_result.append(other_object);
                        }
                    }
                }
            }
            return self.collided_objects_result.items[0..self.collided_objects_result.items.len];
        }

        pub fn getCollidedObjectsFromPoint(self: *@This(), pos: Vec2) ![]ObjectT {
            const grid_pos = self.toGridPos(pos.x, pos.y);
            if (self.map.get(grid_pos)) |*found_cell| {
                self.collided_objects_result.clearRetainingCapacity();
                for (found_cell.objects.items) |object| {
                    const other_collider = self.object_to_data_map.get(object).?.collider;
                    if (other_collider.doesPointOverlap(&pos)) {
                        try self.collided_objects_result.append(object);
                    }
                }
                return self.collided_objects_result.items[0..self.collided_objects_result.items.len];
            }
            return &[_]ObjectT{};
        }

        pub fn removeObject(self: *@This(), object: ObjectT) void {
            if (self.object_to_data_map.getPtr(object)) |object_data| {
                for (0..object_data.cell_list.len) |i| {
                    object_data.cell_list.items[i].removeObject(object);
                }
                _ = self.object_to_data_map.remove(object);
            }
        }

        inline fn toGridPos(self: *@This(), x: f32, y: f32) Vec2i {
            const cell_size: i32 = @intCast(self.cell_size);
            return .{ .x = @divFloor(@as(i32, @intFromFloat(x)),  cell_size), .y = @divFloor(@as(i32, @intFromFloat(y)), cell_size) };
        }

        fn addObjectToCell(self: *@This(), grid_pos: Vec2i, object: ObjectT) !?*Cell {
            var cell: *Cell = undefined;
            if (self.map.getEntry(grid_pos)) |entry| {
                cell = entry.value_ptr;
            } else {
                const get_put_obj = try self.map.getOrPut(grid_pos);
                cell = get_put_obj.value_ptr;
                cell.objects = ObjectList.init(self.map.allocator);
            }
            if (try cell.addUniqueObject(object)) {
                return cell;
            }
            return null;
        }
    };
}
