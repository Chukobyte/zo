const std = @import("std");
const testing = std.testing;
const zo = @import("zo");
const ecs = zo.ecs;
const string = zo.string;

const Vec2 = zo.math.Vec2;
const Rect2 = zo.math.Rect2;
const Delegate = zo.delegate.Delegate;

test "SpatialHashMap basic insert and retrieve" {
    const SpatialHashMapT = zo.spatial_hash_map.SpatialHashMap;
    const SpatialHashMap = SpatialHashMapT(u32);

    const allocator = std.testing.allocator;
    var map = try SpatialHashMap.init(allocator, 32);
    defer map.deinit();

    const collider: Rect2 = .{ .x = 5.0, .y = 10.0, .w = 40.0, .h = 80.0 };
    try map.updateObjectPosition(47, collider);

    const objects: []u32 = map.getObjects(.{ .x = 10.0, .y = 30.0 });
    try std.testing.expectEqual(1, objects.len);
    try std.testing.expectEqual(47, objects[0]);

    const collided_objects: []u32 = try map.getCollidedObjectsFromPoint(.{ .x = 10.0, .y = 30.0 });
    try std.testing.expectEqual(1, collided_objects.len);
    try std.testing.expectEqual(47, collided_objects[0]);

    const non_collided_objects: []u32 = try map.getCollidedObjectsFromPoint(.{ .x = 20.0, .y = 91.0 });
    try std.testing.expectEqual(0, non_collided_objects.len);

    map.removeObject(47);
    const empty_objects: []u32 = map.getObjects(.{ .x = 10.0, .y = 30.0 });
    try std.testing.expectEqual(0, empty_objects.len);
}

// test "SpatialHashMap multiple objects collision" {
//     const SpatialHashMapT = zo.spatial_hash_map.SpatialHashMap;
//     const SpatialHashMap = SpatialHashMapT(u32);
//     const allocator = std.testing.allocator;
//     var map = try SpatialHashMap.init(allocator, 32);
//     defer map.deinit();
//
//     // Insert two objects with overlapping colliders.
//     const colliderA: Rect2 = .{ .x = 10.0, .y = 10.0, .w = 50.0, .h = 50.0 };
//     const colliderB: Rect2 = .{ .x = 40.0, .y = 40.0, .w = 50.0, .h = 50.0 };
//     try map.updateObjectPosition(1, colliderA);
//     try map.updateObjectPosition(2, colliderB);
//
//     // Insert a third object that does not overlap.
//     const colliderC: Rect2 = .{ .x = 200.0, .y = 200.0, .w = 30.0, .h = 30.0 };
//     try map.updateObjectPosition(3, colliderC);
//
//     // Test collision: Object 1 should see object 2, and vice versa.
//     const collided1 = try map.getCollidedObjects(1);
//     try std.testing.expectEqual(1, collided1.len);
//     try std.testing.expectEqual(2, collided1[0]);
//
//     const collided2 = try map.getCollidedObjects(2);
//     try std.testing.expectEqual(1, collided2.len);
//     try std.testing.expectEqual(1, collided2[0]);
//
//     // Object 3 should have no collisions.
//     const collided3 = try map.getCollidedObjects(3);
//     try std.testing.expectEqual(0, collided3.len);
//
//     // Query from a point in the overlapping area.
//     const point: Vec2 = .{ .x = 45.0, .y = 45.0 };
//     const collidedFromPoint = try map.getCollidedObjectsFromPoint(point);
//     // Expect that both object 1 and 2 are reported.
//     var found1 = false;
//     var found2 = false;
//     for (collidedFromPoint) |obj| {
//         if (obj == 1) found1 = true;
//         if (obj == 2) found2 = true;
//     }
//     try std.testing.expect(found1);
//     try std.testing.expect(found2);
// }

// test "SpatialHashMap update moves object" {
//     const SpatialHashMapT = zo.spatial_hash_map.SpatialHashMap;
//     const SpatialHashMap = SpatialHashMapT(u32);
//     const allocator = std.testing.allocator;
//     var map = try SpatialHashMap.init(allocator, 32);
//     defer map.deinit();
//
//     // Insert an object at a given position.
//     const collider1: Rect2 = .{ .x = 10.0, .y = 10.0, .w = 20.0, .h = 20.0 };
//     try map.updateObjectPosition(10, collider1);
//     const objects1 = map.getObjects(.{ .x = 10.0, .y = 10.0 });
//     try std.testing.expectEqual(1, objects1.len);
//     try std.testing.expectEqual(10, objects1[0]);
//
//     // Update its position to a different grid cell.
//     const collider2: Rect2 = .{ .x = 100.0, .y = 100.0, .w = 20.0, .h = 20.0 };
//     try map.updateObjectPosition(10, collider2);
//     // The old cell should now be empty.
//     const objectsOld = map.getObjects(.{ .x = 10.0, .y = 10.0 });
//     try std.testing.expectEqual(0, objectsOld.len);
//     // The new cell should contain the object.
//     const objectsNew = map.getObjects(.{ .x = 100.0, .y = 100.0 });
//     try std.testing.expectEqual(1, objectsNew.len);
//     try std.testing.expectEqual(10, objectsNew[0]);
// }

test "SpatialHashMap removal cleans up cells" {
    const SpatialHashMapT = zo.spatial_hash_map.SpatialHashMap;
    const SpatialHashMap = SpatialHashMapT(u32);
    const allocator = std.testing.allocator;
    var map = try SpatialHashMap.init(allocator, 32);
    defer map.deinit();

    // Insert several objects in the same grid cell.
    const collider: Rect2 = .{ .x = 15.0, .y = 15.0, .w = 30.0, .h = 30.0 };
    try map.updateObjectPosition(101, collider);
    try map.updateObjectPosition(102, collider);
    try map.updateObjectPosition(103, collider);

    const objects = map.getObjects(.{ .x = 15.0, .y = 15.0 });
    try std.testing.expectEqual(3, objects.len);

    // Remove one object and verify it's gone.
    map.removeObject(102);
    const objects_after_remove = map.getObjects(.{ .x = 15.0, .y = 15.0 });
    try std.testing.expectEqual(2, objects_after_remove.len);
    for (objects_after_remove) |obj| {
        try std.testing.expect(obj != 102);
    }
}

test "Delegate basic subscribe and broadcast" {
    const allocator = std.testing.allocator;

    // Delegate type: function that takes an i32 and returns void
    const MyDelegate = Delegate(fn (i32) void);
    var delegate = MyDelegate.init(allocator);
    defer delegate.deinit();

    const Local = struct {
        var call_count: usize = 0;
        var last_value: i32 = 0;

        pub fn callback(value: i32) void {
            call_count += 1;
            last_value = value;
        }
    };

    const handle = try delegate.subscribe(Local.callback);
    delegate.broadcast(.{ 42 });

    try testing.expectEqual(@as(usize, 1), Local.call_count);
    try testing.expectEqual(@as(i32, 42), Local.last_value);

    delegate.unsubscribe(handle);
    delegate.broadcast(.{ 99 });

    // Should not call the callback again
    try testing.expectEqual(@as(usize, 1), Local.call_count);
    try testing.expectEqual(@as(i32, 42), Local.last_value);
}

const World = ecs.ECSWorld(.{
    .components = &[_]type{ Position },
    .entity_interfaces = &[_]type{},
    .systems = &[_]type{ PositionSystem },
    .archetypes = &[_][]const type{
        &[_]type{ Position },
    },
});

const Position = struct {
    x: f32,
    y: f32,
};

const PositionSystem = struct {
    pub fn getSignature() []const type {
        return &.{ Position };
    }

    pub fn postWorldUpdate(_: *@This(), world: anytype, _: f32) void {
        const Iterator = World.ArchetypeComponentIterator(&[_]type{ Position });
        var iter = Iterator.init(world);
        while (iter.next()) |it| {
            const pos = it.getComponent(Position);
            pos.x += 1.0;
            pos.y += 1.0;
        }
    }
};

test "ECS with system that updates position" {
    const allocator = std.testing.allocator;
    var world = try World.init(allocator);
    defer world.deinit();

    const entity = try world.initEntity(null);
    const pos = Position{ .x = 5.0, .y = 10.0 };
    try world.setComponent(entity, Position, &pos);

    try world.update(0.0);

    const updated = world.getComponent(entity, Position);
    try testing.expect(updated != null);
    try testing.expectEqual(@as(f32, 6.0), updated.?.x);
    try testing.expectEqual(@as(f32, 11.0), updated.?.y);
}

test "DynamicString: empty string" {
    const allocator = std.testing.allocator;
    var ds = string.String32.init(allocator);
    defer ds.deinit();
    // Should be empty since init calls set("").
    try testing.expectEqualStrings("", ds.get());
    try testing.expect(ds.isEmpty());
}

test "DynamicString: set short string (stack allocation)" {
    const allocator = std.testing.allocator;
    var ds = string.String32.init(allocator);
    defer ds.deinit();
    try ds.set("Hi", .{});
    try testing.expectEqualStrings("Hi", ds.get());
    try testing.expectEqual(2, ds.len);
    // Because the string "Hi" fits in 32 bytes, it remains in stack mode.
    try testing.expectEqual(string.String32.Mode.stack, ds.mode);
}

test "DynamicString: set long string (heap allocation)" {
    // Use a string type with a small stack buffer.
    const allocator = std.testing.allocator;
    var ds = string.String4.init(allocator);
    defer ds.deinit();
    // "Hello" is 5 characters plus the null terminator (6 bytes total)
    // which exceeds the 4-byte stack buffer.
    try ds.set("Hello", .{});
    try testing.expectEqualStrings("Hello", ds.get());
    try testing.expectEqual(5, ds.len);
    try testing.expectEqual(string.String4.Mode.heap, ds.mode);
    ds.deinit();
}

test "DynamicString: setRaw short string" {
    const allocator = std.testing.allocator;
    var ds = string.String32.init(allocator);
    defer ds.deinit();
    try ds.setRaw("Test");
    try testing.expectEqualStrings("Test", ds.get());
    try testing.expectEqual(4, ds.len);
    try testing.expectEqual(string.String32.Mode.stack, ds.mode);
    ds.deinit();
}

test "DynamicString: setRaw long string" {
    // For a longer string, use a type with a small stack buffer.
    const allocator = std.testing.allocator;
    var ds = string.String8.init(allocator);
    defer ds.deinit();
    // "LongerStr" is 9 characters plus null terminator = 10 bytes, exceeding 8.
    try ds.setRaw("LongerStr");
    try testing.expectEqualStrings("LongerStr", ds.get());
    try testing.expectEqual(9, ds.len);
    try testing.expectEqual(string.String8.Mode.heap, ds.mode);
    ds.deinit();
}

test "DynamicString: initAndSet and initAndSetRaw" {
    const allocator = std.testing.allocator;
    var ds = try string.String32.initAndSet(allocator, "Hello {s}!", .{"World"});
    defer ds.deinit();
    try testing.expectEqualStrings("Hello World!", ds.get());

    var ds2 = try string.String32.initAndSetRaw(allocator, "RawData");
    defer ds2.deinit();
    try testing.expectEqualStrings("RawData", ds2.get());
}

test "DynamicString: freeHeap frees heap buffer" {
    const allocator = std.testing.allocator;
    var ds = string.String4.init(allocator);
    defer ds.deinit();
    // "Overflow" is longer than 4 bytes, so it should go to heap mode.
    try ds.set("Overflow", .{});
    try testing.expectEqual(string.String4.Mode.heap, ds.mode);
    ds.freeHeap();
    try testing.expect(ds.heap_buffer == null);
}

test "DynamicString: copy string" {
    const allocator = std.testing.allocator;

    // Create an original string.
    var original = try string.String32.initAndSet(allocator, "Hello {s}!", .{"Clone"});
    defer original.deinit();

    // Clone the original string.
    var copy = try original.copy();
    defer copy.deinit();

    // Check that both strings have the same content, length, and mode.
    try testing.expectEqualStrings(original.get(), copy.get());
    try testing.expectEqual(original.len, copy.len);
    try testing.expectEqual(original.mode, copy.mode);

    // Modify the original string.
    try original.set("Modified", .{});

    // Verify that the clone remains unchanged.
    try testing.expect(!original.equal(&copy));
}
