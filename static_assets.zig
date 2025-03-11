///! Zig file used to embed assets at compile time

// Fonts
pub const default_font = EmbeddedAsset.create("assets/font/verdana.ttf");

// Images
pub const seika_idle_texture = EmbeddedAsset.create("assets/images/seika_idle0.png");

// Audio
pub const rainbow_orb_audio = EmbeddedAsset.create("assets/audio/rainbow_orb.wav");


const EmbeddedAsset = struct {
    ptr: *const anyopaque,
    len: usize,

    fn create(comptime file_path: []const u8) EmbeddedAsset {
        const embedded_file = @embedFile(file_path);
        return EmbeddedAsset{
            .ptr = @ptrCast(embedded_file.ptr),
            .len = embedded_file.len,
        };
    }
};