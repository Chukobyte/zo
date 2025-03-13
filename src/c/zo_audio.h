#pragma once

#include "zo_defines.h"

typedef struct ZoAudioSource {
    const char* file_path;
    f64 pitch;
    i32 channels;
    u32 sample_rate;
    void* samples;
    i32 sample_count;
    u32 dataId;
} ZoAudioSource;

// Initialize audio library
bool zo_audio_init();
// Deinitialize audio library
void zo_audio_deinit();
// Load wav from file path
ZoAudioSource* zo_audio_load_wav(const char* file_path);
// Load wav from memory
ZoAudioSource* zo_audio_load_wav_from_memory(const void* buffer, size_t buffer_len);
// Delete audio source
void zo_audio_delete_audio_source(ZoAudioSource* source);
// Play audio source
void zo_audio_play(ZoAudioSource* source, bool doesLoop);
// Stop audio source if playing
void zo_audio_stop(ZoAudioSource* source);
