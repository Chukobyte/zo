const std = @import("std");

pub const glad = @cImport({
    @cInclude("glad/glad.h");
});

pub const stb_image = @cImport({
    @cInclude("stb_image/stb_image.h");
});

pub const ft = @cImport({
    @cInclude("freetype/freetype.h");
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
const Vec2u = math.Vec2u;
const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const Rect2 = math.Rect2;
const Transform2D = math.Transform2D;
const Mat4 = math.Mat4;
const Dim2 = math.Dim2;
const Dim2i = math.Dim2i;
const LinearColor = math.LinearColor;
const String = string.String;
const FixedArrayList = @import("misc.zig").FixedArrayList;
const StaticAsset = @import("static_asset.zig").StaticAsset;

const log = @import("logger.zig").log;

pub const RenderContext = struct {
    resolution: Dim2i = undefined,
    ft_instance: ft.FT_Library = undefined,
};

var render_context: RenderContext = .{};

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
            LinearColor => glad.glUniform4f(glad.glGetUniformLocation(self.id, name), @as(GLfloat, value.r), @as(GLfloat, value.g), @as(GLfloat, value.b), @as(GLfloat, value.a)),
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
            []LinearColor => glad.glUniform4fv(glad.glGetUniformLocation(self.id, name), @intCast(count), @as(GLfloat, value.r), @as(GLfloat, value.g), @as(GLfloat, value.b), @as(GLfloat, value.a)),
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
    is_white_square: bool = false,

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

    pub inline fn initFromMemory2(allocator: std.mem.Allocator, asset: StaticAsset, nearest_neighbor: bool) !@This() {
        return try initFromMemory(allocator, asset.ptr, asset.len, nearest_neighbor);
    }

    pub fn initWhiteSquare(allocator: std.mem.Allocator, nearest_neighbor: bool, size: Dim2i) !@This() {
        var texture: Texture = initImpl(allocator, nearest_neighbor);
        texture.nr_channels = 4;
        texture.width = size.w;
        texture.height = size.h;
        texture.is_white_square = true;
        const data_size: usize = @intCast(size.w * size.h * texture.nr_channels);
        const data: []u8 = try allocator.alloc(u8, data_size);
        texture.data = @ptrCast(data);
        for (0..data_size) |i| {
            texture.data[i] = 255;
        }
        try texture.generate();
        return texture;
    }

    pub fn initWhiteSquareBorder(allocator: std.mem.Allocator, nearest_neighbor: bool, size: Dim2i, thickness: usize) !@This() {
        var texture: Texture = initImpl(allocator, nearest_neighbor);
        texture.nr_channels = 4;
        texture.width = size.w;
        texture.height = size.h;
        texture.is_white_square = true;

        const data_size: usize = @intCast(size.w * size.h * texture.nr_channels);
        const data: []u8 = try allocator.alloc(u8, data_size);
        texture.data = @ptrCast(data);

        const height: usize = @intCast(size.h);
        const width: usize = @intCast(size.w);
        for (0..height) |y| {
            for (0..width) |x| {
                const idx: usize = (y * width + x) * 4;
                const is_border = x < thickness or x >= width - thickness or y < thickness or y >= height - thickness;
                if (is_border) {
                    texture.data[idx + 0] = 255; // R
                    texture.data[idx + 1] = 255; // G
                    texture.data[idx + 2] = 255; // B
                    texture.data[idx + 3] = 255; // A (Opaque)
                } else {
                    texture.data[idx + 0] = 0;   // R
                    texture.data[idx + 1] = 0;   // G
                    texture.data[idx + 2] = 0;   // B
                    texture.data[idx + 3] = 0;   // A (Transparent)
                }
            }
        }

        try texture.generate();
        return texture;
    }

    pub fn deinit(self: *@This()) void {
        if (self.file_path) |file_path| {
            self.allocator.free(file_path);
        }
        if (self.data != null) {
            if (self.is_white_square) {
                const data: []u8 = std.mem.span(self.data);
                self.allocator.free(data);
            } else {
                stb_image.stbi_image_free(self.data);
            }
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
        glad.glTexImage2D(
            glad.GL_TEXTURE_2D,
            0,
            self.internal_format,
            self.width,
            self.height,
            0,
            self.image_format,
            glad.GL_UNSIGNED_BYTE,
            self.data
        );
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
    texture_id: GLuint,
    size: Vec2u,
    bearing: Vec2i,
    advance: u32,
};

const FontError = error {
    FailedToLoad,
};

pub const Font = struct {
    vao: GLuint,
    vbo: GLuint,
    size: i32,
    text_height: f32,
    ascent: f32,
    characters: [128]FontCharacter, // First 128 of ASCII set

    const EmptyFont: @This() = .{ .vao = undefined, .vbo = undefined, .size = undefined, .text_height = undefined, .ascent = undefined, .characters = undefined };

    pub fn init(file_path: []const u8, font_size: usize, nearest_neighbor: bool) !@This() {
        var face: ft.FT_Face = undefined;
        var font = EmptyFont;
        font.size = @intCast(font_size);
        if (ft.FT_New_Face(render_context.ft_instance, file_path.ptr, 0, &face) != 0) {
            ft.FT_Done_Face(face);
            return FontError.FailedToLoad;
        }
        try font.internalInit(face, nearest_neighbor);
        return font;
    }

    pub fn initFromMemory(buffer: *const anyopaque, buffer_len: usize, font_size: usize, nearest_neighbor: bool) !@This() {
        var face: ft.FT_Face = undefined;
        var font = EmptyFont;
        font.size = @intCast(font_size);
        const buffer_raw: [*c]const u8 = @alignCast(@ptrCast(buffer));
        if (ft.FT_New_Memory_Face(render_context.ft_instance, &buffer_raw[0], @intCast(buffer_len), 0, &face) != 0) {
            _ = ft.FT_Done_Face(face);
            return FontError.FailedToLoad;
        }
        try font.internalInit(face, nearest_neighbor);
        return font;
    }

    pub inline fn initFromMemory2(asset: StaticAsset, font_size: usize, nearest_neighbor: bool) !@This() {
        return try initFromMemory(asset.ptr, asset.len, font_size, nearest_neighbor);
    }

    pub fn deinit(self: *Font) void {
        _ = self;
    }

    pub fn getTextWidth(self: *const Font, text: []const u8) f32 {
        var width: f32 = 0.0;
        for (text) |c| {
            const index: usize = @intCast(c);
            // Skip characters outside our ASCII range.
            if (index >= self.characters.len) continue;
            const ch = self.characters[index];
            // ch.advance is in 26.6 fixed point, so we shift right by 6 to get pixels.
            const advance_pixels: f32 = @floatFromInt(ch.advance >> 6);
            width += advance_pixels;
        }
        return width;
    }


    fn internalInit(self: *@This(), face: ft.FT_Face, nearest_neighbor: bool) !void {
        // Set size to load glyphs, width set to 0 to dynamically adjust
        if (ft.FT_Set_Pixel_Sizes(face, 0, @intCast(self.size)) != 0) {
            return FontError.FailedToLoad;
        }
        // Disable byte alignment restriction
        glad.glPixelStorei(glad.GL_UNPACK_ALIGNMENT, 1);
        // Load first 128 characters of ASCII set
        var max_ascent: f32 = 0.0;
        var max_descent: f32 = 0.0;
        var c: ft.FT_ULong = 0;
        while (c < 128) : (c += 1) {
            // Load character glyph
            if (ft.FT_Load_Char(face, c, ft.FT_LOAD_RENDER) != 0) {
                log(.critical, "Free type failed to load glyph for {any}", .{c});
                return FontError.FailedToLoad;
            }
            var text_texture: GLuint = undefined;
            glad.glGenTextures(1, &text_texture);
            glad.glBindTexture(glad.GL_TEXTURE_2D, text_texture);
            glad.glTexImage2D(
                glad.GL_TEXTURE_2D,
                0,
                glad.GL_R8,
                @intCast(face.*.glyph.*.bitmap.width),
                @intCast(face.*.glyph.*.bitmap.rows),
                0,
                glad.GL_RED,
                glad.GL_UNSIGNED_BYTE,
                face.*.glyph.*.bitmap.buffer
            );
            glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_S, glad.GL_CLAMP_TO_EDGE);
            glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_WRAP_T, glad.GL_CLAMP_TO_EDGE);
            const filter_type: GLint = if (nearest_neighbor) glad.GL_NEAREST else glad.GL_LINEAR;
            glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MIN_FILTER, filter_type);
            glad.glTexParameteri(glad.GL_TEXTURE_2D, glad.GL_TEXTURE_MAG_FILTER, filter_type);

            const ascent: f32 = @floatFromInt(face.*.glyph.*.bitmap_top);
            const descent: f32 = @as(f32, @floatFromInt(face.*.glyph.*.bitmap.rows)) - ascent;
            if (max_ascent < ascent) { max_ascent = ascent; }
            if (max_descent < descent) { max_descent = descent; }

            self.characters[c] = .{
                .texture_id = text_texture,
                .size = .{ .x = face.*.glyph.*.bitmap.width, .y = face.*.glyph.*.bitmap.rows },
                .bearing = .{ .x = @intCast(face.*.glyph.*.bitmap_left), .y = @intCast(face.*.glyph.*.bitmap_top) },
                .advance = @intCast(face.*.glyph.*.advance.x),
            };
        }

        self.text_height = max_ascent + max_descent;
        self.ascent = max_ascent;

        glad.glBindTexture(glad.GL_TEXTURE_2D, 0);

        // Configure vao and vbo
        glad.glGenVertexArrays(1, &self.vao);
        glad.glGenBuffers(1, &self.vbo);
        glad.glBindVertexArray(self.vao);
        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, self.vbo);
        glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(GLfloat) * 6 * 4, null, glad.GL_DYNAMIC_DRAW);
        // Setup vertex attribute as we just pass in the vertex to the shader
        glad.glEnableVertexAttribArray(0);
        glad.glVertexAttribPointer(0, 4, glad.GL_FLOAT, glad.GL_FALSE, 4 * @sizeOf(GLfloat), null);
        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, 0);
        glad.glBindVertexArray(0);

        _ = ft.FT_Done_Face(face);
    }
};

pub const RenderData = struct {
    vao: GLuint = undefined,
    vbo: GLuint = undefined,
    shader: Shader = undefined,
    projection: Mat4 = undefined,
};

pub const DrawSpriteParams = struct {
    texture: *const Texture,
    source_rect: Rect2,
    global_matrix: Mat4,
    dest_size: ?Dim2 = null,
    modulate: LinearColor = .{ .r = 1.0, .g = 1.0, .b = 1.0 },
    flip_h: bool = false,
    flip_v: bool = false,
    z_index: i32 = 0,
};

const SpriteRenderer = struct {
    const sprite_vertex_shader_source =
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

    const sprite_fragment_shader_source =
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

    const max_sprite_count = 16;
    const number_of_vertices = 6;
    const verts_stride = 10;
    const vertex_buffer_size: comptime_int = verts_stride * number_of_vertices * max_sprite_count;
    var render_data: RenderData = .{};

    pub fn init() !void {
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
        glad.glGenVertexArrays(1, &render_data.vao);
        glad.glBindVertexArray(render_data.vao);

        glad.glGenBuffers(1, &render_data.vbo);
        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, render_data.vbo);
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

        render_data.projection = math.ortho(0.0, @floatFromInt(render_context.resolution.w), @floatFromInt(render_context.resolution.h), 0.0, -1.0, 1.0);
        render_data.shader = try Shader.compileNew(sprite_vertex_shader_source, sprite_fragment_shader_source);
        render_data.shader.use();
        render_data.shader.setUniform("u_texture", i32, 0);
        render_data.shader.setUniform("projection", Mat4, render_data.projection);
    }

    pub fn deinit() void {}

    pub fn drawSprite(params: DrawSpriteParams) void {
        var single: [1]DrawSpriteParams = .{ params };
        drawSprites(single[0..]);
    }

    pub fn drawSprites(params: []const DrawSpriteParams) void {
        glad.glDepthMask(glad.GL_FALSE);

        glad.glBindVertexArray(render_data.vao);
        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, render_data.vbo);

        var models: [max_sprite_count]Mat4 = undefined;
        var verts: [vertex_buffer_size * max_sprite_count]GLfloat = undefined;
        const number_of_sprites: usize = params.len;
        if (number_of_sprites > max_sprite_count) { log(.critical, "Reached max sprite in draw call, aborting!", .{}); return; }
        render_data.shader.use();
        for (0..number_of_sprites) |i| {
            const p = &params[i];
            const dest_size_2d: Dim2 = p.dest_size orelse .{ .w = @floatFromInt(p.texture.width), .h = @floatFromInt(p.texture.height) };
            const dest_size: Vec3 = .{ .x = dest_size_2d.w, .y = dest_size_2d.h, .z = 1.0 };
            var model = p.global_matrix;
            model.scale2(dest_size);
            models[i] = model;

            const model_id: f32 = @floatFromInt(i);
            const texture_coords: TextureCoords = TextureCoords.generate(p.texture, &p.source_rect, p.flip_h, p.flip_v);

            // Create vertex data for the sprite.
            for (0..number_of_vertices) |j| {
                const use_s_min: bool = (j == 0 or j == 2 or j == 3);
                const use_t_min: bool = (j == 1 or j == 2 or j == 5);
                // Compute the offset (row) in the vertex array.
                const row: usize = (j * verts_stride) + (i * verts_stride * number_of_vertices);
                verts[row + 0] = model_id;
                verts[row + 1] = if (use_s_min) 0.0 else 1.0;
                verts[row + 2] = if (use_t_min) 0.0 else 1.0;
                verts[row + 3] = if (use_s_min) texture_coords.s_min else texture_coords.s_max;
                verts[row + 4] = if (use_t_min) texture_coords.t_min else texture_coords.t_max;
                verts[row + 5] = @as(GLfloat, p.modulate.r);
                verts[row + 6] = @as(GLfloat, p.modulate.g);
                verts[row + 7] = @as(GLfloat, p.modulate.b);
                verts[row + 8] = @as(GLfloat, p.modulate.a);
                verts[row + 9] = if(p.texture.using_nearest_neighbor) 1.0 else 0.0;
            }
        }
        render_data.shader.setUniformArray("models", []Mat4, &models, number_of_sprites);

        glad.glActiveTexture(glad.GL_TEXTURE0);
        glad.glBindTexture(glad.GL_TEXTURE_2D, params[0].texture.id);

        glad.glBufferData(glad.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(verts)), @ptrCast(&verts[0]), glad.GL_DYNAMIC_DRAW);
        glad.glDrawArrays(glad.GL_TRIANGLES, 0, @as(GLsizei, @intCast(number_of_sprites * number_of_vertices)));

        glad.glBindVertexArray(0);
    }
};

pub const DrawTextParams = struct {
    text: [:0]const u8,
    font: *Font,
    position: Vec2, // Global position
    scale: f32 = 1.0,
    color: LinearColor = LinearColor.White,
    z_index: i32 = 0,
};

const FontRenderer = struct {
    const font_vertex_shader_source =
        \\#version 330 core
        \\layout (location = 0) in vec4 vertex; // (pos, tex)
        \\
        \\out vec2 tex_coords;
        \\
        \\uniform mat4 projection;
        \\
        \\void main() {{
        \\    gl_Position = projection * vec4(vertex.xy, 0.0f, 1.0f);
        \\    tex_coords = vertex.zw;
        \\}}
        ;

    const font_fragment_shader_source =
        \\#version 330 core
        \\in vec2 tex_coords;
        \\
        \\out vec4 color;
        \\
        \\uniform sampler2D text_value;
        \\uniform vec4 text_color;
        \\
        \\void main() {{
        \\    vec4 sampled = vec4(1.0f, 1.0f, 1.0f, texture(text_value, tex_coords).r);
        \\    color = text_color * sampled;
        \\}}
        ;

    const InitializeError = error {
        FreeType,
    };

    var render_data: RenderData = .{};

    pub fn init() !void {
        if (ft.FT_Init_FreeType(&render_context.ft_instance) != 0) {
            log(.critical, "Unable to initialize FreeType library!", .{});
            return InitializeError.FreeType;
        }
        render_data.projection = math.ortho(0.0, @floatFromInt(render_context.resolution.w), @floatFromInt(-render_context.resolution.h), 0.0, -1.0, 1.0);
        render_data.shader = try Shader.compileNew(font_vertex_shader_source, font_fragment_shader_source);
        render_data.shader.use();
        render_data.shader.setUniform("text_value", i32, 0);
        render_data.shader.setUniform("projection", Mat4, render_data.projection);
    }

    pub fn deinit() void {
        _ = ft.FT_Done_FreeType(render_context.ft_instance);
    }

    pub fn drawText(p: *const DrawTextParams) void {
        render_data.shader.use();
        render_data.shader.setUniform("text_color", LinearColor, p.color);
        glad.glActiveTexture(glad.GL_TEXTURE0);
        glad.glBindVertexArray(p.font.vao);

        // Iterate over each character in the text.
        var x: f32 = p.position.x;
        const y: f32 = p.position.y;
        for (p.text) |c| {
            const ch = p.font.characters[@intCast(c)];
            const x_pos: f32 = x + @as(f32, @floatFromInt(ch.bearing.x)) * p.scale;
            const y_pos: f32 = -y - p.font.text_height - (@as(f32, @floatFromInt(@as(i32, @intCast(ch.size.y)) - ch.bearing.y)) * p.scale);
            const w: f32 = @as(f32, @floatFromInt(ch.size.x)) * p.scale;
            const h: f32 = @as(f32, @floatFromInt(ch.size.y)) * p.scale;
            // Update VBO for each characters
            const verts: [6][4]f32 = .{
                .{ x_pos,       y_pos + h, 0.0, 0.0 },
                .{ x_pos,       y_pos,     0.0, 1.0 },
                .{ x_pos + w,   y_pos,     1.0, 1.0 },

                .{ x_pos,       y_pos + h, 0.0, 0.0 },
                .{ x_pos + w,   y_pos,     1.0, 1.0 },
                .{ x_pos + w,   y_pos + h, 1.0, 0.0 },
            };

            // Bind the glyph's texture.
            glad.glBindTexture(glad.GL_TEXTURE_2D, ch.texture_id);
            glad.glBindBuffer(glad.GL_ARRAY_BUFFER, p.font.vbo);
            glad.glBufferSubData(glad.GL_ARRAY_BUFFER, 0, @sizeOf(@TypeOf(verts)), @ptrCast(&verts[0]));
            glad.glDrawArrays(glad.GL_TRIANGLES, 0, 6);
            // Advance the cursor for the next glyph.
            // (ch.advance >> 6) converts from 1/64 pixels to pixels.
            const advance_amount: u32 = @intCast(ch.advance >> 6);
            const advance_total: f32 = @floatFromInt(advance_amount);
            x += advance_total * p.scale;
        }

        glad.glBindBuffer(glad.GL_ARRAY_BUFFER, 0);
        glad.glBindVertexArray(0);
        glad.glBindTexture(glad.GL_TEXTURE_2D, 0);
    }
};

pub const DrawCommand = union(enum) {
    pub const BatchDrawSpritesParams = struct {
        params: FixedArrayList(DrawSpriteParams, 16) = FixedArrayList(DrawSpriteParams, 16).init(),
    };

    sprite: DrawSpriteParams,
    sprites: BatchDrawSpritesParams,
    text: DrawTextParams,

    pub inline fn getZIndex(self: *const @This()) i32 {
        return switch (self.*) {
            .sprite => |sprite| sprite.z_index,
            .sprites => |sprites| sprites.params.items[0].z_index,
            .text => |text| text.z_index,
        };
    }
};

const DrawCommandData = struct {
    command: DrawCommand,
    id: u32,
};

var draw_command_data: std.ArrayList(DrawCommandData) = undefined;
var draw_command_index: u32 = 0;

pub fn init(resolution: Dim2i) !void {
    draw_command_data = std.ArrayList(DrawCommandData).init(std.heap.page_allocator);
    render_context.resolution = resolution;
    glad.glEnable(glad.GL_CULL_FACE);
    glad.glEnable(glad.GL_BLEND);
    glad.glBlendFunc(glad.GL_SRC_ALPHA, glad.GL_ONE_MINUS_SRC_ALPHA);

    try SpriteRenderer.init();
    try FontRenderer.init();
}

pub fn deinit() void {
    SpriteRenderer.deinit();
    FontRenderer.deinit();
    draw_command_data.deinit();
}

pub inline fn getResolution() Dim2i {
    return render_context.resolution;
}

// TODO: Pre sort and batch draw calls

pub fn queueSpriteDraw(p: *const DrawSpriteParams) !void {
    try draw_command_data.append(.{
        .command = .{ .sprite = p.* },
        .id = draw_command_index,
    });
    draw_command_index += 1;
}

pub fn queueSpriteDraws(params: []const DrawSpriteParams) !void {
    var draw_sprites: DrawCommand.BatchDrawSpritesParams = .{};
    for (params) |p| {
        try draw_sprites.params.append(p);
    }
    try draw_command_data.append(.{
        .command = .{ .sprites = draw_sprites },
        .id = draw_command_index,
    });
    draw_command_index += 1;
}

pub fn queueTextDraw(p: *const DrawTextParams) !void {
    try draw_command_data.append(.{
        .command = .{ .text = p.* },
        .id = draw_command_index,
    });
    draw_command_index += 1;
}

pub fn processQueuedDrawCalls() void {
    const Local = struct {
        const EmptyContext = struct {};

        pub fn sortDrawCommands(data: []DrawCommandData) void {
            std.sort.insertion(DrawCommandData, data, EmptyContext{}, lessThan);
        }

        fn lessThan(_: EmptyContext, a: DrawCommandData, b: DrawCommandData) bool {
            const aZIndex: i32 = a.command.getZIndex();
            const bZIndex: i32 = b.command.getZIndex();
            return aZIndex < bZIndex or (aZIndex == bZIndex and a.id < b.id);
        }
    };

    Local.sortDrawCommands(draw_command_data.items);

    for (draw_command_data.items) |*data| {
        switch (data.command) {
            .sprite => SpriteRenderer.drawSprite(data.command.sprite),
            .sprites => SpriteRenderer.drawSprites(data.command.sprites.params.asSlice()),
            .text => FontRenderer.drawText(&data.command.text),
        }
    }
    draw_command_data.clearRetainingCapacity();
    draw_command_index = 0;
}
