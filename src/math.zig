const std = @import("std");

// Vector2
pub fn Vector2(comptime T: type) type {
    return struct {
        x: T = @as(T, 0),
        y: T = @as(T, 0),

        pub const Zero = @This(){ .x = @as(T, 0), .y = @as(T, 0) };
        pub const One = @This(){ .x = @as(T, 1), .y = @as(T, 1) };
        pub const Left = @This(){ .x = @as(T, -1), .y = @as(T, 0) };
        pub const Right = @This(){ .x = @as(T, 1), .y = @as(T, 0) };
        pub const Up = @This(){ .x = @as(T, 0), .y = @as(T, -1) };
        pub const Down = @This(){ .x = @as(T, 0), .y = @as(T, 1) };

        pub fn equals(a: *const @This(), b: *const @This()) bool {
            return a.x == b.x and a.y == b.y;
        }

        pub fn add(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x + b.x,
                .y = a.y + b.y,
            };
        }

        pub fn sub(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x - b.x,
                .y = a.y - b.y,
            };
        }

        pub fn div(a: *const @This(), b: *const @This()) @This() {
            std.debug.assert(b.x != 0 and b.y != 0);
            return @This(){
                .x = a.x / b.x,
                .y = a.y / b.y,
            };
        }

        pub fn mult(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x * b.x,
                .y = a.y * b.y,
            };
        }
    };
}

pub const Vec2 = Vector2(f32);
pub const Vec2f = Vec2;
pub const Vec2i = Vector2(i32);
pub const Vec2u = Vector2(u32);

// Vector3
pub fn Vector3(comptime T: type) type {
    return struct {
        x: T = @as(T, 0),
        y: T = @as(T, 0),
        z: T = @as(T, 0),

        pub const Zero = @This(){ .x = @as(T, 0), .y = @as(T, 0), .z = @as(T, 0) };
        pub const One = @This(){ .x = @as(T, 1), .y = @as(T, 1), .z = @as(T, 1) };

        pub fn equals(a: *const @This(), b: *const @This()) bool {
            return a.x == b.x and a.y == b.y and a.z == b.z;
        }

        pub fn add(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x + b.x ,
                .y = a.y + b.y,
                .z = a.z + b.z,
            };
        }

        pub fn sub(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
            };
        }

        pub fn div(a: *const @This(), b: *const @This()) @This() {
            std.debug.assert(b.x != 0 and b.y != 0 and b.z != 0);
            return @This(){
                .x = a.x / b.x,
                .y = a.y / b.y,
                .z = a.z / b.z,
            };
        }

        pub fn mult(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x * b.x,
                .y = a.y * b.y,
                .z = a.z * b.z,
            };
        }
    };
}

pub const Vec3 = Vector3(f32);
pub const Vec3f = Vec3;
pub const Vec3i = Vector3(i32);
pub const Vec3u = Vector3(u32);

// Vector4
pub fn Vector4(comptime T: type) type {
    return struct {
        x: T = @as(T, 0),
        y: T = @as(T, 0),
        z: T = @as(T, 0),
        w: T = @as(T, 0),

        pub const Zero = @This(){
            .x = @as(T, 0),
            .y = @as(T, 0),
            .z = @as(T, 0),
            .w = @as(T, 0),
        };
        pub const One = @This(){
            .x = @as(T, 1),
            .y = @as(T, 1),
            .z = @as(T, 1),
            .w = @as(T, 1),
        };

        pub fn equals(a: *const @This(), b: *const @This()) bool {
            return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w;
        }

        pub fn add(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x + b.x,
                .y = a.y + b.y,
                .z = a.z + b.z,
                .w = a.w + b.w,
            };
        }

        pub fn sub(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
                .w = a.w - b.w,
            };
        }

        pub fn mult(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .x = a.x * b.x,
                .y = a.y * b.y,
                .z = a.z * b.z,
                .w = a.w * b.w,
            };
        }

        pub fn div(a: *const @This(), b: *const @This()) @This() {
            std.debug.assert(b.x != 0 and b.y != 0 and b.z != 0 and b.w != 0);
            return @This(){
                .x = a.x / b.x,
                .y = a.y / b.y,
                .z = a.z / b.z,
                .w = a.w / b.w,
            };
        }
    };
}

pub const Vec4 = Vector4(f32);
pub const Vec4f = Vec4;
pub const Vec4i = Vector4(i32);
pub const Vec4u = Vector4(u32);

/// Matrix4
pub fn Matrix4(comptime T: type) type {
    return struct {
        /// data[column][row] in column-major order
        data: [4][4]T, // column-major order

        pub const Identity = @This(){
            .data = [_][4]T{
                .{ @as(T, 1), @as(T, 0), @as(T, 0), @as(T, 0) }, // Column 0
                .{ @as(T, 0), @as(T, 1), @as(T, 0), @as(T, 0) }, // Column 1
                .{ @as(T, 0), @as(T, 0), @as(T, 1), @as(T, 0) }, // Column 2
                .{ @as(T, 0), @as(T, 0), @as(T, 0), @as(T, 1) }, // Column 3
            },
        };

        pub fn equals(a: *const @This(), b: *const @This()) bool {
            for (a.data, 0..4) |col, i| {
                for (col, 0..4) |elem, j| {
                    if (elem != b.data[i][j]) return false;
                }
            }
            return true;
        }

        pub fn add(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .data = [_][4]T{
                    .{ a.data[0][0] + b.data[0][0], a.data[0][1] + b.data[0][1], a.data[0][2] + b.data[0][2], a.data[0][3] + b.data[0][3] },
                    .{ a.data[1][0] + b.data[1][0], a.data[1][1] + b.data[1][1], a.data[1][2] + b.data[1][2], a.data[1][3] + b.data[1][3] },
                    .{ a.data[2][0] + b.data[2][0], a.data[2][1] + b.data[2][1], a.data[2][2] + b.data[2][2], a.data[2][3] + b.data[2][3] },
                    .{ a.data[3][0] + b.data[3][0], a.data[3][1] + b.data[3][1], a.data[3][2] + b.data[3][2], a.data[3][3] + b.data[3][3] },
                },
            };
        }

        pub fn sub(a: *const @This(), b: *const @This()) @This() {
            return @This(){
                .data = [_][4]T{
                    .{ a.data[0][0] - b.data[0][0], a.data[0][1] - b.data[0][1], a.data[0][2] - b.data[0][2], a.data[0][3] - b.data[0][3] },
                    .{ a.data[1][0] - b.data[1][0], a.data[1][1] - b.data[1][1], a.data[1][2] - b.data[1][2], a.data[1][3] - b.data[1][3] },
                    .{ a.data[2][0] - b.data[2][0], a.data[2][1] - b.data[2][1], a.data[2][2] - b.data[2][2], a.data[2][3] - b.data[2][3] },
                    .{ a.data[3][0] - b.data[3][0], a.data[3][1] - b.data[3][1], a.data[3][2] - b.data[3][2], a.data[3][3] - b.data[3][3] },
                },
            };
        }

        pub fn mul(a: *const @This(), b: *const @This()) @This() {
            var result: [4][4]T = undefined;
            for (0..4) |c| {
                for (0..4) |r| {
                    var sum: T = @as(T, 0);
                    for (0..4) |k| {
                        // a.data[k][r] is element (r,k) of a; b.data[c][k] is element (k,c) of b.
                        sum += a.data[k][r] * b.data[c][k];
                    }
                    result[c][r] = sum;
                }
            }
            return @This(){ .data = result };
        }


        /// In-place multiplication: self = self * b
        pub fn mul2(self: *@This(), b: *const @This()) void {
            self.* = self.mul(b);
        }

        /// Translation: For column-major, translation is stored in the fourth column.
        pub fn translate(self: *@This(), v: Vec3) void {
            self.data[3][0] = v.x;
            self.data[3][1] = v.y;
            self.data[3][2] = v.z;
        }

        /// Multiply self by a translation matrix.
        pub fn translate2(self: *@This(), v: Vec3) void {
            var transMat = @This().Identity;
            transMat.translate(v);
            self.mul2(&transMat);
        }

        /// Rotation along the Z axis.
        pub fn rotateZ(self: *@This(), angle_rad: f32) void {
            const c = std.math.cos(angle_rad);
            const s = std.math.sin(angle_rad);
            self.data[0][0] = c;
            self.data[0][1] = s;
            self.data[1][0] = -s;
            self.data[1][1] = c;
        }

        /// Rotate along the Z axis and multiply
        pub fn rotateZ2(self: *@This(), angle_rad: f32) void {
            var rotMat = @This().Identity;
            rotMat.rotateZ(angle_rad);
            self.mul2(&rotMat);
        }

        /// Scale
        pub fn scale(self: *@This(), v: Vec3) void {
            self.data[0][0] = v.x;
            self.data[1][1] = v.y;
            self.data[2][2] = v.z;
        }

        /// Scale and multiply
        pub fn scale2(self: *@This(), v: Vec3) void {
            var scaleMat = @This().Identity;
            scaleMat.scale(v);
            self.mul2(&scaleMat);
        }

        pub fn determinant(self: *const @This()) f32 {
            const Local = struct {
                fn det3(m: [3][3]f32) f32 {
                    return m[0][0]*(m[1][1]*m[2][2] - m[1][2]*m[2][1])
                        - m[0][1]*(m[1][0]*m[2][2] - m[1][2]*m[2][0])
                        + m[0][2]*(m[1][0]*m[2][1] - m[1][1]*m[2][0]);
                }
            };
            var m0: [3][3]f32 = undefined;
            m0[0] = .{ self.data[1][0], self.data[1][1], self.data[1][2] };
            m0[1] = .{ self.data[2][0], self.data[2][1], self.data[2][2] };
            m0[2] = .{ self.data[3][0], self.data[3][1], self.data[3][2] };
            const det0 = self.data[0][0] * Local.det3(m0);

            var m1: [3][3]f32 = undefined;
            m1[0] = .{ self.data[1][0], self.data[1][1], self.data[1][3] };
            m1[1] = .{ self.data[2][0], self.data[2][1], self.data[2][3] };
            m1[2] = .{ self.data[3][0], self.data[3][1], self.data[3][3] };
            const det1 = self.data[0][1] * Local.det3(m1);

            var m2: [3][3]f32 = undefined;
            m2[0] = .{ self.data[1][0], self.data[1][2], self.data[1][3] };
            m2[1] = .{ self.data[2][0], self.data[2][2], self.data[2][3] };
            m2[2] = .{ self.data[3][0], self.data[3][2], self.data[3][3] };
            const det2 = self.data[0][2] * Local.det3(m2);

            var m3: [3][3]f32 = undefined;
            m3[0] = .{ self.data[1][1], self.data[1][2], self.data[1][3] };
            m3[1] = .{ self.data[2][1], self.data[2][2], self.data[2][3] };
            m3[2] = .{ self.data[3][1], self.data[3][2], self.data[3][3] };
            const det3_val = self.data[0][3] * Local.det3(m3);

            return det0 - det1 + det2 - det3_val;
        }
    };
}

pub const Mat4 = Matrix4(f32);
pub const Mat4f = Mat4;


// Transform2D
pub fn Transformation2D(comptime PosT: type, comptime ScaleT: type, comptime RotT: type) type {
    return struct {
        position: Vector2(PosT) = Vector2(PosT){},
        scale: Vector2(ScaleT) = Vector2(ScaleT){ .x = @as(ScaleT, 1), .y = @as(ScaleT, 1) },
        rotation: RotT = @as(RotT, 0),

        // Defaults to identity, so just create an empty struct
        pub const Identity = @This(){};
    };
}

pub const Transform2D = Transformation2D(f32, f32, f32);

// Rect2
pub fn Rectangle2(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        w: T,
        h: T,

        pub fn doesOverlap(self: *const @This(), other: *const @This()) bool {
            return !(
            self.x > other.x + other.w or
                self.x + self.w < other.x or
                self.y > other.y + other.h or
                self.y + self.h < other.y
            );
        }
    };
}

pub const Rect2 = Rectangle2(f32);
pub const Rect2f = Rect2;
pub const Rect2i = Rectangle2(i32);
pub const Rect2u = Rectangle2(u32);

// Color
pub const Color = struct {
    r: u32,
    g: u32,
    b: u32,
    a: u32 = 255,

    pub const Black = @This(){ .r = 0, .g = 0, .b = 0 };
    pub const White = @This(){ .r = 255, .g = 255, .b = 255 };
    pub const Red = @This(){ .r = 255, .g = 0, .b = 0 };
    pub const Green = @This(){ .r = 0, .g = 255, .b = 0 };
    pub const Blue = @This(){ .r = 0, .g = 0, .b = 255 };
};

pub const LinearColor = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32 = 1.0,
};

/// Map a value from one range to another
pub inline fn mapToRange(comptime T: type, input: T, input_min: T, input_max: T, output_min: T, output_max: T) T {
    return (((input - input_min) / (input_max - input_min)) * (output_max - output_min) + output_min);
}

/// Creates an orthographic projection matrix
pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, nearZ: f32, farZ: f32) Mat4 {
    return Mat4{
        .data = [_][4]f32{
            .{ 2.0 / (right - left), 0.0, 0.0, 0.0 },
            .{ 0.0, 2.0 / (top - bottom), 0.0, 0.0 },
            .{ 0.0, 0.0, -2.0 / (farZ - nearZ), 0.0 },
            .{ -(right + left) / (right - left), -(top + bottom) / (top - bottom), -(farZ + nearZ) / (farZ - nearZ), 1.0 },
        },
    };
}
