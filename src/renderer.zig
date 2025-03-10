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
const Mat4 = math.Mat4;

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
    const verts_stride: comptime_int = 10;
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
