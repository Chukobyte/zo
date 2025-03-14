#include "zo_audio.h"

#define MINIAUDIO_IMPLEMENTATION
#include <miniaudio.h>

#define ZO_MAX_AUDIO_SOURCES 64
#define ZO_MAX_AUDIO_INSTANCES 32

static ZoAudioSource* load_wav_from_data(const void* buffer, size_t buffer_len);
static void audio_data_callback(void* device, void* output, const void* input, ma_uint32 frame_count);
static bool resample_audio(ZoAudioSource* audio_source);
static char* read_file_contents(const char* file_path, usize* size);
static usize get_file_size(const char* file_path);

typedef struct ZoAudioInstance {
    ZoAudioSource* source;
    bool is_playing;
    bool does_loop;
    f64 sample_position;
    bool is_active;
} ZoAudioInstance;

static ma_device audio_device;
static uint32 audio_wav_sample_rate = 0;
static ZoAudioInstance audio_instances[ZO_MAX_AUDIO_INSTANCES];
static usize audio_instances_count = 0;

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
  audio_wav_sample_rate = audio_device.sampleRate;

  return true;
}

void zo_audio_deinit() {
  ma_device_uninit(&audio_device);
}

ZoAudioSource* zo_audio_load_wav(const char* file_path) {
  usize len = 0;
  char* file_data = read_file_contents(file_path, &len);
  if (!file_data) {
      return NULL;
  }
  ZoAudioSource* new_audio_source = load_wav_from_data(file_data, len);
  if (!new_audio_source) {
      return NULL;
  }
  new_audio_source->file_path = file_path;
  return new_audio_source;
}

ZoAudioSource* zo_audio_load_wav_from_memory(const void* buffer, size_t buffer_len) {
  return load_wav_from_data(buffer, buffer_len);
}

void zo_audio_delete_audio_source(ZoAudioSource* source) {}

bool zo_audio_play(ZoAudioSource* source, bool doesLoop) {
    if (audio_instances_count >= ZO_MAX_AUDIO_INSTANCES) {
        return false;
    }
    ZoAudioInstance* audio_instance = &audio_instances[audio_instances_count++];
    audio_instance->source = source;
    audio_instance->does_loop = doesLoop;
    audio_instance->sample_position = 0.0f;
    audio_instance->is_playing = true;
    audio_instance->is_active = true;
    return true;
}

void zo_audio_stop(ZoAudioSource* source) {
    for (usize i = 0; i < audio_instances_count; i++) {
        ZoAudioInstance* audio_instance = &audio_instances[i];
        if (audio_instance->source == source) {
            audio_instance->is_playing = false;
            break;
        }
    }
}

ZoAudioSource* load_wav_from_data(const void* buffer, size_t buffer_len) {
    i32 sample_count;
    u32 channels;
    u32 sample_rate;
    drwav_uint64 totalPcmFrameCount = 0;

    void* samples = drwav_open_memory_and_read_pcm_frames_s16(buffer, buffer_len, &channels, &sample_rate, &totalPcmFrameCount, NULL);
    if (!samples) {
        // TODO: Either log error or return an error enum
        return NULL;
    }

    sample_count = (int32)totalPcmFrameCount * channels;

    ZoAudioSource* new_audio_source = malloc(sizeof(ZoAudioSource));
    // For memory loaded audio, file_path may be NULL or a descriptive identifier.
    new_audio_source->file_path = NULL;
    new_audio_source->pitch = 1.0;
    new_audio_source->sample_count = sample_count;
    new_audio_source->sample_rate = sample_rate;
    new_audio_source->channels = channels;
    new_audio_source->samples = samples;

    // Resample if the sample rate is different from the audio device's sample rate.
    if (new_audio_source->sample_rate != audio_wav_sample_rate) {
        if (!resample_audio(new_audio_source)) {
            return NULL;
        }
    }
    return new_audio_source;
}

void audio_data_callback(void* device, void* output, const void* input, ma_uint32 frame_count) {
    if (audio_instances_count == 0) {
        return;
    }
    ma_device* audio_device = (ma_device*)device;
    memset(output, 0, frame_count * audio_device->playback.channels * ma_get_bytes_per_sample(audio_device->playback.format));
    usize removed_instances = 0;
    for (usize i = 0; i < audio_instances_count; i++) {
        ZoAudioInstance* audio_instance = &audio_instances[i];
        if (!audio_instance->is_playing) {
            audio_instance->is_active = false;
            removed_instances++;
            continue;
        }

        const int32 channels = audio_instance->source->channels;
        const f64 pitch = audio_instance->source->pitch;
        int16* sampleOut = (int16*)output;
        const int16* samples = (int16*)audio_instance->source->samples;
        const uint64 samplesToWrite = (uint64)frame_count;

        // Write to output
        for (uint64 writeSample = 0; writeSample < samplesToWrite; writeSample++) {
            const f64 startSamplePosition = audio_instance->sample_position;

            uint64 curIndex = (uint64) startSamplePosition;
            if (channels > 1) {
                curIndex &= ~((uint64)0x01);
            }
            const uint64 nextIndex = (curIndex + channels) % audio_instance->source->sample_count;
            const uint64 leftIndexNext = nextIndex;
            const uint64 rightIndexNext = nextIndex + 1;
            const int16 sampleLeftNext = samples[leftIndexNext];
            const int16 sampleRightNext = samples[rightIndexNext];

            *sampleOut++ += sampleLeftNext;
            *sampleOut++ += sampleRightNext;

            // Update the instance's sample position and clamp it
            const f64 targetSamplePosition = startSamplePosition + (f64)channels * pitch;
            audio_instance->sample_position = fmod(targetSamplePosition, audio_instance->source->sample_count);

            // Check if the raw target sample position has passed boundary
            if (targetSamplePosition >= (f64)audio_instance->source->sample_count - channels) {
                audio_instance->sample_position = 0.0;
                if (!audio_instance->does_loop) {
                    audio_instance->is_playing = false;
                    audio_instance->is_active = false;
                    removed_instances++;
                    break;
                }
            }
        }
    }

    // Reshuffle array and update count if data sources have been removed
    if (removed_instances > 0) {
        static ZoAudioInstance tempAudioInstances[ZO_MAX_AUDIO_INSTANCES];
        usize newCount = 0;
        // Place active instances in temp array
        for (usize i = 0; i < audio_instances_count; i++) {
            if (audio_instances[i].is_active) {
                tempAudioInstances[newCount++] = audio_instances[i];
            }
        }
        // Now fill up regular array
        for (usize i = 0; i < newCount; i++) {
            audio_instances[i] = tempAudioInstances[i];
        }
        audio_instances_count = newCount;
    }
}

bool resample_audio(ZoAudioSource* audio_source) {
    const int32 inputFrameCount = audio_source->sample_count / audio_source->channels;
    const f64 resampleRatio = (f64)audio_wav_sample_rate / audio_source->sample_rate;
    const int32 outputFrameCount = (int32)(inputFrameCount * resampleRatio);

    int16* resampledSamples = malloc(outputFrameCount * audio_source->channels * sizeof(int16));
    if (!resampledSamples) {
        free(audio_source->samples);
        free(audio_source);
        return false;
    }

    ma_data_converter_config converterConfig = ma_data_converter_config_init(
        ma_format_s16, ma_format_s16, audio_source->channels, audio_source->channels,
        audio_source->sample_rate, audio_wav_sample_rate
    );
    ma_data_converter converter;
    if (ma_data_converter_init(&converterConfig, NULL, &converter) != MA_SUCCESS) {
        free(audio_source->samples);
        free(resampledSamples);
        free(audio_source);
        return false;
    }

    ma_uint64 inFrames = inputFrameCount;
    ma_uint64 outFrames = outputFrameCount;
    if (ma_data_converter_process_pcm_frames(&converter, resampledSamples, &outFrames, audio_source->samples, &inFrames) != MA_SUCCESS) {
        free(audio_source->samples);
        free(resampledSamples);
        ma_data_converter_uninit(&converter, NULL);
        free(audio_source);
        return false;
    }
    ma_data_converter_uninit(&converter, NULL);
    free(audio_source->samples);
    audio_source->samples = resampledSamples;
    audio_source->sample_rate = (int32)audio_wav_sample_rate;
    audio_source->sample_count = (int32)outFrames * audio_source->channels;
    return true;
}

char* read_file_contents(const char* file_path, usize* size) {
  char* buffer = NULL;
  FILE* fp = fopen(file_path, "rb");
  usize read_size = 0;
  if (fp) {
    read_size = get_file_size(file_path);
    if (read_size == 0) { return NULL; }
    // Update buffer
    buffer = (char*)malloc(read_size + 1);
    if (buffer != NULL) {
      fread(buffer, 1, read_size, fp);
      buffer[read_size] = '\0';
    }
    fclose(fp);
  }
  if (size != NULL) {
    *size = read_size;
  }
  return buffer;
}

usize get_file_size(const char* filePath) {
#ifdef _WIN32
  HANDLE hFile = CreateFile(filePath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (hFile == INVALID_HANDLE_VALUE) {
    return 0;
  }

  LARGE_INTEGER size;
  if (!GetFileSizeEx(hFile, &size)) {
    CloseHandle(hFile);
    return 0;
  }

  CloseHandle(hFile);
  return (usize) size.QuadPart;
#else
  struct stat st;
  stat(filePath, &st);
  return (usize) st.st_size;
#endif
}
