import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

final class Rect extends ffi.Struct {
  @ffi.Int32()
  external int left;

  @ffi.Int32()
  external int top;

  @ffi.Int32()
  external int right;

  @ffi.Int32()
  external int bottom;
}

final class PhysicalMonitor extends ffi.Struct {
  @ffi.IntPtr()
  external int hPhysicalMonitor;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Uint16> description;
}

final class GUID extends ffi.Struct {
  @ffi.Uint32()
  external int Data1;

  @ffi.Uint16()
  external int Data2;

  @ffi.Uint16()
  external int Data3;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Uint8> Data4;
}

final class SP_DEVINFO_DATA extends ffi.Struct {
  @ffi.Uint32()
  external int cbSize;

  external GUID ClassGuid;

  @ffi.Uint32()
  external int DevInst;

  @ffi.IntPtr()
  external int Reserved;
}

final class McTimingReport extends ffi.Struct {
  @ffi.Uint32()
  external int horizontalFrequencyInHertz;

  @ffi.Uint32()
  external int verticalFrequencyInHertz;

  @ffi.Uint8()
  external int timingStatusByte;
}


final class MonitorInfoEx extends ffi.Struct {
  @ffi.Uint32()
  external int cbSize;

  @ffi.Int32()
  external int rcMonitorLeft;

  @ffi.Int32()
  external int rcMonitorTop;

  @ffi.Int32()
  external int rcMonitorRight;

  @ffi.Int32()
  external int rcMonitorBottom;

  @ffi.Int32()
  external int rcWorkLeft;

  @ffi.Int32()
  external int rcWorkTop;

  @ffi.Int32()
  external int rcWorkRight;

  @ffi.Int32()
  external int rcWorkBottom;

  @ffi.Uint32()
  external int dwFlags;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Uint16> szDevice;
}

final class DisplayDevice extends ffi.Struct {
  @ffi.Uint32()
  external int cb;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Uint16> deviceName;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Uint16> deviceString;

  @ffi.Uint32()
  external int stateFlags;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Uint16> deviceID;

  @ffi.Array.multi([128])
  external ffi.Array<ffi.Uint16> deviceKey;
}

final ffi.DynamicLibrary user32 = ffi.DynamicLibrary.open('user32.dll');
final ffi.DynamicLibrary dxva2 = ffi.DynamicLibrary.open('dxva2.dll');
final ffi.DynamicLibrary kernel32 = ffi.DynamicLibrary.open('kernel32.dll');
final ffi.DynamicLibrary advapi32 = ffi.DynamicLibrary.open('advapi32.dll');
final ffi.DynamicLibrary setupapi = ffi.DynamicLibrary.open('setupapi.dll');
final ffi.DynamicLibrary ole32 = ffi.DynamicLibrary.open('ole32.dll');

typedef EnumDisplayMonitorsNative = ffi.Int32 Function(ffi.IntPtr hdc, ffi.Pointer<Rect> lprcClip, ffi.Pointer<ffi.NativeFunction<MonitorEnumProcNative>> lpfnEnum, ffi.IntPtr dwData);
typedef EnumDisplayMonitorsDart = int Function(int hdc, ffi.Pointer<Rect> lprcClip, ffi.Pointer<ffi.NativeFunction<MonitorEnumProcNative>> lpfnEnum, int dwData);

typedef MonitorEnumProcNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.IntPtr hdcMonitor, ffi.Pointer<Rect> lprcMonitor, ffi.IntPtr dwData);

typedef GetNumberOfPhysicalMonitorsNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Uint32> pdwNumberOfPhysicalMonitors);
typedef GetNumberOfPhysicalMonitorsDart = int Function(int hMonitor, ffi.Pointer<ffi.Uint32> pdwNumberOfPhysicalMonitors);

typedef GetPhysicalMonitorsFromHMonitorNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint32 dwPhysicalMonitorArraySize, ffi.Pointer<PhysicalMonitor> pPhysicalMonitorArray);
typedef GetPhysicalMonitorsFromHMonitorDart = int Function(int hMonitor, int dwPhysicalMonitorArraySize, ffi.Pointer<PhysicalMonitor> pPhysicalMonitorArray);

typedef DestroyPhysicalMonitorNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef DestroyPhysicalMonitorDart = int Function(int hMonitor);

typedef GetCapabilitiesStringLengthNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Uint32> pdwCapabilitiesStringLengthInCharacters);
typedef GetCapabilitiesStringLengthDart = int Function(int hMonitor, ffi.Pointer<ffi.Uint32> pdwCapabilitiesStringLengthInCharacters);

typedef CapabilitiesRequestAndCapabilitiesReplyNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Int8> pszASCIICapabilitiesString, ffi.Uint32 dwCapabilitiesStringLengthInCharacters);
typedef CapabilitiesRequestAndCapabilitiesReplyDart = int Function(int hMonitor, ffi.Pointer<ffi.Int8> pszASCIICapabilitiesString, int dwCapabilitiesStringLengthInCharacters);

typedef GetVcpFeatureNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint8 bVCPCode, ffi.Pointer<ffi.Uint32> pvct, ffi.Pointer<ffi.Uint32> pdwCurrentValue, ffi.Pointer<ffi.Uint32> pdwMaximumValue);
typedef GetVcpFeatureDart = int Function(int hMonitor, int bVCPCode, ffi.Pointer<ffi.Uint32> pvct, ffi.Pointer<ffi.Uint32> pdwCurrentValue, ffi.Pointer<ffi.Uint32> pdwMaximumValue);

typedef SetVcpFeatureNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint8 bVCPCode, ffi.Uint32 dwNewValue);
typedef SetVcpFeatureDart = int Function(int hMonitor, int bVCPCode, int dwNewValue);

typedef SaveCurrentSettingsNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef SaveCurrentSettingsDart = int Function(int hMonitor);

typedef GetTimingReportNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<McTimingReport> pmtrMonitorTimingReport);
typedef GetTimingReportDart = int Function(int hMonitor, ffi.Pointer<McTimingReport> pmtrMonitorTimingReport);

typedef GetLastErrorNative = ffi.Uint32 Function();
typedef GetLastErrorDart = int Function();

typedef RegOpenKeyExNative = ffi.Int32 Function(ffi.IntPtr hKey, ffi.Pointer<Utf16> lpSubKey, ffi.Uint32 ulOptions, ffi.Uint32 samDesired, ffi.Pointer<ffi.IntPtr> phkResult);
typedef RegOpenKeyExDart = int Function(int hKey, ffi.Pointer<Utf16> lpSubKey, int ulOptions, int samDesired, ffi.Pointer<ffi.IntPtr> phkResult);

typedef RegEnumKeyExNative = ffi.Int32 Function(ffi.IntPtr hKey, ffi.Uint32 dwIndex, ffi.Pointer<Utf16> lpName, ffi.Pointer<ffi.Uint32> lpcchName, ffi.Pointer<ffi.Uint32> lpReserved, ffi.Pointer<Utf16> lpClass, ffi.Pointer<ffi.Uint32> lpcchClass, ffi.Pointer<ffi.Int64> lpftLastWriteTime);
typedef RegEnumKeyExDart = int Function(int hKey, int dwIndex, ffi.Pointer<Utf16> lpName, ffi.Pointer<ffi.Uint32> lpcchName, ffi.Pointer<ffi.Uint32> lpReserved, ffi.Pointer<Utf16> lpClass, ffi.Pointer<ffi.Uint32> lpcchClass, ffi.Pointer<ffi.Int64> lpftLastWriteTime);

typedef RegQueryValueExNative = ffi.Int32 Function(ffi.IntPtr hKey, ffi.Pointer<Utf16> lpValueName, ffi.Pointer<ffi.Uint32> lpReserved, ffi.Pointer<ffi.Uint32> lpType, ffi.Pointer<ffi.Uint8> lpData, ffi.Pointer<ffi.Uint32> lpcbData);
typedef RegQueryValueExDart = int Function(int hKey, ffi.Pointer<Utf16> lpValueName, ffi.Pointer<ffi.Uint32> lpReserved, ffi.Pointer<ffi.Uint32> lpType, ffi.Pointer<ffi.Uint8> lpData, ffi.Pointer<ffi.Uint32> lpcbData);

typedef RegCloseKeyNative = ffi.Int32 Function(ffi.IntPtr hKey);
typedef RegCloseKeyDart = int Function(int hKey);

typedef GetMonitorInfoNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<MonitorInfoEx> lpmi);
typedef GetMonitorInfoDart = int Function(int hMonitor, ffi.Pointer<MonitorInfoEx> lpmi);

typedef EnumDisplayDevicesNative = ffi.Int32 Function(ffi.Pointer<Utf16> lpDevice, ffi.Uint32 iDevNum, ffi.Pointer<DisplayDevice> lpDisplayDevice, ffi.Uint32 dwFlags);
typedef EnumDisplayDevicesDart = int Function(ffi.Pointer<Utf16> lpDevice, int iDevNum, ffi.Pointer<DisplayDevice> lpDisplayDevice, int dwFlags);

typedef CLSIDFromStringNative = ffi.Int32 Function(ffi.Pointer<Utf16> lpsz, ffi.Pointer<GUID> pclsid);
typedef CLSIDFromStringDart = int Function(ffi.Pointer<Utf16> lpsz, ffi.Pointer<GUID> pclsid);

typedef SetupDiGetClassDevsNative = ffi.IntPtr Function(ffi.Pointer<GUID> ClassGuid, ffi.Pointer<Utf16> Enumerator, ffi.IntPtr hwndParent, ffi.Uint32 Flags);
typedef SetupDiGetClassDevsDart = int Function(ffi.Pointer<GUID> ClassGuid, ffi.Pointer<Utf16> Enumerator, int hwndParent, int Flags);

typedef SetupDiEnumDeviceInfoNative = ffi.Int32 Function(ffi.IntPtr DeviceInfoSet, ffi.Uint32 MemberIndex, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData);
typedef SetupDiEnumDeviceInfoDart = int Function(int DeviceInfoSet, int MemberIndex, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData);

typedef SetupDiOpenDevRegKeyNative = ffi.IntPtr Function(ffi.IntPtr DeviceInfoSet, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData, ffi.Uint32 Scope, ffi.Uint32 HwProfile, ffi.Uint32 KeyType, ffi.Uint32 samDesired);
typedef SetupDiOpenDevRegKeyDart = int Function(int DeviceInfoSet, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData, int Scope, int HwProfile, int KeyType, int samDesired);

typedef SetupDiDestroyDeviceInfoListNative = ffi.Int32 Function(ffi.IntPtr DeviceInfoSet);
typedef SetupDiDestroyDeviceInfoListDart = int Function(int DeviceInfoSet);

typedef SetupDiGetDeviceInstanceIdNative = ffi.Int32 Function(ffi.IntPtr DeviceInfoSet, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData, ffi.Pointer<Utf16> DeviceInstanceId, ffi.Uint32 DeviceInstanceIdSize, ffi.Pointer<ffi.Uint32> RequiredSize);
typedef SetupDiGetDeviceInstanceIdDart = int Function(int DeviceInfoSet, ffi.Pointer<SP_DEVINFO_DATA> DeviceInfoData, ffi.Pointer<Utf16> DeviceInstanceId, int DeviceInstanceIdSize, ffi.Pointer<ffi.Uint32> RequiredSize);


/// 枚举所有显示监视器
///
/// 遍历系统中所有的显示监视器，并为每个监视器调用回调函数。
/// 用于获取系统中所有逻辑监视器的句柄列表。
///
/// 参数:
/// - [hdc]: 设备上下文句柄，传入 0 表示枚举所有监视器
/// - [lprcClip]: 裁剪矩形指针，传入 nullptr 表示不裁剪
/// - [lpfnEnum]: 枚举回调函数指针，为每个监视器调用一次
/// - [dwData]: 传递给回调函数的用户自定义数据
///
/// 返回值: 成功返回非零值，失败返回 0
final EnumDisplayMonitorsDart EnumDisplayMonitors = user32.lookupFunction<EnumDisplayMonitorsNative, EnumDisplayMonitorsDart>('EnumDisplayMonitors');

/// 获取物理监视器数量
///
/// 根据逻辑监视器句柄（HMONITOR）获取与之关联的物理监视器数量。
/// 一个逻辑监视器可能对应多个物理监视器（如拼接屏）。
///
/// 参数:
/// - [hMonitor]: 逻辑监视器句柄
/// - [pdwNumberOfPhysicalMonitors]: 输出参数，接收物理监视器数量
///
/// 返回值: 成功返回非零值，失败返回 0
final GetNumberOfPhysicalMonitorsDart GetNumberOfPhysicalMonitorsFromHMONITOR = dxva2.lookupFunction<GetNumberOfPhysicalMonitorsNative, GetNumberOfPhysicalMonitorsDart>('GetNumberOfPhysicalMonitorsFromHMONITOR');

/// 获取物理监视器信息
///
/// 根据逻辑监视器句柄获取所有关联的物理监视器句柄和描述信息。
/// 返回的物理监视器句柄用于后续的 DDC/CI 通信。
///
/// 参数:
/// - [hMonitor]: 逻辑监视器句柄
/// - [dwPhysicalMonitorArraySize]: 物理监视器数组大小
/// - [pPhysicalMonitorArray]: 输出参数，接收物理监视器信息数组
///
/// 返回值: 成功返回非零值，失败返回 0
final GetPhysicalMonitorsFromHMonitorDart GetPhysicalMonitorsFromHMONITOR = dxva2.lookupFunction<GetPhysicalMonitorsFromHMonitorNative, GetPhysicalMonitorsFromHMonitorDart>('GetPhysicalMonitorsFromHMONITOR');

/// 销毁物理监视器句柄
///
/// 释放通过 GetPhysicalMonitorsFromHMONITOR 获取的物理监视器句柄。
/// 使用完毕后必须调用此函数以释放系统资源。
///
/// 参数:
/// - [hMonitor]: 要销毁的物理监视器句柄
///
/// 返回值: 成功返回非零值，失败返回 0
final DestroyPhysicalMonitorDart DestroyPhysicalMonitor = dxva2.lookupFunction<DestroyPhysicalMonitorNative, DestroyPhysicalMonitorDart>('DestroyPhysicalMonitor');

/// 获取 Capabilities 字符串长度
///
/// 查询监视器 DDC/CI Capabilities 字符串的长度（字符数）。
/// 用于在读取 Capabilities 字符串前分配合适大小的缓冲区。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
/// - [pdwCapabilitiesStringLengthInCharacters]: 输出参数，接收字符串长度
///
/// 返回值: 成功返回非零值，失败返回 0
final GetCapabilitiesStringLengthDart GetCapabilitiesStringLength = dxva2.lookupFunction<GetCapabilitiesStringLengthNative, GetCapabilitiesStringLengthDart>('GetCapabilitiesStringLength');

/// 请求并接收 Capabilities 字符串
///
/// 通过 DDC/CI 协议从监视器读取 Capabilities 字符串。
/// Capabilities 字符串描述了监视器支持的所有 VCP 功能代码和取值范围。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
/// - [pszASCIICapabilitiesString]: 输出参数，接收 ASCII 格式的 Capabilities 字符串
/// - [dwCapabilitiesStringLengthInCharacters]: 缓冲区大小（字符数）
///
/// 返回值: 成功返回非零值，失败返回 0
final CapabilitiesRequestAndCapabilitiesReplyDart CapabilitiesRequestAndCapabilitiesReply = dxva2.lookupFunction<CapabilitiesRequestAndCapabilitiesReplyNative, CapabilitiesRequestAndCapabilitiesReplyDart>('CapabilitiesRequestAndCapabilitiesReply');

/// 获取 VCP 功能值
///
/// 读取监视器指定 VCP 功能代码的当前值、最大值和类型。
/// VCP (Virtual Control Panel) 是 DDC/CI 协议中用于控制监视器参数的标准接口。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
/// - [bVCPCode]: VCP 功能代码（如 0x10 表示亮度）
/// - [pvct]: 输出参数，接收 VCP 代码类型（可为 nullptr）
/// - [pdwCurrentValue]: 输出参数，接收当前值
/// - [pdwMaximumValue]: 输出参数，接收最大值（可为 nullptr）
///
/// 返回值: 成功返回非零值，失败返回 0
final GetVcpFeatureDart GetVCPFeatureAndVCPFeatureReply = dxva2.lookupFunction<GetVcpFeatureNative, GetVcpFeatureDart>('GetVCPFeatureAndVCPFeatureReply');

/// 设置 VCP 功能值
///
/// 通过 DDC/CI 协议设置监视器指定 VCP 功能代码的新值。
/// 用于控制亮度、对比度、输入源等监视器参数。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
/// - [bVCPCode]: VCP 功能代码
/// - [dwNewValue]: 要设置的新值
///
/// 返回值: 成功返回非零值，失败返回 0
final SetVcpFeatureDart SetVCPFeature = dxva2.lookupFunction<SetVcpFeatureNative, SetVcpFeatureDart>('SetVCPFeature');

/// 保存当前设置
///
/// 将监视器当前的所有设置保存到非易失性存储器（NVRAM）。
/// 确保设置在断电后仍然保留。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
///
/// 返回值: 成功返回非零值，失败返回 0
final SaveCurrentSettingsDart SaveCurrentSettings = dxva2.lookupFunction<SaveCurrentSettingsNative, SaveCurrentSettingsDart>('SaveCurrentSettings');

/// 获取时序报告
///
/// 读取监视器当前的水平和垂直刷新频率以及时序状态。
/// 用于诊断监视器的同步状态和显示模式。
///
/// 参数:
/// - [hMonitor]: 物理监视器句柄
/// - [pmtrMonitorTimingReport]: 输出参数，接收时序报告结构
///
/// 返回值: 成功返回非零值，失败返回 0
final GetTimingReportDart GetTimingReport = dxva2.lookupFunction<GetTimingReportNative, GetTimingReportDart>('GetTimingReport');

/// 获取最后的错误代码
///
/// 返回调用线程最后一次发生的 Win32 错误代码。
/// 用于诊断 Windows API 调用失败的原因。
///
/// 参数: 无
///
/// 返回值: 最后一次错误的错误代码
final GetLastErrorDart GetLastError = kernel32.lookupFunction<GetLastErrorNative, GetLastErrorDart>('GetLastError');

/// 打开注册表项
///
/// 打开指定的注册表项以进行读取或写入操作。
/// 用于访问监视器的 EDID 和其他配置信息。
///
/// 参数:
/// - [hKey]: 父注册表项句柄（如 HKEY_LOCAL_MACHINE）
/// - [lpSubKey]: 要打开的子项路径
/// - [ulOptions]: 保留参数，必须为 0
/// - [samDesired]: 访问权限掩码（如 KEY_READ）
/// - [phkResult]: 输出参数，接收打开的注册表项句柄
///
/// 返回值: 成功返回 ERROR_SUCCESS (0)，失败返回错误代码
final RegOpenKeyExDart RegOpenKeyExW = advapi32.lookupFunction<RegOpenKeyExNative, RegOpenKeyExDart>('RegOpenKeyExW');

/// 枚举注册表子项
///
/// 枚举指定注册表项下的所有子项名称。
/// 用于遍历监视器设备的注册表信息。
///
/// 参数:
/// - [hKey]: 注册表项句柄
/// - [dwIndex]: 子项索引（从 0 开始）
/// - [lpName]: 输出参数，接收子项名称
/// - [lpcchName]: 输入/输出参数，缓冲区大小和实际名称长度
/// - [lpReserved]: 保留参数，必须为 nullptr
/// - [lpClass]: 输出参数，接收类名（可为 nullptr）
/// - [lpcchClass]: 输入/输出参数，类名缓冲区大小（可为 nullptr）
/// - [lpftLastWriteTime]: 输出参数，接收最后写入时间（可为 nullptr）
///
/// 返回值: 成功返回 ERROR_SUCCESS (0)，无更多项返回 ERROR_NO_MORE_ITEMS
final RegEnumKeyExDart RegEnumKeyExW = advapi32.lookupFunction<RegEnumKeyExNative, RegEnumKeyExDart>('RegEnumKeyExW');

/// 查询注册表值
///
/// 读取指定注册表项中某个值的数据、类型和大小。
/// 用于获取监视器的 EDID、友好名称等信息。
///
/// 参数:
/// - [hKey]: 注册表项句柄
/// - [lpValueName]: 值名称（nullptr 表示默认值）
/// - [lpReserved]: 保留参数，必须为 nullptr
/// - [lpType]: 输出参数，接收值类型（可为 nullptr）
/// - [lpData]: 输出参数，接收值数据（可为 nullptr）
/// - [lpcbData]: 输入/输出参数，缓冲区大小和实际数据大小
///
/// 返回值: 成功返回 ERROR_SUCCESS (0)，失败返回错误代码
final RegQueryValueExDart RegQueryValueExW = advapi32.lookupFunction<RegQueryValueExNative, RegQueryValueExDart>('RegQueryValueExW');

/// 关闭注册表项
///
/// 关闭通过 RegOpenKeyExW 打开的注册表项句柄。
/// 使用完毕后必须调用以释放系统资源。
///
/// 参数:
/// - [hKey]: 要关闭的注册表项句柄
///
/// 返回值: 成功返回 ERROR_SUCCESS (0)，失败返回错误代码
final RegCloseKeyDart RegCloseKey = advapi32.lookupFunction<RegCloseKeyNative, RegCloseKeyDart>('RegCloseKey');

/// 获取监视器信息
///
/// 获取指定监视器的详细信息，包括工作区域、显示区域、标志和设备名称。
/// 用于获取逻辑监视器的基本属性。
///
/// 参数:
/// - [hMonitor]: 逻辑监视器句柄
/// - [lpmi]: 输出参数，接收监视器信息结构（需预先设置 cbSize 字段）
///
/// 返回值: 成功返回非零值，失败返回 0
final GetMonitorInfoDart GetMonitorInfoW = user32.lookupFunction<GetMonitorInfoNative, GetMonitorInfoDart>('GetMonitorInfoW');

/// 枚举显示设备
///
/// 枚举系统中的显示适配器和监视器设备。
/// 用于获取显示设备的名称、状态和标识信息。
///
/// 参数:
/// - [lpDevice]: 设备名称（nullptr 表示枚举所有适配器）
/// - [iDevNum]: 设备索引（从 0 开始）
/// - [lpDisplayDevice]: 输出参数，接收设备信息（需预先设置 cb 字段）
/// - [dwFlags]: 枚举标志（如 EDD_GET_DEVICE_INTERFACE_NAME）
///
/// 返回值: 成功返回非零值，失败返回 0
final EnumDisplayDevicesDart EnumDisplayDevicesW = user32.lookupFunction<EnumDisplayDevicesNative, EnumDisplayDevicesDart>('EnumDisplayDevicesW');

/// 从字符串转换为 CLSID
///
/// 将字符串格式的 GUID 转换为 GUID 结构体。
/// 用于处理设备类 GUID，如监视器设备类。
///
/// 参数:
/// - [lpsz]: 字符串格式的 GUID（如 "{4d36e96e-e325-11ce-bfc1-08002be10318}"）
/// - [pclsid]: 输出参数，接收转换后的 GUID 结构
///
/// 返回值: 成功返回 S_OK (0)，失败返回 HRESULT 错误代码
final CLSIDFromStringDart CLSIDFromString = ole32.lookupFunction<CLSIDFromStringNative, CLSIDFromStringDart>('CLSIDFromString');

/// 获取设备信息集
///
/// 创建包含指定设备类所有设备的设备信息集。
/// 用于枚举系统中的监视器设备。
///
/// 参数:
/// - [ClassGuid]: 设备类 GUID 指针（nullptr 表示所有类）
/// - [Enumerator]: 枚举器名称（nullptr 表示所有枚举器）
/// - [hwndParent]: 父窗口句柄（通常为 0）
/// - [Flags]: 控制标志（如 DIGCF_PRESENT | DIGCF_DEVICEINTERFACE）
///
/// 返回值: 成功返回设备信息集句柄，失败返回 INVALID_HANDLE_VALUE
final SetupDiGetClassDevsDart SetupDiGetClassDevsW = setupapi.lookupFunction<SetupDiGetClassDevsNative, SetupDiGetClassDevsDart>('SetupDiGetClassDevsW');

/// 枚举设备信息
///
/// 从设备信息集中枚举指定索引的设备信息。
/// 用于遍历所有监视器设备。
///
/// 参数:
/// - [DeviceInfoSet]: 设备信息集句柄
/// - [MemberIndex]: 设备索引（从 0 开始）
/// - [DeviceInfoData]: 输出参数，接收设备信息（需预先设置 cbSize 字段）
///
/// 返回值: 成功返回非零值，失败返回 0
final SetupDiEnumDeviceInfoDart SetupDiEnumDeviceInfo = setupapi.lookupFunction<SetupDiEnumDeviceInfoNative, SetupDiEnumDeviceInfoDart>('SetupDiEnumDeviceInfo');

/// 打开设备注册表项
///
/// 打开设备信息集中指定设备的注册表项。
/// 用于访问设备的驱动程序参数和配置信息。
///
/// 参数:
/// - [DeviceInfoSet]: 设备信息集句柄
/// - [DeviceInfoData]: 设备信息数据指针
/// - [Scope]: 注册表项范围（如 DICS_FLAG_GLOBAL）
/// - [HwProfile]: 硬件配置文件 ID（通常为 0）
/// - [KeyType]: 注册表项类型（如 DIREG_DEV）
/// - [samDesired]: 访问权限掩码（如 KEY_READ）
///
/// 返回值: 成功返回注册表项句柄，失败返回 INVALID_HANDLE_VALUE
final SetupDiOpenDevRegKeyDart SetupDiOpenDevRegKey = setupapi.lookupFunction<SetupDiOpenDevRegKeyNative, SetupDiOpenDevRegKeyDart>('SetupDiOpenDevRegKey');

/// 销毁设备信息列表
///
/// 释放通过 SetupDiGetClassDevsW 创建的设备信息集。
/// 使用完毕后必须调用以释放系统资源。
///
/// 参数:
/// - [DeviceInfoSet]: 要销毁的设备信息集句柄
///
/// 返回值: 成功返回非零值，失败返回 0
final SetupDiDestroyDeviceInfoListDart SetupDiDestroyDeviceInfoList = setupapi.lookupFunction<SetupDiDestroyDeviceInfoListNative, SetupDiDestroyDeviceInfoListDart>('SetupDiDestroyDeviceInfoList');

/// 获取设备实例 ID
///
/// 获取设备信息集中指定设备的设备实例 ID（Device Instance ID）。
/// 设备实例 ID 是设备在系统中的唯一标识符。
///
/// 参数:
/// - [DeviceInfoSet]: 设备信息集句柄
/// - [DeviceInfoData]: 设备信息数据指针
/// - [DeviceInstanceId]: 输出参数，接收设备实例 ID 字符串
/// - [DeviceInstanceIdSize]: 缓冲区大小（字符数）
/// - [RequiredSize]: 输出参数，接收所需缓冲区大小（可为 nullptr）
///
/// 返回值: 成功返回非零值，失败返回 0
final SetupDiGetDeviceInstanceIdDart SetupDiGetDeviceInstanceIdW = setupapi.lookupFunction<SetupDiGetDeviceInstanceIdNative, SetupDiGetDeviceInstanceIdDart>('SetupDiGetDeviceInstanceIdW');
