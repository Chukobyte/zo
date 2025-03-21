const zo = @import("zo");
const component_systems = @import("component_systems.zig");
const global = @import("global.zig");

const math = zo.math;
const renderer = zo.renderer;

const Transform2D = math.Transform2D;
const Vec2 = math.Vec2;
const Rect2 = math.Rect2;
const Mat4 = math.Mat4;
const Font = renderer.Font;
const Texture = renderer.Texture;
const String = zo.string.HeapString;
const World = global.World;
const Node = World.Node;
const Transform2DComponent = component_systems.Transform2DComponent;
const SpriteComponent = component_systems.SpriteComponent;
const TextLabelComponent = component_systems.TextLabelComponent;
const NodeMatrixInterface = component_systems.NodeMatrixInterface;

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

pub const GameObject = struct {
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
