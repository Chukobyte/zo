const zo = @import("zo");
const global = @import("global.zig");

const math = zo.math;
const renderer = zo.renderer;

const Transform2D = math.Transform2D;
const Vec2 = math.Vec2;
const Rect2 = math.Rect2;
const LinearColor = math.LinearColor;
const Mat4 = math.Mat4;
const Dim2u = math.Dim2u;
const Font = renderer.Font;
const Texture = renderer.Texture;
const String = zo.string.HeapString;
const MultiLineString = zo.string.HeapMultiLineString;
const World = global.World;
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
    const LabelClass = struct {
        text: String,
    };
    const TextBoxClass = struct {
        text: MultiLineString,
        size: Dim2u,

        pub fn setText(self: *@This(), font: *const Font, text: []const u8, scale: f32) !void {
            const max_line_width = @as(f32, @floatFromInt(self.size.w));
            var width: f32 = 0.0;
            self.text.clear();
            var line_string = String.init(self.text.allocator);
            defer line_string.deinit();
            for (text) |c| {
                const index: usize = @intCast(c);
                if (index >= font.characters.len) { continue; }
                const ch = font.characters[index];
                // ch.advance is in 26.6 fixed point, so we shift right by 6 to get pixels.
                const advance_pixels: f32 = @floatFromInt(ch.advance >> 6);
                const new_width: f32 = advance_pixels * scale;
                if (width + new_width >= max_line_width) {
                    try self.text.addLine(line_string.get());
                    try line_string.set("{c}", .{ c });
                    width = new_width;
                } else {
                    try line_string.set("{s}{c}", .{ line_string.get(), c });
                    width += new_width;
                }
            }
            if (!line_string.isEmpty()) {
                try self.text.addLine(line_string.get());
            }
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
                            const line_height: f32 = text_label_comp.font.text_height * @as(f32, @floatFromInt(i));
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
};
