const ma = @cImport({
    @cDefine("MINIAUDIO_IMPLEMENTATION", {});
    @cInclude("miniaudio.h");
});

const ma_uint32 = ma.ma_uint32;

fn audio_data_callback(_: ?*anyopaque, _: ?*anyopaque, _: ?*const anyopaque, _: ma_uint32) callconv(.c) void {}

const AudioError = error {
    FailedToInitialize,
};

var audio_device: ma.ma_device = undefined;

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
    config.playback.format = ma.ma_format_s16;
    config.playback.channels = 2;
    config.capture.pDeviceID = null;
    config.capture.format = ma.ma_format_s16;
    config.capture.channels = 1;
    config.sampleRate = 0; // miniaudio chooses the best sample rate
    config.dataCallback = audio_data_callback;
    config.pUserData = null;
    // if (ma.ma_device_init(null, &config, &audio_device) != ma.MA_SUCCESS) {
    //     return AudioError.FailedToInitialize;
    // }
    // if (ma.ma_device_start(&audio_device) != ma.MA_SUCCESS) {
    //     return AudioError.FailedToInitialize;
    // }
}

pub fn deinit() void {
    // ma.ma_device_uninit(&audio_device);
}
