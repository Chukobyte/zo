//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Types (31)
//--------------------------------------------------------------------------------
// TODO: this type has an InvalidHandleValue of '0', what can Zig do with this information?
pub const PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT = isize;

// TODO: this type has an InvalidHandleValue of '0', what can Zig do with this information?
pub const PRJ_DIR_ENTRY_BUFFER_HANDLE = isize;

pub const PRJ_NOTIFY_TYPES = packed struct(u32) {
    SUPPRESS_NOTIFICATIONS: u1 = 0,
    FILE_OPENED: u1 = 0,
    NEW_FILE_CREATED: u1 = 0,
    FILE_OVERWRITTEN: u1 = 0,
    PRE_DELETE: u1 = 0,
    PRE_RENAME: u1 = 0,
    PRE_SET_HARDLINK: u1 = 0,
    FILE_RENAMED: u1 = 0,
    HARDLINK_CREATED: u1 = 0,
    FILE_HANDLE_CLOSED_NO_MODIFICATION: u1 = 0,
    FILE_HANDLE_CLOSED_FILE_MODIFIED: u1 = 0,
    FILE_HANDLE_CLOSED_FILE_DELETED: u1 = 0,
    FILE_PRE_CONVERT_TO_FULL: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const PRJ_NOTIFY_NONE = PRJ_NOTIFY_TYPES{ };
pub const PRJ_NOTIFY_SUPPRESS_NOTIFICATIONS = PRJ_NOTIFY_TYPES{ .SUPPRESS_NOTIFICATIONS = 1 };
pub const PRJ_NOTIFY_FILE_OPENED = PRJ_NOTIFY_TYPES{ .FILE_OPENED = 1 };
pub const PRJ_NOTIFY_NEW_FILE_CREATED = PRJ_NOTIFY_TYPES{ .NEW_FILE_CREATED = 1 };
pub const PRJ_NOTIFY_FILE_OVERWRITTEN = PRJ_NOTIFY_TYPES{ .FILE_OVERWRITTEN = 1 };
pub const PRJ_NOTIFY_PRE_DELETE = PRJ_NOTIFY_TYPES{ .PRE_DELETE = 1 };
pub const PRJ_NOTIFY_PRE_RENAME = PRJ_NOTIFY_TYPES{ .PRE_RENAME = 1 };
pub const PRJ_NOTIFY_PRE_SET_HARDLINK = PRJ_NOTIFY_TYPES{ .PRE_SET_HARDLINK = 1 };
pub const PRJ_NOTIFY_FILE_RENAMED = PRJ_NOTIFY_TYPES{ .FILE_RENAMED = 1 };
pub const PRJ_NOTIFY_HARDLINK_CREATED = PRJ_NOTIFY_TYPES{ .HARDLINK_CREATED = 1 };
pub const PRJ_NOTIFY_FILE_HANDLE_CLOSED_NO_MODIFICATION = PRJ_NOTIFY_TYPES{ .FILE_HANDLE_CLOSED_NO_MODIFICATION = 1 };
pub const PRJ_NOTIFY_FILE_HANDLE_CLOSED_FILE_MODIFIED = PRJ_NOTIFY_TYPES{ .FILE_HANDLE_CLOSED_FILE_MODIFIED = 1 };
pub const PRJ_NOTIFY_FILE_HANDLE_CLOSED_FILE_DELETED = PRJ_NOTIFY_TYPES{ .FILE_HANDLE_CLOSED_FILE_DELETED = 1 };
pub const PRJ_NOTIFY_FILE_PRE_CONVERT_TO_FULL = PRJ_NOTIFY_TYPES{ .FILE_PRE_CONVERT_TO_FULL = 1 };
pub const PRJ_NOTIFY_USE_EXISTING_MASK = PRJ_NOTIFY_TYPES{
    .SUPPRESS_NOTIFICATIONS = 1,
    .FILE_OPENED = 1,
    .NEW_FILE_CREATED = 1,
    .FILE_OVERWRITTEN = 1,
    .PRE_DELETE = 1,
    .PRE_RENAME = 1,
    .PRE_SET_HARDLINK = 1,
    .FILE_RENAMED = 1,
    .HARDLINK_CREATED = 1,
    .FILE_HANDLE_CLOSED_NO_MODIFICATION = 1,
    .FILE_HANDLE_CLOSED_FILE_MODIFIED = 1,
    .FILE_HANDLE_CLOSED_FILE_DELETED = 1,
    .FILE_PRE_CONVERT_TO_FULL = 1,
    ._13 = 1,
    ._14 = 1,
    ._15 = 1,
    ._16 = 1,
    ._17 = 1,
    ._18 = 1,
    ._19 = 1,
    ._20 = 1,
    ._21 = 1,
    ._22 = 1,
    ._23 = 1,
    ._24 = 1,
    ._25 = 1,
    ._26 = 1,
    ._27 = 1,
    ._28 = 1,
    ._29 = 1,
    ._30 = 1,
    ._31 = 1,
};

pub const PRJ_NOTIFICATION = enum(i32) {
    FILE_OPENED = 2,
    NEW_FILE_CREATED = 4,
    FILE_OVERWRITTEN = 8,
    PRE_DELETE = 16,
    PRE_RENAME = 32,
    PRE_SET_HARDLINK = 64,
    FILE_RENAMED = 128,
    HARDLINK_CREATED = 256,
    FILE_HANDLE_CLOSED_NO_MODIFICATION = 512,
    FILE_HANDLE_CLOSED_FILE_MODIFIED = 1024,
    FILE_HANDLE_CLOSED_FILE_DELETED = 2048,
    FILE_PRE_CONVERT_TO_FULL = 4096,
};
pub const PRJ_NOTIFICATION_FILE_OPENED = PRJ_NOTIFICATION.FILE_OPENED;
pub const PRJ_NOTIFICATION_NEW_FILE_CREATED = PRJ_NOTIFICATION.NEW_FILE_CREATED;
pub const PRJ_NOTIFICATION_FILE_OVERWRITTEN = PRJ_NOTIFICATION.FILE_OVERWRITTEN;
pub const PRJ_NOTIFICATION_PRE_DELETE = PRJ_NOTIFICATION.PRE_DELETE;
pub const PRJ_NOTIFICATION_PRE_RENAME = PRJ_NOTIFICATION.PRE_RENAME;
pub const PRJ_NOTIFICATION_PRE_SET_HARDLINK = PRJ_NOTIFICATION.PRE_SET_HARDLINK;
pub const PRJ_NOTIFICATION_FILE_RENAMED = PRJ_NOTIFICATION.FILE_RENAMED;
pub const PRJ_NOTIFICATION_HARDLINK_CREATED = PRJ_NOTIFICATION.HARDLINK_CREATED;
pub const PRJ_NOTIFICATION_FILE_HANDLE_CLOSED_NO_MODIFICATION = PRJ_NOTIFICATION.FILE_HANDLE_CLOSED_NO_MODIFICATION;
pub const PRJ_NOTIFICATION_FILE_HANDLE_CLOSED_FILE_MODIFIED = PRJ_NOTIFICATION.FILE_HANDLE_CLOSED_FILE_MODIFIED;
pub const PRJ_NOTIFICATION_FILE_HANDLE_CLOSED_FILE_DELETED = PRJ_NOTIFICATION.FILE_HANDLE_CLOSED_FILE_DELETED;
pub const PRJ_NOTIFICATION_FILE_PRE_CONVERT_TO_FULL = PRJ_NOTIFICATION.FILE_PRE_CONVERT_TO_FULL;

pub const PRJ_EXT_INFO_TYPE = enum(i32) {
    K = 1,
};
pub const PRJ_EXT_INFO_TYPE_SYMLINK = PRJ_EXT_INFO_TYPE.K;

pub const PRJ_EXTENDED_INFO = extern struct {
    InfoType: PRJ_EXT_INFO_TYPE,
    NextInfoOffset: u32,
    Anonymous: extern union {
        Symlink: extern struct {
            TargetName: ?[*:0]const u16,
        },
    },
};

pub const PRJ_NOTIFICATION_MAPPING = extern struct {
    NotificationBitMask: PRJ_NOTIFY_TYPES,
    NotificationRoot: ?[*:0]const u16,
};

pub const PRJ_STARTVIRTUALIZING_FLAGS = packed struct(u32) {
    USE_NEGATIVE_PATH_CACHE: u1 = 0,
    _1: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const PRJ_FLAG_NONE = PRJ_STARTVIRTUALIZING_FLAGS{ };
pub const PRJ_FLAG_USE_NEGATIVE_PATH_CACHE = PRJ_STARTVIRTUALIZING_FLAGS{ .USE_NEGATIVE_PATH_CACHE = 1 };

pub const PRJ_STARTVIRTUALIZING_OPTIONS = extern struct {
    Flags: PRJ_STARTVIRTUALIZING_FLAGS,
    PoolThreadCount: u32,
    ConcurrentThreadCount: u32,
    NotificationMappings: ?*PRJ_NOTIFICATION_MAPPING,
    NotificationMappingsCount: u32,
};

pub const PRJ_VIRTUALIZATION_INSTANCE_INFO = extern struct {
    InstanceID: Guid,
    WriteAlignment: u32,
};

pub const PRJ_PLACEHOLDER_ID = enum(i32) {
    H = 128,
};
pub const PRJ_PLACEHOLDER_ID_LENGTH = PRJ_PLACEHOLDER_ID.H;

pub const PRJ_PLACEHOLDER_VERSION_INFO = extern struct {
    ProviderID: [128]u8,
    ContentID: [128]u8,
};

pub const PRJ_FILE_BASIC_INFO = extern struct {
    IsDirectory: BOOLEAN,
    FileSize: i64,
    CreationTime: LARGE_INTEGER,
    LastAccessTime: LARGE_INTEGER,
    LastWriteTime: LARGE_INTEGER,
    ChangeTime: LARGE_INTEGER,
    FileAttributes: u32,
};

pub const PRJ_PLACEHOLDER_INFO = extern struct {
    FileBasicInfo: PRJ_FILE_BASIC_INFO,
    EaInformation: extern struct {
        EaBufferSize: u32,
        OffsetToFirstEa: u32,
    },
    SecurityInformation: extern struct {
        SecurityBufferSize: u32,
        OffsetToSecurityDescriptor: u32,
    },
    StreamsInformation: extern struct {
        StreamsInfoBufferSize: u32,
        OffsetToFirstStreamInfo: u32,
    },
    VersionInfo: PRJ_PLACEHOLDER_VERSION_INFO,
    VariableData: [1]u8,
};

pub const PRJ_UPDATE_TYPES = packed struct(u32) {
    ALLOW_DIRTY_METADATA: u1 = 0,
    ALLOW_DIRTY_DATA: u1 = 0,
    ALLOW_TOMBSTONE: u1 = 0,
    RESERVED1: u1 = 0,
    RESERVED2: u1 = 0,
    ALLOW_READ_ONLY: u1 = 0,
    MAX_VAL: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const PRJ_UPDATE_NONE = PRJ_UPDATE_TYPES{ };
pub const PRJ_UPDATE_ALLOW_DIRTY_METADATA = PRJ_UPDATE_TYPES{ .ALLOW_DIRTY_METADATA = 1 };
pub const PRJ_UPDATE_ALLOW_DIRTY_DATA = PRJ_UPDATE_TYPES{ .ALLOW_DIRTY_DATA = 1 };
pub const PRJ_UPDATE_ALLOW_TOMBSTONE = PRJ_UPDATE_TYPES{ .ALLOW_TOMBSTONE = 1 };
pub const PRJ_UPDATE_RESERVED1 = PRJ_UPDATE_TYPES{ .RESERVED1 = 1 };
pub const PRJ_UPDATE_RESERVED2 = PRJ_UPDATE_TYPES{ .RESERVED2 = 1 };
pub const PRJ_UPDATE_ALLOW_READ_ONLY = PRJ_UPDATE_TYPES{ .ALLOW_READ_ONLY = 1 };
pub const PRJ_UPDATE_MAX_VAL = PRJ_UPDATE_TYPES{ .MAX_VAL = 1 };

pub const PRJ_UPDATE_FAILURE_CAUSES = packed struct(u32) {
    DIRTY_METADATA: u1 = 0,
    DIRTY_DATA: u1 = 0,
    TOMBSTONE: u1 = 0,
    READ_ONLY: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const PRJ_UPDATE_FAILURE_CAUSE_NONE = PRJ_UPDATE_FAILURE_CAUSES{ };
pub const PRJ_UPDATE_FAILURE_CAUSE_DIRTY_METADATA = PRJ_UPDATE_FAILURE_CAUSES{ .DIRTY_METADATA = 1 };
pub const PRJ_UPDATE_FAILURE_CAUSE_DIRTY_DATA = PRJ_UPDATE_FAILURE_CAUSES{ .DIRTY_DATA = 1 };
pub const PRJ_UPDATE_FAILURE_CAUSE_TOMBSTONE = PRJ_UPDATE_FAILURE_CAUSES{ .TOMBSTONE = 1 };
pub const PRJ_UPDATE_FAILURE_CAUSE_READ_ONLY = PRJ_UPDATE_FAILURE_CAUSES{ .READ_ONLY = 1 };

pub const PRJ_FILE_STATE = packed struct(u32) {
    PLACEHOLDER: u1 = 0,
    HYDRATED_PLACEHOLDER: u1 = 0,
    DIRTY_PLACEHOLDER: u1 = 0,
    FULL: u1 = 0,
    TOMBSTONE: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};
pub const PRJ_FILE_STATE_PLACEHOLDER = PRJ_FILE_STATE{ .PLACEHOLDER = 1 };
pub const PRJ_FILE_STATE_HYDRATED_PLACEHOLDER = PRJ_FILE_STATE{ .HYDRATED_PLACEHOLDER = 1 };
pub const PRJ_FILE_STATE_DIRTY_PLACEHOLDER = PRJ_FILE_STATE{ .DIRTY_PLACEHOLDER = 1 };
pub const PRJ_FILE_STATE_FULL = PRJ_FILE_STATE{ .FULL = 1 };
pub const PRJ_FILE_STATE_TOMBSTONE = PRJ_FILE_STATE{ .TOMBSTONE = 1 };

pub const PRJ_CALLBACK_DATA_FLAGS = enum(i32) {
    START_SCAN = 1,
    TURN_SINGLE_ENTRY = 2,
};
pub const PRJ_CB_DATA_FLAG_ENUM_RESTART_SCAN = PRJ_CALLBACK_DATA_FLAGS.START_SCAN;
pub const PRJ_CB_DATA_FLAG_ENUM_RETURN_SINGLE_ENTRY = PRJ_CALLBACK_DATA_FLAGS.TURN_SINGLE_ENTRY;

pub const PRJ_CALLBACK_DATA = extern struct {
    Size: u32,
    Flags: PRJ_CALLBACK_DATA_FLAGS,
    NamespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    CommandId: i32,
    FileId: Guid,
    DataStreamId: Guid,
    FilePathName: ?[*:0]const u16,
    VersionInfo: ?*PRJ_PLACEHOLDER_VERSION_INFO,
    TriggeringProcessId: u32,
    TriggeringProcessImageFileName: ?[*:0]const u16,
    InstanceContext: ?*anyopaque,
};

pub const PRJ_START_DIRECTORY_ENUMERATION_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
    enumerationId: ?*const Guid,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_GET_DIRECTORY_ENUMERATION_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
    enumerationId: ?*const Guid,
    searchExpression: ?[*:0]const u16,
    dirEntryBufferHandle: PRJ_DIR_ENTRY_BUFFER_HANDLE,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_END_DIRECTORY_ENUMERATION_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
    enumerationId: ?*const Guid,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_GET_PLACEHOLDER_INFO_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_GET_FILE_DATA_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
    byteOffset: u64,
    length: u32,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_QUERY_FILE_NAME_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_NOTIFICATION_PARAMETERS = extern union {
    PostCreate: extern struct {
        NotificationMask: PRJ_NOTIFY_TYPES,
    },
    FileRenamed: extern struct {
        NotificationMask: PRJ_NOTIFY_TYPES,
    },
    FileDeletedOnHandleClose: extern struct {
        IsFileModified: BOOLEAN,
    },
};

pub const PRJ_NOTIFICATION_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
    isDirectory: BOOLEAN,
    notification: PRJ_NOTIFICATION,
    destinationFileName: ?[*:0]const u16,
    operationParameters: ?*PRJ_NOTIFICATION_PARAMETERS,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const PRJ_CANCEL_COMMAND_CB = *const fn(
    callbackData: ?*const PRJ_CALLBACK_DATA,
) callconv(@import("std").os.windows.WINAPI) void;

pub const PRJ_CALLBACKS = extern struct {
    StartDirectoryEnumerationCallback: ?PRJ_START_DIRECTORY_ENUMERATION_CB,
    EndDirectoryEnumerationCallback: ?PRJ_END_DIRECTORY_ENUMERATION_CB,
    GetDirectoryEnumerationCallback: ?PRJ_GET_DIRECTORY_ENUMERATION_CB,
    GetPlaceholderInfoCallback: ?PRJ_GET_PLACEHOLDER_INFO_CB,
    GetFileDataCallback: ?PRJ_GET_FILE_DATA_CB,
    QueryFileNameCallback: ?PRJ_QUERY_FILE_NAME_CB,
    NotificationCallback: ?PRJ_NOTIFICATION_CB,
    CancelCommandCallback: ?PRJ_CANCEL_COMMAND_CB,
};

pub const PRJ_COMPLETE_COMMAND_TYPE = enum(i32) {
    NOTIFICATION = 1,
    ENUMERATION = 2,
};
pub const PRJ_COMPLETE_COMMAND_TYPE_NOTIFICATION = PRJ_COMPLETE_COMMAND_TYPE.NOTIFICATION;
pub const PRJ_COMPLETE_COMMAND_TYPE_ENUMERATION = PRJ_COMPLETE_COMMAND_TYPE.ENUMERATION;

pub const PRJ_COMPLETE_COMMAND_EXTENDED_PARAMETERS = extern struct {
    CommandType: PRJ_COMPLETE_COMMAND_TYPE,
    Anonymous: extern union {
        Notification: extern struct {
            NotificationMask: PRJ_NOTIFY_TYPES,
        },
        Enumeration: extern struct {
            DirEntryBufferHandle: PRJ_DIR_ENTRY_BUFFER_HANDLE,
        },
    },
};


//--------------------------------------------------------------------------------
// Section: Functions (19)
//--------------------------------------------------------------------------------
// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjStartVirtualizing(
    virtualizationRootPath: ?[*:0]const u16,
    callbacks: ?*const PRJ_CALLBACKS,
    instanceContext: ?*const anyopaque,
    options: ?*const PRJ_STARTVIRTUALIZING_OPTIONS,
    namespaceVirtualizationContext: ?*PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjStopVirtualizing(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
) callconv(@import("std").os.windows.WINAPI) void;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjClearNegativePathCache(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    totalEntryNumber: ?*u32,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjGetVirtualizationInstanceInfo(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    virtualizationInstanceInfo: ?*PRJ_VIRTUALIZATION_INSTANCE_INFO,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjMarkDirectoryAsPlaceholder(
    rootPathName: ?[*:0]const u16,
    targetPathName: ?[*:0]const u16,
    versionInfo: ?*const PRJ_PLACEHOLDER_VERSION_INFO,
    virtualizationInstanceID: ?*const Guid,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjWritePlaceholderInfo(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    destinationFileName: ?[*:0]const u16,
    // TODO: what to do with BytesParamIndex 3?
    placeholderInfo: ?*const PRJ_PLACEHOLDER_INFO,
    placeholderInfoSize: u32,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.19041'
pub extern "projectedfslib" fn PrjWritePlaceholderInfo2(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    destinationFileName: ?[*:0]const u16,
    // TODO: what to do with BytesParamIndex 3?
    placeholderInfo: ?*const PRJ_PLACEHOLDER_INFO,
    placeholderInfoSize: u32,
    ExtendedInfo: ?*const PRJ_EXTENDED_INFO,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
// This function from dll 'PROJECTEDFSLIB' is being skipped because it has some sort of issue
pub fn PrjUpdateFileIfNeeded() void { @panic("this function is not working"); }

// TODO: this type is limited to platform 'windows10.0.17763'
// This function from dll 'PROJECTEDFSLIB' is being skipped because it has some sort of issue
pub fn PrjDeleteFile() void { @panic("this function is not working"); }

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjWriteFileData(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    dataStreamId: ?*const Guid,
    // TODO: what to do with BytesParamIndex 4?
    buffer: ?*anyopaque,
    byteOffset: u64,
    length: u32,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjGetOnDiskFileState(
    destinationFileName: ?[*:0]const u16,
    fileState: ?*PRJ_FILE_STATE,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjAllocateAlignedBuffer(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    size: usize,
) callconv(@import("std").os.windows.WINAPI) ?*anyopaque;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjFreeAlignedBuffer(
    buffer: ?*anyopaque,
) callconv(@import("std").os.windows.WINAPI) void;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjCompleteCommand(
    namespaceVirtualizationContext: PRJ_NAMESPACE_VIRTUALIZATION_CONTEXT,
    commandId: i32,
    completionResult: HRESULT,
    extendedParameters: ?*PRJ_COMPLETE_COMMAND_EXTENDED_PARAMETERS,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjFillDirEntryBuffer(
    fileName: ?[*:0]const u16,
    fileBasicInfo: ?*PRJ_FILE_BASIC_INFO,
    dirEntryBufferHandle: PRJ_DIR_ENTRY_BUFFER_HANDLE,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.19041'
pub extern "projectedfslib" fn PrjFillDirEntryBuffer2(
    dirEntryBufferHandle: PRJ_DIR_ENTRY_BUFFER_HANDLE,
    fileName: ?[*:0]const u16,
    fileBasicInfo: ?*PRJ_FILE_BASIC_INFO,
    extendedInfo: ?*PRJ_EXTENDED_INFO,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjFileNameMatch(
    fileNameToCheck: ?[*:0]const u16,
    pattern: ?[*:0]const u16,
) callconv(@import("std").os.windows.WINAPI) BOOLEAN;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjFileNameCompare(
    fileName1: ?[*:0]const u16,
    fileName2: ?[*:0]const u16,
) callconv(@import("std").os.windows.WINAPI) i32;

// TODO: this type is limited to platform 'windows10.0.17763'
pub extern "projectedfslib" fn PrjDoesNameContainWildCards(
    fileName: ?[*:0]const u16,
) callconv(@import("std").os.windows.WINAPI) BOOLEAN;


//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Section: Imports (5)
//--------------------------------------------------------------------------------
const Guid = @import("../zig.zig").Guid;
const BOOLEAN = @import("../foundation.zig").BOOLEAN;
const HRESULT = @import("../foundation.zig").HRESULT;
const LARGE_INTEGER = @import("../foundation.zig").LARGE_INTEGER;
const PWSTR = @import("../foundation.zig").PWSTR;

test {
    // The following '_ = <FuncPtrType>' lines are a workaround for https://github.com/ziglang/zig/issues/4476
    if (@hasDecl(@This(), "PRJ_START_DIRECTORY_ENUMERATION_CB")) { _ = PRJ_START_DIRECTORY_ENUMERATION_CB; }
    if (@hasDecl(@This(), "PRJ_GET_DIRECTORY_ENUMERATION_CB")) { _ = PRJ_GET_DIRECTORY_ENUMERATION_CB; }
    if (@hasDecl(@This(), "PRJ_END_DIRECTORY_ENUMERATION_CB")) { _ = PRJ_END_DIRECTORY_ENUMERATION_CB; }
    if (@hasDecl(@This(), "PRJ_GET_PLACEHOLDER_INFO_CB")) { _ = PRJ_GET_PLACEHOLDER_INFO_CB; }
    if (@hasDecl(@This(), "PRJ_GET_FILE_DATA_CB")) { _ = PRJ_GET_FILE_DATA_CB; }
    if (@hasDecl(@This(), "PRJ_QUERY_FILE_NAME_CB")) { _ = PRJ_QUERY_FILE_NAME_CB; }
    if (@hasDecl(@This(), "PRJ_NOTIFICATION_CB")) { _ = PRJ_NOTIFICATION_CB; }
    if (@hasDecl(@This(), "PRJ_CANCEL_COMMAND_CB")) { _ = PRJ_CANCEL_COMMAND_CB; }

    @setEvalBranchQuota(
        comptime @import("std").meta.declarations(@This()).len * 3
    );

    // reference all the pub declarations
    if (!@import("builtin").is_test) return;
    inline for (comptime @import("std").meta.declarations(@This())) |decl| {
        _ = @field(@This(), decl.name);
    }
}
