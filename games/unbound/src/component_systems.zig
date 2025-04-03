const std = @import("std");
const zo = @import("zo");
const global = @import("global.zig");

const math = zo.math;
const renderer = zo.renderer;
const input = zo.input;
const window = zo.window;
const audio = zo.audio;

const SubscriberHandle = zo.delegate.SubscriberHandle;
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
const FixedArrayList = zo.misc.FixedArrayList;
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
                    .global_matrix = transform_comp.global_matrix,
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
    texture: Texture = undefined,

    pub fn init(self: *@This(), _: *World) !void {
        self.texture = try Texture.initWhiteSquare(global.allocator, true, .{ .w = 1, .h = 1 });
    }

    pub fn deinit(self: *@This(), _: *World) void {
        self.texture.deinit();
    }

    pub fn postWorldTick(self: *@This(), world: *World) !void {
        const draw_source: Rect2 = .{ .x = 0.0, .y = 0.0, .w = 1.0, .h = 1.0 };
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
                    .global_matrix = transform_comp.global_matrix,
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

/// Responses from clicking with the left mouse button, also used for 'Return' for confirmations
pub const OnClickResponse = enum {
    none,
    success,
    invalid,
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
    on_click: ?*const fn(Entity) OnClickResponse = null,
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

    /// Keyboard navigational element
    pub const NavigationElement = struct {
        position: Vec2, // World position
        size: Dim2, // Container size
        owner_entity: Entity,
        left: ?*@This() = null,
        right: ?*@This() = null,
        up: ?*@This() = null,
        down: ?*@This() = null,
        on_focus: ?*const fn(Entity) void = null,
        on_unfocus: ?*const fn(Entity) void = null,
        on_pressed: ?*const fn(Entity) OnClickResponse = null,

        pub fn getElementFromDir(self: *@This(), dir: Vec2i) ?*@This() {
            if (dir.x == -1) { return self.left; }
            else if (dir.x == 1) { return self.right; }
            else if (dir.y == -1) { return self.up; }
            else if (dir.y == 1) { return self.down; }
            return null;
        }
    };

    const border_draw_source: Rect2 = .{ .x = 0.0, .y = 0.0, .w = 16.0, .h = 8.0 };

    spatial_hash_map: EntitySpatialHashMap = undefined,
    prev_mouse_pos: Vec2i = Vec2i.Zero,
    nav_elements: FixedArrayList(NavigationElement, 16) = undefined,
    focued_nav_element: ?*NavigationElement = null,
    border_texture: Texture = undefined,
    scene_change_handle: ?SubscriberHandle = null,

    pub fn init(self: *@This(), _: *World) !void {
        self.spatial_hash_map = try EntitySpatialHashMap.init(global.allocator, 64);
        self.nav_elements = FixedArrayList(NavigationElement, 16).init();
        self.border_texture = try Texture.initWhiteSquareBorder(global.allocator, true, .{ .w = @intFromFloat(border_draw_source.w), .h = @intFromFloat(border_draw_source.h) }, 2);
        // self.scene_change_handle = try global.scene_system.on_scene_changed.subscribe(onSceneChange);
    }

    pub fn deinit(self: *@This(), _: *World) void {
        global.scene_system.on_scene_changed.unsubscribe(self.scene_change_handle.?);
        self.spatial_hash_map.deinit();
        self.border_texture.deinit();
    }

    pub fn onEntityRegistered(self: *@This(), _: *World, entity: Entity) void {
        self.onUpdatePosition(entity) catch { log(.critical, "Failed to update position on registered for entity = {d}", .{ entity }); };
    }

    pub fn preWorldTick(self: *@This(), world: *World) !void {
        const ComponentIterator = World.ArchetypeComponentIterator(getSignature());

        if (self.scene_change_handle == null) {
            self.scene_change_handle = try global.scene_system.on_scene_changed.subscribe(onSceneChange);
        }

        const mouse_pos: Vec2i = input.getWorldMousePosition(window.getWindowSize(), renderer.getResolution());

        var has_moved = false;
        if (!self.prev_mouse_pos.equals(&mouse_pos)) {
            self.prev_mouse_pos = mouse_pos;
            has_moved = true;
        }

        const global_mouse_pos: Vec2 = .{ .x = @floatFromInt(mouse_pos.x), .y = @floatFromInt(mouse_pos.y) };
        const clicked_pressed: bool = input.isKeyPressed(.{ .key = .mouse_button_left });
        const just_clicked_pressed: bool = input.isKeyJustPressed(.{ .key = .mouse_button_left });
        // TODO: We can use the spatial hash cell based on the global mouse position instead of iterating over every entity
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
                    var on_click_response: OnClickResponse = .success;
                    if (event_comp.on_click) |on_click| {
                        on_click_response = on_click(iter.getEntity());
                    }
                    try processOnClickResponse(on_click_response);
                }
            }
        }

        // Process navigation
        if (self.nav_elements.len == 0) { return; }
        // Clear nav element when a click is registered and don't process this frame
        if (just_clicked_pressed) {
            self.unfocus();
            return;
        }
        const element_just_pressed: bool = input.isKeyJustPressed(.{ .key = .keyboard_return });
        // Process navigation movement
        var nav_dir: ?Vec2i = null;
        if (input.isKeyJustPressed(.{ .key = .keyboard_left })) {
            nav_dir = Vec2i.Left;
        } else if (input.isKeyJustPressed(.{ .key = .keyboard_right })) {
            nav_dir = Vec2i.Right;
        } else if (input.isKeyJustPressed(.{ .key = .keyboard_up })) {
            nav_dir = Vec2i.Up;
        } else if (input.isKeyJustPressed(.{ .key = .keyboard_down })) {
            nav_dir = Vec2i.Down;
        }

        // Early out as there has been no navigational movement or confirmation (Return)
        if (!element_just_pressed and nav_dir == null) { return; }

        if (self.focued_nav_element) |nav_element| {
            // Pressing element takes precedence over directional movements
            if (element_just_pressed) {
                var on_click_response: OnClickResponse = .success;
                if (nav_element.on_pressed) |on_pressed| {
                    on_click_response = on_pressed(nav_element.owner_entity);
                }
                try processOnClickResponse(on_click_response);
            } else if (nav_dir) |dir| {
                if (nav_element.getElementFromDir(dir)) |new_nav_element| {
                    self.setFocused(new_nav_element);
                }
            }
        } else {
            // Set focused item to first created navigation element.
            self.setFocused(&self.nav_elements.items[0]);
        }
    }

    pub fn postWorldTick(self: *@This(), _: *World) !void {
        // Draw border as 9 slice rect
        if (self.focued_nav_element) |nav_element| {
            const texture_size: Dim2 = .{ .w = @floatFromInt(self.border_texture.width), .h = @floatFromInt(self.border_texture.height) };
            const border_color: LinearColor = .{ .r = 0.0, .g = 0.8, .b = 0.8 };
            const border: Rect2 = .{ .x = 1.0, .y = 1.0, .w = 14.0, .h = 6.0 };
            const z_index: i32 = 10;
            var param_list = FixedArrayList(renderer.DrawSpriteParams, 9).init();
            const left   = border.x;
            const right  = texture_size.w - (border.x + border.w);
            const top    = border.y;
            const bottom = texture_size.h - (border.y + border.h);
            const center_width  = border.w;
            const center_height = border.h;
            const src_x = [4]f32{ 0.0, left, left + center_width, texture_size.w };
            const src_y = [4]f32{ 0.0, top, top + center_height, texture_size.h };
            const dst_x = [4]f32{ 0.0, left, nav_element.size.w - right, nav_element.size.w };
            const dst_y = [4]f32{ 0.0, top, nav_element.size.h - bottom, nav_element.size.h };
            // Iterate through 9 slices and queue draw accordingly
            for (0..3) |i| {
                for (0..3) |j| {
                    const src_rect = Rect2{
                        .x = src_x[i],
                        .y = src_y[j],
                        .w = src_x[i + 1] - src_x[i],
                        .h = src_y[j + 1] - src_y[j],
                    };

                    const dest = Dim2{
                        .w = dst_x[i + 1] - dst_x[i],
                        .h = dst_y[j + 1] - dst_y[j],
                    };

                    const transform = Transform2D{
                        .position = nav_element.position.add(&Vec2{ .x = dst_x[i], .y = dst_y[j] }),
                    };

                    try param_list.append(.{
                        .texture = &self.border_texture,
                        .source_rect = src_rect,
                        .global_matrix = transform.toMat4(),
                        .dest_size = dest,
                        .modulate = border_color,
                        .z_index = z_index,
                    });
                }
            }

            try renderer.queueSpriteDraws(param_list.asSlice());
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

    pub fn generateNavElement(self: *@This(), position: Vec2, size: Dim2, owner_entity: Entity) !*NavigationElement {
        const index: usize = self.nav_elements.len;
        try self.nav_elements.append(.{ .position = position, .size = size, .owner_entity = owner_entity });
        return &self.nav_elements.items[index];
    }

    pub fn resetNavElements(self: *@This()) void {
        self.focued_nav_element = null;
        self.nav_elements.clear();
    }

    pub fn getSignature() []const type {
        return &.{ Transform2DComponent, UIEventComponent };
    }

    pub fn onSceneChange(_: usize) void {
        if (global.world.getSystemInstance(@This())) |self| {
            self.resetNavElements();
        }
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

    fn setFocused(self: *@This(), nav_element: *NavigationElement) void {
        self.unfocus();
        self.focued_nav_element = nav_element;
        if (self.focued_nav_element.?.on_focus) |on_focus| {
            on_focus(nav_element.owner_entity);
        }
    }

    fn unfocus(self: *@This()) void {
        if (self.focued_nav_element) |focused_element| {
            if (focused_element.on_unfocus) |on_unfocus| {
                on_unfocus(focused_element.owner_entity);
                self.focued_nav_element = null;
            }
        }
    }

    fn processOnClickResponse(on_click_response: OnClickResponse) !void {
        switch (on_click_response) {
            .success => try global.assets.audio.click.play(false),
            .invalid => try global.assets.audio.invalid_click.play(false),
            .none => {},
        }
    }
};
