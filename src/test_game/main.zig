const std = @import("std");

const static_assets = @import("static_assets");

const zo = @import("zo");

const game = @import("game.zig");

const ecs = zo.ecs;
const renderer = zo.renderer;
const audio = zo.audio;
const window = zo.window;
const input = zo.input;
const math = zo.math;

const Vec2 = math.Vec2;
const Rect2 = math.Rect2;
const Transform2D = math.Transform2D;
const Dim2i = math.Dim2i;
const Mat4 = math.Mat4;
const LinearColor = math.LinearColor;
const Texture = renderer.Texture;
const Font = renderer.Font;

const AudioSource = audio.AudioSource;

const String = zo.string.String;

const log = zo.log;

const Transform2DComponent = struct {
    local: Transform2D = Transform2D.Identity,
    global: Transform2D = Transform2D.Identity,
    global_matrix: Mat4 = Mat4.Identity,
    is_global_dirty: bool = false,
    z_index: i32 = 0,
    is_z_index_relative_to_parent: bool = true,
    in_screen_space: bool = false,
};

const SpriteComponent = struct {
    texture: *Texture,
    draw_source: Rect2,
    origin: Vec2 = Vec2.Zero,
    flip_h: bool = false,
    flip_v: bool = false,
    modulate: LinearColor = LinearColor.White,
};

const TextLabelComponent = struct {
    text: String,
    font: *Font,
    color: LinearColor = LinearColor.White,
};

const NodeGlobalMatrixInterface = struct {
    pub fn setGlobalMatrixDirty(node: *Node, is_dirty: bool) void {
        if (global_world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            transform_comp.is_global_dirty = is_dirty;
        }
    }

    pub fn isGlobalMatrixDirty(node: *Node) bool {
        if (global_world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            return transform_comp.is_global_dirty;
        }
        log(.warn, "Attempting to check if global matrix is dirty, to node {any} which doesn't have a transform component!", .{node});
        return false;
    }

    pub fn setGlobalMatrix(node: *Node, matrix: *const Mat4) void {
        if (global_world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            transform_comp.global_matrix = matrix.*;
        }
    }

    pub fn globalMatrixMultiply(node: *Node, matrix: *const Mat4) Mat4 {
        if (global_world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            return transform_comp.global_matrix.mul(matrix);
        }
        log(.warn, "Attempting to multiply node {any} which doesn't have a transform component!", .{node});
        return Mat4.Identity;
    }

    pub fn getLocalTransform(node: *Node) Mat4 {
        if (global_world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            var local_transform = transform_comp.local;
            const dest_size = getRenderableSize(node);
            local_transform.scale.x *= @floatFromInt(dest_size.w);
            local_transform.scale.y *= @floatFromInt(dest_size.h);
            return local_transform.toMat4();
        }
        log(.warn, "Attempting to get local transform of node {any} which doesn't have a transform component!", .{node});
        return Mat4.Identity;
    }

    fn getRenderableSize(node: *Node) Dim2i {
        if (global_world.getComponent(node.entity, SpriteComponent)) |sprite_comp| {
            return Dim2i{ .w = sprite_comp.texture.width, .h = sprite_comp.texture.height };
        }
        return Dim2i{ .w = 1, .h = 1 };
    }
};

const SpriteRenderingSystem = struct {
    pub fn postWorldTick(_: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(&.{ Transform2DComponent, SpriteComponent });
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (scene_system.getNode(iter.getEntity())) |node| {
                scene_system.updateNodeGlobalMatrix(NodeGlobalMatrixInterface, node);
                const transform_comp = iter.getComponent(Transform2DComponent);
                const sprite_comp = iter.getComponent(SpriteComponent);
                try renderer.queueSpriteDraw(&.{
                    .texture = sprite_comp.texture,
                    .source_rect = sprite_comp.draw_source,
                    .global_matrix = &transform_comp.global_matrix,
                    .modulate = sprite_comp.modulate,
                    .flip_h = sprite_comp.flip_h,
                    .flip_v = sprite_comp.flip_v,
                    .z_index =  transform_comp.z_index,
                });
            }
        }
    }
};

const TextRenderingSystem = struct {
    pub fn postWorldTick(_: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(&.{ Transform2DComponent, TextLabelComponent });
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (scene_system.getNode(iter.getEntity())) |node| {
                scene_system.updateNodeGlobalMatrix(NodeGlobalMatrixInterface, node);
                const transform_comp = iter.getComponent(Transform2DComponent);
                const text_label_comp = iter.getComponent(TextLabelComponent);
                try renderer.queueTextDraw(&.{
                    .text = text_label_comp.text.get(),
                    .font = text_label_comp.font,
                    .position = transform_comp.global.position,
                    .scale = transform_comp.global.scale.x, // Only recongnizes x scale for now
                    .color = text_label_comp.color,
                    .z_index =  transform_comp.z_index,
                });
            }
        }
    }
};

const World = ecs.ECSWorld(.{
    .entity_interfaces = &.{ MainEntity },
    // .components = &.{ Transform2DComponent, SpriteComponent, TextLabelComponent },
    .components = &.{ Transform2DComponent, SpriteComponent },
    // .systems = &.{ SpriteRenderingSystem, TextRenderingSystem },
    .systems = &.{ SpriteRenderingSystem },
    .archetypes = @as([]const []const type, &.{
        &.{ Transform2DComponent, SpriteComponent },
        // &.{ Transform2DComponent, TextLabelComponent },
    }),
});
const SceneSystem = World.SceneSystem(.{ .definitions = &[_]ecs.SceneDefinition{ .{ .name = "Default", .node_interface = MainEntity, } } });
const Node = World.Node;

const allocator: std.mem.Allocator = std.heap.page_allocator;
var map_textue: Texture = undefined;
var verdana_font: Font = undefined;
var rainbow_orb_audio: AudioSource = undefined;
var global_world: World = undefined;
var scene_system: SceneSystem = undefined;

const MainEntity = struct {
    pub fn init(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world; _ = entity;
    }
    pub fn deinit(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self;
        try world.setComponent(entity, Transform2DComponent, &.{});
        try world.setComponent(entity, SpriteComponent, &.{
            .texture = &map_textue,
            .draw_source = .{ .x = 0.0, .y = 0.0, .w = @floatFromInt(map_textue.width), .h = @floatFromInt(map_textue.height) }
        });
    }
    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            try rainbow_orb_audio.play(false);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }

        // try renderer.queueSpriteDraw(&.{
        //     .texture = &map_textue,
        //     .source_rect = .{ .x = 0.0, .y = 0.0, .w = 640.0, .h = 360.0 },
        // });

        try renderer.queueTextDraw(&.{
            .text = "Virginia",
            .font = &verdana_font,
            .position = .{ .x = 100.0, .y = 340.0 },
            .z_index = 2,
        });

        try renderer.queueTextDraw(&.{
            .text = "Colonial America",
            .font = &verdana_font,
            .position = .{ .x = 200.0, .y = 200.0 },
            .z_index = 1,
        });
    }
    pub fn fixed_update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
    }
};

const GameMain = struct {

    const GameObject = struct {
        node: *ecs.Node,

        pub inline fn isValid(self: *const @This()) bool {
            scene_system.isNodeValid(self.node);
        }
    };

    pub fn init() !void {
        global_world = try World.init(allocator);
        scene_system = SceneSystem.init(&global_world);
        scene_system.changeScene("Default");
        map_textue = try Texture.initFromMemory2(std.heap.page_allocator, static_assets.map_texture, true);
        verdana_font = try Font.initFromMemory2(static_assets.default_font, 16, true);
        rainbow_orb_audio = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio);
    }

    pub fn deinit() void {
        map_textue.deinit();
        verdana_font.deinit();
        rainbow_orb_audio.deinit();
        scene_system.deinit();
        global_world.deinit();
    }

    pub fn preTick() !void {
        try global_world.preTick();
    }

    pub fn update(delta_seconds: f32) !void {
        if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
            scene_system.changeScene("Default");
        }
        try scene_system.newFrame();
        try global_world.update(delta_seconds);
    }

    pub fn fixedUpdate(delta_seconds: f32) !void {
        try global_world.fixedUpdate(delta_seconds);
    }

    pub fn postTick() !void {
        try global_world.postTick();
    }

};

pub fn main() !void {
    try zo.run(.{
        .window = .{
            .title = "Test Game",
            .pos = .{ .x = 100.0, .y = 100.0 },
            .size = .{ .w = 640, .h = 360 },
        },
        .game = GameMain,
        .target_fps = 60,
    });
}
