//! All logic related specifically to the game prototype

const std = @import("std");
const zo = @import("zo");
const game = @import("game.zig");
const component_systems = @import("component_systems.zig");
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
const Dim2 = math.Dim2;
const Dim2i = math.Dim2i;
const Mat4 = math.Mat4;
const LinearColor = math.LinearColor;
const Texture = renderer.Texture;
const Font = renderer.Font;
const AudioSource = audio.AudioSource;
const String = zo.string.String4;
const World = global.World;
const SceneSystem = global.SceneSystem;
const Node = World.Node;
const Transform2DComponent = component_systems.Transform2DComponent;
const SpriteComponent = component_systems.SpriteComponent;
const TextLabelComponent = component_systems.TextLabelComponent;
const NodeMatrixInterface = component_systems.NodeMatrixInterface;

const log = zo.log;

const SpriteObject = struct {};
const TextLabelObject = struct {};

const GameObjectClass = union(enum) {
    sprite: SpriteObject,
    text_label: TextLabelObject,
};

fn GameObjectParams(object_class: GameObjectClass) type {
    switch (object_class) {
        .sprite => return struct {
            texture: *Texture,
            draw_source: Rect2,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
        .text_label => return struct {
            text: []const u8,
            font: *Font,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
    }
}

const GameObject = struct {
    node: *Node,
    class: GameObjectClass,

    /// Initializes game object and add to scene
    pub fn initInScene(comptime object_class: GameObjectClass, params: GameObjectParams(object_class), parent: ?*Node, entity_interface: ?type) !@This() {
        const new_node: *Node = try global.scene_system.createNodeAndEntity(.{ .interface = entity_interface orelse null });
        try global.scene_system.addNodeToScene(new_node, parent);
        var game_object: GameObject = @This(){
            .node = new_node,
            .class = object_class,
        };
        try game_object.setupClassAndComponents(object_class, params);
        return game_object;
    }

    /// Initializes game object, assumes it's already in the scene
    pub fn initFromNode(comptime object_class: GameObjectClass, params: GameObjectParams(object_class), node: *Node) !@This() {
        var game_object: GameObject = @This(){
            .node = node,
            .class = object_class,
        };
        try game_object.setupClassAndComponents(object_class, params);
        return game_object;
    }

    pub fn deinit(self: *@This()) void {
        global.scene_system.removeNodeFromScene(self.node);
    }

    /// Overrides local position
    pub fn setLocalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.local.position = pos;
        transform_comp.is_global_dirty = true;
    }
    /// Updates local position (add to it)
    pub fn updateLocalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.local.position = transform_comp.local.position.add(&pos);
        transform_comp.is_global_dirty = true;
    }
    /// Overrides global position
    pub fn setGlobalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.global.position = pos;
        transform_comp.global_matrix = transform_comp.global.toMat4();
        global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(self.node.entity).?);
    }
    /// Updates global position (add to it)
    pub fn updateGlobalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.global.position = transform_comp.global.position.add(&pos);
        transform_comp.global_matrix = transform_comp.global.toMat4();
        global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(self.node.entity).?);
    }

    pub inline fn isValid(self: *const @This()) bool {
        return global.scene_system.isNodeValid(self.node);
    }

    fn setupClassAndComponents(self: *@This(), comptime object_class: GameObjectClass, params: GameObjectParams(object_class)) !void {
        switch (object_class) {
            .sprite => {
                self.class = .{ .sprite = SpriteObject{} };
                try global.world.setComponent(self.node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                try global.world.setComponent(self.node.entity, SpriteComponent, &.{ .texture = params.texture, .draw_source = params.draw_source });
            },
            .text_label => {
                self.class = .{ .text_label = TextLabelObject{} };
                try global.world.setComponent(self.node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                try global.world.setComponent(self.node.entity, TextLabelComponent, &.{ .text = try String.initAndSetRaw(global.allocator, params.text), .font = params.font });
            },
        }
    }
};

pub const MainSceneDefinition = struct {
    pub fn getNodeInterface() type {
        return MainEntity;
    }
};

pub const MainEntity = struct {
    var main_object: GameObject = undefined;
    var virginia_text: GameObject = undefined;
    var colonial_text: GameObject = undefined;

    pub fn init(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world; _ = entity;
    }
    pub fn deinit(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn onEnterScene(self: *@This(), world: *World, entity: ecs.Entity) !void {
        _ = self; _ = world;
        // Setup main entity
        const main_node = global.scene_system.getNode(entity).?;
        const map_texuture_size: Dim2 = .{ .w = @floatFromInt(global.assets.textures.map.width), .h = @floatFromInt(global.assets.textures.map.height) };
        main_object = try GameObject.initFromNode(
            .sprite,
            .{ .texture = &global.assets.textures.map, .draw_source = .{ .x = 0.0, .y = 0.0, .w = map_texuture_size.w, .h = map_texuture_size.h } },
            main_node
        );
        virginia_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Virginia", .font = &global.assets.fonts.verdana, .transform = .{ .position = .{ .x = 100.0, .y = 340.0 } }, .z_index = 2 },
            main_node,
            null
        );
        colonial_text = try GameObject.initInScene(
            .text_label,
            .{ .text = "Colonial America", .font = &global.assets.fonts.verdana, .transform = .{ .position = .{ .x = 200.0, .y = 200.0 } }, .z_index = 1 },
            main_node,
            null
        );
    }
    pub fn onExitScene(self: *@This(), world: *World, entity: ecs.Entity) void {
        _ = self; _ = world; _ = entity;
    }
    pub fn update(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity; _ = delta_seconds;
        if (input.is_key_just_pressed(.{ .key = .keyboard_space })) {
            try global.assets.audio.rainbow_orb.play(false);
        }

        if (input.is_key_just_pressed(.{ .key = .keyboard_escape })) {
            zo.quit();
        }
    }
    pub fn fixedUpdate(self: *@This(), world: *World, entity: ecs.Entity, delta_seconds: f32) !void {
        _ = self; _ = world; _ = entity;
        const move_speed: f32 = 100;
        if (input.is_key_pressed(.{ .key = .keyboard_a })) {
            main_object.updateLocalPosition(.{ .x = -move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_d })) {
            main_object.updateLocalPosition(.{ .x = move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_s })) {
            main_object.updateLocalPosition(.{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_w })) {
            main_object.updateLocalPosition(.{ .x = 0.0, .y = -move_speed * delta_seconds });
        }

        if (input.is_key_pressed(.{ .key = .keyboard_l })) {
            virginia_text.updateGlobalPosition(.{ .x = move_speed * delta_seconds, .y = 0.0 });
        } else if (input.is_key_pressed(.{ .key = .keyboard_j })) {
            virginia_text.updateGlobalPosition(.{ .x = -move_speed * delta_seconds, .y = 0.0 });
        }
        if (input.is_key_pressed(.{ .key = .keyboard_k })) {
            virginia_text.updateGlobalPosition(.{ .x = 0.0, .y = move_speed * delta_seconds });
        } else if (input.is_key_pressed(.{ .key = .keyboard_i })) {
            virginia_text.updateGlobalPosition(.{ .x = 0.0, .y = -move_speed * delta_seconds });
        }
    }
};

pub const GameMain = struct {

    pub fn init() !void {
        try global.init(global.allocator);
        global.scene_system.changeScene(MainSceneDefinition);
    }

    pub fn deinit() void {
        global.deinit();
    }

    pub fn preTick() !void {
        try global.world.preTick();
    }

    pub fn update(delta_seconds: f32) !void {
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
