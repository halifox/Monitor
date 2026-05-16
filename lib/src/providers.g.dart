// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(logicalMonitors)
final logicalMonitorsProvider = LogicalMonitorsProvider._();

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

final class LogicalMonitorsProvider
    extends $FunctionalProvider<List<int>, List<int>, List<int>>
    with $Provider<List<int>> {
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
  LogicalMonitorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logicalMonitorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logicalMonitorsHash();

  @$internal
  @override
  $ProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<int> create(Ref ref) {
    return logicalMonitors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<int>>(value),
    );
  }
}

String _$logicalMonitorsHash() => r'fe6c29d1c286fcd50cd0282863f0970e409a02a0';

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

@ProviderFor(physicalMonitors)
final physicalMonitorsProvider = PhysicalMonitorsFamily._();

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

final class PhysicalMonitorsProvider
    extends $FunctionalProvider<List<int>, List<int>, List<int>>
    with $Provider<List<int>> {
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
  PhysicalMonitorsProvider._({
    required PhysicalMonitorsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'physicalMonitorsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$physicalMonitorsHash();

  @override
  String toString() {
    return r'physicalMonitorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<int> create(Ref ref) {
    final argument = this.argument as int;
    return physicalMonitors(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PhysicalMonitorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$physicalMonitorsHash() => r'7c9c979224c0db68ed63bce820841adde9bcfd54';

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

final class PhysicalMonitorsFamily extends $Family
    with $FunctionalFamilyOverride<List<int>, int> {
  PhysicalMonitorsFamily._()
    : super(
        retry: null,
        name: r'physicalMonitorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

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

  PhysicalMonitorsProvider call(int hMonitor) =>
      PhysicalMonitorsProvider._(argument: hMonitor, from: this);

  @override
  String toString() => r'physicalMonitorsProvider';
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

@ProviderFor(logicalMonitorName)
final logicalMonitorNameProvider = LogicalMonitorNameFamily._();

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

final class LogicalMonitorNameProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
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
  LogicalMonitorNameProvider._({
    required LogicalMonitorNameFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'logicalMonitorNameProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logicalMonitorNameHash();

  @override
  String toString() {
    return r'logicalMonitorNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as int;
    return logicalMonitorName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LogicalMonitorNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logicalMonitorNameHash() =>
    r'd4422ac1acd0a3ff118b9e6d502f5e16627fcbb1';

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

final class LogicalMonitorNameFamily extends $Family
    with $FunctionalFamilyOverride<String, int> {
  LogicalMonitorNameFamily._()
    : super(
        retry: null,
        name: r'logicalMonitorNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

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

  LogicalMonitorNameProvider call(int hMonitor) =>
      LogicalMonitorNameProvider._(argument: hMonitor, from: this);

  @override
  String toString() => r'logicalMonitorNameProvider';
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

@ProviderFor(monitorCapabilities)
final monitorCapabilitiesProvider = MonitorCapabilitiesFamily._();

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

final class MonitorCapabilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<CapabilitiesInfo>,
          CapabilitiesInfo,
          FutureOr<CapabilitiesInfo>
        >
    with $FutureModifier<CapabilitiesInfo>, $FutureProvider<CapabilitiesInfo> {
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
  MonitorCapabilitiesProvider._({
    required MonitorCapabilitiesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'monitorCapabilitiesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monitorCapabilitiesHash();

  @override
  String toString() {
    return r'monitorCapabilitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CapabilitiesInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CapabilitiesInfo> create(Ref ref) {
    final argument = this.argument as int;
    return monitorCapabilities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonitorCapabilitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monitorCapabilitiesHash() =>
    r'd10e90e3775ae7243eae11f38200396d510addd2';

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

final class MonitorCapabilitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CapabilitiesInfo>, int> {
  MonitorCapabilitiesFamily._()
    : super(
        retry: null,
        name: r'monitorCapabilitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

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

  MonitorCapabilitiesProvider call(int handle) =>
      MonitorCapabilitiesProvider._(argument: handle, from: this);

  @override
  String toString() => r'monitorCapabilitiesProvider';
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

@ProviderFor(featureValue)
final featureValueProvider = FeatureValueFamily._();

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

final class FeatureValueProvider
    extends
        $FunctionalProvider<
          AsyncValue<VcpReadResult>,
          VcpReadResult,
          FutureOr<VcpReadResult>
        >
    with $FutureModifier<VcpReadResult>, $FutureProvider<VcpReadResult> {
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
  FeatureValueProvider._({
    required FeatureValueFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'featureValueProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$featureValueHash();

  @override
  String toString() {
    return r'featureValueProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<VcpReadResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VcpReadResult> create(Ref ref) {
    final argument = this.argument as (int, int);
    return featureValue(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FeatureValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$featureValueHash() => r'd8b6e6404bd8a179c975602af139566f67c7b8a4';

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

final class FeatureValueFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VcpReadResult>, (int, int)> {
  FeatureValueFamily._()
    : super(
        retry: null,
        name: r'featureValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

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

  FeatureValueProvider call(int handle, int code) =>
      FeatureValueProvider._(argument: (handle, code), from: this);

  @override
  String toString() => r'featureValueProvider';
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

@ProviderFor(setFeatureValue)
final setFeatureValueProvider = SetFeatureValueFamily._();

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

final class SetFeatureValueProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
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
  SetFeatureValueProvider._({
    required SetFeatureValueFamily super.from,
    required (int, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'setFeatureValueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setFeatureValueHash();

  @override
  String toString() {
    return r'setFeatureValueProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (int, int, int);
    return setFeatureValue(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is SetFeatureValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setFeatureValueHash() => r'6bb1a27b8fc674accd059bf3fe49a8f55e1674c9';

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

final class SetFeatureValueFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (int, int, int)> {
  SetFeatureValueFamily._()
    : super(
        retry: null,
        name: r'setFeatureValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  SetFeatureValueProvider call(int handle, int code, int value) =>
      SetFeatureValueProvider._(argument: (handle, code, value), from: this);

  @override
  String toString() => r'setFeatureValueProvider';
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

@ProviderFor(saveMonitorSettings)
final saveMonitorSettingsProvider = SaveMonitorSettingsFamily._();

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

final class SaveMonitorSettingsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
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
  SaveMonitorSettingsProvider._({
    required SaveMonitorSettingsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'saveMonitorSettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saveMonitorSettingsHash();

  @override
  String toString() {
    return r'saveMonitorSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return saveMonitorSettings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveMonitorSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saveMonitorSettingsHash() =>
    r'244215ef4801c656ef3eb9f08cde22254f8d082b';

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

final class SaveMonitorSettingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  SaveMonitorSettingsFamily._()
    : super(
        retry: null,
        name: r'saveMonitorSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  SaveMonitorSettingsProvider call(int handle) =>
      SaveMonitorSettingsProvider._(argument: handle, from: this);

  @override
  String toString() => r'saveMonitorSettingsProvider';
}

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

@ProviderFor(monitorEdid)
final monitorEdidProvider = MonitorEdidFamily._();

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

final class MonitorEdidProvider
    extends
        $FunctionalProvider<
          AsyncValue<EdidInfo?>,
          EdidInfo?,
          FutureOr<EdidInfo?>
        >
    with $FutureModifier<EdidInfo?>, $FutureProvider<EdidInfo?> {
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
  MonitorEdidProvider._({
    required MonitorEdidFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'monitorEdidProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monitorEdidHash();

  @override
  String toString() {
    return r'monitorEdidProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EdidInfo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EdidInfo?> create(Ref ref) {
    final argument = this.argument as int;
    return monitorEdid(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonitorEdidProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monitorEdidHash() => r'1081827efe2ff3cea4e1e2ac435776b3395817f8';

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

final class MonitorEdidFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EdidInfo?>, int> {
  MonitorEdidFamily._()
    : super(
        retry: null,
        name: r'monitorEdidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

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

  MonitorEdidProvider call(int hMonitor) =>
      MonitorEdidProvider._(argument: hMonitor, from: this);

  @override
  String toString() => r'monitorEdidProvider';
}
