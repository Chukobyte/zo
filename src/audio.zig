const ma = @cImport({
    @cDefine("MINIAUDIO_IMPLEMENTATION", {});
    @cInclude("miniaudio.h");
});

pub const AudioSource = struct {
    pitch: f64,
    channels: i32,
    sample_rate: i32,
    samples: [*c]anyopaque,
    sample_count: i32,
    data_id: u32,
    file_path: ?[]u8,

    pub fn initWav(_: []const u8) !@This() {}
    pub fn initWavFromMemory(_: *const anyopaque, _: usize) !@This() {}
};

pub fn init() !void {
    var config: ma.ma_device_config = ma.ma_device_config_init(ma.ma_device_type_playback);
    config.playback.pDeviceID = null;
}

pub fn deinit() void {}
