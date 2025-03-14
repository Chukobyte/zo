const a = @cImport({
    @cInclude("zo_audio.h");
});

const ZoAudioSource = a.ZoAudioSource;

const AudioError = error {
    FailedToInitialize,
    FailedToPlay,
};

pub const AudioSource = struct {
    audio_source: *ZoAudioSource, // Internal audio source defined in c, can most likely replace with zig implementation post 0.15.0

    pub fn initWav(file_path: []const u8) !@This() {
        const internal_audio_source: ?*ZoAudioSource = a.zo_audio_load_wav(file_path.ptr);
        if (internal_audio_source == null) {
            return AudioError.FailedToInitialize;
        }
        return @This(){ .audio_source = internal_audio_source.? };
    }

    pub fn initWavFromMemory(buffer: *const anyopaque, buffer_len: usize) !@This() {
        const internal_audio_source: ?*ZoAudioSource = a.zo_audio_load_wav_from_memory(buffer, buffer_len);
        if (internal_audio_source == null) {
            return AudioError.FailedToInitialize;
        }
        return @This(){ .audio_source = internal_audio_source.? };
    }

    pub fn deinit(self: *@This()) void {
        a.zo_audio_delete_audio_source(self.audio_source);
    }

    pub fn play(self: *@This(), does_loop: bool) !void {
        if (!a.zo_audio_play(self.audio_source, does_loop)) {
            return AudioError.FailedToPlay;
        }
    }

    pub fn stop(self: @This()) void {
        a.zo_audio_stop(self.audio_source);
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
