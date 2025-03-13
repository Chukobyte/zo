///! Zig file used to embed assets at compile time

// Fonts
pub const default_font = StaticAsset.create("assets/fonts/verdana.ttf");

// Images
pub const seika_idle_texture = StaticAsset.create("assets/images/seika_idle0.png");

// Audio
pub const rainbow_orb_audio = StaticAsset.create("assets/audio/rainbow_orb.wav");


const StaticAsset = struct {
    ptr: *const anyopaque,
    len: usize,

    fn create(comptime file_path: []const u8) StaticAsset {
        const embedded_file = @embedFile(file_path);
        return StaticAsset{
            .ptr = @ptrCast(embedded_file.ptr),
            .len = embedded_file.len,
        };
    }
};