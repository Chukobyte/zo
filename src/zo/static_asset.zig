///! Zig file used to embed assets at compile time

pub const StaticAsset = struct {
    ptr: *const anyopaque,
    len: usize,

    pub fn create(embedded: anytype) StaticAsset {
        return StaticAsset{
            .ptr = @ptrCast(embedded.ptr),
            .len = embedded.len,
        };
    }

    fn createInternal(comptime file_path: []const u8) StaticAsset {
        const embedded_file = @embedFile(file_path);
        return StaticAsset{
            .ptr = @ptrCast(embedded_file.ptr),
            .len = embedded_file.len,
        };
    }
};