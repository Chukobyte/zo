const ma = @cImport({
    @cDefine("MINIAUDIO_IMPLEMENTATION", {});
    @cInclude("miniaudio.h");
});

pub fn init() !void {}

pub fn deinit() void {}
