import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'capabilities_parser.dart';
import 'models.dart';
import 'vcp_catalog.dart';

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

typedef _EnumDisplayMonitorsNative = ffi.Int32 Function(
  ffi.IntPtr hdc,
  ffi.Pointer<Rect> lprcClip,
  ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> lpfnEnum,
  ffi.IntPtr dwData,
);
typedef _EnumDisplayMonitorsDart = int Function(
  int hdc,
  ffi.Pointer<Rect> lprcClip,
  ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> lpfnEnum,
  int dwData,
);

typedef _MonitorEnumProcNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.IntPtr hdcMonitor,
  ffi.Pointer<Rect> lprcMonitor,
  ffi.IntPtr dwData,
);

typedef _GetNumberOfPhysicalMonitorsNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Pointer<ffi.Uint32> numberOfPhysicalMonitors,
);
typedef _GetNumberOfPhysicalMonitorsDart = int Function(
  int hMonitor,
  ffi.Pointer<ffi.Uint32> numberOfPhysicalMonitors,
);

typedef _GetPhysicalMonitorsFromHMonitorNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Uint32 physicalMonitorArraySize,
  ffi.Pointer<PhysicalMonitor> physicalMonitorArray,
);
typedef _GetPhysicalMonitorsFromHMonitorDart = int Function(
  int hMonitor,
  int physicalMonitorArraySize,
  ffi.Pointer<PhysicalMonitor> physicalMonitorArray,
);

typedef _DestroyPhysicalMonitorNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef _DestroyPhysicalMonitorDart = int Function(int hMonitor);

typedef _GetCapabilitiesStringLengthNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Pointer<ffi.Uint32> length,
);
typedef _GetCapabilitiesStringLengthDart = int Function(
  int hMonitor,
  ffi.Pointer<ffi.Uint32> length,
);

typedef _CapabilitiesRequestAndCapabilitiesReplyNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Pointer<ffi.Int8> capabilitiesString,
  ffi.Uint32 length,
);
typedef _CapabilitiesRequestAndCapabilitiesReplyDart = int Function(
  int hMonitor,
  ffi.Pointer<ffi.Int8> capabilitiesString,
  int length,
);

typedef _GetVcpFeatureNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Uint8 vcpCode,
  ffi.Pointer<ffi.Uint32> codeType,
  ffi.Pointer<ffi.Uint32> currentValue,
  ffi.Pointer<ffi.Uint32> maximumValue,
);
typedef _GetVcpFeatureDart = int Function(
  int hMonitor,
  int vcpCode,
  ffi.Pointer<ffi.Uint32> codeType,
  ffi.Pointer<ffi.Uint32> currentValue,
  ffi.Pointer<ffi.Uint32> maximumValue,
);

typedef _SetVcpFeatureNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Uint8 vcpCode,
  ffi.Uint32 newValue,
);
typedef _SetVcpFeatureDart = int Function(int hMonitor, int vcpCode, int newValue);

typedef _SaveCurrentSettingsNative = ffi.Int32 Function(ffi.IntPtr hMonitor);
typedef _SaveCurrentSettingsDart = int Function(int hMonitor);

typedef _GetTimingReportNative = ffi.Int32 Function(
  ffi.IntPtr hMonitor,
  ffi.Pointer<McTimingReport> timingReport,
);
typedef _GetTimingReportDart = int Function(
  int hMonitor,
  ffi.Pointer<McTimingReport> timingReport,
);

typedef _GetLastErrorNative = ffi.Uint32 Function();
typedef _GetLastErrorDart = int Function();

class WindowsDdcCiService {
  WindowsDdcCiService()
      : _user32 = ffi.DynamicLibrary.open('user32.dll'),
        _dxva2 = ffi.DynamicLibrary.open('dxva2.dll'),
        _kernel32 = ffi.DynamicLibrary.open('kernel32.dll'),
        _parser = const CapabilitiesParser() {
    _enumDisplayMonitors =
        _user32.lookupFunction<_EnumDisplayMonitorsNative, _EnumDisplayMonitorsDart>(
      'EnumDisplayMonitors',
    );
    _getNumberOfPhysicalMonitors =
        _dxva2.lookupFunction<
          _GetNumberOfPhysicalMonitorsNative,
          _GetNumberOfPhysicalMonitorsDart
        >('GetNumberOfPhysicalMonitorsFromHMONITOR');
    _getPhysicalMonitorsFromHMonitor =
        _dxva2.lookupFunction<
          _GetPhysicalMonitorsFromHMonitorNative,
          _GetPhysicalMonitorsFromHMonitorDart
        >('GetPhysicalMonitorsFromHMONITOR');
    _destroyPhysicalMonitor =
        _dxva2.lookupFunction<_DestroyPhysicalMonitorNative, _DestroyPhysicalMonitorDart>(
      'DestroyPhysicalMonitor',
    );
    _getCapabilitiesStringLength =
        _dxva2.lookupFunction<
          _GetCapabilitiesStringLengthNative,
          _GetCapabilitiesStringLengthDart
        >('GetCapabilitiesStringLength');
    _capabilitiesRequestAndCapabilitiesReply =
        _dxva2.lookupFunction<
          _CapabilitiesRequestAndCapabilitiesReplyNative,
          _CapabilitiesRequestAndCapabilitiesReplyDart
        >('CapabilitiesRequestAndCapabilitiesReply');
    _getVcpFeature = _dxva2.lookupFunction<_GetVcpFeatureNative, _GetVcpFeatureDart>(
      'GetVCPFeatureAndVCPFeatureReply',
    );
    _setVcpFeature =
        _dxva2.lookupFunction<_SetVcpFeatureNative, _SetVcpFeatureDart>('SetVCPFeature');
    _saveCurrentSettings =
        _dxva2.lookupFunction<_SaveCurrentSettingsNative, _SaveCurrentSettingsDart>(
      'SaveCurrentSettings',
    );
    _getTimingReport =
        _dxva2.lookupFunction<_GetTimingReportNative, _GetTimingReportDart>('GetTimingReport');
    _getLastError =
        _kernel32.lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');
  }

  final ffi.DynamicLibrary _user32;
  final ffi.DynamicLibrary _dxva2;
  final ffi.DynamicLibrary _kernel32;
  final CapabilitiesParser _parser;

  late final _EnumDisplayMonitorsDart _enumDisplayMonitors;
  late final _GetNumberOfPhysicalMonitorsDart _getNumberOfPhysicalMonitors;
  late final _GetPhysicalMonitorsFromHMonitorDart _getPhysicalMonitorsFromHMonitor;
  late final _DestroyPhysicalMonitorDart _destroyPhysicalMonitor;
  late final _GetCapabilitiesStringLengthDart _getCapabilitiesStringLength;
  late final _CapabilitiesRequestAndCapabilitiesReplyDart _capabilitiesRequestAndCapabilitiesReply;
  late final _GetVcpFeatureDart _getVcpFeature;
  late final _SetVcpFeatureDart _setVcpFeature;
  late final _SaveCurrentSettingsDart _saveCurrentSettings;
  late final _GetTimingReportDart _getTimingReport;
  late final _GetLastErrorDart _getLastError;

  final Map<String, _MonitorHandle> _openMonitors = <String, _MonitorHandle>{};

  static final ffi.Pointer<ffi.NativeFunction<_MonitorEnumProcNative>> _monitorEnumCallback =
      ffi.Pointer.fromFunction<_MonitorEnumProcNative>(_monitorEnumProc, 0);

  static List<int>? _enumCollector;

  static int _monitorEnumProc(
    int hMonitor,
    int hdcMonitor,
    ffi.Pointer<Rect> lprcMonitor,
    int dwData,
  ) {
    _enumCollector?.add(hMonitor);
    return 1;
  }

  Future<List<MonitorSnapshot>> loadMonitors() async {
    if (!Platform.isWindows) {
      return const <MonitorSnapshot>[
        MonitorSnapshot(
          id: 'non-windows',
          description: '当前平台不支持',
          capabilities: null,
          capabilitiesData: null,
          features: <MonitorFeatureState>[],
          unknownFeatures: <MonitorFeatureState>[],
          errorMessage: '这个版本当前只实现 Windows + dxva2.dll。',
        ),
      ];
    }

    _closeHandles();
    final List<int> hMonitors = _enumerateDisplayMonitors();
    final List<MonitorSnapshot> snapshots = <MonitorSnapshot>[];
    int monitorIndex = 0;

    for (final int hMonitor in hMonitors) {
      final List<_RawPhysicalMonitor> physicalMonitors = _enumeratePhysicalMonitors(hMonitor);
      for (int physicalIndex = 0; physicalIndex < physicalMonitors.length; physicalIndex++) {
        final _RawPhysicalMonitor physicalMonitor = physicalMonitors[physicalIndex];
        final String id = 'monitor-$monitorIndex-$physicalIndex';
        final _MonitorHandle handle = _MonitorHandle(
          id: id,
          handle: physicalMonitor.handle,
          description: physicalMonitor.description,
        );
        _openMonitors[id] = handle;
        snapshots.add(_snapshotForHandle(handle));
      }
      monitorIndex++;
    }

    if (snapshots.isEmpty) {
      return const <MonitorSnapshot>[
        MonitorSnapshot(
          id: 'no-monitor',
          description: '没有找到可用显示器',
          capabilities: null,
          capabilitiesData: null,
          features: <MonitorFeatureState>[],
          unknownFeatures: <MonitorFeatureState>[],
          errorMessage: '没有枚举到支持 DDC/CI 的物理显示器。请确认显示器启用了 DDC/CI，并且不在远程桌面环境下。',
        ),
      ];
    }

    return snapshots;
  }

  Future<MonitorSnapshot> refreshMonitor(String monitorId) async {
    final _MonitorHandle? handle = _openMonitors[monitorId];
    if (handle == null) {
      throw StateError('显示器句柄不存在，请先刷新设备列表。');
    }
    return _snapshotForHandle(handle);
  }

  Future<void> setFeatureValue(String monitorId, int code, int value) async {
    final _MonitorHandle handle = _requireHandle(monitorId);
    final int result = _setVcpFeature(handle.handle, code, value);
    if (result == 0) {
      throw StateError('设置 VCP 0x${_hex(code)} 失败，Win32 错误 ${_getLastError()}.');
    }
  }

  Future<VcpReadResult> readFeatureValue(String monitorId, int code) async {
    final _MonitorHandle handle = _requireHandle(monitorId);
    return _readVcpValue(handle.handle, code);
  }

  Future<void> saveSettings(String monitorId) async {
    final _MonitorHandle handle = _requireHandle(monitorId);
    final int result = _saveCurrentSettings(handle.handle);
    if (result == 0) {
      throw StateError('保存显示器设置失败，Win32 错误 ${_getLastError()}.');
    }
  }

  void dispose() {
    _closeHandles();
  }

  _MonitorHandle _requireHandle(String monitorId) {
    final _MonitorHandle? handle = _openMonitors[monitorId];
    if (handle == null) {
      throw StateError('显示器句柄不存在，请先刷新设备列表。');
    }
    return handle;
  }

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

  List<_RawPhysicalMonitor> _enumeratePhysicalMonitors(int hMonitor) {
    final ffi.Pointer<ffi.Uint32> countPointer = calloc<ffi.Uint32>();
    try {
      final int countResult = _getNumberOfPhysicalMonitors(hMonitor, countPointer);
      if (countResult == 0) {
        return const <_RawPhysicalMonitor>[];
      }
      final int count = countPointer.value;
      if (count == 0) {
        return const <_RawPhysicalMonitor>[];
      }
      final ffi.Pointer<PhysicalMonitor> physicalArray = calloc<PhysicalMonitor>(count);
      try {
        final int getResult = _getPhysicalMonitorsFromHMonitor(hMonitor, count, physicalArray);
        if (getResult == 0) {
          return const <_RawPhysicalMonitor>[];
        }
        final List<_RawPhysicalMonitor> monitors = <_RawPhysicalMonitor>[];
        for (int index = 0; index < count; index++) {
          final PhysicalMonitor raw = (physicalArray + index).ref;
          monitors.add(_RawPhysicalMonitor(
            handle: raw.hPhysicalMonitor,
            description: _wcharArrayToString(raw.description),
          ));
        }
        return monitors;
      } finally {
        calloc.free(physicalArray);
      }
    } finally {
      calloc.free(countPointer);
    }
  }

  MonitorSnapshot _snapshotForHandle(_MonitorHandle handle) {
    final String? capabilities = _readCapabilities(handle.handle);
    ParsedCapabilities? parsed;
    if (capabilities != null && capabilities.isNotEmpty) {
      parsed = _parser.parse(capabilities);
    }

    final _TimingReportData? timing = _readTimingReport(handle.handle);
    final Set<int> supportedCodes = parsed?.supportedVcpCodes ?? <int>{};
    final Map<int, Set<int>> supportedValues = parsed?.supportedVcpValues ?? <int, Set<int>>{};
    final Set<int> probeCodes = supportedCodes.isNotEmpty
        ? Set<int>.from(supportedCodes)
        : kKnownVcpFeatureMap.keys.toSet();

    final Map<int, VcpReadResult> readResults = <int, VcpReadResult>{};
    final List<int> sortedProbeCodes = probeCodes.toList()..sort();
    for (final int code in sortedProbeCodes) {
      readResults[code] = _readVcpValue(handle.handle, code);
    }

    final List<MonitorFeatureState> features = <MonitorFeatureState>[];
    for (final VcpFeatureDefinition definition in kKnownVcpFeatures) {
      final VcpReadResult? readResult = readResults[definition.code];
      final bool supported = supportedCodes.isEmpty
          ? (readResult?.success ?? false)
          : supportedCodes.contains(definition.code) || (readResult?.success ?? false);
      features.add(
        MonitorFeatureState(
          code: definition.code,
          definition: definition,
          supported: supported,
          supportedValues: supportedValues[definition.code] ?? <int>{},
          readResult: readResult,
        ),
      );
    }

    final List<MonitorFeatureState> unknownFeatures = <MonitorFeatureState>[];
    final List<int> extraCodes = supportedCodes
        .where((int code) => !kKnownVcpFeatureMap.containsKey(code))
        .toList()
      ..sort();
    for (final int code in extraCodes) {
      unknownFeatures.add(
        MonitorFeatureState(
          code: code,
          definition: null,
          supported: true,
          supportedValues: supportedValues[code] ?? <int>{},
          readResult: readResults[code],
        ),
      );
    }

    return MonitorSnapshot(
      id: handle.id,
      description: handle.description,
      capabilities: capabilities,
      capabilitiesData: parsed,
      features: features,
      unknownFeatures: unknownFeatures,
      horizontalFrequency: timing?.horizontalFrequencyInHertz,
      verticalFrequency: timing?.verticalFrequencyInHertz,
    );
  }

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

  VcpReadResult _readVcpValue(int handle, int code) {
    final ffi.Pointer<ffi.Uint32> codeType = calloc<ffi.Uint32>();
    final ffi.Pointer<ffi.Uint32> currentValue = calloc<ffi.Uint32>();
    final ffi.Pointer<ffi.Uint32> maximumValue = calloc<ffi.Uint32>();
    try {
      final int result = _getVcpFeature(handle, code, codeType, currentValue, maximumValue);
      if (result == 0) {
        return VcpReadResult(
          success: false,
          windowsError: _getLastError(),
        );
      }
      return VcpReadResult(
        success: true,
        currentValue: currentValue.value,
        maximumValue: maximumValue.value,
        codeType: codeType.value,
      );
    } finally {
      calloc.free(codeType);
      calloc.free(currentValue);
      calloc.free(maximumValue);
    }
  }

  _TimingReportData? _readTimingReport(int handle) {
    final ffi.Pointer<McTimingReport> report = calloc<McTimingReport>();
    try {
      final int result = _getTimingReport(handle, report);
      if (result == 0) {
        return null;
      }
      return _TimingReportData(
        horizontalFrequencyInHertz: report.ref.horizontalFrequencyInHertz,
        verticalFrequencyInHertz: report.ref.verticalFrequencyInHertz,
      );
    } finally {
      calloc.free(report);
    }
  }

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

  void _closeHandles() {
    for (final _MonitorHandle handle in _openMonitors.values) {
      _destroyPhysicalMonitor(handle.handle);
    }
    _openMonitors.clear();
  }

  static String _hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();
}

class _RawPhysicalMonitor {
  const _RawPhysicalMonitor({
    required this.handle,
    required this.description,
  });

  final int handle;
  final String description;
}

class _MonitorHandle {
  const _MonitorHandle({
    required this.id,
    required this.handle,
    required this.description,
  });

  final String id;
  final int handle;
  final String description;
}

class _TimingReportData {
  const _TimingReportData({
    required this.horizontalFrequencyInHertz,
    required this.verticalFrequencyInHertz,
  });

  final int horizontalFrequencyInHertz;
  final int verticalFrequencyInHertz;
}
