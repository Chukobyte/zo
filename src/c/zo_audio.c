#include "zo_audio.h"

#define MINIAUDIO_IMPLEMENTATION
#include <miniaudio.h>

#define ZO_MAX_AUDIO_SOURCES 64
#define ZO_MAX_AUDIO_INSTANCES 32

static void audio_data_callback(void* device, void* output, const void* input, ma_uint32 frame_count);

static ma_device audio_device;

bool zo_audio_init() {
  // Device
  ma_device_config config = ma_device_config_init(ma_device_type_playback);
  config.playback.pDeviceID = NULL;
  config.playback.format = ma_format_s16;
  config.playback.channels = 2;
  config.capture.pDeviceID = NULL;
  config.capture.format = ma_format_s16;
  config.capture.channels = 1;
  config.sampleRate = 0; // Allow miniaudio to choose sample rate
  config.dataCallback = audio_data_callback;
  config.pUserData = NULL;
  if (ma_device_init(NULL, &config, &audio_device) != MA_SUCCESS) {
    return false;
  }
  if (ma_device_start(&audio_device) != MA_SUCCESS) {
    return false;
  }

  return true;
}

void zo_audio_deinit() {
  ma_device_uninit(&audio_device);
}

ZoAudioSource* zo_audio_load_wav(const char* file_path) {
  return NULL;
}

ZoAudioSource* zo_audio_load_wav_from_memory(const void* buffer, size_t buffer_len) {
  return NULL;
}

void zo_audio_delete_audio_source(ZoAudioSource* source) {}

void zo_audio_play(ZoAudioSource* source, bool doesLoop) {}

void zo_audio_stop(ZoAudioSource* source) {}

void audio_data_callback(void* device, void* output, const void* input, ma_uint32 frame_count) {
  ma_device* audio_device = (ma_device*)device;
}
