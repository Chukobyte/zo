//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (1)
//--------------------------------------------------------------------------------
pub const E_SURFACE_CONTENTS_LOST = @as(u32, 2150301728);

//--------------------------------------------------------------------------------
// Section: Types (19)
//--------------------------------------------------------------------------------
const IID_ISurfaceImageSourceNative_Value = Guid.initString("f2e9edc1-d307-4525-9886-0fafaa44163c");
pub const IID_ISurfaceImageSourceNative = &IID_ISurfaceImageSourceNative_Value;
pub const ISurfaceImageSourceNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetDevice: *const fn(
            self: *const ISurfaceImageSourceNative,
            device: ?*IDXGIDevice,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        BeginDraw: *const fn(
            self: *const ISurfaceImageSourceNative,
            updateRect: RECT,
            surface: ?*?*IDXGISurface,
            offset: ?*POINT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        EndDraw: *const fn(
            self: *const ISurfaceImageSourceNative,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetDevice(self: *const ISurfaceImageSourceNative, device: ?*IDXGIDevice) callconv(.Inline) HRESULT {
        return self.vtable.SetDevice(self, device);
    }
    pub fn BeginDraw(self: *const ISurfaceImageSourceNative, updateRect: RECT, surface: ?*?*IDXGISurface, offset: ?*POINT) callconv(.Inline) HRESULT {
        return self.vtable.BeginDraw(self, updateRect, surface, offset);
    }
    pub fn EndDraw(self: *const ISurfaceImageSourceNative) callconv(.Inline) HRESULT {
        return self.vtable.EndDraw(self);
    }
};

const IID_IVirtualSurfaceUpdatesCallbackNative_Value = Guid.initString("dbf2e947-8e6c-4254-9eee-7738f71386c9");
pub const IID_IVirtualSurfaceUpdatesCallbackNative = &IID_IVirtualSurfaceUpdatesCallbackNative_Value;
pub const IVirtualSurfaceUpdatesCallbackNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        UpdatesNeeded: *const fn(
            self: *const IVirtualSurfaceUpdatesCallbackNative,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn UpdatesNeeded(self: *const IVirtualSurfaceUpdatesCallbackNative) callconv(.Inline) HRESULT {
        return self.vtable.UpdatesNeeded(self);
    }
};

const IID_IVirtualSurfaceImageSourceNative_Value = Guid.initString("e9550983-360b-4f53-b391-afd695078691");
pub const IID_IVirtualSurfaceImageSourceNative = &IID_IVirtualSurfaceImageSourceNative_Value;
pub const IVirtualSurfaceImageSourceNative = extern union {
    pub const VTable = extern struct {
        base: ISurfaceImageSourceNative.VTable,
        Invalidate: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            updateRect: RECT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetUpdateRectCount: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            count: ?*u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetUpdateRects: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            updates: [*]RECT,
            count: u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetVisibleBounds: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            bounds: ?*RECT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        RegisterForUpdatesNeeded: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            callback: ?*IVirtualSurfaceUpdatesCallbackNative,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Resize: *const fn(
            self: *const IVirtualSurfaceImageSourceNative,
            newWidth: i32,
            newHeight: i32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    ISurfaceImageSourceNative: ISurfaceImageSourceNative,
    IUnknown: IUnknown,
    pub fn Invalidate(self: *const IVirtualSurfaceImageSourceNative, updateRect: RECT) callconv(.Inline) HRESULT {
        return self.vtable.Invalidate(self, updateRect);
    }
    pub fn GetUpdateRectCount(self: *const IVirtualSurfaceImageSourceNative, count: ?*u32) callconv(.Inline) HRESULT {
        return self.vtable.GetUpdateRectCount(self, count);
    }
    pub fn GetUpdateRects(self: *const IVirtualSurfaceImageSourceNative, updates: [*]RECT, count: u32) callconv(.Inline) HRESULT {
        return self.vtable.GetUpdateRects(self, updates, count);
    }
    pub fn GetVisibleBounds(self: *const IVirtualSurfaceImageSourceNative, bounds: ?*RECT) callconv(.Inline) HRESULT {
        return self.vtable.GetVisibleBounds(self, bounds);
    }
    pub fn RegisterForUpdatesNeeded(self: *const IVirtualSurfaceImageSourceNative, callback: ?*IVirtualSurfaceUpdatesCallbackNative) callconv(.Inline) HRESULT {
        return self.vtable.RegisterForUpdatesNeeded(self, callback);
    }
    pub fn Resize(self: *const IVirtualSurfaceImageSourceNative, newWidth: i32, newHeight: i32) callconv(.Inline) HRESULT {
        return self.vtable.Resize(self, newWidth, newHeight);
    }
};

const IID_ISwapChainBackgroundPanelNative_Value = Guid.initString("43bebd4e-add5-4035-8f85-5608d08e9dc9");
pub const IID_ISwapChainBackgroundPanelNative = &IID_ISwapChainBackgroundPanelNative_Value;
pub const ISwapChainBackgroundPanelNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetSwapChain: *const fn(
            self: *const ISwapChainBackgroundPanelNative,
            swapChain: ?*IDXGISwapChain,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetSwapChain(self: *const ISwapChainBackgroundPanelNative, swapChain: ?*IDXGISwapChain) callconv(.Inline) HRESULT {
        return self.vtable.SetSwapChain(self, swapChain);
    }
};

const IID_ISurfaceImageSourceManagerNative_Value = Guid.initString("4c8798b7-1d88-4a0f-b59b-b93f600de8c8");
pub const IID_ISurfaceImageSourceManagerNative = &IID_ISurfaceImageSourceManagerNative_Value;
pub const ISurfaceImageSourceManagerNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        FlushAllSurfacesWithDevice: *const fn(
            self: *const ISurfaceImageSourceManagerNative,
            device: ?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn FlushAllSurfacesWithDevice(self: *const ISurfaceImageSourceManagerNative, device: ?*IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.FlushAllSurfacesWithDevice(self, device);
    }
};

const IID_ISurfaceImageSourceNativeWithD2D_Value = Guid.initString("54298223-41e1-4a41-9c08-02e8256864a1");
pub const IID_ISurfaceImageSourceNativeWithD2D = &IID_ISurfaceImageSourceNativeWithD2D_Value;
pub const ISurfaceImageSourceNativeWithD2D = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetDevice: *const fn(
            self: *const ISurfaceImageSourceNativeWithD2D,
            device: ?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        BeginDraw: *const fn(
            self: *const ISurfaceImageSourceNativeWithD2D,
            updateRect: ?*const RECT,
            iid: ?*const Guid,
            updateObject: **anyopaque,
            offset: ?*POINT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        EndDraw: *const fn(
            self: *const ISurfaceImageSourceNativeWithD2D,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SuspendDraw: *const fn(
            self: *const ISurfaceImageSourceNativeWithD2D,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ResumeDraw: *const fn(
            self: *const ISurfaceImageSourceNativeWithD2D,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetDevice(self: *const ISurfaceImageSourceNativeWithD2D, device: ?*IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.SetDevice(self, device);
    }
    pub fn BeginDraw(self: *const ISurfaceImageSourceNativeWithD2D, updateRect: ?*const RECT, iid: ?*const Guid, updateObject: **anyopaque, offset: ?*POINT) callconv(.Inline) HRESULT {
        return self.vtable.BeginDraw(self, updateRect, iid, updateObject, offset);
    }
    pub fn EndDraw(self: *const ISurfaceImageSourceNativeWithD2D) callconv(.Inline) HRESULT {
        return self.vtable.EndDraw(self);
    }
    pub fn SuspendDraw(self: *const ISurfaceImageSourceNativeWithD2D) callconv(.Inline) HRESULT {
        return self.vtable.SuspendDraw(self);
    }
    pub fn ResumeDraw(self: *const ISurfaceImageSourceNativeWithD2D) callconv(.Inline) HRESULT {
        return self.vtable.ResumeDraw(self);
    }
};

const IID_ISwapChainPanelNative_Value = Guid.initString("f92f19d2-3ade-45a6-a20c-f6f1ea90554b");
pub const IID_ISwapChainPanelNative = &IID_ISwapChainPanelNative_Value;
pub const ISwapChainPanelNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetSwapChain: *const fn(
            self: *const ISwapChainPanelNative,
            swapChain: ?*IDXGISwapChain,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetSwapChain(self: *const ISwapChainPanelNative, swapChain: ?*IDXGISwapChain) callconv(.Inline) HRESULT {
        return self.vtable.SetSwapChain(self, swapChain);
    }
};

const IID_ISwapChainPanelNative2_Value = Guid.initString("d5a2f60c-37b2-44a2-937b-8d8eb9726821");
pub const IID_ISwapChainPanelNative2 = &IID_ISwapChainPanelNative2_Value;
pub const ISwapChainPanelNative2 = extern union {
    pub const VTable = extern struct {
        base: ISwapChainPanelNative.VTable,
        SetSwapChainHandle: *const fn(
            self: *const ISwapChainPanelNative2,
            swapChainHandle: ?HANDLE,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    ISwapChainPanelNative: ISwapChainPanelNative,
    IUnknown: IUnknown,
    pub fn SetSwapChainHandle(self: *const ISwapChainPanelNative2, swapChainHandle: ?HANDLE) callconv(.Inline) HRESULT {
        return self.vtable.SetSwapChainHandle(self, swapChainHandle);
    }
};

const IID_IDesktopWindowXamlSourceNative_Value = Guid.initString("3cbcf1bf-2f76-4e9c-96ab-e84b37972554");
pub const IID_IDesktopWindowXamlSourceNative = &IID_IDesktopWindowXamlSourceNative_Value;
pub const IDesktopWindowXamlSourceNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        AttachToWindow: *const fn(
            self: *const IDesktopWindowXamlSourceNative,
            parentWnd: ?HWND,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_WindowHandle: *const fn(
            self: *const IDesktopWindowXamlSourceNative,
            hWnd: ?*?HWND,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn AttachToWindow(self: *const IDesktopWindowXamlSourceNative, parentWnd: ?HWND) callconv(.Inline) HRESULT {
        return self.vtable.AttachToWindow(self, parentWnd);
    }
    pub fn get_WindowHandle(self: *const IDesktopWindowXamlSourceNative, hWnd: ?*?HWND) callconv(.Inline) HRESULT {
        return self.vtable.get_WindowHandle(self, hWnd);
    }
};

const IID_IDesktopWindowXamlSourceNative2_Value = Guid.initString("e3dcd8c7-3057-4692-99c3-7b7720afda31");
pub const IID_IDesktopWindowXamlSourceNative2 = &IID_IDesktopWindowXamlSourceNative2_Value;
pub const IDesktopWindowXamlSourceNative2 = extern union {
    pub const VTable = extern struct {
        base: IDesktopWindowXamlSourceNative.VTable,
        PreTranslateMessage: *const fn(
            self: *const IDesktopWindowXamlSourceNative2,
            message: ?*const MSG,
            result: ?*BOOL,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IDesktopWindowXamlSourceNative: IDesktopWindowXamlSourceNative,
    IUnknown: IUnknown,
    pub fn PreTranslateMessage(self: *const IDesktopWindowXamlSourceNative2, message: ?*const MSG, result: ?*BOOL) callconv(.Inline) HRESULT {
        return self.vtable.PreTranslateMessage(self, message, result);
    }
};

const IID_IReferenceTrackerTarget_Value = Guid.initString("64bd43f8-bfee-4ec4-b7eb-2935158dae21");
pub const IID_IReferenceTrackerTarget = &IID_IReferenceTrackerTarget_Value;
pub const IReferenceTrackerTarget = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        AddRefFromReferenceTracker: *const fn(
            self: *const IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) u32,
        ReleaseFromReferenceTracker: *const fn(
            self: *const IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) u32,
        Peg: *const fn(
            self: *const IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Unpeg: *const fn(
            self: *const IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn AddRefFromReferenceTracker(self: *const IReferenceTrackerTarget) callconv(.Inline) u32 {
        return self.vtable.AddRefFromReferenceTracker(self);
    }
    pub fn ReleaseFromReferenceTracker(self: *const IReferenceTrackerTarget) callconv(.Inline) u32 {
        return self.vtable.ReleaseFromReferenceTracker(self);
    }
    pub fn Peg(self: *const IReferenceTrackerTarget) callconv(.Inline) HRESULT {
        return self.vtable.Peg(self);
    }
    pub fn Unpeg(self: *const IReferenceTrackerTarget) callconv(.Inline) HRESULT {
        return self.vtable.Unpeg(self);
    }
};

const IID_IReferenceTracker_Value = Guid.initString("11d3b13a-180e-4789-a8be-7712882893e6");
pub const IID_IReferenceTracker = &IID_IReferenceTracker_Value;
pub const IReferenceTracker = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        ConnectFromTrackerSource: *const fn(
            self: *const IReferenceTracker,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        DisconnectFromTrackerSource: *const fn(
            self: *const IReferenceTracker,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        FindTrackerTargets: *const fn(
            self: *const IReferenceTracker,
            callback: ?*IFindReferenceTargetsCallback,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetReferenceTrackerManager: *const fn(
            self: *const IReferenceTracker,
            value: ?*?*IReferenceTrackerManager,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        AddRefFromTrackerSource: *const fn(
            self: *const IReferenceTracker,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ReleaseFromTrackerSource: *const fn(
            self: *const IReferenceTracker,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        PegFromTrackerSource: *const fn(
            self: *const IReferenceTracker,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn ConnectFromTrackerSource(self: *const IReferenceTracker) callconv(.Inline) HRESULT {
        return self.vtable.ConnectFromTrackerSource(self);
    }
    pub fn DisconnectFromTrackerSource(self: *const IReferenceTracker) callconv(.Inline) HRESULT {
        return self.vtable.DisconnectFromTrackerSource(self);
    }
    pub fn FindTrackerTargets(self: *const IReferenceTracker, callback: ?*IFindReferenceTargetsCallback) callconv(.Inline) HRESULT {
        return self.vtable.FindTrackerTargets(self, callback);
    }
    pub fn GetReferenceTrackerManager(self: *const IReferenceTracker, value: ?*?*IReferenceTrackerManager) callconv(.Inline) HRESULT {
        return self.vtable.GetReferenceTrackerManager(self, value);
    }
    pub fn AddRefFromTrackerSource(self: *const IReferenceTracker) callconv(.Inline) HRESULT {
        return self.vtable.AddRefFromTrackerSource(self);
    }
    pub fn ReleaseFromTrackerSource(self: *const IReferenceTracker) callconv(.Inline) HRESULT {
        return self.vtable.ReleaseFromTrackerSource(self);
    }
    pub fn PegFromTrackerSource(self: *const IReferenceTracker) callconv(.Inline) HRESULT {
        return self.vtable.PegFromTrackerSource(self);
    }
};

const IID_IReferenceTrackerManager_Value = Guid.initString("3cf184b4-7ccb-4dda-8455-7e6ce99a3298");
pub const IID_IReferenceTrackerManager = &IID_IReferenceTrackerManager_Value;
pub const IReferenceTrackerManager = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        ReferenceTrackingStarted: *const fn(
            self: *const IReferenceTrackerManager,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        FindTrackerTargetsCompleted: *const fn(
            self: *const IReferenceTrackerManager,
            findFailed: u8,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ReferenceTrackingCompleted: *const fn(
            self: *const IReferenceTrackerManager,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetReferenceTrackerHost: *const fn(
            self: *const IReferenceTrackerManager,
            value: ?*IReferenceTrackerHost,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn ReferenceTrackingStarted(self: *const IReferenceTrackerManager) callconv(.Inline) HRESULT {
        return self.vtable.ReferenceTrackingStarted(self);
    }
    pub fn FindTrackerTargetsCompleted(self: *const IReferenceTrackerManager, findFailed: u8) callconv(.Inline) HRESULT {
        return self.vtable.FindTrackerTargetsCompleted(self, findFailed);
    }
    pub fn ReferenceTrackingCompleted(self: *const IReferenceTrackerManager) callconv(.Inline) HRESULT {
        return self.vtable.ReferenceTrackingCompleted(self);
    }
    pub fn SetReferenceTrackerHost(self: *const IReferenceTrackerManager, value: ?*IReferenceTrackerHost) callconv(.Inline) HRESULT {
        return self.vtable.SetReferenceTrackerHost(self, value);
    }
};

const IID_IFindReferenceTargetsCallback_Value = Guid.initString("04b3486c-4687-4229-8d14-505ab584dd88");
pub const IID_IFindReferenceTargetsCallback = &IID_IFindReferenceTargetsCallback_Value;
pub const IFindReferenceTargetsCallback = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        FoundTrackerTarget: *const fn(
            self: *const IFindReferenceTargetsCallback,
            target: ?*IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn FoundTrackerTarget(self: *const IFindReferenceTargetsCallback, target: ?*IReferenceTrackerTarget) callconv(.Inline) HRESULT {
        return self.vtable.FoundTrackerTarget(self, target);
    }
};

pub const XAML_REFERENCETRACKER_DISCONNECT = enum(i32) {
    DEFAULT = 0,
    SUSPEND = 1,
};
pub const XAML_REFERENCETRACKER_DISCONNECT_DEFAULT = XAML_REFERENCETRACKER_DISCONNECT.DEFAULT;
pub const XAML_REFERENCETRACKER_DISCONNECT_SUSPEND = XAML_REFERENCETRACKER_DISCONNECT.SUSPEND;

const IID_IReferenceTrackerHost_Value = Guid.initString("29a71c6a-3c42-4416-a39d-e2825a07a773");
pub const IID_IReferenceTrackerHost = &IID_IReferenceTrackerHost_Value;
pub const IReferenceTrackerHost = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        DisconnectUnusedReferenceSources: *const fn(
            self: *const IReferenceTrackerHost,
            options: XAML_REFERENCETRACKER_DISCONNECT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ReleaseDisconnectedReferenceSources: *const fn(
            self: *const IReferenceTrackerHost,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        NotifyEndOfReferenceTrackingOnThread: *const fn(
            self: *const IReferenceTrackerHost,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        GetTrackerTarget: *const fn(
            self: *const IReferenceTrackerHost,
            unknown: ?*IUnknown,
            newReference: ?*?*IReferenceTrackerTarget,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        AddMemoryPressure: *const fn(
            self: *const IReferenceTrackerHost,
            bytesAllocated: u64,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        RemoveMemoryPressure: *const fn(
            self: *const IReferenceTrackerHost,
            bytesAllocated: u64,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn DisconnectUnusedReferenceSources(self: *const IReferenceTrackerHost, options: XAML_REFERENCETRACKER_DISCONNECT) callconv(.Inline) HRESULT {
        return self.vtable.DisconnectUnusedReferenceSources(self, options);
    }
    pub fn ReleaseDisconnectedReferenceSources(self: *const IReferenceTrackerHost) callconv(.Inline) HRESULT {
        return self.vtable.ReleaseDisconnectedReferenceSources(self);
    }
    pub fn NotifyEndOfReferenceTrackingOnThread(self: *const IReferenceTrackerHost) callconv(.Inline) HRESULT {
        return self.vtable.NotifyEndOfReferenceTrackingOnThread(self);
    }
    pub fn GetTrackerTarget(self: *const IReferenceTrackerHost, unknown: ?*IUnknown, newReference: ?*?*IReferenceTrackerTarget) callconv(.Inline) HRESULT {
        return self.vtable.GetTrackerTarget(self, unknown, newReference);
    }
    pub fn AddMemoryPressure(self: *const IReferenceTrackerHost, bytesAllocated: u64) callconv(.Inline) HRESULT {
        return self.vtable.AddMemoryPressure(self, bytesAllocated);
    }
    pub fn RemoveMemoryPressure(self: *const IReferenceTrackerHost, bytesAllocated: u64) callconv(.Inline) HRESULT {
        return self.vtable.RemoveMemoryPressure(self, bytesAllocated);
    }
};

const IID_IReferenceTrackerExtension_Value = Guid.initString("4e897caa-59d5-4613-8f8c-f7ebd1f399b0");
pub const IID_IReferenceTrackerExtension = &IID_IReferenceTrackerExtension_Value;
pub const IReferenceTrackerExtension = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
};

pub const TrackerHandle__ = extern struct {
    unused: i32,
};

const IID_ITrackerOwner_Value = Guid.initString("eb24c20b-9816-4ac7-8cff-36f67a118f4e");
pub const IID_ITrackerOwner = &IID_ITrackerOwner_Value;
pub const ITrackerOwner = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        CreateTrackerHandle: *const fn(
            self: *const ITrackerOwner,
            returnValue: ?*?*TrackerHandle__,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        DeleteTrackerHandle: *const fn(
            self: *const ITrackerOwner,
            handle: ?*TrackerHandle__,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetTrackerValue: *const fn(
            self: *const ITrackerOwner,
            handle: ?*TrackerHandle__,
            value: ?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        TryGetSafeTrackerValue: *const fn(
            self: *const ITrackerOwner,
            handle: ?*TrackerHandle__,
            returnValue: ?*?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) u8,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn CreateTrackerHandle(self: *const ITrackerOwner, returnValue: ?*?*TrackerHandle__) callconv(.Inline) HRESULT {
        return self.vtable.CreateTrackerHandle(self, returnValue);
    }
    pub fn DeleteTrackerHandle(self: *const ITrackerOwner, handle: ?*TrackerHandle__) callconv(.Inline) HRESULT {
        return self.vtable.DeleteTrackerHandle(self, handle);
    }
    pub fn SetTrackerValue(self: *const ITrackerOwner, handle: ?*TrackerHandle__, value: ?*IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.SetTrackerValue(self, handle, value);
    }
    pub fn TryGetSafeTrackerValue(self: *const ITrackerOwner, handle: ?*TrackerHandle__, returnValue: ?*?*IUnknown) callconv(.Inline) u8 {
        return self.vtable.TryGetSafeTrackerValue(self, handle, returnValue);
    }
};


//--------------------------------------------------------------------------------
// Section: Functions (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Section: Imports (12)
//--------------------------------------------------------------------------------
const Guid = @import("../../zig.zig").Guid;
const BOOL = @import("../../foundation.zig").BOOL;
const HANDLE = @import("../../foundation.zig").HANDLE;
const HRESULT = @import("../../foundation.zig").HRESULT;
const HWND = @import("../../foundation.zig").HWND;
const IDXGIDevice = @import("../../graphics/dxgi.zig").IDXGIDevice;
const IDXGISurface = @import("../../graphics/dxgi.zig").IDXGISurface;
const IDXGISwapChain = @import("../../graphics/dxgi.zig").IDXGISwapChain;
const IUnknown = @import("../../system/com.zig").IUnknown;
const MSG = @import("../../ui/windows_and_messaging.zig").MSG;
const POINT = @import("../../foundation.zig").POINT;
const RECT = @import("../../foundation.zig").RECT;

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
