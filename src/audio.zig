const a = @cImport({
    @cInclude("zo_audio.h");
});

const ZoAudioSource = a.ZoAudioSource;

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

    pub fn initWav(file_path: []const u8) !@This() {
        const internal_audio_source: ?*ZoAudioSource = a.zo_audio_load_wav(file_path.ptr);
        if (internal_audio_source == null) {
            return AudioError.FailedToInitialize;
        }
    }

    pub fn initWavFromMemory(buffer: *const anyopaque, buffer_len: usize) !@This() {
        const internal_audio_source: ?*ZoAudioSource = a.zo_audio_load_wav_from_memory(buffer, buffer_len);
        if (internal_audio_source == null) {
            return AudioError.FailedToInitialize;
        }
    }
};

pub fn init() !void {
    if (!a.zo_audio_init()) {
        return AudioError.FailedToInitialize;
    }
}

pub fn deinit() void {
    a.zo_audio_deinit();
}
