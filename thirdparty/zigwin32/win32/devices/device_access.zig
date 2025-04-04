//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (45)
//--------------------------------------------------------------------------------
pub const ED_BASE = @as(i32, 4096);
pub const DEV_PORT_SIM = @as(u32, 1);
pub const DEV_PORT_COM1 = @as(u32, 2);
pub const DEV_PORT_COM2 = @as(u32, 3);
pub const DEV_PORT_COM3 = @as(u32, 4);
pub const DEV_PORT_COM4 = @as(u32, 5);
pub const DEV_PORT_DIAQ = @as(u32, 6);
pub const DEV_PORT_ARTI = @as(u32, 7);
pub const DEV_PORT_1394 = @as(u32, 8);
pub const DEV_PORT_USB = @as(u32, 9);
pub const DEV_PORT_MIN = @as(u32, 1);
pub const DEV_PORT_MAX = @as(u32, 9);
pub const ED_TOP = @as(u32, 1);
pub const ED_MIDDLE = @as(u32, 2);
pub const ED_BOTTOM = @as(u32, 4);
pub const ED_LEFT = @as(u32, 256);
pub const ED_CENTER = @as(u32, 512);
pub const ED_RIGHT = @as(u32, 1024);
pub const ED_AUDIO_ALL = @as(u32, 268435456);
pub const ED_AUDIO_1 = @as(i32, 1);
pub const ED_AUDIO_2 = @as(i32, 2);
pub const ED_AUDIO_3 = @as(i32, 4);
pub const ED_AUDIO_4 = @as(i32, 8);
pub const ED_AUDIO_5 = @as(i32, 16);
pub const ED_AUDIO_6 = @as(i32, 32);
pub const ED_AUDIO_7 = @as(i32, 64);
pub const ED_AUDIO_8 = @as(i32, 128);
pub const ED_AUDIO_9 = @as(i32, 256);
pub const ED_AUDIO_10 = @as(i32, 512);
pub const ED_AUDIO_11 = @as(i32, 1024);
pub const ED_AUDIO_12 = @as(i32, 2048);
pub const ED_AUDIO_13 = @as(i32, 4096);
pub const ED_AUDIO_14 = @as(i32, 8192);
pub const ED_AUDIO_15 = @as(i32, 16384);
pub const ED_AUDIO_16 = @as(i32, 32768);
pub const ED_AUDIO_17 = @as(i32, 65536);
pub const ED_AUDIO_18 = @as(i32, 131072);
pub const ED_AUDIO_19 = @as(i32, 262144);
pub const ED_AUDIO_20 = @as(i32, 524288);
pub const ED_AUDIO_21 = @as(i32, 1048576);
pub const ED_AUDIO_22 = @as(i32, 2097152);
pub const ED_AUDIO_23 = @as(i32, 4194304);
pub const ED_AUDIO_24 = @as(i32, 8388608);
pub const ED_VIDEO = @as(i32, 33554432);
pub const CLSID_DeviceIoControl = Guid.initString("12d3e372-874b-457d-9fdf-73977778686c");

//--------------------------------------------------------------------------------
// Section: Types (3)
//--------------------------------------------------------------------------------
const IID_IDeviceRequestCompletionCallback_Value = Guid.initString("999bad24-9acd-45bb-8669-2a2fc0288b04");
pub const IID_IDeviceRequestCompletionCallback = &IID_IDeviceRequestCompletionCallback_Value;
pub const IDeviceRequestCompletionCallback = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Invoke: *const fn(
            self: *const IDeviceRequestCompletionCallback,
            requestResult: HRESULT,
            bytesReturned: u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn Invoke(self: *const IDeviceRequestCompletionCallback, requestResult: HRESULT, bytesReturned: u32) callconv(.Inline) HRESULT {
        return self.vtable.Invoke(self, requestResult, bytesReturned);
    }
};

const IID_IDeviceIoControl_Value = Guid.initString("9eefe161-23ab-4f18-9b49-991b586ae970");
pub const IID_IDeviceIoControl = &IID_IDeviceIoControl_Value;
pub const IDeviceIoControl = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        DeviceIoControlSync: *const fn(
            self: *const IDeviceIoControl,
            ioControlCode: u32,
            inputBuffer: ?[*:0]u8,
            inputBufferSize: u32,
            outputBuffer: ?[*:0]u8,
            outputBufferSize: u32,
            bytesReturned: ?*u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        DeviceIoControlAsync: *const fn(
            self: *const IDeviceIoControl,
            ioControlCode: u32,
            inputBuffer: ?[*:0]u8,
            inputBufferSize: u32,
            outputBuffer: ?[*:0]u8,
            outputBufferSize: u32,
            requestCompletionCallback: ?*IDeviceRequestCompletionCallback,
            cancelContext: ?*usize,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        CancelOperation: *const fn(
            self: *const IDeviceIoControl,
            cancelContext: usize,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn DeviceIoControlSync(self: *const IDeviceIoControl, ioControlCode: u32, inputBuffer: ?[*:0]u8, inputBufferSize: u32, outputBuffer: ?[*:0]u8, outputBufferSize: u32, bytesReturned: ?*u32) callconv(.Inline) HRESULT {
        return self.vtable.DeviceIoControlSync(self, ioControlCode, inputBuffer, inputBufferSize, outputBuffer, outputBufferSize, bytesReturned);
    }
    pub fn DeviceIoControlAsync(self: *const IDeviceIoControl, ioControlCode: u32, inputBuffer: ?[*:0]u8, inputBufferSize: u32, outputBuffer: ?[*:0]u8, outputBufferSize: u32, requestCompletionCallback: ?*IDeviceRequestCompletionCallback, cancelContext: ?*usize) callconv(.Inline) HRESULT {
        return self.vtable.DeviceIoControlAsync(self, ioControlCode, inputBuffer, inputBufferSize, outputBuffer, outputBufferSize, requestCompletionCallback, cancelContext);
    }
    pub fn CancelOperation(self: *const IDeviceIoControl, cancelContext: usize) callconv(.Inline) HRESULT {
        return self.vtable.CancelOperation(self, cancelContext);
    }
};

const IID_ICreateDeviceAccessAsync_Value = Guid.initString("3474628f-683d-42d2-abcb-db018c6503bc");
pub const IID_ICreateDeviceAccessAsync = &IID_ICreateDeviceAccessAsync_Value;
pub const ICreateDeviceAccessAsync = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Cancel: *const fn(
            self: *const ICreateDeviceAccessAsync,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Wait: *const fn(
            self: *const ICreateDeviceAccessAsync,
            timeout: u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Close: *const fn(
            self: *const ICreateDeviceAccessAsync,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetResult: *const fn(
            self: *const ICreateDeviceAccessAsync,
            riid: ?*const Guid,
            deviceAccess: **anyopaque,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn Cancel(self: *const ICreateDeviceAccessAsync) callconv(.Inline) HRESULT {
        return self.vtable.Cancel(self);
    }
    pub fn Wait(self: *const ICreateDeviceAccessAsync, timeout: u32) callconv(.Inline) HRESULT {
        return self.vtable.Wait(self, timeout);
    }
    pub fn Close(self: *const ICreateDeviceAccessAsync) callconv(.Inline) HRESULT {
        return self.vtable.Close(self);
    }
    pub fn GetResult(self: *const ICreateDeviceAccessAsync, riid: ?*const Guid, deviceAccess: **anyopaque) callconv(.Inline) HRESULT {
        return self.vtable.GetResult(self, riid, deviceAccess);
    }
};


//--------------------------------------------------------------------------------
// Section: Functions (1)
//--------------------------------------------------------------------------------
pub extern "deviceaccess" fn CreateDeviceAccessInstance(
    deviceInterfacePath: ?[*:0]const u16,
    desiredAccess: u32,
    createAsync: **ICreateDeviceAccessAsync,
) callconv(@import("std").os.windows.WINAPI) HRESULT;


//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Section: Imports (4)
//--------------------------------------------------------------------------------
const Guid = @import("../zig.zig").Guid;
const HRESULT = @import("../foundation.zig").HRESULT;
const IUnknown = @import("../system/com.zig").IUnknown;
const PWSTR = @import("../foundation.zig").PWSTR;

test {
    @setEvalBranchQuota(
        comptime @import("std").meta.declarations(@This()).len * 3
    );

    // reference all the pub declarations
    if (!@import("builtin").is_test) return;
    inline for (comptime @import("std").meta.declarations(@This())) |decl| {
        _ = @field(@This(), decl.name);
    }
}
