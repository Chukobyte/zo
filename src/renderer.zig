pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

const math = @import("math.zig");

const GLint = glad.GLint;
const GLuint = glad.GLuint;
const GLsizei = glad.GLsizei;

const Vec2 = math.Vec2;
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

var render_context = .{};

pub fn init(res_width: i32, res_height: i32) !void {
    render_context.res_width = res_width;
    render_context.res_height = res_height;
    glad.glEnable(glad.GL_CULL_FACE);
    glad.glEnable(glad.GL_BLEND);
    glad.glBlendFunc(glad.GL_SRC_ALPHA, glad.GL_ONE_MINUS_SRC_ALPHA);
}

pub fn deinit() void {}
