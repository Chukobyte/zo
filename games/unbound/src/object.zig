const std = @import("std");
const zo = @import("zo");
const component_systems = @import("component_systems.zig");
const global = @import("global.zig");

const math = zo.math;
const renderer = zo.renderer;
const delegate = zo.delegate;
const ecs = zo.ecs;

const Transform2D = math.Transform2D;
const Vec2 = math.Vec2;
const Rect2 = math.Rect2;
const Mat4 = math.Mat4;
const Dim2u = math.Dim2u;
const Font = renderer.Font;
const Texture = renderer.Texture;
const String = zo.string.HeapString;
const MultiLineString = zo.string.HeapMultiLineString;
const World = global.World;
const Node = World.Node;
const Entity = ecs.Entity;
const Transform2DComponent = component_systems.Transform2DComponent;
const SpriteComponent = component_systems.SpriteComponent;
const TextLabelComponent = component_systems.TextLabelComponent;
const UIEventComponent = component_systems.UIEventComponent;
const ColorRectComponent = component_systems.ColorRectComponent;
const NodeMatrixInterface = component_systems.NodeMatrixInterface;
const UIEventSystem = component_systems.UIEventSystem;
const OnClickResponse = component_systems.OnClickResponse;

const log = zo.log;

pub const SpriteClass = struct {};

pub const TextLabelClass = struct {};

pub const TextBoxClass = struct {};

pub const TextButtonClass = struct {
    const TextAlignmentH = enum {
        left,
        center,
        right
    };
    const TextAlignmentV = enum {
        top,
        center,
        bottom
    };

    text_box: *GameObject = undefined,
    alignment_h: TextAlignmentH = .left,
    alignment_v: TextAlignmentV = .top,
    alignment_padding: Vec2 = Vec2.Zero,

    /// Updates the text_box local position based on alignment
    pub fn refreshTextAlignment(self: *@This()) void {
        if (global.world.getComponent(self.text_box.node.entity, TextLabelComponent)) |text_label_comp| {
            const text_scale: f32 = 1.0; // TODO: Calculate from transform
            const text_box = &text_label_comp.class.text_box;
            if (text_box.text.lineCount() == 0) { return; }
            // Horizontal alignment
            const line_text: []const u8 = text_box.text.getLine(0) catch "";
            const text_width: f32 = text_label_comp.font.getTextWidth(line_text) * text_scale;
            const container_width: f32 = @floatFromInt(text_box.size.w);
            const space_from_left: f32 = if (container_width > text_width) container_width - text_width else container_width;
            const left_padding: f32 = switch (self.alignment_h) {
                .left => 0.0,
                .center => space_from_left / 2.0,
                .right => space_from_left,
            };
            // Vertical alignment
            const container_height: f32 = @floatFromInt(text_box.size.h);
            const text_height: f32 = text_label_comp.font.text_height * text_scale;
            const space_from_top: f32 = if (container_height > text_height) container_height - text_height else container_height;
            const top_padding: f32 = switch (self.alignment_v) {
                .top => 0.0,
                .center => space_from_top / 2.0,
                .bottom => space_from_top,
            };
            // Update position
            const local_text_pos: Vec2 = .{ .x = left_padding + self.alignment_padding.x, .y = top_padding + self.alignment_padding.y };
            self.text_box.setLocalPosition(local_text_pos);
        }
    }
};

const GameObjectClass = union(enum) {
    sprite: SpriteClass,
    text_label: TextLabelClass,
    text_box: TextBoxClass,
    text_button: TextButtonClass,
};

fn GameObjectParams(ClassT: type) type {
    switch (ClassT) {
        SpriteClass => return struct {
            texture: *Texture,
            draw_source: Rect2,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
        TextLabelClass => return struct {
            font: *Font,
            text: ?[]const u8 = null,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
        TextBoxClass => return struct {
            font: *Font,
            size: Dim2u,
            text: ?[]const u8 = null,
            line_spacing: f32 = 0.0,
            use_background: bool = false,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
        TextButtonClass => return struct {
            collision: Rect2,
            font: *Font,
            text: ?[]const u8 = null,
            on_hover: ?*const fn(Entity) void = null,
            on_unhover: ?*const fn(Entity) void = null,
            on_click: ?*const fn(Entity) OnClickResponse = null,
            alignment_h: TextButtonClass.TextAlignmentH = .center,
            alignment_v: TextButtonClass.TextAlignmentV = .center,
            /// If additional padding adjustments are needed
            alignment_padding: Vec2 = Vec2.Zero,
            transform: Transform2D = Transform2D.Identity,
            z_index: i32 = 0,
        },
        else => @compileError("Must use Game Object Class type!"),
    }
}

pub const GameObject = struct {
    node: *Node,
    class: GameObjectClass,

    /// Initializes game object and add to scene
    pub fn initInScene(comptime ClassT: type, params: GameObjectParams(ClassT), parent: ?*Node, entity_interface: ?type) !*@This() {
        const new_node: *Node = try global.scene_system.createNodeAndEntity(.{ .interface = entity_interface orelse null });
        try global.scene_system.addNodeToScene(new_node, parent);
        return try init(new_node, ClassT, params);
    }

    /// Initializes game object, assumes it's already in the scene
    pub fn initFromNode(comptime ClassT: GameObjectClass, params: GameObjectParams(ClassT), node: *Node) !*@This() {
        return try init(node, ClassT, params);
    }

    pub fn deinit(self: *@This()) void {
        global.scene_system.removeNodeFromScene(self.node);
    }

    /// Overrides local position
    pub fn setLocalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.local.position = pos;
        transform_comp.is_global_dirty = true;
        global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, self.node);
        self.onMovementUpdate("set local position");
    }

    /// Updates local position (add to it)
    pub fn updateLocalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.local.position = transform_comp.local.position.add(&pos);
        transform_comp.is_global_dirty = true;
        global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, self.node);
        self.onMovementUpdate("update local position");
    }

    /// Overrides global position
    pub fn setGlobalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.global.position = pos;
        transform_comp.global_matrix = transform_comp.global.toMat4();
        global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(self.node.entity).?);
        self.onMovementUpdate("set global position");
    }

    /// Updates global position (add to it)
    pub fn updateGlobalPosition(self: *@This(), pos: Vec2) void {
        const transform_comp = global.world.getComponent(self.node.entity, Transform2DComponent).?;
        transform_comp.global.position = transform_comp.global.position.add(&pos);
        transform_comp.global_matrix = transform_comp.global.toMat4();
        global.scene_system.updateNodeLocalMatrix(NodeMatrixInterface, global.scene_system.getNode(self.node.entity).?);
        self.onMovementUpdate("update global position");
    }

    pub inline fn isValid(self: *const @This()) bool {
        return global.scene_system.isNodeValid(self.node);
    }

    fn init(node: *Node, comptime ClassT: type, params: GameObjectParams(ClassT)) !*@This() {
        var game_object: *@This() = try GameObjectSystem.instance.?.initObject(node.entity);
        game_object.node = node;
        // Setup class specific object components and class properties
        switch (ClassT) {
            SpriteClass => {
                try global.world.setComponent(node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                try global.world.setComponent(node.entity, SpriteComponent, &.{ .texture = params.texture, .draw_source = params.draw_source });
                game_object.class = .{ .sprite = .{ } };
            },
            TextLabelClass => {
                try global.world.setComponent(node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                const text_string = if (params.text == null) String.init(global.allocator) else try String.initAndSetRaw(global.allocator, params.text.?);
                try global.world.setComponent(node.entity, TextLabelComponent, &.{ .class = .{ .label = .{ .text = text_string } }, .font = params.font });
                game_object.class = .{ .text_label = .{ } };
            },
            TextBoxClass => {
                try global.world.setComponent(node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                try global.world.setComponent(node.entity, TextLabelComponent, &.{ .class = .{ .text_box = .{ .text = MultiLineString.init(global.allocator), .size = params.size, .line_spacing = params.line_spacing } }, .font = params.font });
                if (params.text) |text| {
                    const transform_comp = global.world.getComponent(node.entity, Transform2DComponent).?;
                    const text_label_comp = global.world.getComponent(node.entity, TextLabelComponent).?;
                    try text_label_comp.class.text_box.setText(params.font, text, transform_comp.global.scale.x);
                    game_object.class = .{ .text_box = .{ } };
                }
                if (params.use_background) {
                    try global.world.setComponent(node.entity, ColorRectComponent, &.{ .size = .{ .w = @floatFromInt(params.size.w), .h = @floatFromInt(params.size.h) }, .color = .{ .r = 0.4, .g = 0.4, .b = 0.4 } });
                }
            },
            TextButtonClass => {
                try global.world.setComponent(node.entity, Transform2DComponent, &.{ .local = params.transform, .z_index = params.z_index });
                try global.world.setComponent(node.entity, UIEventComponent, &.{ .collider = params.collision, .on_hover = params.on_hover, .on_unhover = params.on_unhover, .on_click = params.on_click });
                try global.world.setComponent(node.entity, ColorRectComponent, &.{ .size = .{ .w = params.collision.w, .h = params.collision.h }, .color = .{ .r = 0.4, .g = 0.4, .b = 0.4 } });
                const text_box = try initInScene(
                    TextBoxClass,
                    .{ .font = params.font, .size = .{ .w = @intFromFloat(params.collision.w), .h = @intFromFloat(params.collision.h) }, .text = params.text, .z_index = params.z_index + 1 },
                    node,
                    null
                );
                game_object.class = .{ .text_button = .{ .text_box = text_box, .alignment_h = params.alignment_h, .alignment_v = params.alignment_v, .alignment_padding = params.alignment_padding } };
                game_object.class.text_button.refreshTextAlignment();
            },
            else => @compileError("Must use Game Object Class type!"),
        }
        game_object.onMovementUpdate("init");
        return game_object;
    }

    fn onMovementUpdate(self: *@This(), context: []const u8) void {
        if (global.world.hasComponent(self.node.entity,UIEventComponent)) {
            const ui_system: *UIEventSystem = global.world.getSystemInstance(UIEventSystem).?;
            ui_system.onUpdatePosition(self.node.entity) catch { log(.critical, "Failed to {s}!  Node = {any}", .{ context, self.node }); };
        }
    }
};

/// Used to keep track of GameObject pointers mapped to entities and to handle callbacks
pub const GameObjectSystem = struct {
    var instance: ?@This() = null;
    var on_entity_deinit_handle: ?delegate.SubscriberHandle = null;

    objects: std.AutoHashMap(Entity, GameObject),

    pub fn init(allocator: std.mem.Allocator) !*@This() {
        instance = @This(){ .objects = std.AutoHashMap(Entity, GameObject).init(allocator) };
        try instance.?.objects.ensureTotalCapacity(100);
        on_entity_deinit_handle = try global.world.on_entity_deinit.subscribe(onEntityDeinit);
        return &instance.?;
    }

    pub fn deinit(self: *@This()) void {
        if (on_entity_deinit_handle) |handle| {
            global.world.on_entity_deinit.unsubscribe(handle);
            self.objects.deinit();
            on_entity_deinit_handle = null;
        }
    }

    pub fn initObject(self: *@This(), entity: Entity) !*GameObject {
        const result = try self.objects.getOrPut(entity);
        return result.value_ptr;
    }

    pub fn onEntityDeinit(entity: Entity) void {
        if (instance) |*self| {
            _ = self.objects.remove(entity);
        }
    }
};
