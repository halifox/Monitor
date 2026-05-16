import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:ffi/ffi.dart';
import 'package:pureddcci/src/pureddc/vcp_read_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pureddc/ddc_bindings.dart';
import 'pureddc/capabilities_info.dart';
import 'pureddc/edid_info.dart';

part 'providers.g.dart';

/// 逻辑监视器列表提供者
///
/// 枚举系统中所有的逻辑监视器，返回监视器句柄列表。
/// 通过调用 Windows API EnumDisplayMonitors 遍历所有显示监视器。
/// 每个逻辑监视器可能对应一个或多个物理监视器（如拼接屏）。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
///
/// 返回值: 逻辑监视器句柄（HMONITOR）列表
@Riverpod(keepAlive: true)
List<int> logicalMonitors(Ref ref) {
  debugPrint('[Provider] logicalMonitors: 开始枚举逻辑监视器');
  final List<int> localMonitors = [];
  final callable = ffi.NativeCallable<MonitorEnumProcNative>.isolateLocal((
    int hMonitor,
    int hdcMonitor,
    ffi.Pointer<Rect> lprcMonitor,
    int dwData,
  ) {
    debugPrint('[Provider] logicalMonitors: 发现监视器句柄 0x${hMonitor.toRadixString(16)}');
    localMonitors.add(hMonitor);
    return 1;
  }, exceptionalReturn: 0);
  try {
    final ffi.Pointer<ffi.NativeFunction<MonitorEnumProcNative>> ptr = callable.nativeFunction;
    final int result = EnumDisplayMonitors(0, ffi.nullptr, ptr, 0);
    if (result == 0) {
      debugPrint('[Provider] logicalMonitors: 枚举失败, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to enumerate display monitors, Win32 error ${GetLastError()}.');
    }
    debugPrint('[Provider] logicalMonitors: 枚举完成, 共找到 ${localMonitors.length} 个监视器');
  } finally {
    callable.close();
  }
  return localMonitors;
}

/// 物理监视器列表提供者
///
/// 根据逻辑监视器句柄获取所有关联的物理监视器句柄列表。
/// 一个逻辑监视器可能对应多个物理监视器（如拼接屏幕）。
/// 物理监视器句柄用于后续的 DDC/CI 通信操作。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [hMonitor]: 逻辑监视器句柄
///
/// 返回值: 物理监视器句柄列表
///
/// 异常: 如果获取失败则抛出 StateError
@Riverpod(keepAlive: true)
List<int> physicalMonitors(Ref ref, int hMonitor) {
  debugPrint('[Provider] physicalMonitors: 开始获取物理监视器, hMonitor=0x${hMonitor.toRadixString(16)}');
  return using((arena) {
    final ffi.Pointer<ffi.Uint32> countPointer = arena<ffi.Uint32>();
    final int countResult = GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor, countPointer);
    if (countResult == 0) {
      debugPrint('[Provider] physicalMonitors: 获取物理监视器数量失败, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to get physical monitor count, Win32 error ${GetLastError()}.');
    }
    final int count = countPointer.value;
    debugPrint('[Provider] physicalMonitors: 物理监视器数量 = $count');
    if (count == 0) {
      throw StateError('Monitor handle $hMonitor has no associated physical monitors.');
    }
    final ffi.Pointer<PhysicalMonitor> physicalArray = arena<PhysicalMonitor>(count);
    final int getResult = GetPhysicalMonitorsFromHMONITOR(hMonitor, count, physicalArray);
    if (getResult == 0) {
      debugPrint('[Provider] physicalMonitors: 获取物理监视器信息失败, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to get physical monitor info, Win32 error ${GetLastError()}.');
    }

    final List<int> handles = <int>[];
    for (int index = 0; index < count; index++) {
      final PhysicalMonitor raw = (physicalArray + index).ref;
      debugPrint('[Provider] physicalMonitors: 物理监视器[$index] 句柄 = 0x${raw.hPhysicalMonitor.toRadixString(16)}');
      handles.add(raw.hPhysicalMonitor);
    }
    debugPrint('[Provider] physicalMonitors: 完成, 返回 ${handles.length} 个物理监视器句柄');
    return handles;
  });
}

/// 逻辑监视器名称提供者
///
/// 获取逻辑监视器的友好名称（显示设备描述字符串）。
/// 通过 GetMonitorInfoW 获取设备名称，再通过 EnumDisplayDevicesW 获取设备描述。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [hMonitor]: 逻辑监视器句柄
///
/// 返回值: 监视器的友好名称字符串
///
/// 异常: 如果获取失败则抛出 StateError
@Riverpod(keepAlive: true)
String logicalMonitorName(Ref ref, int hMonitor) {
  debugPrint('[Provider] logicalMonitorName: 开始获取监视器名称, hMonitor=0x${hMonitor.toRadixString(16)}');
  return using((arena) {
    final ffi.Pointer<MonitorInfoEx> monitorInfo = arena<MonitorInfoEx>();
    monitorInfo.ref.cbSize = ffi.sizeOf<MonitorInfoEx>();

    final int result = GetMonitorInfoW(hMonitor, monitorInfo);
    if (result == 0) {
      debugPrint('[Provider] logicalMonitorName: 获取监视器信息失败, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to get monitor info, Win32 error ${GetLastError()}.');
    }

    final String deviceName = wcharArrayToStringN(monitorInfo.ref.szDevice, 32);
    debugPrint('[Provider] logicalMonitorName: 设备名称 = $deviceName');
    if (deviceName.isEmpty) {
      throw StateError('Monitor device name is empty.');
    }

    final ffi.Pointer<DisplayDevice> displayDevice = arena<DisplayDevice>();
    displayDevice.ref.cb = ffi.sizeOf<DisplayDevice>();

    final ffi.Pointer<Utf16> deviceNamePtr = deviceName.toNativeUtf16(allocator: arena);
    final int enumResult = EnumDisplayDevicesW(deviceNamePtr, 0, displayDevice, 0);
    if (enumResult == 0) {
      debugPrint('[Provider] logicalMonitorName: 枚举显示设备失败, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to enumerate display devices, Win32 error ${GetLastError()}.');
    }
    final String displayName = wcharArrayToString(displayDevice.ref.deviceString);
    debugPrint('[Provider] logicalMonitorName: 显示名称 = $displayName');
    return displayName;
  });
}

/// 异步读取监视器 Capabilities 字符串
///
/// 在独立的 Isolate 中执行，避免阻塞主线程。
/// 首先获取 Capabilities 字符串长度，然后分配缓冲区并读取完整字符串。
/// 读取后在内部解析为结构化的 CapabilitiesInfo 对象。
///
/// 参数:
/// - [handle]: 物理监视器句柄
///
/// 返回值: 解析后的 CapabilitiesInfo 对象
///
/// 异常: 如果读取失败则抛出 StateError
@Riverpod(keepAlive: true)
Future<CapabilitiesInfo> monitorCapabilities(Ref ref, int handle) async {
  debugPrint('[Provider] monitorCapabilities: 开始读取 Capabilities, handle=0x${handle.toRadixString(16)}');
  return await Isolate.run(() {
    return using((arena) {
      final ffi.Pointer<ffi.Uint32> lengthPointer = arena<ffi.Uint32>();
      final int lengthResult = GetCapabilitiesStringLength(handle, lengthPointer);
      if (lengthResult == 0 || lengthPointer.value == 0) {
        debugPrint('[Provider] monitorCapabilities: 读取 Capabilities 长度失败, Win32 错误 ${GetLastError()}');
        throw StateError('Failed to read capabilities length, Win32 error ${GetLastError()}.');
      }
      final int length = lengthPointer.value;
      debugPrint('[Provider] monitorCapabilities: Capabilities 字符串长度 = $length');
      final ffi.Pointer<ffi.Int8> buffer = arena<ffi.Int8>(length);
      final int capabilityResult = CapabilitiesRequestAndCapabilitiesReply(handle, buffer, length);
      if (capabilityResult == 0) {
        debugPrint('[Provider] monitorCapabilities: 读取 Capabilities 失败, Win32 错误 ${GetLastError()}');
        throw StateError('Failed to read capabilities, Win32 error ${GetLastError()}.');
      }
      final rawString = buffer.cast<Utf8>().toDartString();
      debugPrint('[Provider] monitorCapabilities: 读取成功, 原始字符串长度 = ${rawString.length}');
      final result = CapabilitiesInfo.parse(rawString);
      debugPrint('[Provider] monitorCapabilities: 解析完成');
      return result;
    });
  });
}

/// VCP 功能值读取提供者
///
/// 异步读取监视器指定 VCP 功能代码的当前值、最大值和类型。
/// 在独立的 Isolate 中执行，避免阻塞主线程。
/// VCP (Virtual Control Panel) 用于控制监视器的各种参数，如亮度、对比度、输入源等。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [handle]: 物理监视器句柄
/// - [code]: VCP 功能代码（如 0x10 表示亮度）
///
/// 返回值: VcpReadResult 对象，包含当前值、最大值和代码类型
///
/// 异常: 如果读取失败则抛出 StateError
@Riverpod(keepAlive: true)
Future<VcpReadResult> featureValue(Ref ref, int handle, int code) async {
  debugPrint('[Provider] featureValue: 开始读取 VCP, handle=0x${handle.toRadixString(16)}, code=0x${code.toRadixString(16)}');
  return await Isolate.run(() {
    return using((arena) {
      final ffi.Pointer<ffi.Uint32> codeType = arena<ffi.Uint32>();
      final ffi.Pointer<ffi.Uint32> currentValue = arena<ffi.Uint32>();
      final ffi.Pointer<ffi.Uint32> maximumValue = arena<ffi.Uint32>();
      final int result = GetVCPFeatureAndVCPFeatureReply(handle, code, codeType, currentValue, maximumValue);
      if (result == 0) {
        debugPrint('[Provider] featureValue: 读取 VCP 失败, code=0x${code.toRadixString(16)}, Win32 错误 ${GetLastError()}');
        throw StateError('Failed to read VCP 0x${hex(code)}, Win32 error ${GetLastError()}.');
      }
      debugPrint('[Provider] featureValue: 读取成功, code=0x${code.toRadixString(16)}, current=0x${currentValue.value.toRadixString(16)}, max=0x${maximumValue.value.toRadixString(16)}, type=${codeType.value}');
      return VcpReadResult(
        currentValue: currentValue.value,
        maximumValue: maximumValue.value,
        codeType: codeType.value,
      );
    });
  });
}

/// 设置 VCP 功能值
///
/// 异步设置监视器指定 VCP 功能代码的新值。
/// 在独立的 Isolate 中执行，避免阻塞主线程。
/// 用于控制监视器参数，如调整亮度、对比度、切换输入源等。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [handle]: 物理监视器句柄
/// - [code]: VCP 功能代码
/// - [value]: 要设置的新值
///
/// 异常: 如果设置失败则抛出 StateError
@riverpod
Future<void> setFeatureValue(Ref ref, int handle, int code, int value) async {
  debugPrint('[Provider] setFeatureValue: 开始设置 VCP, handle=0x${handle.toRadixString(16)}, code=0x${code.toRadixString(16)}, value=0x${value.toRadixString(16)}');
  await Isolate.run(() {
    final int result = SetVCPFeature(handle, code, value);
    if (result == 0) {
      debugPrint('[Provider] setFeatureValue: 设置 VCP 失败, code=0x${code.toRadixString(16)}, Win32 错误 ${GetLastError()}');
      throw StateError('Failed to set VCP 0x${hex(code)}, Win32 error ${GetLastError()}.');
    }
    debugPrint('[Provider] setFeatureValue: 设置成功, code=0x${code.toRadixString(16)}, value=0x${value.toRadixString(16)}');
  });
}

/// 保存监视器设置
///
/// 将监视器的当前设置保存到非易失性存储器中。
/// 确保监视器断电后设置不会丢失。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [handle]: 物理监视器句柄
///
/// 异常: 如果保存失败则抛出 StateError
@riverpod
Future<void> saveMonitorSettings(Ref ref, int handle) async {
  debugPrint('[Provider] saveMonitorSettings: 开始保存监视器设置, handle=0x${handle.toRadixString(16)}');
  final int result = SaveCurrentSettings(handle);
  if (result == 0) {
    debugPrint('[Provider] saveMonitorSettings: 保存失败, Win32 错误 ${GetLastError()}');
    throw StateError('Failed to save monitor settings, Win32 error ${GetLastError()}.');
  }
  debugPrint('[Provider] saveMonitorSettings: 保存成功');
}

/// 将 Windows 宽字符数组转换为 Dart 字符串（固定长度）
///
/// 从 ffi.Array<ffi.Uint16> 读取固定长度（128 个字符）的宽字符数组，
/// 并转换为 Dart 字符串。遇到空字符（\0）时停止读取。
/// 用于处理 Windows API 返回的固定大小字符串缓冲区。
///
/// 参数:
/// - [values]: 宽字符数组（UTF-16 编码）
///
/// 返回值: 转换后的 Dart 字符串
String wcharArrayToString(ffi.Array<ffi.Uint16> values) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < 128; i++) {
    final int codeUnit = values[i];
    if (codeUnit == 0) {
      break;
    }
    buffer.writeCharCode(codeUnit);
  }
  return buffer.toString().trim();
}

/// 将 Windows 宽字符数组转换为 Dart 字符串（自定义长度）
///
/// 从 ffi.Array<ffi.Uint16> 读取指定长度的宽字符数组，
/// 并转换为 Dart 字符串。遇到空字符（\0）时停止读取。
/// 用于处理 Windows API 返回的可变大小字符串缓冲区。
///
/// 参数:
/// - [values]: 宽字符数组（UTF-16 编码）
/// - [maxLength]: 最大读取长度
///
/// 返回值: 转换后的 Dart 字符串
String wcharArrayToStringN(ffi.Array<ffi.Uint16> values, int maxLength) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < maxLength; i++) {
    final int codeUnit = values[i];
    if (codeUnit == 0) {
      break;
    }
    buffer.writeCharCode(codeUnit);
  }
  return buffer.toString().trim();
}

/// 将整数转换为两位十六进制字符串
///
/// 将整数值转换为大写的两位十六进制表示形式。
/// 如果值小于 16，则在前面补零。
/// 用于格式化 VCP 功能代码、设备 ID 等十六进制值。
///
/// 参数:
/// - [value]: 要转换的整数值（通常为 0-255）
///
/// 返回值: 两位大写十六进制字符串（如 "0A", "FF"）
String hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();

/// 读取显示器 EDID 数据提供者
///
/// 从 Windows 注册表读取显示器的 EDID（Extended Display Identification Data）信息。
/// EDID 包含显示器的制造商、型号、序列号、支持的分辨率等详细信息。
///
/// 参数:
/// - [ref]: Riverpod 引用对象
/// - [hMonitor]: 逻辑监视器句柄
///
/// 返回值: 解析后的 EdidInfo 对象，如果读取失败则返回 null
@Riverpod(keepAlive: true)
Future<EdidInfo?> monitorEdid(Ref ref, int hMonitor) async {
  debugPrint('[Provider] monitorEdid: 开始读取 EDID, hMonitor=0x${hMonitor.toRadixString(16)}');
  return await Isolate.run(() {
    final result = _readEdidFromRegistry(hMonitor);
    if (result != null) {
      debugPrint('[Provider] monitorEdid: EDID 读取成功');
    } else {
      debugPrint('[Provider] monitorEdid: EDID 读取失败或不存在');
    }
    return result;
  });
}

/// 从注册表读取 EDID 数据
///
/// 通过逻辑监视器句柄获取设备名称，然后从注册表中读取对应的 EDID 数据。
/// EDID 数据存储在 HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\DISPLAY 下。
EdidInfo? _readEdidFromRegistry(int hMonitor) {
  debugPrint('[Registry] _readEdidFromRegistry: 开始从注册表读取 EDID, hMonitor=0x${hMonitor.toRadixString(16)}');
  return using((arena) {
    // 获取监视器设备名称
    final ffi.Pointer<MonitorInfoEx> monitorInfo = arena<MonitorInfoEx>();
    monitorInfo.ref.cbSize = ffi.sizeOf<MonitorInfoEx>();

    final int result = GetMonitorInfoW(hMonitor, monitorInfo);
    if (result == 0) {
      debugPrint('[Registry] _readEdidFromRegistry: 获取监视器信息失败');
      return null;
    }

    final String deviceName = wcharArrayToStringN(monitorInfo.ref.szDevice, 32);
    debugPrint('[Registry] _readEdidFromRegistry: 设备名称 = $deviceName');

    // 枚举显示设备获取设备 ID
    final ffi.Pointer<DisplayDevice> displayDevice = arena<DisplayDevice>();
    displayDevice.ref.cb = ffi.sizeOf<DisplayDevice>();

    final ffi.Pointer<Utf16> deviceNamePtr = deviceName.toNativeUtf16(allocator: arena);
    final int enumResult = EnumDisplayDevicesW(deviceNamePtr, 0, displayDevice, 0);
    if (enumResult == 0) {
      debugPrint('[Registry] _readEdidFromRegistry: 枚举显示设备失败');
      return null;
    }

    final String deviceID = wcharArrayToString(displayDevice.ref.deviceID);
    debugPrint('[Registry] _readEdidFromRegistry: 设备 ID = $deviceID');

    // 从设备 ID 中提取注册表路径
    final edidData = _readEdidFromDeviceId(deviceID, arena);
    if (edidData == null) {
      debugPrint('[Registry] _readEdidFromRegistry: 从设备 ID 读取 EDID 失败');
      return null;
    }

    debugPrint('[Registry] _readEdidFromRegistry: EDID 数据读取成功, 长度 = ${edidData.length}');
    return EdidInfo.parse(edidData);
  });
}

/// 从设备 ID 读取 EDID 数据
Uint8List? _readEdidFromDeviceId(String deviceID, Arena arena) {
  debugPrint('[Registry] _readEdidFromDeviceId: 开始读取, deviceID = $deviceID');
  const int HKEY_LOCAL_MACHINE = 0x80000002;
  const int KEY_READ = 0x20019;
  const int ERROR_SUCCESS = 0;

  // 解析设备 ID，提取监视器类型和 ID
  final parts = deviceID.split('\\');
  if (parts.length < 2) {
    debugPrint('[Registry] _readEdidFromDeviceId: 设备 ID 格式无效');
    return null;
  }

  final monitorId = parts[1];
  debugPrint('[Registry] _readEdidFromDeviceId: 监视器 ID = $monitorId');

  // 构建注册表路径
  final registryPath = 'SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$monitorId';
  debugPrint('[Registry] _readEdidFromDeviceId: 注册表路径 = $registryPath');

  final ffi.Pointer<Utf16> pathPtr = registryPath.toNativeUtf16(allocator: arena);
  final ffi.Pointer<ffi.IntPtr> hKey = arena<ffi.IntPtr>();

  // 打开注册表项
  int status = RegOpenKeyExW(HKEY_LOCAL_MACHINE, pathPtr, 0, KEY_READ, hKey);
  if (status != ERROR_SUCCESS) {
    debugPrint('[Registry] _readEdidFromDeviceId: 打开注册表项失败, status = $status');
    return null;
  }

  try {
    // 枚举子项（通常是设备实例）
    final ffi.Pointer<ffi.Uint16> subKeyName = arena<ffi.Uint16>(256);
    final ffi.Pointer<ffi.Uint32> subKeyNameLength = arena<ffi.Uint32>();
    subKeyNameLength.value = 256;

    status = RegEnumKeyExW(
      hKey.value,
      0,
      subKeyName.cast<Utf16>(),
      subKeyNameLength,
      ffi.nullptr,
      ffi.nullptr,
      ffi.nullptr,
      ffi.nullptr,
    );

    if (status != ERROR_SUCCESS) {
      debugPrint('[Registry] _readEdidFromDeviceId: 枚举子项失败, status = $status');
      return null;
    }

    final subKeyNameStr = String.fromCharCodes(
      subKeyName.asTypedList(subKeyNameLength.value).takeWhile((c) => c != 0),
    );
    debugPrint('[Registry] _readEdidFromDeviceId: 子项名称 = $subKeyNameStr');

    // 打开子项
    final subKeyPath = '$registryPath\\$subKeyNameStr\\Device Parameters';
    debugPrint('[Registry] _readEdidFromDeviceId: 子项路径 = $subKeyPath');

    final ffi.Pointer<Utf16> subKeyPathPtr = subKeyPath.toNativeUtf16(allocator: arena);
    final ffi.Pointer<ffi.IntPtr> hSubKey = arena<ffi.IntPtr>();

    status = RegOpenKeyExW(HKEY_LOCAL_MACHINE, subKeyPathPtr, 0, KEY_READ, hSubKey);
    if (status != ERROR_SUCCESS) {
      debugPrint('[Registry] _readEdidFromDeviceId: 打开子项失败, status = $status');
      return null;
    }

    try {
      // 读取 EDID 值
      final ffi.Pointer<Utf16> valueName = 'EDID'.toNativeUtf16(allocator: arena);
      final ffi.Pointer<ffi.Uint32> dataSize = arena<ffi.Uint32>();
      dataSize.value = 0;

      // 先获取数据大小
      status = RegQueryValueExW(
        hSubKey.value,
        valueName,
        ffi.nullptr,
        ffi.nullptr,
        ffi.nullptr,
        dataSize,
      );

      if (status != ERROR_SUCCESS || dataSize.value == 0) {
        debugPrint('[Registry] _readEdidFromDeviceId: 查询 EDID 大小失败, status = $status, size = ${dataSize.value}');
        return null;
      }

      debugPrint('[Registry] _readEdidFromDeviceId: EDID 数据大小 = ${dataSize.value}');

      // 分配缓冲区并读取数据
      final ffi.Pointer<ffi.Uint8> buffer = arena<ffi.Uint8>(dataSize.value);
      status = RegQueryValueExW(
        hSubKey.value,
        valueName,
        ffi.nullptr,
        ffi.nullptr,
        buffer,
        dataSize,
      );

      if (status != ERROR_SUCCESS) {
        debugPrint('[Registry] _readEdidFromDeviceId: 读取 EDID 数据失败, status = $status');
        return null;
      }

      // 转换为 Uint8List
      final edidData = Uint8List(dataSize.value);
      for (int i = 0; i < dataSize.value; i++) {
        edidData[i] = buffer[i];
      }

      debugPrint('[Registry] _readEdidFromDeviceId: EDID 数据读取成功');
      return edidData;
    } finally {
      RegCloseKey(hSubKey.value);
    }
  } finally {
    RegCloseKey(hKey.value);
  }
}
