import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pureddc/ddc_bindings.dart';
import 'pureddc/models.dart';

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
@riverpod
List<int> logicalMonitors(Ref ref) {
  final List<int> localMonitors = [];
  final callable = ffi.NativeCallable<MonitorEnumProcNative>.isolateLocal((
    int hMonitor,
    int hdcMonitor,
    ffi.Pointer<Rect> lprcMonitor,
    int dwData,
  ) {
    localMonitors.add(hMonitor);
    return 1;
  }, exceptionalReturn: 0);
  try {
    final ffi.Pointer<ffi.NativeFunction<MonitorEnumProcNative>> ptr = callable.nativeFunction;
    final int result = EnumDisplayMonitors(0, ffi.nullptr, ptr, 0);
    if (result == 0) {
      throw StateError('枚举显示监视器失败，Win32 错误 ${GetLastError()}.');
    }
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
@riverpod
List<int> physicalMonitors(Ref ref, int hMonitor) {
  return using((arena) {
    final ffi.Pointer<ffi.Uint32> countPointer = arena<ffi.Uint32>();
    final int countResult = GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor, countPointer);
    if (countResult == 0) {
      throw StateError('获取物理监视器数量失败，Win32 错误 ${GetLastError()}.');
    }
    final int count = countPointer.value;
    if (count == 0) {
      throw StateError('监视器句柄 $hMonitor 没有关联的物理监视器.');
    }
    final ffi.Pointer<PhysicalMonitor> physicalArray = arena<PhysicalMonitor>(count);
    final int getResult = GetPhysicalMonitorsFromHMONITOR(hMonitor, count, physicalArray);
    if (getResult == 0) {
      throw StateError('获取物理监视器信息失败，Win32 错误 ${GetLastError()}.');
    }

    final List<int> handles = <int>[];
    for (int index = 0; index < count; index++) {
      final PhysicalMonitor raw = (physicalArray + index).ref;
      handles.add(raw.hPhysicalMonitor);
    }
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
@riverpod
String logicalMonitorName(Ref ref, int hMonitor) {
  return using((arena) {
    final ffi.Pointer<MonitorInfoEx> monitorInfo = arena<MonitorInfoEx>();
    monitorInfo.ref.cbSize = ffi.sizeOf<MonitorInfoEx>();

    final int result = GetMonitorInfoW(hMonitor, monitorInfo);
    if (result == 0) {
      throw StateError('获取监视器信息失败，Win32 错误 ${GetLastError()}.');
    }

    final String deviceName = wcharArrayToStringN(monitorInfo.ref.szDevice, 32);
    if (deviceName.isEmpty) {
      throw StateError('监视器设备名称为空.');
    }

    final ffi.Pointer<DisplayDevice> displayDevice = arena<DisplayDevice>();
    displayDevice.ref.cb = ffi.sizeOf<DisplayDevice>();

    final ffi.Pointer<Utf16> deviceNamePtr = deviceName.toNativeUtf16(allocator: arena);
    final int enumResult = EnumDisplayDevicesW(deviceNamePtr, 0, displayDevice, 0);
    if (enumResult == 0) {
      throw StateError('枚举显示设备失败，Win32 错误 ${GetLastError()}.');
    }

    return wcharArrayToString(displayDevice.ref.deviceString);
  });
}

/// 异步读取监视器 Capabilities 字符串
///
/// 在独立的 Isolate 中执行，避免阻塞主线程。
/// 首先获取 Capabilities 字符串长度，然后分配缓冲区并读取完整字符串。
///
/// 参数:
/// - [handle]: 物理监视器句柄
///
/// 返回值: ASCII 格式的 Capabilities 字符串
///
/// 异常: 如果读取失败则抛出 StateError
@riverpod
Future<String> monitorCapabilities(Ref ref, int handle) async {
  return await Isolate.run(() {
    return using((arena) {
      final ffi.Pointer<ffi.Uint32> lengthPointer = arena<ffi.Uint32>();
      final int lengthResult = GetCapabilitiesStringLength(handle, lengthPointer);
      if (lengthResult == 0 || lengthPointer.value == 0) {
        throw StateError('读取 capabilities 长度失败，Win32 错误 ${GetLastError()}.');
      }
      final int length = lengthPointer.value;
      final ffi.Pointer<ffi.Int8> buffer = arena<ffi.Int8>(length);
      final int capabilityResult = CapabilitiesRequestAndCapabilitiesReply(handle, buffer, length);
      if (capabilityResult == 0) {
        throw StateError('读取 capabilities 失败，Win32 错误 ${GetLastError()}.');
      }
      return buffer.cast<Utf8>().toDartString();
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
@riverpod
Future<VcpReadResult> featureValue(Ref ref, int handle, int code) async {
  return await Isolate.run(() {
    return using((arena) {
      final ffi.Pointer<ffi.Uint32> codeType = arena<ffi.Uint32>();
      final ffi.Pointer<ffi.Uint32> currentValue = arena<ffi.Uint32>();
      final ffi.Pointer<ffi.Uint32> maximumValue = arena<ffi.Uint32>();
      final int result = GetVCPFeatureAndVCPFeatureReply(handle, code, codeType, currentValue, maximumValue);
      if (result == 0) {
        throw StateError('读取 VCP 0x${hex(code)} 失败，Win32 错误 ${GetLastError()}.');
      }
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
  await Isolate.run(() {
    final int result = SetVCPFeature(handle, code, value);
    if (result == 0) {
      throw StateError('设置 VCP 0x${hex(code)} 失败，Win32 错误 ${GetLastError()}.');
    }
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
  final int result = SaveCurrentSettings(handle);
  if (result == 0) {
    throw StateError('保存显示器设置失败，Win32 错误 ${GetLastError()}.');
  }
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
