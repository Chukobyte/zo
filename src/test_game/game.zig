//! All logic related specifically to the game prototype

const std = @import("std");

const static_assets = @import("static_assets");

const zo = @import("zo");

const game = @import("game.zig");
const global = @import("global.zig");

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

// const String = zo.string.String;
const String = zo.string.DynamicString(4, false);

const World = global.World;
const SceneSystem = global.SceneSystem;
const Node = World.Node;

const log = zo.log;

pub const Transform2DComponent = struct {
    local: Transform2D = Transform2D.Identity,
    global: Transform2D = Transform2D.Identity,
    global_matrix: Mat4 = Mat4.Identity,
    is_global_dirty: bool = false,
    z_index: i32 = 0,
    is_z_index_relative_to_parent: bool = true,
    in_screen_space: bool = false,
};

pub const SpriteComponent = struct {
    texture: *Texture,
    draw_source: Rect2,
    origin: Vec2 = Vec2.Zero,
    flip_h: bool = false,
    flip_v: bool = false,
    modulate: LinearColor = LinearColor.White,
};

pub const TextLabelComponent = struct {
    text: String,
    font: *Font,
    color: LinearColor = LinearColor.White,
};

const NodeMatrixInterface = struct {
    pub fn setGlobalMatrixDirty(node: *Node, is_dirty: bool) void {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            transform_comp.is_global_dirty = is_dirty;
        }
    }

    pub fn isGlobalMatrixDirty(node: *Node) bool {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            return transform_comp.is_global_dirty;
        }
        log(.warn, "Attempting to check if global matrix is dirty, to node {any} which doesn't have a transform component!", .{node});
        return false;
    }

    pub fn setGlobalMatrix(node: *Node, matrix: *const Mat4) void {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            transform_comp.global_matrix = matrix.*;
            transform_comp.global.fromMat4(matrix);
        }
    }

    pub fn getGlobalMatrix(node: *Node) Mat4 {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            return transform_comp.global_matrix;
        }
        return Mat4.Identity;
    }

    pub fn setLocalMatrix(node: *Node, matrix: *const Mat4) void {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            transform_comp.local.fromMat4(matrix);
            transform_comp.is_global_dirty = true;
        }
    }

    pub fn globalMatrixMultiply(node: *Node, matrix: *const Mat4) Mat4 {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            return transform_comp.global_matrix.mul(matrix);
        }
        log(.warn, "Attempting to multiply node {any} which doesn't have a transform component!", .{node});
        return Mat4.Identity;
    }

    pub fn getLocalTransform(node: *Node) Mat4 {
        if (global.world.getComponent(node.entity, Transform2DComponent)) |transform_comp| {
            var local_transform = transform_comp.local;
            return local_transform.toMat4();
        }
        log(.warn, "Attempting to get local transform of node {any} which doesn't have a transform component!", .{node});
        return Mat4.Identity;
    }
};

pub const SpriteRenderingSystem = struct {
    pub fn postWorldTick(_: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(&.{ Transform2DComponent, SpriteComponent });
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (global.scene_system.getNode(iter.getEntity())) |node| {
                global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, node);
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

pub const TextRenderingSystem = struct {
    pub fn postWorldTick(_: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(&.{ Transform2DComponent, TextLabelComponent });
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (global.scene_system.getNode(iter.getEntity())) |node| {
                global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, node);
                const transform_comp = iter.getComponent(Transform2DComponent);
                const text_label_comp = iter.getComponent(TextLabelComponent);
                try renderer.queueTextDraw(&.{
                    .text = text_label_comp.text.getCString(),
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

const SpriteObject = struct {};
const TextLabelObject = struct {};

const GameObjectClass = union(enum) {
    sprite: SpriteObject,
    text: TextLabelObject,
};

const GameObject = struct {
    class: GameObjectClass,
};

const allocator: std.mem.Allocator = std.heap.page_allocator;
var map_textue: Texture = undefined;
var verdana_font: Font = undefined;
var rainbow_orb_audio: AudioSource = undefined;

pub const MainEntity = struct {
    var virginia_text_node: *Node = undefined;
    var colonial_text_node: *Node = undefined;

    pub fn init(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world; _ = entity;
    }
    pub fn deinit(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self;
        const main_node = global.scene_system.getNode(entity).?;
        // Setup main entity
        try world.setComponent(entity, Transform2DComponent, &.{});
        try world.setComponent(entity, SpriteComponent, &.{
            .texture = &map_textue,
            .draw_source = .{ .x = 0.0, .y = 0.0, .w = @floatFromInt(map_textue.width), .h = @floatFromInt(map_textue.height) },
        });

        // Virgina text entity
        virginia_text_node = try global.scene_system.createNodeAndEntity(null);
        try world.setComponent(virginia_text_node.entity, Transform2DComponent, &.{ .local = .{ .position = .{ .x = 100.0, .y = 340.0 } }, .global = .{ .position = .{ .x = 100.0, .y = 340.0 } }, .z_index = 2, });
        try world.setComponent(virginia_text_node.entity, TextLabelComponent, &.{ .text = try String.initAndSet(allocator, "Virginia", .{}), .font = &verdana_font });
        try global.scene_system.addNodeToScene(virginia_text_node, main_node);

        // Colonial text entity
        colonial_text_node = try global.scene_system.createNodeAndEntity(null);
        try world.setComponent(colonial_text_node.entity, Transform2DComponent, &.{ .local = .{ .position = .{ .x = 200.0, .y = 200.0 } }, .global = .{ .position = .{ .x = 200.0, .y = 200.0 } }, .z_index = 1, });
        try world.setComponent(colonial_text_node.entity, TextLabelComponent, &.{ .text = try String.initAndSet(allocator, "Colonial America", .{}), .font = &verdana_font });
        try global.scene_system.addNodeToScene(colonial_text_node, main_node);
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
    }
    pub fn fixedUpdate(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world;
        const Local = struct {
            /// Overrides local position
            fn setLocalPosition(e: ecs.Entity, pos: Vec2) void {
                const transform_comp = global.world.getComponent(e, Transform2DComponent).?;
                transform_comp.local.position = pos;
                transform_comp.is_global_dirty = true;
            }
            /// Updates local position (add to it)
            fn updateLocalPosition(e: ecs.Entity, pos: Vec2) void {
                const transform_comp = global.world.getComponent(e, Transform2DComponent).?;
                transform_comp.local.position = transform_comp.local.position.add(&pos);
                transform_comp.is_global_dirty = true;
            }
            /// Overrides global position
            fn setGlobalPosition(e: ecs.Entity, pos: Vec2) void {
                const transform_comp = global.world.getComponent(e, Transform2DComponent).?;
                transform_comp.global.position = pos;
                transform_comp.global_matrix = transform_comp.global.toMat4();
                global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(e).?);
            }
            /// Updates global position (add to it)
            fn updateGlobalPosition(e: ecs.Entity, pos: Vec2) void {
                const transform_comp = global.world.getComponent(e, Transform2DComponent).?;
                transform_comp.global.position = transform_comp.global.position.add(&pos);
                transform_comp.global_matrix = transform_comp.global.toMat4();
                global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(e).?);
            }
        };
        const move_speed: f32 = 100;
        if (input.is_key_pressed(.{ .key = .keyboard_a })) {
            Local.updateLocalPosition(entity, .{ .x = -move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_d })) {
            Local.updateLocalPosition(entity, .{ .x = move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_s })) {
            Local.updateLocalPosition(entity, .{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_w })) {
            Local.updateLocalPosition(entity, .{ .x = 0.0, .y = -move_speed * delta_seconds });
        }

        if (input.is_key_pressed(.{ .key = .keyboard_l })) {
            Local.updateGlobalPosition(virginia_text_node.entity, .{ .x = move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_j })) {
            Local.updateGlobalPosition(virginia_text_node.entity, .{ .x = -move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_k })) {
            Local.updateGlobalPosition(virginia_text_node.entity, .{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_i })) {
            Local.updateGlobalPosition(virginia_text_node.entity, .{ .x = 0.0, .y = -move_speed * delta_seconds });
        }
    }
};

pub const GameMain = struct {

    pub fn init() !void {
        try global.init(allocator);
        global.scene_system.changeScene("Default");
        map_textue = try Texture.initFromMemory2(std.heap.page_allocator, static_assets.map_texture, true);
        verdana_font = try Font.initFromMemory2(static_assets.default_font, 16, true);
        rainbow_orb_audio = try AudioSource.initWavFromMemory2(static_assets.rainbow_orb_audio);
    }

    pub fn deinit() void {
        map_textue.deinit();
        verdana_font.deinit();
        rainbow_orb_audio.deinit();
        global.deinit();
    }

    pub fn preTick() !void {
        try global.world.preTick();
    }

    pub fn update(delta_seconds: f32) !void {
        // if (input.is_key_just_pressed(.{ .key = .keyboard_a })) {
        //     global.scene_system.changeScene("Default");
        // }
        try global.scene_system.newFrame();
        try global.world.update(delta_seconds);
    }

    pub fn fixedUpdate(delta_seconds: f32) !void {
        try global.world.fixedUpdate(delta_seconds);
    }

    pub fn postTick() !void {
        try global.world.postTick();
    }
};
