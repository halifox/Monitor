import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import 'models.dart';

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

final class McTimingReport extends ffi.Struct {
  @ffi.Uint32()
  external int horizontalFrequencyInHertz;

  @ffi.Uint32()
  external int verticalFrequencyInHertz;

  @ffi.Uint8()
  external int timingStatusByte;
}

typedef _EnumDisplayMonitorsNative = ffi.Int32 Function(ffi.IntPtr hdc, ffi.Pointer<Rect> lprcClip, ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> lpfnEnum, ffi.IntPtr dwData);
typedef _EnumDisplayMonitorsDart = int Function(int hdc, ffi.Pointer<Rect> lprcClip, ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> lpfnEnum, int dwData);

typedef _MonitorEnumProcNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.IntPtr hdcMonitor, ffi.Pointer<Rect> lprcMonitor, ffi.IntPtr dwData);

typedef _GetNumberOfPhysicalMonitorsNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Uint32> numberOfPhysicalMonitors);
typedef _GetNumberOfPhysicalMonitorsDart = int Function(int hMonitor, ffi.Pointer<ffi.Uint32> numberOfPhysicalMonitors);

typedef _GetPhysicalMonitorsFromHMonitorNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint32 physicalMonitorArraySize, ffi.Pointer<PhysicalMonitor> physicalMonitorArray);
typedef _GetPhysicalMonitorsFromHMonitorDart = int Function(int hMonitor, int physicalMonitorArraySize, ffi.Pointer<PhysicalMonitor> physicalMonitorArray);

typedef _DestroyPhysicalMonitorNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef _DestroyPhysicalMonitorDart = int Function(int hMonitor);

typedef _GetCapabilitiesStringLengthNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Uint32> length);
typedef _GetCapabilitiesStringLengthDart = int Function(int hMonitor, ffi.Pointer<ffi.Uint32> length);

typedef _CapabilitiesRequestAndCapabilitiesReplyNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<ffi.Int8> capabilitiesString, ffi.Uint32 length);
typedef _CapabilitiesRequestAndCapabilitiesReplyDart = int Function(int hMonitor, ffi.Pointer<ffi.Int8> capabilitiesString, int length);

typedef _GetVcpFeatureNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint8 vcpCode, ffi.Pointer<ffi.Uint32> codeType, ffi.Pointer<ffi.Uint32> currentValue, ffi.Pointer<ffi.Uint32> maximumValue);
typedef _GetVcpFeatureDart = int Function(int hMonitor, int vcpCode, ffi.Pointer<ffi.Uint32> codeType, ffi.Pointer<ffi.Uint32> currentValue, ffi.Pointer<ffi.Uint32> maximumValue);

typedef _SetVcpFeatureNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Uint8 vcpCode, ffi.Uint32 newValue);
typedef _SetVcpFeatureDart = int Function(int hMonitor, int vcpCode, int newValue);

typedef _SaveCurrentSettingsNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef _SaveCurrentSettingsDart = int Function(int hMonitor);

typedef _GetTimingReportNative = ffi.Int32 Function(ffi.IntPtr hMonitor, ffi.Pointer<McTimingReport> timingReport);
typedef _GetTimingReportDart = int Function(int hMonitor, ffi.Pointer<McTimingReport> timingReport);

typedef _GetLastErrorNative = ffi.Uint32 Function();
typedef _GetLastErrorDart = int Function();

class WindowsDdcCiService {
  WindowsDdcCiService();

  static final ffi.DynamicLibrary _user32 = ffi.DynamicLibrary.open('user32.dll');
  static final ffi.DynamicLibrary _dxva2 = ffi.DynamicLibrary.open('dxva2.dll');
  static final ffi.DynamicLibrary _kernel32 = ffi.DynamicLibrary.open('kernel32.dll');

  final _EnumDisplayMonitorsDart _enumDisplayMonitors = _user32.lookupFunction<_EnumDisplayMonitorsNative, _EnumDisplayMonitorsDart>('EnumDisplayMonitors');
  final _GetNumberOfPhysicalMonitorsDart _getNumberOfPhysicalMonitors = _dxva2.lookupFunction<_GetNumberOfPhysicalMonitorsNative, _GetNumberOfPhysicalMonitorsDart>('GetNumberOfPhysicalMonitorsFromHMONITOR');
  final _GetPhysicalMonitorsFromHMonitorDart _getPhysicalMonitorsFromHMonitor = _dxva2.lookupFunction<_GetPhysicalMonitorsFromHMonitorNative, _GetPhysicalMonitorsFromHMonitorDart>('GetPhysicalMonitorsFromHMONITOR');
  final _DestroyPhysicalMonitorDart _destroyPhysicalMonitor = _dxva2.lookupFunction<_DestroyPhysicalMonitorNative, _DestroyPhysicalMonitorDart>('DestroyPhysicalMonitor');
  final _GetCapabilitiesStringLengthDart _getCapabilitiesStringLength = _dxva2.lookupFunction<_GetCapabilitiesStringLengthNative, _GetCapabilitiesStringLengthDart>('GetCapabilitiesStringLength');
  final _CapabilitiesRequestAndCapabilitiesReplyDart _capabilitiesRequestAndCapabilitiesReply = _dxva2.lookupFunction<_CapabilitiesRequestAndCapabilitiesReplyNative, _CapabilitiesRequestAndCapabilitiesReplyDart>('CapabilitiesRequestAndCapabilitiesReply');
  final _GetVcpFeatureDart _getVcpFeature = _dxva2.lookupFunction<_GetVcpFeatureNative, _GetVcpFeatureDart>('GetVCPFeatureAndVCPFeatureReply');
  final _SetVcpFeatureDart _setVcpFeature = _dxva2.lookupFunction<_SetVcpFeatureNative, _SetVcpFeatureDart>('SetVCPFeature');
  final _SaveCurrentSettingsDart _saveCurrentSettings = _dxva2.lookupFunction<_SaveCurrentSettingsNative, _SaveCurrentSettingsDart>('SaveCurrentSettings');
  final _GetTimingReportDart _getTimingReport = _dxva2.lookupFunction<_GetTimingReportNative, _GetTimingReportDart>('GetTimingReport');
  final _GetLastErrorDart _getLastError = _kernel32.lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');

  static final ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> _monitorEnumCallback = ffi.Pointer.fromFunction<_MonitorEnumProcNative>(_monitorEnumProc, 0);

  static List<int>? _enumCollector;

  /*
   * 作为 `EnumDisplayMonitors` 的原生回调，收集当前枚举到的逻辑显示器句柄。
   *
   * Windows 在每发现一个显示器时都会调用这里一次。本实现只提取 `hMonitor`，
   * 并写入当前枚举过程共享的 `_enumCollector`。返回 `1` 表示继续枚举。
   */
  static int _monitorEnumProc(int hMonitor, int hdcMonitor, ffi.Pointer<Rect> lprcMonitor, int dwData) {
    _enumCollector?.add(hMonitor);
    return 1;
  }

  final List<RawPhysicalMonitor> monitors = [];

  /*
   * 枚举当前系统中可访问的物理显示器，并返回每台显示器的快照信息。
   *
   * 处理流程包括：
   * 1. 在非 Windows 平台上直接返回说明性占位结果。
   * 2. 关闭上一次加载时保留的物理显示器句柄，避免资源泄漏。
   * 3. 先枚举逻辑显示器，再展开为 DDC/CI 可访问的物理显示器。
   * 4. 为每个物理显示器建立内部句柄映射，并同步读取能力和特性状态。
   *
   * 如果没有找到可用的 DDC/CI 物理显示器，会返回带错误说明的占位快照，
   * 而不是抛异常，便于上层 UI 直接展示失败原因。
   */

  Future<List<RawPhysicalMonitor>> loadMonitors() async {
    _closeHandles();
    final List<int> hMonitors = _enumerateDisplayMonitors();
    for (final int hMonitor in hMonitors) {
      final List<RawPhysicalMonitor> physicalMonitors = _enumeratePhysicalMonitors(hMonitor);
      for (int physicalIndex = 0; physicalIndex < physicalMonitors.length; physicalIndex++) {
        final RawPhysicalMonitor physicalMonitor = physicalMonitors[physicalIndex];
        monitors.add(physicalMonitor);
      }
    }
    return monitors;
  }

  /*
   * 写入指定显示器的 VCP 特性值。
   *
   * [monitorId] 用于定位已打开的物理显示器句柄，[code] 是 VCP code，
   * [value] 是要写入的新值。底层调用 `SetVCPFeature`，失败时会把
   * 最新 Win32 错误码带进异常消息，方便定位权限、硬件或协议问题。
   */
  Future<void> setFeatureValue(int handle, int code, int value) async {
    final int result = _setVcpFeature(handle, code, value);
    if (result == 0) {
      throw StateError('设置 VCP 0x${_hex(code)} 失败，Win32 错误 ${_getLastError()}.');
    }
  }

  /*
   * 读取指定显示器某个 VCP 特性的当前值和最大值。
   *
   * 返回值中的 `success` 表示底层读取是否成功；即使显示器不支持对应 VCP，
   * 也不会直接抛异常，而是通过 `VcpReadResult` 返回失败状态和错误码。
   */
  Future<VcpReadResult> readFeatureValue(int handle, int code) async {
    return _readVcpValue(handle, code);
  }

  /*
   * 请求显示器持久化当前设置。
   *
   * 底层调用 `SaveCurrentSettings`。这通常用于在修改亮度、对比度或输入源后，
   * 尝试让显示器将当前状态保存到设备本身的配置中。
   */
  Future<void> saveSettings(int handle) async {
    final int result = _saveCurrentSettings(handle);
    if (result == 0) {
      throw StateError('保存显示器设置失败，Win32 错误 ${_getLastError()}.');
    }
  }

  Future<String> readCapabilities(int handle) async {
    final String? result = _readCapabilities(handle);
    if (result == null) {
      throw StateError('保存显示器设置失败，Win32 错误 ${_getLastError()}.');
    }
    return result;
  }

  /*
   * 释放当前服务持有的全部物理显示器句柄。
   *
   * 调用后，之前缓存的 `monitorId` 将不再可用；如果需要再次操作显示器，
   * 应重新执行 [loadMonitors] 获取新句柄。
   */
  void dispose() {
    _closeHandles();
  }

  /*
   * 枚举系统中的逻辑显示器句柄。
   *
   * 这里调用 `EnumDisplayMonitors` 获取 HMONITOR 列表。为了兼容 C 回调签名，
   * 使用静态列表 `_enumCollector` 作为临时收集容器，并在 `finally` 中确保清理。
   * 如果 Win32 调用失败，会直接抛出包含错误码的异常。
   */
  List<int> _enumerateDisplayMonitors() {
    final List<int> result = <int>[];
    _enumCollector = result;
    try {
      final int success = _enumDisplayMonitors(0, ffi.nullptr, _monitorEnumCallback, 0);
      if (success == 0) {
        throw StateError('EnumDisplayMonitors 失败，Win32 错误 ${_getLastError()}.');
      }
      return List<int>.from(result);
    } finally {
      _enumCollector = null;
    }
  }

  /*
   * 将单个逻辑显示器句柄展开为对应的物理显示器句柄集合。
   *
   * 一个 HMONITOR 可能映射到一个或多个物理显示器。方法先读取数量，
   * 再分配 `PHYSICAL_MONITOR` 数组并调用 `GetPhysicalMonitorsFromHMONITOR`。
   * 失败时返回空列表，而不是抛异常，让上层继续处理其他显示器。
   */
  List<RawPhysicalMonitor> _enumeratePhysicalMonitors(int hMonitor) {
    final ffi.Pointer<ffi.Uint32> countPointer = calloc<ffi.Uint32>();
    try {
      final int countResult = _getNumberOfPhysicalMonitors(hMonitor, countPointer);
      if (countResult == 0) {
        return const <RawPhysicalMonitor>[];
      }
      final int count = countPointer.value;
      if (count == 0) {
        return const <RawPhysicalMonitor>[];
      }
      final ffi.Pointer<PhysicalMonitor> physicalArray = calloc<PhysicalMonitor>(count);
      try {
        final int getResult = _getPhysicalMonitorsFromHMonitor(hMonitor, count, physicalArray);
        if (getResult == 0) {
          return const <RawPhysicalMonitor>[];
        }
        final List<RawPhysicalMonitor> monitors = <RawPhysicalMonitor>[];
        for (int index = 0; index < count; index++) {
          final PhysicalMonitor raw = (physicalArray + index).ref;
          monitors.add(RawPhysicalMonitor(handle: raw.hPhysicalMonitor, description: _wcharArrayToString(raw.description)));
        }
        return monitors;
      } finally {
        calloc.free(physicalArray);
      }
    } finally {
      calloc.free(countPointer);
    }
  }

  /*
   * 读取显示器的 MCCS capabilities 字符串。
   *
   * 首先通过 `GetCapabilitiesStringLength` 获取缓冲区长度，再调用
   * `CapabilitiesRequestAndCapabilitiesReply` 读取完整字符串。
   * 返回 `null` 表示显示器未提供该能力，或底层调用失败。
   */
  String? _readCapabilities(int handle) {
    final ffi.Pointer<ffi.Uint32> lengthPointer = calloc<ffi.Uint32>();
    try {
      final int lengthResult = _getCapabilitiesStringLength(handle, lengthPointer);
      if (lengthResult == 0 || lengthPointer.value == 0) {
        return null;
      }
      final int length = lengthPointer.value;
      final ffi.Pointer<ffi.Int8> buffer = calloc<ffi.Int8>(length);
      try {
        final int capabilityResult = _capabilitiesRequestAndCapabilitiesReply(handle, buffer, length);
        if (capabilityResult == 0) {
          return null;
        }
        return buffer.cast<Utf8>().toDartString();
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(lengthPointer);
    }
  }

  /*
   * 读取某个 VCP code 的当前状态。
   *
   * 成功时返回当前值、最大值和 code type；失败时返回 `success=false`，
   * 并附带最新 Win32 错误码。该方法负责所有 FFI 指针的分配与释放，
   * 调用方只需要关心 `VcpReadResult`。
   */
  VcpReadResult _readVcpValue(int handle, int code) {
    final ffi.Pointer<ffi.Uint32> codeType = calloc<ffi.Uint32>();
    final ffi.Pointer<ffi.Uint32> currentValue = calloc<ffi.Uint32>();
    final ffi.Pointer<ffi.Uint32> maximumValue = calloc<ffi.Uint32>();
    try {
      final int result = _getVcpFeature(handle, code, codeType, currentValue, maximumValue);
      if (result == 0) {
        return VcpReadResult(success: false, windowsError: _getLastError());
      }
      return VcpReadResult(success: true, currentValue: currentValue.value, maximumValue: maximumValue.value, codeType: codeType.value);
    } finally {
      calloc.free(codeType);
      calloc.free(currentValue);
      calloc.free(maximumValue);
    }
  }

  /*
   * 读取显示器当前时序报告。
   *
   * 若显示器支持 `GetTimingReport`，会返回当前水平和垂直刷新频率；
   * 若调用失败，则返回 `null`，表示此能力不可用或暂时无法读取。
   */
  _TimingReportData? _readTimingReport(int handle) {
    final ffi.Pointer<McTimingReport> report = calloc<McTimingReport>();
    try {
      final int result = _getTimingReport(handle, report);
      if (result == 0) {
        return null;
      }
      return _TimingReportData(horizontalFrequencyInHertz: report.ref.horizontalFrequencyInHertz, verticalFrequencyInHertz: report.ref.verticalFrequencyInHertz);
    } finally {
      calloc.free(report);
    }
  }

  /*
   * 将固定长度的 UTF-16 宽字符数组转换为 Dart 字符串。
   *
   * Windows 的 `PHYSICAL_MONITOR.szPhysicalMonitorDescription` 使用以 `0`
   * 结尾的定长缓冲区。这里逐个读取字符，遇到终止符停止，并去掉两端空白。
   */
  String _wcharArrayToString(ffi.Array<ffi.Uint16> values) {
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

  /*
   * 关闭并清空当前缓存的全部物理显示器句柄。
   *
   * 每个句柄都通过 `DestroyPhysicalMonitor` 释放，随后清空 `_openMonitors`。
   * 该方法可重复调用，用于重新加载设备前的资源回收和服务销毁。
   */
  void _closeHandles() {
    for (final handle in monitors) {
      _destroyPhysicalMonitor(handle.handle);
    }
  }

  /*
   * 把数值格式化为两位十六进制字符串。
   *
   * 主要用于输出 VCP code，例如 `0x10`、`0x60`，方便错误信息和日志阅读。
   */
  static String _hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();
}

class RawPhysicalMonitor {
  /*
   * 保存从 Win32 枚举阶段读出的原始物理显示器信息。
   *
   * [handle] 是尚未包装的物理显示器句柄，[description] 是设备返回的
   * 原始描述文本，后续会被转成内部 `_MonitorHandle` 使用。
   */
  const RawPhysicalMonitor({required this.handle, required this.description});

  final int handle;
  final String description;
}

class _TimingReportData {
  /*
   * 封装显示器当前时序读取结果。
   *
   * 这里只保留上层会用到的水平和垂直频率，避免直接把原始 FFI 结构体暴露到
   * 业务逻辑中。
   */
  const _TimingReportData({required this.horizontalFrequencyInHertz, required this.verticalFrequencyInHertz});

  final int horizontalFrequencyInHertz;
  final int verticalFrequencyInHertz;
}
