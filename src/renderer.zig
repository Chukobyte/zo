pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

const math = @import("math.zig");

const GLint = glad.GLint;
const GLuint = glad.GLuint;
const GLsizei = glad.GLsizei;

const Vec2 = math.Vec2;

pub const RenderContext = struct {
    res_width: i32 = undefined,
    res_height: i32 = undefined,
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

var render_context = .{};

pub fn init(res_width: i32, res_height: i32) !void {
    render_context.res_width = res_width;
    render_context.res_height = res_height;
    glad.glEnable(glad.GL_CULL_FACE);
    glad.glEnable(glad.GL_BLEND);
    glad.glBlendFunc(glad.GL_SRC_ALPHA, glad.GL_ONE_MINUS_SRC_ALPHA);
}

pub fn deinit() void {}
