///! World and scene related stuff

const std = @import("std");
const zo = @import("zo");

const game = @import("game.zig");

const ecs = zo.ecs;

pub const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{ game.MainEntity },
    .components = &.{ game.Transform2DComponent, game.SpriteComponent, game.TextLabelComponent },
    .systems = &.{ game.SpriteRenderingSystem, game.TextRenderingSystem },
    .archetypes = @as([]const []const type, &.{
        &.{ game.Transform2DComponent, game.SpriteComponent },
        &.{ game.Transform2DComponent, game.TextLabelComponent },
    }),
});
pub const SceneSystem = World.SceneSystem(.{ .definitions = &[_]ecs.SceneDefinition{ .{ .name = "Default", .node_interface = game.MainEntity, } } });

pub var world: World = undefined;
pub var scene_system: SceneSystem = undefined;

pub fn init(allocator: std.mem.Allocator) !void {
    world = try World.init(allocator);
    scene_system = SceneSystem.init(&world);
}

pub fn deinit() void {
    scene_system.deinit();
    world.deinit();
}
