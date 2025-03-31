///! Zig file used to embed assets at compile time

const StaticAsset = @import("zo").StaticAsset;

// Fonts
pub const default_font = StaticAsset.create(@embedFile("assets/fonts/pixeloid_sans.ttf"));

// Images
pub const map_texture = StaticAsset.create(@embedFile("assets/images/map_mockup.png"));

// Audio
pub const click_audio = StaticAsset.create(@embedFile("assets/audio/click.wav"));
pub const invalid_click_audio = StaticAsset.create(@embedFile("assets/audio/invalid_click.wav"));
