const std = @import("std");
const zo = @import("zo");
const global = @import("global.zig");

const math = zo.math;
const renderer = zo.renderer;
const input = zo.input;
const window = zo.window;
const audio = zo.audio;
const FixedDelegate = zo.delegate.FixedDelegate;

const Transform2D = math.Transform2D;
const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Rect2 = math.Rect2;
const LinearColor = math.LinearColor;
const Mat4 = math.Mat4;
const Dim2 = math.Dim2;
const Dim2u = math.Dim2u;
const Font = renderer.Font;
const Texture = renderer.Texture;
const AudioSource = audio.AudioSource;
const String = zo.string.HeapString;
const MultiLineString = zo.string.HeapMultiLineString;
const World = global.World;
const Node = World.Node;
const Entity = zo.ecs.Entity;
const SpatialHashMap = zo.spatial_hash_map.SpatialHashMap;

const log = zo.log;

pub const Transform2DComponent = struct {
    local: Transform2D = Transform2D.Identity,
    global: Transform2D = Transform2D.Identity,
    global_matrix: Mat4 = Mat4.Identity,
    is_global_dirty: bool = true,
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
    const LabelClass = struct {
        text: String,
    };
    const TextBoxClass = struct {
        text: MultiLineString,
        size: Dim2u,
        line_spacing: f32 = 0.0,

        const Word = struct {
            text: String,
            width: f32 = 0.0,
        };

        pub fn setText(self: *@This(), font: *const Font, text: []const u8, scale: f32) !void {
            self.text.clear();
            const max_line_width = @as(f32, @floatFromInt(self.size.w));
            var space_width: f32 = 0;
            var line_width: f32 = 0.0;
            var line_text = String.init(self.text.allocator);
            var words = try self.getWords(font, text, scale, &space_width);
            for (words.items) |*word| {
                // Handle new line
                if (!line_text.isEmpty() and word.text.buffer[0] == '\n') {
                    try self.text.addLine(line_text.get());
                    line_text.clear();
                    line_width = 0;
                }
                else if (line_width + word.width + space_width >= max_line_width) {
                    try self.text.addLine(line_text.get());
                    try line_text.setRaw(word.text.get());
                    line_width = word.width;
                } else {
                    if (line_text.isEmpty()) {
                        try line_text.setRaw(word.text.get());
                        line_width = word.width;
                    } else {
                        var current_text = try line_text.copy();
                        defer current_text.deinit();
                        try line_text.appendChar(' ');
                        try line_text.appendRaw(word.text.get());
                        line_width += word.width + space_width;
                    }
                }
            }
            if (!line_text.isEmpty()) {
                try self.text.addLine(line_text.get());
            }
            // Clean up
            for (words.items) |*word| {
                word.text.deinit();
            }
            words.deinit();
        }

        fn getWords(self: *@This(), font: *const Font, text: []const u8, scale: f32, space_width: ?*f32) !std.ArrayList(Word) {
            var words = std.ArrayList(Word).init(self.text.allocator);
            var current_word: Word = .{ .text = String.init(self.text.allocator) };
            for (text) |c| {
                const index: usize = @intCast(c);
                if (index >= font.characters.len) { continue; }
                const ch = font.characters[index];
                // ch.advance is in 26.6 fixed point, so we shift right by 6 to get pixels.
                const advance_pixels: f32 = @floatFromInt(ch.advance >> 6);
                const new_char_width: f32 = advance_pixels * scale;

                if (c == ' ') {
                    try words.append(current_word);
                    current_word.text = String.init(self.text.allocator);
                    current_word.width = 0.0;
                } else {
                    if (c == '\n') {
                        try words.append(current_word);
                        current_word.text = try String.initAndSetRaw(self.text.allocator, "\n");
                        current_word.width = 0.0;
                        try words.append(current_word);
                        current_word.text = String.init(self.text.allocator);
                    } else {
                        try current_word.text.appendChar(c);
                        current_word.width += new_char_width;
                    }
                }
            }
            if (current_word.width > 0.0) {
                try words.append(current_word);
            } else {
                current_word.text.deinit();
            }
            if (space_width) |s_width| {
                const ch = font.characters[@intCast(' ')];
                const advance_pixels: f32 = @floatFromInt(ch.advance >> 6);
                s_width.* = advance_pixels * scale;
            }
           return words;
        }
    };

    const Class = union(enum) {
        label: LabelClass,
        text_box: TextBoxClass,
    };

    class: Class,
    font: *Font,
    color: LinearColor = LinearColor.White,
};

pub const ColorRectComponent = struct {
    size: Dim2,
    color: LinearColor,
};

pub const NodeMatrixInterface = struct {
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
        const ComponentIterator = World.ArchetypeComponentIterator(getSignature());
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

    pub fn getSignature() []const type {
        return &.{ Transform2DComponent, SpriteComponent };
    }
};

pub const TextRenderingSystem = struct {
    pub fn postWorldTick(_: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(getSignature());
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (global.scene_system.getNode(iter.getEntity())) |node| {
                global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, node);
                const transform_comp = iter.getComponent(Transform2DComponent);
                const text_label_comp = iter.getComponent(TextLabelComponent);
                switch (text_label_comp.class) {
                    .label => {
                        try renderer.queueTextDraw(&.{
                            .text = text_label_comp.class.label.text.getCString(),
                            .font = text_label_comp.font,
                            .position = transform_comp.global.position,
                            .scale = transform_comp.global.scale.x, // Only recongnizes x scale for now
                            .color = text_label_comp.color,
                            .z_index =  transform_comp.z_index,
                        });
                    },
                    .text_box => {
                        var text_box = &text_label_comp.class.text_box;
                        const global_pos = transform_comp.global.position;
                        for (0..text_box.text.lines.items.len) |i| {
                            var line_string = &text_box.text.lines.items[i];
                            const line_height: f32 = (text_label_comp.font.text_height + text_box.line_spacing) * @as(f32, @floatFromInt(i));
                            const line_pos: Vec2 = .{ .x = global_pos.x, .y = global_pos.y + line_height };
                            try renderer.queueTextDraw(&.{
                                .text = line_string.getCString(),
                                .font = text_label_comp.font,
                                .position = line_pos,
                                .scale = transform_comp.global.scale.x, // Only recongnizes x scale for now
                                .color = text_label_comp.color,
                                .z_index =  transform_comp.z_index,
                            });
                        }
                    },
                }
            }
        }
    }

    pub fn onEntityUnregistered(_: *@This(), world: *World, entity: Entity) void {
        if (world.getComponent(entity, TextLabelComponent)) | text_label_comp| {
            switch (text_label_comp.class) {
                .label => text_label_comp.class.label.text.deinit(),
                .text_box => text_label_comp.class.text_box.text.deinit(),
            }
        }
    }

    pub fn getSignature() []const type {
        return &.{ Transform2DComponent, TextLabelComponent };
    }
};

pub const ColorRectSystem = struct {

    const draw_source: Rect2 = .{ .x = 0.0, .y = 0.0, .w = 1.0, .h = 1.0 };

    texture: Texture = undefined,

    pub fn init(self: *@This(), _: *World) !void {
        self.texture = try Texture.initWhiteSquare(global.allocator, true, .{ .w = 1, .h = 1 });
    }

    pub fn deinit(self: *@This(), _: *World) void {
        self.texture.deinit();
    }

    pub fn postWorldTick(self: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(getSignature());
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            if (global.scene_system.getNode(iter.getEntity())) |node| {
                global.scene_system.updateNodeGlobalMatrix(NodeMatrixInterface, node);
                const transform_comp = iter.getComponent(Transform2DComponent);
                const color_rect = iter.getComponent(ColorRectComponent);
                try renderer.queueSpriteDraw(&.{
                    .texture = &self.texture,
                    .source_rect = draw_source,
                    .global_matrix = &transform_comp.global_matrix,
                    .dest_size = color_rect.size,
                    .modulate = color_rect.color,
                    .flip_h = false,
                    .flip_v = false,
                    .z_index =  transform_comp.z_index - 1,
                });
            }
        }
    }

    pub fn getSignature() []const type {
        return &.{ Transform2DComponent, ColorRectComponent };
    }
};

pub const UIEventComponent = struct {
    pub const Style = struct {
        hover: ?LinearColor = null,
        unhover: ?LinearColor = null,
        click: ?LinearColor = null,
    };

    const default_style: Style = .{
        .hover = .{ .r = 0.6, .g = 0.6, .b = 0.6 },
        .unhover = .{ .r = 0.4, .g = 0.4, .b = 0.4 },
        .click = .{ .r = 0.8, .g = 0.8, .b = 0.8 },
    };

    collider: Rect2,
    on_hover: ?*const fn(Entity) void = null,
    on_unhover: ?*const fn(Entity) void = null,
    on_click: ?*const fn(Entity) void = null,
    style: Style = default_style,
    is_mouse_hovering: bool = false,
};

pub const UIEventSystem = struct {
    const EntitySpatialHashMap = SpatialHashMap(Entity);
    const StyleType = enum {
        hover,
        unhover,
        click
    };

    spatial_hash_map: EntitySpatialHashMap = undefined,
    prev_mouse_pos: Vec2i = Vec2i.Zero,
    on_click_audio_override: ?*AudioSource = null,

    pub fn init(self: *@This(), _: *World) !void {
        self.spatial_hash_map = try EntitySpatialHashMap.init(global.allocator, 64);
    }

    pub fn deinit(self: *@This(), _: *World) void {
        self.spatial_hash_map.deinit();
    }

    pub fn onEntityRegistered(self: *@This(), _: *World, entity: Entity) void {
        self.onUpdatePosition(entity) catch { log(.critical, "Failed to update position on registered for entity = {d}", .{ entity }); };
    }

    pub fn preWorldTick(self: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(getSignature());

        const mouse_pos: Vec2i = input.getWorldMousePosition(window.getWindowSize(), renderer.getResolution());

        var has_moved = false;
        if (!self.prev_mouse_pos.equals(&mouse_pos)) {
            self.prev_mouse_pos = mouse_pos;
            has_moved = true;
        }

        const global_mouse_pos: Vec2 = .{ .x = @floatFromInt(mouse_pos.x), .y = @floatFromInt(mouse_pos.y) };
        const clicked_pressed: bool = input.isKeyPressed(.{ .key = .mouse_button_left });
        const just_clicked_pressed: bool = input.isKeyJustPressed(.{ .key = .mouse_button_left });
        var comp_iter = ComponentIterator.init(world);
        while (comp_iter.next()) |iter| {
            const entity = iter.getEntity();
            const transform_comp = iter.getComponent(Transform2DComponent);
            const event_comp = iter.getComponent(UIEventComponent);
            if (has_moved) {
                try self.updateState(entity, &global_mouse_pos, transform_comp, event_comp);
            }
            if (event_comp.is_mouse_hovering) {
                if (clicked_pressed) {
                    setStyleColor(.click, entity, event_comp);
                } else {
                    setStyleColor(.hover, entity, event_comp);
                }
                if (just_clicked_pressed) {
                    if (event_comp.on_click) |on_click| {
                        on_click(iter.getEntity());
                    }
                    var click_audio: *AudioSource = self.on_click_audio_override orelse &global.assets.audio.click;
                    try click_audio.play(false);
                    self.on_click_audio_override = null;
                }
            }
        }
    }

    pub fn onUpdatePosition(self: *@This(), entity: Entity) !void {
        if (global.world.getComponent(entity, Transform2DComponent)) |transform_comp| {
        if (global.world.getComponent(entity, UIEventComponent)) |event_comp| {
            const mouse_pos: Vec2i = input.getWorldMousePosition(window.getWindowSize(), renderer.getResolution());
            const global_mouse_pos: Vec2 = .{ .x = @floatFromInt(mouse_pos.x), .y = @floatFromInt(mouse_pos.y) };
            try self.updateState(entity, &global_mouse_pos, transform_comp, event_comp);
        }}
    }

    pub inline fn getClickedEntities(self: *@This(), pos: Vec2) []Entity {
        return self.spatial_hash_map.getObjects(pos);
    }

    pub fn getSignature() []const type {
        return &.{ Transform2DComponent, UIEventComponent };
    }

    fn updateState(self: *@This(), entity: Entity, global_mouse_pos: *const Vec2, transform_comp: *Transform2DComponent, event_comp: *UIEventComponent) !void {
        // Update spatial hash
        // TODO: Fix so it relies on global position
        const pos = &transform_comp.local.position;
        const spatial_collider: Rect2 = .{
            .x = pos.x + event_comp.collider.x, .y = pos.y + event_comp.collider.y,
            .w = event_comp.collider.w, .h = event_comp.collider.h,
        };
        try self.spatial_hash_map.updateObjectPosition(entity, spatial_collider);

        if (spatial_collider.doesPointOverlap(global_mouse_pos)) {
            if (!event_comp.is_mouse_hovering) {
                event_comp.is_mouse_hovering = true;
                setStyleColor(.hover, entity, event_comp);
                if (event_comp.on_hover) |on_hover| {
                    on_hover(entity);
                }
            }
        } else {
            if (event_comp.is_mouse_hovering) {
                event_comp.is_mouse_hovering = false;
                setStyleColor(.unhover, entity, event_comp);
                if (event_comp.on_unhover) |on_unhover| {
                    on_unhover(entity);
                }
            }
        }
    }

    fn setStyleColor(comptime style_type: StyleType, entity: Entity, event_comp: *UIEventComponent) void {
        if (global.world.getComponent(entity, ColorRectComponent)) |color_rect_comp| {
            switch (style_type) {
                .hover => {
                    if (event_comp.style.hover) |hover_color| {
                        color_rect_comp.color = hover_color;
                    }
                },
                .unhover => {
                    if (event_comp.style.unhover) |unhover_color| {
                        color_rect_comp.color = unhover_color;
                    }
                },
                .click => {
                    if (event_comp.style.click) |click_color| {
                        color_rect_comp.color = click_color;
                    }
                },
            }
        }
    }
};
