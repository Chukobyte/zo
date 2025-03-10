const std = @import("std");

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

const math = @import("math.zig");

const GLint = glad.GLint;
const GLuint = glad.GLuint;
const GLsizei = glad.GLsizei;
const GLfloat = glad.GLfloat;

const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const Rect2 = math.Rect2;
const Transform2D = math.Transform2D;
const Mat4 = math.Mat4;
const LinearColor = math.LinearColor;

pub const RenderContext = struct {
    res_width: i32 = undefined,
    res_height: i32 = undefined,
};

pub const Shader = struct {
    id: GLuint,

    pub fn compileNew(vertex_source: []const u8, fragment_source: []const u8) Shader {
        _ = vertex_source; _ = fragment_source;
        return Shader{ .id = 0 }; // TODO: Implement
    }

    pub fn use(self: *const Shader) void {
        _ = self;
    }

    pub fn setUniform(self: *const Shader, name: []const u8, comptime T: type, value: T) void {
        _ = self; _ = name; _ = value;
        switch (T) {
            bool =>  {},
            i32 =>  {},
            f32 =>  {},
            Vec2 =>  {},
            Vec3 =>  {},
            Vec4 =>  {},
            Mat4 =>  {},
            else => @compileError("Unsupported type for Shader.setUniform!"),
        }
    }

    pub fn setUniformArray(self: *const Shader, name: []const u8, comptime T: type, value: T, count: usize) void {
        _ = self; _ = name; _ = value; _ = count;
        switch (T) {
            bool =>  {},
            i32 =>  {},
            f32 =>  {},
            Vec2 =>  {},
            Vec3 =>  {},
            Vec4 =>  {},
            Mat4 =>  {},
            else => @compileError("Unsupported type for Shader.setUniform!"),
        }
    }
};

pub const Texture = struct {
    id: GLuint,
    data: []u8,
    width: GLsizei,
    height: GLsizei,
    nr_channels: i32,
    internal_format: GLint,
    image_format: GLint,
    wrap_s: GLint,
    wrap_t: GLint,
    using_nearest_neighbor: bool,
    file_path: []u8,
};

pub const TextureCoords = struct {
    s_min: f32 = 0.0,
    s_max: f32 = 1.0,
    t_min: f32 = 0.0,
    t_max: f32 = 1.0,

    pub fn generate(texture: *const Texture, draw_source: *const Rect2, flip_h: bool, flip_v: bool) @This() {
        var texture_coords = @This(){};
        if (texture.width != draw_source.w or texture.height != draw_source.h) {
            texture_coords.s_min = (draw_source.x + 0.5) / texture.width;
            texture_coords.s_max = (draw_source.x + draw_source.w - 0.5) / texture.width;
            texture_coords.t_min = (draw_source.y + 0.5) / texture.height;
            texture_coords.t_max = (draw_source.y + draw_source.h - 0.5) / texture.height;
        }
        if (flip_h) {
            const temp_s_min = texture_coords.s_min;
            texture_coords.s_min = texture_coords.s_max;
            texture_coords.s_max = temp_s_min;
        }
        if (flip_v) {
            const temp_t_min = texture_coords.t_min;
            texture_coords.t_min = texture_coords.t_max;
            texture_coords.t_max = temp_t_min;
        }
        return texture_coords;
    }
};

pub const FontCharacter = struct {
    texture_id: GLint,
    size: Vec2,
    bearing: Vec2,
    advance: u32,
};

pub const Font = struct {
    vao: GLuint,
    vbo: GLuint,
    size: i32,
    characters: [128]FontCharacter, // First 128 of ASCII set
};

pub const RenderData = struct {
    vao: GLuint = undefined,
    vbo: GLuint = undefined,
    shader: Shader = undefined,
    projection: Mat4 = undefined,
    resolution: Vec2i = undefined,
};

pub const DrawSpriteParams = struct {
    texture: *const Texture,
    source_rect: Rect2,
    dest_size: Vec2,
    transform: Transform2D,
    color: LinearColor = .{ 1.0, 1.0, 1.0, 1.0 },
    flip_h: bool = false,
    flip_v: bool = false,
    z_index: i32 = 0,
};

var render_context: RenderContext = .{};
var sprite_render_data: RenderData = .{};

pub const sprite_vertex_shader_source =
    \\#version 330 core
    \\layout (location = 0) in float in_id;
    \\layout (location = 1) in vec2 in_pos;
    \\layout (location = 2) in vec2 in_uv;
    \\layout (location = 3) in vec4 in_color_mod;
    \\layout (location = 4) in float in_use_nearest;
    \\
    \\out vec2 frag_uv;
    \\out vec4 frag_color_mod;
    \\out float frag_use_nearest;
    \\
    \\uniform mat4 models[100];
    \\uniform mat4 projection;
    \\
    \\void main() {
    \\    int sprite_index = int(in_id);
    \\    frag_uv = in_uv;
    \\    frag_color_mod = in_color_mod;
    \\    frag_use_nearest = in_use_nearest;
    \\    gl_Position = projection * models[sprite_index] * vec4(in_pos, 0.0, 1.0);
    \\}
;

pub const sprite_fragment_shader_source =
    \\#version 330 core
    \\in vec2 frag_uv;
    \\in vec4 frag_color_mod;
    \\in float frag_use_nearest;
    \\
    \\out vec4 out_color;
    \\
    \\uniform sampler2D u_texture;
    \\
    \\vec2 apply_nearest_neighbor(vec2 uv, vec2 texture_size) {
    \\    vec2 pixel = uv * texture_size;
    \\    vec2 nearest = floor(pixel + 0.5);
    \\    vec2 dudv = fwidth(pixel);
    \\    pixel = nearest + clamp((pixel - nearest) / dudv, -0.5, 0.5);
    \\    return pixel / texture_size;
    \\}
    \\
    \\void main() {
    \\    vec2 tex_size = textureSize(u_texture, 0);
    \\    vec2 final_uv = mix(frag_uv, apply_nearest_neighbor(frag_uv, tex_size), frag_use_nearest);
    \\    out_color = frag_color_mod * texture(u_texture, final_uv);
    \\}
;

const max_sprite_count = 10;
const number_of_vertices = 6;
const verts_stride = 10;
const vertex_buffer_size: comptime_int = verts_stride * number_of_vertices * max_sprite_count;

pub fn init(res_width: i32, res_height: i32) !void {
    render_context.res_width = res_width;
    render_context.res_height = res_height;
    glad.glEnable(glad.GL_CULL_FACE);
    glad.glEnable(glad.GL_BLEND);
    glad.glBlendFunc(glad.GL_SRC_ALPHA, glad.GL_ONE_MINUS_SRC_ALPHA);

    // Init sprite rendering
    const vertices: []GLfloat = [_]GLfloat{
        //id (1) // positions (2) // texture coordinates (2) // color (4) // using nearest neighbor (1)
        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0,

        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
        0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0,
    };

    // Initialize render data
    glad.glGenVertexArrays(1, &sprite_render_data.vao);
    glad.glGenBuffers(1, &sprite_render_data.vbo);

    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, sprite_render_data.vbo);
    glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(vertices), vertices, glad.GL_DYNAMIC_DRAW);

    glad.glBindVertexArray(sprite_render_data.vao);
    // id attribute
    glad.glVertexAttribPointer(0, 1, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), null);
    glad.glEnableVertexAttribArray(0);
    // position attribute
    glad.glVertexAttribPointer(1, 2, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), @sizeOf(GLfloat));
    glad.glEnableVertexAttribArray(1);
    // texture coord attribute
    glad.glVertexAttribPointer(2, 2, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), 3 * @sizeOf(GLfloat));
    glad.glEnableVertexAttribArray(2);
    // color attribute
    glad.glVertexAttribPointer(3, 4, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), 5 * @sizeOf(GLfloat));
    glad.glEnableVertexAttribArray(3);
    // color attribute
    glad.glVertexAttribPointer(4, 1, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), 9 * @sizeOf(GLfloat));
    glad.glEnableVertexAttribArray(4);

    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, 0);
    glad.glBindVertexArray(0);

    sprite_render_data.shader = Shader.compileNew(sprite_vertex_shader_source, sprite_fragment_shader_source);
    sprite_render_data.shader.use();
    sprite_render_data.resolution = .{ .x = res_width, .y = res_height };
    sprite_render_data.projection = math.ortho(0.0, sprite_render_data.resolution.x, sprite_render_data.resolution.y, -1.0, 1.0);
    sprite_render_data.shader.setUniform("projection", Mat4, sprite_render_data.projection);
}

pub fn deinit() void {}

// TODO: Fix
pub fn drawSprite(p: *const DrawSpriteParams) void {
    glad.glDepthMask(false);

    glad.glBindVertexArray(sprite_render_data.vao);
    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, sprite_render_data.vbo);

    var models: [max_sprite_count * 16]Mat4 = undefined;
    const number_of_sprites: usize = 1;
    for (0..number_of_sprites) |i| {
        const model_offset = i * 16;
        var model: Mat4 = Mat4.Identity;
        model.translate(.{ .x = p.transform.position.x, .y = p.transform.position.y });
        model.rotate_z(p.transform.rotation * (std.math.pi / 180));
        model.scale(.{ .x = p.transform.scale.x * p.dest_size.x, .y = p.transform.scale.y * p.dest_size.y, .z = 1.0 });

        sprite_render_data.shader.use();

        const model_id: f32 = @floatFromInt(i);
        const determinate: f32 = model.determinant();
        const texture_coords: TextureCoords = TextureCoords.generate(p.texture, p.source_rect, p.flip_h, p.flip_v);

        std.mem.copy(f32, models[model_offset .. model_offset + 16], model.data[0..]);

        sprite_render_data.shader.setUniformArray("models", Mat4, models, number_of_sprites);

        // Create vertex data for the sprite.
        var verts: [verts_stride * number_of_vertices]GLfloat = undefined;
        for (0..number_of_vertices) |j| {
            var isSMin: bool = false;
            var isTMin: bool = false;
            if (determinate >= 0.0) {
                isSMin = (j == 0 or j == 2 or j == 3);
                isTMin = (j == 1 or j == 2 or j == 5);
            } else {
                isSMin = (j == 1 or j == 2 or j == 5);
                isTMin = (j == 0 or j == 2 or j == 3);
            }
            // Compute the offset (row) in the vertex array.
            const row: usize = (j * verts_stride) + (i * verts_stride * number_of_vertices);
            verts[row + 0] = model_id;
            verts[row + 1] = if (isSMin) 0.0 else 1.0;
            verts[row + 2] = if (isTMin) 0.0 else 1.0;
            verts[row + 3] = if (isSMin) texture_coords.s_min else texture_coords.s_max;
            verts[row + 4] = if (isTMin) texture_coords.t_min else texture_coords.t_max;
            verts[row + 5] = @as(GLfloat, p.color.r);
            verts[row + 6] = @as(GLfloat, p.color.g);
            verts[row + 7] = @as(GLfloat, p.color.b);
            verts[row + 8] = @as(GLfloat, p.color.a);
            verts[row + 9] = @floatFromInt(p.texture.applyNearestNeighbor);
        }

        glad.glActiveTexture(glad.GL_TEXTURE0);
        glad.glBindTexture(glad.GL_TEXTURE_2D, p.texture.id);

        glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(verts), &verts, glad.GL_DYNAMIC_DRAW);
        glad.glDrawArrays(glad.GL_TRIANGLES, 0, @as(GLsizei, number_of_sprites * number_of_vertices));

        glad.glBindVertexArray(0);
    }
}
