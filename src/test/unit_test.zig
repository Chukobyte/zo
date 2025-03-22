const std = @import("std");
const testing = std.testing;
const zo = @import("zo");
const ecs = zo.ecs;

const Vec2i = zo.math.Vec2i;
const Delegate = zo.delegate.Delegate;

test "SpatialHashMap basic insert and retrieve" {
    const SpatialHashMapT = zo.spatial_hash_map.SpatialHashMap;
    const SpatialHashMap = SpatialHashMapT(.{ .KeyT = Vec2i, .DataT = u32 });

    const allocator = std.testing.allocator;
    var map = try SpatialHashMap.init(allocator, 32);
    defer map.deinit();

    const pos = Vec2i{ .x = 5, .y = 10 };
    const cell = try map.getCell(pos);
    cell.data = 99;

    const retrieved = try map.getCell(pos);
    try std.testing.expectEqual(@as(u32, 99), retrieved.data);
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

    const handle = delegate.subscribe(Local.callback);
    delegate.broadcast(.{ 42 });

    try testing.expectEqual(@as(usize, 1), Local.call_count);
    try testing.expectEqual(@as(i32, 42), Local.last_value);

    try delegate.unsubscribe(handle);
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
