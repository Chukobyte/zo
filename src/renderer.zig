const std = @import("std");

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

pub const stb_image = @cImport({
    @cInclude("stb_image/stb_image.h");
});

const math = @import("math.zig");
const string = @import("string.zig");

const GLint = glad.GLint;
const GLuint = glad.GLuint;
const GLsizei = glad.GLsizei;
const GLfloat = glad.GLfloat;
const GLchar = glad.GLchar;
const GLenum = glad.GLenum;

const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const Rect2 = math.Rect2;
const Transform2D = math.Transform2D;
const Mat4 = math.Mat4;
const LinearColor = math.LinearColor;

const String = string.String;

const log = @import("logger.zig").log;

pub const RenderContext = struct {
    res_width: i32 = undefined,
    res_height: i32 = undefined,
};

const ShaderError = error{
    FailedToCompile,
};

fn printOpenGLErrors(context: ?[]const u8) void {
    // Loop indefinitely until glGetError returns GL_NO_ERROR.
    while (true) {
        // Get the current OpenGL error.
        const err: GLenum = glad.glGetError();
        if (err == glad.GL_NO_ERROR) break;

        // If context is provided, log it.
        if (context) |con| {
            log(.critical, "context = {s}", .{con});
        }

        // Log the error code.
        log(.critical, "err = {d}", .{err});

        // Print a string description of the error.
        switch (err) {
            glad.GL_NO_ERROR => log(.critical, "GL_NO_ERROR", .{}),
            glad.GL_INVALID_ENUM => log(.critical, "GL_INVALID_ENUM", .{}),
            glad.GL_INVALID_VALUE => log(.critical, "GL_INVALID_VALUE", .{}),
            glad.GL_INVALID_OPERATION => log(.critical, "GL_INVALID_OPERATION", .{}),
            glad.GL_INVALID_FRAMEBUFFER_OPERATION => log(.critical, "GL_INVALID_FRAMEBUFFER_OPERATION", .{}),
            else => log(.critical, "Not able to find error type!", .{}),
        }
    }
}

pub const Shader = struct {
    id: GLuint,

    const ShaderType = enum {
        vertex,
        fragment,
        program,
    };

    pub fn compileNew(comptime vertex_source: []const u8, comptime fragment_source: []const u8) !Shader {
        // vertex
        var source_string_v: String = try String.initAndSet(std.heap.page_allocator, vertex_source, .{});
        defer source_string_v.deinit();
        const vertex: GLuint = glad.glCreateShader(glad.GL_VERTEX_SHADER);
        glad.glShaderSource(vertex, 1, &@alignCast(@ptrCast(source_string_v.getCString())), null);
        glad.glCompileShader(vertex);
        if (!checkCompileErrors(vertex, .vertex)) { return ShaderError.FailedToCompile; }

        // fragment
        const fragment: GLuint = glad.glCreateShader(glad.GL_FRAGMENT_SHADER);
        var source_string_f: String = try String.initAndSet(std.heap.page_allocator, fragment_source, .{});
        defer source_string_f.deinit();
        glad.glShaderSource(fragment, 1, &@alignCast(@ptrCast(source_string_f.getCString())), null);
        glad.glCompileShader(fragment);
        if (!checkCompileErrors(fragment, .fragment)) { return ShaderError.FailedToCompile; }

        // attach and link shaders
        const shader: Shader = .{ .id = glad.glCreateProgram() };
        glad.glAttachShader(shader.id, vertex);
        glad.glAttachShader(shader.id, fragment);
        glad.glLinkProgram(shader.id);
        if (!checkCompileErrors(shader.id, .program)) { return ShaderError.FailedToCompile; }

        glad.glDeleteShader(vertex);
        glad.glDeleteShader(fragment);
        return shader;
    }

    pub fn use(self: *const Shader) void {
        glad.glUseProgram(self.id);
    }

    pub fn setUniform(self: *const Shader, name: [:0]const u8, comptime T: type, value: T) void {
        switch (T) {
            bool => glad.glUniform1i(glad.glGetUniformLocation(self.id, name), @as(GLint, value)),
            i32 => glad.glUniform1i(glad.glGetUniformLocation(self.id, name), @as(GLint, value)),
            f32 => glad.glUniform1f(glad.glGetUniformLocation(self.id, name), @as(GLfloat, value)),
            Vec2 => glad.glUniform2f(glad.glGetUniformLocation(self.id, name), @as(GLfloat, value.x), @as(GLfloat, value.y)),
            Vec3 => glad.glUniform3f(glad.glGetUniformLocation(self.id, name), @as(GLfloat, value.x), @as(GLfloat, value.y), @as(GLfloat, value.z)),
            Vec4 => glad.glUniform4f(glad.glGetUniformLocation(self.id, name), @as(GLfloat, value.x), @as(GLfloat, value.y), @as(GLfloat, value.z), @as(GLfloat, value.w)),
            Mat4 => glad.glUniformMatrix4fv(glad.glGetUniformLocation(self.id, name), 1, glad.GL_FALSE, @as(*const GLfloat, &value.data[0][0])),
            else => @compileError("Unsupported type for Shader.setUniform!"),
        }
    }

    pub fn setUniformArray(self: *const Shader, name: [:0]const u8, comptime T: type, value: T, count: usize) void {
        switch (T) {
            []bool => glad.glUniform1iv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLint, value)),
            []i32 => glad.glUniform1iv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLint, value)),
            []f32 => glad.glUniform1fv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLfloat, value)),
            []Vec2 => glad.glUniform2fv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLfloat, value.x), @as(GLfloat, value.y)),
            []Vec3 => glad.glUniform3fv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLfloat, value.x), @as(GLfloat, value.y), @as(GLfloat, value.z)),
            []Vec4 => glad.glUniform4fv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLfloat, value.x), @as(GLfloat, value.y), @as(GLfloat, value.z), @as(GLfloat, value.w)),
            []Mat4 => glad.glUniformMatrix4fv(glad.glGetUniformLocation(self.id, name), @intCast(count), glad.GL_FALSE, @as(*const GLfloat, &value[0].data[0][0])),
            else => @compileError("Unsupported type for Shader.setUniformArray!"),
        }
    }

    fn checkCompileErrors(shader_id: GLuint, shader_type: ShaderType) bool {
        var success: GLint = undefined;
        var info_log: [1024]GLchar = undefined;
        if (shader_type == .program) {
            glad.glGetProgramiv(shader_id, glad.GL_LINK_STATUS, &success);
            if (success == 0) {
                glad.glGetProgramInfoLog(shader_id, info_log.len, null, &info_log[0]);
                log(.critical, "Shader type '{}' linking failed!\nInfoLog = {s}", .{shader_type, info_log});
                return false;
            }
        } else {
            glad.glGetShaderiv(shader_id, glad.GL_COMPILE_STATUS, &success);
            if (success == 0) {
                glad.glGetShaderInfoLog(shader_id, info_log.len, null, &info_log[0]);
                log(.critical, "Shader type '{}' compilation failed!\nInfoLog = {s}", .{shader_type, info_log});
                return false;
            }
        }
        return true;
    }
};

const TextureError = error{
    FailedToGenerate,
};

pub const Texture = struct {
    id: GLuint,
    data: [*c]u8,
    width: GLsizei,
    height: GLsizei,
    nr_channels: i32,
    allocator: std.mem.Allocator,
    image_format: GLuint,
    internal_format: GLint = glad.GL_RGBA,
    wrap_s: GLint = glad.GL_CLAMP_TO_BORDER,
    wrap_t: GLint = glad.GL_CLAMP_TO_BORDER,
    using_nearest_neighbor: bool = true,
    file_path: ?[]u8 = null,

    const EmptyTexture: Texture = .{ .id = undefined, .data = undefined, .width = undefined, .height = undefined, .nr_channels = undefined, .allocator = undefined, .image_format = undefined  };

    pub fn init(allocator: std.mem.Allocator, file_path: []const u8, nearest_neighbor: bool) !@This() {
        var texture: Texture = initImpl(allocator, nearest_neighbor);
        texture.file_path = texture.allocator.alloc(u8, file_path.len);
        std.mem.copyForwards(u8, texture.file_path, file_path);
        texture.data = stb_image.stbi_load(&file_path[0], &texture.width, &texture.height, &texture.nr_channels, 0);
        try texture.generate();
        return texture;
    }

    pub fn initFromMemory(allocator: std.mem.Allocator, buffer: *const anyopaque, buffer_len: usize, nearest_neighbor: bool) !@This() {
        var texture: Texture = initImpl(allocator, nearest_neighbor);
        const buffer_raw: [*c]const u8 = @alignCast(@ptrCast(buffer));
        texture.data = stb_image.stbi_load_from_memory(&buffer_raw[0], @intCast(buffer_len), &texture.width, &texture.height, &texture.nr_channels, 0);
        try texture.generate();
        return texture;
    }

    pub fn deinit(self: *@This()) void {
        if (self.file_path) |file_path| {
            self.allocator.free(file_path);
        }
        if (self.data != null) {
            stb_image.stbi_image_free(self.data);
        }
    }

    fn initImpl(allocator: std.mem.Allocator, nearest_neighbor: bool) @This() {
        var texture: Texture = Texture.EmptyTexture;
        texture.allocator = allocator;
        texture.using_nearest_neighbor = nearest_neighbor;
        return texture;
    }

    fn generate(self: *@This()) !void {
        self.image_format = switch (self.nr_channels) {
            1 => glad.GL_RED,
            3 => glad.GL_RGB,
            4 => glad.GL_RGBA,
            else => return TextureError.FailedToGenerate,
        };
        // Generate opengl texture
        glad.glGenTextures(1, &self.id);
        glad.glBindTexture(glad.GL_TEXTURE_2D, self.id);
        glad.glTexImage2D(glad.GL_TEXTURE_2D, 0, self.internal_format, self.width, self.height, 0, self.image_format, glad.GL_UNSIGNED_BYTE, self.data);
        glad.glGenerateMipmap(glad.GL_TEXTURE_2D);
        // Wrap and filter modes
        glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_S, self.wrap_s);
        glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_T, self.wrap_t);
        // Defaults to bilinear interpolation
        glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MIN_FILTER, glad.GL_LINEAR);
        glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MAG_FILTER, glad.GL_LINEAR);

        glad.glBindTexture(glad.GL_TEXTURE_2D, 0);
    }
};

pub const TextureCoords = struct {
    s_min: f32 = 0.0,
    s_max: f32 = 1.0,
    t_min: f32 = 0.0,
    t_max: f32 = 1.0,

    pub fn generate(texture: *const Texture, draw_source: *const Rect2, flip_h: bool, flip_v: bool) @This() {
        var texture_coords = @This(){};
        const width: usize = @intFromFloat(draw_source.w);
        const height: usize = @intFromFloat(draw_source.h);
        if (texture.width != width or texture.height != height) {
            const f_width: f32 = @floatFromInt(texture.width);
            const f_height: f32 = @floatFromInt(texture.height);
            texture_coords.s_min = (draw_source.x + 0.5) / f_width;
            texture_coords.s_max = (draw_source.x + draw_source.w - 0.5) / f_width;
            texture_coords.t_min = (draw_source.y + 0.5) / f_height;
            texture_coords.t_max = (draw_source.y + draw_source.h - 0.5) / f_height;
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
    color: LinearColor = .{ .r = 1.0, .g = 1.0, .b = 1.0 },
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
    \\void main() {{
    \\    int sprite_index = int(in_id);
    \\    frag_uv = in_uv;
    \\    frag_color_mod = in_color_mod;
    \\    frag_use_nearest = in_use_nearest;
    \\    gl_Position = projection * models[sprite_index] * vec4(in_pos, 0.0, 1.0);
    \\}}
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
    \\vec2 apply_nearest_neighbor(vec2 uv, vec2 texture_size) {{
    \\    vec2 pixel = uv * texture_size;
    \\    vec2 nearest = floor(pixel + 0.5);
    \\    vec2 dudv = fwidth(pixel);
    \\    pixel = nearest + clamp((pixel - nearest) / dudv, -0.5, 0.5);
    \\    return pixel / texture_size;
    \\}}
    \\
    \\void main() {{
    \\    vec2 tex_size = textureSize(u_texture, 0);
    \\    vec2 final_uv = mix(frag_uv, apply_nearest_neighbor(frag_uv, tex_size), frag_use_nearest);
    \\    out_color = frag_color_mod * texture(u_texture, final_uv);
    \\}}
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
    const vertices: [verts_stride * number_of_vertices]GLfloat = .{
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

    glad.glBindVertexArray(sprite_render_data.vao);

    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, sprite_render_data.vbo);
    glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), @ptrCast(&vertices[0]), glad.GL_DYNAMIC_DRAW);

    // id attribute
    glad.glVertexAttribPointer(0, 1, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), null);
    glad.glEnableVertexAttribArray(0);
    // position attribute
    glad.glVertexAttribPointer(1, 2, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), @ptrFromInt(@sizeOf(GLfloat)));
    glad.glEnableVertexAttribArray(1);
    // texture coord attribute
    glad.glVertexAttribPointer(2, 2, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), @ptrFromInt(3 * @sizeOf(GLfloat)));
    glad.glEnableVertexAttribArray(2);
    // color attribute
    glad.glVertexAttribPointer(3, 4, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), @ptrFromInt(5 * @sizeOf(GLfloat)));
    glad.glEnableVertexAttribArray(3);
    // using nearest neighbor attribute
    glad.glVertexAttribPointer(4, 1, glad.GL_FLOAT, glad.GL_FALSE, verts_stride * @sizeOf(GLfloat), @ptrFromInt(9 * @sizeOf(GLfloat)));
    glad.glEnableVertexAttribArray(4);

    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, 0);
    glad.glBindVertexArray(0);

    sprite_render_data.shader = try Shader.compileNew(sprite_vertex_shader_source, sprite_fragment_shader_source);
    sprite_render_data.resolution = .{ .x = res_width, .y = res_height };
    sprite_render_data.projection = math.ortho(0.0, @floatFromInt(sprite_render_data.resolution.x), @floatFromInt(sprite_render_data.resolution.y), 0.0, -1.0, 1.0);
    sprite_render_data.shader.use();
    sprite_render_data.shader.setUniform("u_texture", i32, 0);
    sprite_render_data.shader.setUniform("projection", Mat4, sprite_render_data.projection);
}

pub fn deinit() void {}

pub fn drawSprite(p: *const DrawSpriteParams) void {
    glad.glDepthMask(glad.GL_FALSE);

    glad.glBindVertexArray(sprite_render_data.vao);
    glad.glBindBuffer(glad.GL_ARRAY_BUFFER, sprite_render_data.vbo);

    var models: [max_sprite_count]Mat4 = undefined;
    const number_of_sprites: usize = 1;
    for (0..number_of_sprites) |i| {
        // const model_offset = i * 16;
        // TODO: Clean up math and how matrices operations are applied and multiplied
        var model: Mat4 = Mat4.Identity;
        model.translate(.{ .x = p.transform.position.x, .y = p.transform.position.y });
        var t_model = model;
        model.rotate_z(std.math.degreesToRadians(p.transform.rotation));
        var r_model = model;
        model.scale(.{ .x = p.transform.scale.x * p.dest_size.x, .y = p.transform.scale.y * p.dest_size.y, .z = 1.0 });
        var s_model = model;
        model = t_model.mul(&r_model).mul(&s_model);

        models[i] = model;

        sprite_render_data.shader.use();

        const model_id: f32 = @floatFromInt(i);
        const determinate: f32 = model.determinant();
        const texture_coords: TextureCoords = TextureCoords.generate(p.texture, &p.source_rect, p.flip_h, p.flip_v);

        sprite_render_data.shader.setUniformArray("models", []Mat4, &models, number_of_sprites);

        // Create vertex data for the sprite.
        var verts: [vertex_buffer_size]GLfloat = undefined;
        for (0..number_of_vertices) |j| {
            var use_s_min: bool = false;
            var use_t_min: bool = false;
            if (determinate >= 0.0) {
                use_s_min = (j == 0 or j == 2 or j == 3);
                use_t_min = (j == 1 or j == 2 or j == 5);
            } else {
                use_s_min = (j == 1 or j == 2 or j == 5);
                use_t_min = (j == 0 or j == 2 or j == 3);
            }
            // Compute the offset (row) in the vertex array.
            const row: usize = (j * verts_stride) + (i * verts_stride * number_of_vertices);
            verts[row + 0] = model_id;
            verts[row + 1] = if (use_s_min) 0.0 else 1.0;
            verts[row + 2] = if (use_t_min) 0.0 else 1.0;
            verts[row + 3] = if (use_s_min) texture_coords.s_min else texture_coords.s_max;
            verts[row + 4] = if (use_t_min) texture_coords.t_min else texture_coords.t_max;
            verts[row + 5] = @as(GLfloat, p.color.r);
            verts[row + 6] = @as(GLfloat, p.color.g);
            verts[row + 7] = @as(GLfloat, p.color.b);
            verts[row + 8] = @as(GLfloat, p.color.a);
            verts[row + 9] = if(p.texture.using_nearest_neighbor) 1.0 else 0.0;
        }

        glad.glActiveTexture(glad.GL_TEXTURE0);
        glad.glBindTexture(glad.GL_TEXTURE_2D, p.texture.id);

        glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)), @ptrCast(&verts[0]), glad.GL_DYNAMIC_DRAW);
        glad.glDrawArrays(glad.GL_TRIANGLES, 0, @as(GLsizei, number_of_sprites * number_of_vertices));

        glad.glBindVertexArray(0);
    }
}
