const a = @cImport({
    @cInclude("zo_audio.h");
});

const AudioError = error {
    FailedToInitialize,
};

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
    if (!a.zo_audio_init()) {
        return AudioError.FailedToInitialize;
    }
}

pub fn deinit() void {
    a.zo_audio_deinit();
}
