#pragma once

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

typedef size_t usize;

typedef int16_t int16;
typedef int16_t i16;
typedef int32_t int32;
typedef int32_t i32;
typedef int64_t int64;
typedef int64_t i64;

typedef uint32_t uint32;
typedef uint32_t u32;
typedef uint64_t uint64;
typedef uint64_t u64;

typedef float f32;
typedef double f64;

typedef struct ZoAudioSource {
    const char* file_path;
    f64 pitch;
    i32 channels;
    i32 sample_rate;
    void* samples;
    i32 sample_count;
    u32 dataId;
} ZoAudioSource;

