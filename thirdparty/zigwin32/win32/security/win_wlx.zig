//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (59)
//--------------------------------------------------------------------------------
pub const WLX_VERSION_1_0 = @as(u32, 65536);
pub const WLX_VERSION_1_1 = @as(u32, 65537);
pub const WLX_VERSION_1_2 = @as(u32, 65538);
pub const WLX_VERSION_1_3 = @as(u32, 65539);
pub const WLX_VERSION_1_4 = @as(u32, 65540);
pub const WLX_CURRENT_VERSION = @as(u32, 65540);
pub const WLX_SAS_TYPE_TIMEOUT = @as(u32, 0);
pub const WLX_SAS_TYPE_CTRL_ALT_DEL = @as(u32, 1);
pub const WLX_SAS_TYPE_SCRNSVR_TIMEOUT = @as(u32, 2);
pub const WLX_SAS_TYPE_SCRNSVR_ACTIVITY = @as(u32, 3);
pub const WLX_SAS_TYPE_USER_LOGOFF = @as(u32, 4);
pub const WLX_SAS_TYPE_SC_INSERT = @as(u32, 5);
pub const WLX_SAS_TYPE_SC_REMOVE = @as(u32, 6);
pub const WLX_SAS_TYPE_AUTHENTICATED = @as(u32, 7);
pub const WLX_SAS_TYPE_SC_FIRST_READER_ARRIVED = @as(u32, 8);
pub const WLX_SAS_TYPE_SC_LAST_READER_REMOVED = @as(u32, 9);
pub const WLX_SAS_TYPE_SWITCHUSER = @as(u32, 10);
pub const WLX_SAS_TYPE_MAX_MSFT_VALUE = @as(u32, 127);
pub const WLX_LOGON_OPT_NO_PROFILE = @as(u32, 1);
pub const WLX_PROFILE_TYPE_V1_0 = @as(u32, 1);
pub const WLX_PROFILE_TYPE_V2_0 = @as(u32, 2);
pub const WLX_SAS_ACTION_LOGON = @as(u32, 1);
pub const WLX_SAS_ACTION_NONE = @as(u32, 2);
pub const WLX_SAS_ACTION_LOCK_WKSTA = @as(u32, 3);
pub const WLX_SAS_ACTION_LOGOFF = @as(u32, 4);
pub const WLX_SAS_ACTION_PWD_CHANGED = @as(u32, 6);
pub const WLX_SAS_ACTION_TASKLIST = @as(u32, 7);
pub const WLX_SAS_ACTION_UNLOCK_WKSTA = @as(u32, 8);
pub const WLX_SAS_ACTION_FORCE_LOGOFF = @as(u32, 9);
pub const WLX_SAS_ACTION_SHUTDOWN_SLEEP = @as(u32, 12);
pub const WLX_SAS_ACTION_SHUTDOWN_SLEEP2 = @as(u32, 13);
pub const WLX_SAS_ACTION_SHUTDOWN_HIBERNATE = @as(u32, 14);
pub const WLX_SAS_ACTION_RECONNECTED = @as(u32, 15);
pub const WLX_SAS_ACTION_DELAYED_FORCE_LOGOFF = @as(u32, 16);
pub const WLX_SAS_ACTION_SWITCH_CONSOLE = @as(u32, 17);
pub const WLX_WM_SAS = @as(u32, 1625);
pub const WLX_DLG_SAS = @as(u32, 101);
pub const WLX_DLG_INPUT_TIMEOUT = @as(u32, 102);
pub const WLX_DLG_SCREEN_SAVER_TIMEOUT = @as(u32, 103);
pub const WLX_DLG_USER_LOGOFF = @as(u32, 104);
pub const WLX_DIRECTORY_LENGTH = @as(u32, 256);
pub const WLX_CREDENTIAL_TYPE_V1_0 = @as(u32, 1);
pub const WLX_CREDENTIAL_TYPE_V2_0 = @as(u32, 2);
pub const WLX_CONSOLESWITCHCREDENTIAL_TYPE_V1_0 = @as(u32, 1);
pub const STATUSMSG_OPTION_NOANIMATION = @as(u32, 1);
pub const STATUSMSG_OPTION_SETFOREGROUND = @as(u32, 2);
pub const WLX_DESKTOP_NAME = @as(u32, 1);
pub const WLX_DESKTOP_HANDLE = @as(u32, 2);
pub const WLX_CREATE_INSTANCE_ONLY = @as(u32, 1);
pub const WLX_CREATE_USER = @as(u32, 2);
pub const WLX_OPTION_USE_CTRL_ALT_DEL = @as(u32, 1);
pub const WLX_OPTION_CONTEXT_POINTER = @as(u32, 2);
pub const WLX_OPTION_USE_SMART_CARD = @as(u32, 3);
pub const WLX_OPTION_FORCE_LOGOFF_TIME = @as(u32, 4);
pub const WLX_OPTION_IGNORE_AUTO_LOGON = @as(u32, 8);
pub const WLX_OPTION_NO_SWITCH_ON_SAS = @as(u32, 9);
pub const WLX_OPTION_SMART_CARD_PRESENT = @as(u32, 65537);
pub const WLX_OPTION_SMART_CARD_INFO = @as(u32, 65538);
pub const WLX_OPTION_DISPATCH_TABLE_SIZE = @as(u32, 65539);

//--------------------------------------------------------------------------------
// Section: Types (44)
//--------------------------------------------------------------------------------
pub const WLX_SHUTDOWN_TYPE = enum(u32) {
    N = 5,
    _REBOOT = 11,
    _POWER_OFF = 10,
};
pub const WLX_SAS_ACTION_SHUTDOWN = WLX_SHUTDOWN_TYPE.N;
pub const WLX_SAS_ACTION_SHUTDOWN_REBOOT = WLX_SHUTDOWN_TYPE._REBOOT;
pub const WLX_SAS_ACTION_SHUTDOWN_POWER_OFF = WLX_SHUTDOWN_TYPE._POWER_OFF;

pub const WLX_SC_NOTIFICATION_INFO = extern struct {
    pszCard: ?PWSTR,
    pszReader: ?PWSTR,
    pszContainer: ?PWSTR,
    pszCryptoProvider: ?PWSTR,
};

pub const WLX_PROFILE_V1_0 = extern struct {
    dwType: u32,
    pszProfile: ?PWSTR,
};

pub const WLX_PROFILE_V2_0 = extern struct {
    dwType: u32,
    pszProfile: ?PWSTR,
    pszPolicy: ?PWSTR,
    pszNetworkDefaultUserProfile: ?PWSTR,
    pszServerName: ?PWSTR,
    pszEnvironment: ?PWSTR,
};

pub const WLX_MPR_NOTIFY_INFO = extern struct {
    pszUserName: ?PWSTR,
    pszDomain: ?PWSTR,
    pszPassword: ?PWSTR,
    pszOldPassword: ?PWSTR,
};

pub const WLX_TERMINAL_SERVICES_DATA = extern struct {
    ProfilePath: [257]u16,
    HomeDir: [257]u16,
    HomeDirDrive: [4]u16,
};

pub const WLX_CLIENT_CREDENTIALS_INFO_V1_0 = extern struct {
    dwType: u32,
    pszUserName: ?PWSTR,
    pszDomain: ?PWSTR,
    pszPassword: ?PWSTR,
    fPromptForPassword: BOOL,
};

pub const WLX_CLIENT_CREDENTIALS_INFO_V2_0 = extern struct {
    dwType: u32,
    pszUserName: ?PWSTR,
    pszDomain: ?PWSTR,
    pszPassword: ?PWSTR,
    fPromptForPassword: BOOL,
    fDisconnectOnLogonFailure: BOOL,
};

pub const WLX_CONSOLESWITCH_CREDENTIALS_INFO_V1_0 = extern struct {
    dwType: u32,
    UserToken: ?HANDLE,
    LogonId: LUID,
    Quotas: QUOTA_LIMITS,
    UserName: ?PWSTR,
    Domain: ?PWSTR,
    LogonTime: LARGE_INTEGER,
    SmartCardLogon: BOOL,
    ProfileLength: u32,
    MessageType: u32,
    LogonCount: u16,
    BadPasswordCount: u16,
    ProfileLogonTime: LARGE_INTEGER,
    LogoffTime: LARGE_INTEGER,
    KickOffTime: LARGE_INTEGER,
    PasswordLastSet: LARGE_INTEGER,
    PasswordCanChange: LARGE_INTEGER,
    PasswordMustChange: LARGE_INTEGER,
    LogonScript: ?PWSTR,
    HomeDirectory: ?PWSTR,
    FullName: ?PWSTR,
    ProfilePath: ?PWSTR,
    HomeDirectoryDrive: ?PWSTR,
    LogonServer: ?PWSTR,
    UserFlags: u32,
    PrivateDataLen: u32,
    PrivateData: ?*u8,
};

pub const WLX_DESKTOP = extern struct {
    Size: u32,
    Flags: u32,
    hDesktop: ?HDESK,
    pszDesktopName: ?PWSTR,
};

pub const PWLX_USE_CTRL_ALT_DEL = *const fn(
    hWlx: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) void;

pub const PWLX_SET_CONTEXT_POINTER = *const fn(
    hWlx: ?HANDLE,
    pWlxContext: ?*anyopaque,
) callconv(@import("std").os.windows.WINAPI) void;

pub const PWLX_SAS_NOTIFY = *const fn(
    hWlx: ?HANDLE,
    dwSasType: u32,
) callconv(@import("std").os.windows.WINAPI) void;

pub const PWLX_SET_TIMEOUT = *const fn(
    hWlx: ?HANDLE,
    Timeout: u32,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_ASSIGN_SHELL_PROTECTION = *const fn(
    hWlx: ?HANDLE,
    hToken: ?HANDLE,
    hProcess: ?HANDLE,
    hThread: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_MESSAGE_BOX = *const fn(
    hWlx: ?HANDLE,
    hwndOwner: ?HWND,
    lpszText: ?PWSTR,
    lpszTitle: ?PWSTR,
    fuStyle: u32,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_DIALOG_BOX = *const fn(
    hWlx: ?HANDLE,
    hInst: ?HANDLE,
    lpszTemplate: ?PWSTR,
    hwndOwner: ?HWND,
    dlgprc: ?DLGPROC,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_DIALOG_BOX_INDIRECT = *const fn(
    hWlx: ?HANDLE,
    hInst: ?HANDLE,
    hDialogTemplate: ?*DLGTEMPLATE,
    hwndOwner: ?HWND,
    dlgprc: ?DLGPROC,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_DIALOG_BOX_PARAM = *const fn(
    hWlx: ?HANDLE,
    hInst: ?HANDLE,
    lpszTemplate: ?PWSTR,
    hwndOwner: ?HWND,
    dlgprc: ?DLGPROC,
    dwInitParam: LPARAM,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_DIALOG_BOX_INDIRECT_PARAM = *const fn(
    hWlx: ?HANDLE,
    hInst: ?HANDLE,
    hDialogTemplate: ?*DLGTEMPLATE,
    hwndOwner: ?HWND,
    dlgprc: ?DLGPROC,
    dwInitParam: LPARAM,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_SWITCH_DESKTOP_TO_USER = *const fn(
    hWlx: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_SWITCH_DESKTOP_TO_WINLOGON = *const fn(
    hWlx: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_CHANGE_PASSWORD_NOTIFY = *const fn(
    hWlx: ?HANDLE,
    pMprInfo: ?*WLX_MPR_NOTIFY_INFO,
    dwChangeInfo: u32,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_GET_SOURCE_DESKTOP = *const fn(
    hWlx: ?HANDLE,
    ppDesktop: ?*?*WLX_DESKTOP,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_SET_RETURN_DESKTOP = *const fn(
    hWlx: ?HANDLE,
    pDesktop: ?*WLX_DESKTOP,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_CREATE_USER_DESKTOP = *const fn(
    hWlx: ?HANDLE,
    hToken: ?HANDLE,
    Flags: u32,
    pszDesktopName: ?PWSTR,
    ppDesktop: ?*?*WLX_DESKTOP,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_CHANGE_PASSWORD_NOTIFY_EX = *const fn(
    hWlx: ?HANDLE,
    pMprInfo: ?*WLX_MPR_NOTIFY_INFO,
    dwChangeInfo: u32,
    ProviderName: ?PWSTR,
    Reserved: ?*anyopaque,
) callconv(@import("std").os.windows.WINAPI) i32;

pub const PWLX_CLOSE_USER_DESKTOP = *const fn(
    hWlx: ?HANDLE,
    pDesktop: ?*WLX_DESKTOP,
    hToken: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_SET_OPTION = *const fn(
    hWlx: ?HANDLE,
    Option: u32,
    Value: usize,
    OldValue: ?*usize,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_GET_OPTION = *const fn(
    hWlx: ?HANDLE,
    Option: u32,
    Value: ?*usize,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_WIN31_MIGRATE = *const fn(
    hWlx: ?HANDLE,
) callconv(@import("std").os.windows.WINAPI) void;

pub const PWLX_QUERY_CLIENT_CREDENTIALS = *const fn(
    pCred: ?*WLX_CLIENT_CREDENTIALS_INFO_V1_0,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_QUERY_IC_CREDENTIALS = *const fn(
    pCred: ?*WLX_CLIENT_CREDENTIALS_INFO_V1_0,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_QUERY_TS_LOGON_CREDENTIALS = *const fn(
    pCred: ?*WLX_CLIENT_CREDENTIALS_INFO_V2_0,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_DISCONNECT = *const fn(
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub const PWLX_QUERY_TERMINAL_SERVICES_DATA = *const fn(
    hWlx: ?HANDLE,
    pTSData: ?*WLX_TERMINAL_SERVICES_DATA,
    UserName: ?PWSTR,
    Domain: ?PWSTR,
) callconv(@import("std").os.windows.WINAPI) u32;

pub const PWLX_QUERY_CONSOLESWITCH_CREDENTIALS = *const fn(
    pCred: ?*WLX_CONSOLESWITCH_CREDENTIALS_INFO_V1_0,
) callconv(@import("std").os.windows.WINAPI) u32;

pub const WLX_DISPATCH_VERSION_1_0 = extern struct {
    WlxUseCtrlAltDel: ?PWLX_USE_CTRL_ALT_DEL,
    WlxSetContextPointer: ?PWLX_SET_CONTEXT_POINTER,
    WlxSasNotify: ?PWLX_SAS_NOTIFY,
    WlxSetTimeout: ?PWLX_SET_TIMEOUT,
    WlxAssignShellProtection: ?PWLX_ASSIGN_SHELL_PROTECTION,
    WlxMessageBox: ?PWLX_MESSAGE_BOX,
    WlxDialogBox: ?PWLX_DIALOG_BOX,
    WlxDialogBoxParam: ?PWLX_DIALOG_BOX_PARAM,
    WlxDialogBoxIndirect: ?PWLX_DIALOG_BOX_INDIRECT,
    WlxDialogBoxIndirectParam: ?PWLX_DIALOG_BOX_INDIRECT_PARAM,
    WlxSwitchDesktopToUser: ?PWLX_SWITCH_DESKTOP_TO_USER,
    WlxSwitchDesktopToWinlogon: ?PWLX_SWITCH_DESKTOP_TO_WINLOGON,
    WlxChangePasswordNotify: ?PWLX_CHANGE_PASSWORD_NOTIFY,
};

pub const WLX_DISPATCH_VERSION_1_1 = extern struct {
    WlxUseCtrlAltDel: ?PWLX_USE_CTRL_ALT_DEL,
    WlxSetContextPointer: ?PWLX_SET_CONTEXT_POINTER,
    WlxSasNotify: ?PWLX_SAS_NOTIFY,
    WlxSetTimeout: ?PWLX_SET_TIMEOUT,
    WlxAssignShellProtection: ?PWLX_ASSIGN_SHELL_PROTECTION,
    WlxMessageBox: ?PWLX_MESSAGE_BOX,
    WlxDialogBox: ?PWLX_DIALOG_BOX,
    WlxDialogBoxParam: ?PWLX_DIALOG_BOX_PARAM,
    WlxDialogBoxIndirect: ?PWLX_DIALOG_BOX_INDIRECT,
    WlxDialogBoxIndirectParam: ?PWLX_DIALOG_BOX_INDIRECT_PARAM,
    WlxSwitchDesktopToUser: ?PWLX_SWITCH_DESKTOP_TO_USER,
    WlxSwitchDesktopToWinlogon: ?PWLX_SWITCH_DESKTOP_TO_WINLOGON,
    WlxChangePasswordNotify: ?PWLX_CHANGE_PASSWORD_NOTIFY,
    WlxGetSourceDesktop: ?PWLX_GET_SOURCE_DESKTOP,
    WlxSetReturnDesktop: ?PWLX_SET_RETURN_DESKTOP,
    WlxCreateUserDesktop: ?PWLX_CREATE_USER_DESKTOP,
    WlxChangePasswordNotifyEx: ?PWLX_CHANGE_PASSWORD_NOTIFY_EX,
};

pub const WLX_DISPATCH_VERSION_1_2 = extern struct {
    WlxUseCtrlAltDel: ?PWLX_USE_CTRL_ALT_DEL,
    WlxSetContextPointer: ?PWLX_SET_CONTEXT_POINTER,
    WlxSasNotify: ?PWLX_SAS_NOTIFY,
    WlxSetTimeout: ?PWLX_SET_TIMEOUT,
    WlxAssignShellProtection: ?PWLX_ASSIGN_SHELL_PROTECTION,
    WlxMessageBox: ?PWLX_MESSAGE_BOX,
    WlxDialogBox: ?PWLX_DIALOG_BOX,
    WlxDialogBoxParam: ?PWLX_DIALOG_BOX_PARAM,
    WlxDialogBoxIndirect: ?PWLX_DIALOG_BOX_INDIRECT,
    WlxDialogBoxIndirectParam: ?PWLX_DIALOG_BOX_INDIRECT_PARAM,
    WlxSwitchDesktopToUser: ?PWLX_SWITCH_DESKTOP_TO_USER,
    WlxSwitchDesktopToWinlogon: ?PWLX_SWITCH_DESKTOP_TO_WINLOGON,
    WlxChangePasswordNotify: ?PWLX_CHANGE_PASSWORD_NOTIFY,
    WlxGetSourceDesktop: ?PWLX_GET_SOURCE_DESKTOP,
    WlxSetReturnDesktop: ?PWLX_SET_RETURN_DESKTOP,
    WlxCreateUserDesktop: ?PWLX_CREATE_USER_DESKTOP,
    WlxChangePasswordNotifyEx: ?PWLX_CHANGE_PASSWORD_NOTIFY_EX,
    WlxCloseUserDesktop: ?PWLX_CLOSE_USER_DESKTOP,
};

pub const WLX_DISPATCH_VERSION_1_3 = extern struct {
    WlxUseCtrlAltDel: ?PWLX_USE_CTRL_ALT_DEL,
    WlxSetContextPointer: ?PWLX_SET_CONTEXT_POINTER,
    WlxSasNotify: ?PWLX_SAS_NOTIFY,
    WlxSetTimeout: ?PWLX_SET_TIMEOUT,
    WlxAssignShellProtection: ?PWLX_ASSIGN_SHELL_PROTECTION,
    WlxMessageBox: ?PWLX_MESSAGE_BOX,
    WlxDialogBox: ?PWLX_DIALOG_BOX,
    WlxDialogBoxParam: ?PWLX_DIALOG_BOX_PARAM,
    WlxDialogBoxIndirect: ?PWLX_DIALOG_BOX_INDIRECT,
    WlxDialogBoxIndirectParam: ?PWLX_DIALOG_BOX_INDIRECT_PARAM,
    WlxSwitchDesktopToUser: ?PWLX_SWITCH_DESKTOP_TO_USER,
    WlxSwitchDesktopToWinlogon: ?PWLX_SWITCH_DESKTOP_TO_WINLOGON,
    WlxChangePasswordNotify: ?PWLX_CHANGE_PASSWORD_NOTIFY,
    WlxGetSourceDesktop: ?PWLX_GET_SOURCE_DESKTOP,
    WlxSetReturnDesktop: ?PWLX_SET_RETURN_DESKTOP,
    WlxCreateUserDesktop: ?PWLX_CREATE_USER_DESKTOP,
    WlxChangePasswordNotifyEx: ?PWLX_CHANGE_PASSWORD_NOTIFY_EX,
    WlxCloseUserDesktop: ?PWLX_CLOSE_USER_DESKTOP,
    WlxSetOption: ?PWLX_SET_OPTION,
    WlxGetOption: ?PWLX_GET_OPTION,
    WlxWin31Migrate: ?PWLX_WIN31_MIGRATE,
    WlxQueryClientCredentials: ?PWLX_QUERY_CLIENT_CREDENTIALS,
    WlxQueryInetConnectorCredentials: ?PWLX_QUERY_IC_CREDENTIALS,
    WlxDisconnect: ?PWLX_DISCONNECT,
    WlxQueryTerminalServicesData: ?PWLX_QUERY_TERMINAL_SERVICES_DATA,
};

pub const WLX_DISPATCH_VERSION_1_4 = extern struct {
    WlxUseCtrlAltDel: ?PWLX_USE_CTRL_ALT_DEL,
    WlxSetContextPointer: ?PWLX_SET_CONTEXT_POINTER,
    WlxSasNotify: ?PWLX_SAS_NOTIFY,
    WlxSetTimeout: ?PWLX_SET_TIMEOUT,
    WlxAssignShellProtection: ?PWLX_ASSIGN_SHELL_PROTECTION,
    WlxMessageBox: ?PWLX_MESSAGE_BOX,
    WlxDialogBox: ?PWLX_DIALOG_BOX,
    WlxDialogBoxParam: ?PWLX_DIALOG_BOX_PARAM,
    WlxDialogBoxIndirect: ?PWLX_DIALOG_BOX_INDIRECT,
    WlxDialogBoxIndirectParam: ?PWLX_DIALOG_BOX_INDIRECT_PARAM,
    WlxSwitchDesktopToUser: ?PWLX_SWITCH_DESKTOP_TO_USER,
    WlxSwitchDesktopToWinlogon: ?PWLX_SWITCH_DESKTOP_TO_WINLOGON,
    WlxChangePasswordNotify: ?PWLX_CHANGE_PASSWORD_NOTIFY,
    WlxGetSourceDesktop: ?PWLX_GET_SOURCE_DESKTOP,
    WlxSetReturnDesktop: ?PWLX_SET_RETURN_DESKTOP,
    WlxCreateUserDesktop: ?PWLX_CREATE_USER_DESKTOP,
    WlxChangePasswordNotifyEx: ?PWLX_CHANGE_PASSWORD_NOTIFY_EX,
    WlxCloseUserDesktop: ?PWLX_CLOSE_USER_DESKTOP,
    WlxSetOption: ?PWLX_SET_OPTION,
    WlxGetOption: ?PWLX_GET_OPTION,
    WlxWin31Migrate: ?PWLX_WIN31_MIGRATE,
    WlxQueryClientCredentials: ?PWLX_QUERY_CLIENT_CREDENTIALS,
    WlxQueryInetConnectorCredentials: ?PWLX_QUERY_IC_CREDENTIALS,
    WlxDisconnect: ?PWLX_DISCONNECT,
    WlxQueryTerminalServicesData: ?PWLX_QUERY_TERMINAL_SERVICES_DATA,
    WlxQueryConsoleSwitchCredentials: ?PWLX_QUERY_CONSOLESWITCH_CREDENTIALS,
    WlxQueryTsLogonCredentials: ?PWLX_QUERY_TS_LOGON_CREDENTIALS,
};

pub const PFNMSGECALLBACK = *const fn(
    bVerbose: BOOL,
    lpMessage: ?PWSTR,
) callconv(@import("std").os.windows.WINAPI) u32;

pub const WLX_NOTIFICATION_INFO = extern struct {
    Size: u32,
    Flags: u32,
    UserName: ?PWSTR,
    Domain: ?PWSTR,
    WindowStation: ?PWSTR,
    hToken: ?HANDLE,
    hDesktop: ?HDESK,
    pStatusCallback: ?PFNMSGECALLBACK,
};


//--------------------------------------------------------------------------------
// Section: Functions (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Section: Imports (11)
//--------------------------------------------------------------------------------
const BOOL = @import("../foundation.zig").BOOL;
const DLGPROC = @import("../ui/windows_and_messaging.zig").DLGPROC;
const DLGTEMPLATE = @import("../ui/windows_and_messaging.zig").DLGTEMPLATE;
const HANDLE = @import("../foundation.zig").HANDLE;
const HDESK = @import("../system/stations_and_desktops.zig").HDESK;
const HWND = @import("../foundation.zig").HWND;
const LARGE_INTEGER = @import("../foundation.zig").LARGE_INTEGER;
const LPARAM = @import("../foundation.zig").LPARAM;
const LUID = @import("../foundation.zig").LUID;
const PWSTR = @import("../foundation.zig").PWSTR;
const QUOTA_LIMITS = @import("../security.zig").QUOTA_LIMITS;

test {
    // The following '_ = <FuncPtrType>' lines are a workaround for https://github.com/ziglang/zig/issues/4476
    if (@hasDecl(@This(), "PWLX_USE_CTRL_ALT_DEL")) { _ = PWLX_USE_CTRL_ALT_DEL; }
    if (@hasDecl(@This(), "PWLX_SET_CONTEXT_POINTER")) { _ = PWLX_SET_CONTEXT_POINTER; }
    if (@hasDecl(@This(), "PWLX_SAS_NOTIFY")) { _ = PWLX_SAS_NOTIFY; }
    if (@hasDecl(@This(), "PWLX_SET_TIMEOUT")) { _ = PWLX_SET_TIMEOUT; }
    if (@hasDecl(@This(), "PWLX_ASSIGN_SHELL_PROTECTION")) { _ = PWLX_ASSIGN_SHELL_PROTECTION; }
    if (@hasDecl(@This(), "PWLX_MESSAGE_BOX")) { _ = PWLX_MESSAGE_BOX; }
    if (@hasDecl(@This(), "PWLX_DIALOG_BOX")) { _ = PWLX_DIALOG_BOX; }
    if (@hasDecl(@This(), "PWLX_DIALOG_BOX_INDIRECT")) { _ = PWLX_DIALOG_BOX_INDIRECT; }
    if (@hasDecl(@This(), "PWLX_DIALOG_BOX_PARAM")) { _ = PWLX_DIALOG_BOX_PARAM; }
    if (@hasDecl(@This(), "PWLX_DIALOG_BOX_INDIRECT_PARAM")) { _ = PWLX_DIALOG_BOX_INDIRECT_PARAM; }
    if (@hasDecl(@This(), "PWLX_SWITCH_DESKTOP_TO_USER")) { _ = PWLX_SWITCH_DESKTOP_TO_USER; }
    if (@hasDecl(@This(), "PWLX_SWITCH_DESKTOP_TO_WINLOGON")) { _ = PWLX_SWITCH_DESKTOP_TO_WINLOGON; }
    if (@hasDecl(@This(), "PWLX_CHANGE_PASSWORD_NOTIFY")) { _ = PWLX_CHANGE_PASSWORD_NOTIFY; }
    if (@hasDecl(@This(), "PWLX_GET_SOURCE_DESKTOP")) { _ = PWLX_GET_SOURCE_DESKTOP; }
    if (@hasDecl(@This(), "PWLX_SET_RETURN_DESKTOP")) { _ = PWLX_SET_RETURN_DESKTOP; }
    if (@hasDecl(@This(), "PWLX_CREATE_USER_DESKTOP")) { _ = PWLX_CREATE_USER_DESKTOP; }
    if (@hasDecl(@This(), "PWLX_CHANGE_PASSWORD_NOTIFY_EX")) { _ = PWLX_CHANGE_PASSWORD_NOTIFY_EX; }
    if (@hasDecl(@This(), "PWLX_CLOSE_USER_DESKTOP")) { _ = PWLX_CLOSE_USER_DESKTOP; }
    if (@hasDecl(@This(), "PWLX_SET_OPTION")) { _ = PWLX_SET_OPTION; }
    if (@hasDecl(@This(), "PWLX_GET_OPTION")) { _ = PWLX_GET_OPTION; }
    if (@hasDecl(@This(), "PWLX_WIN31_MIGRATE")) { _ = PWLX_WIN31_MIGRATE; }
    if (@hasDecl(@This(), "PWLX_QUERY_CLIENT_CREDENTIALS")) { _ = PWLX_QUERY_CLIENT_CREDENTIALS; }
    if (@hasDecl(@This(), "PWLX_QUERY_IC_CREDENTIALS")) { _ = PWLX_QUERY_IC_CREDENTIALS; }
    if (@hasDecl(@This(), "PWLX_QUERY_TS_LOGON_CREDENTIALS")) { _ = PWLX_QUERY_TS_LOGON_CREDENTIALS; }
    if (@hasDecl(@This(), "PWLX_DISCONNECT")) { _ = PWLX_DISCONNECT; }
    if (@hasDecl(@This(), "PWLX_QUERY_TERMINAL_SERVICES_DATA")) { _ = PWLX_QUERY_TERMINAL_SERVICES_DATA; }
    if (@hasDecl(@This(), "PWLX_QUERY_CONSOLESWITCH_CREDENTIALS")) { _ = PWLX_QUERY_CONSOLESWITCH_CREDENTIALS; }
    if (@hasDecl(@This(), "PFNMSGECALLBACK")) { _ = PFNMSGECALLBACK; }

    @setEvalBranchQuota(
        comptime @import("std").meta.declarations(@This()).len * 3
    );

    // reference all the pub declarations
    if (!@import("builtin").is_test) return;
    inline for (comptime @import("std").meta.declarations(@This())) |decl| {
        _ = @field(@This(), decl.name);
    }
}
