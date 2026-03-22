// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'n.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(windowsDdcCiService)
final windowsDdcCiServiceProvider = WindowsDdcCiServiceProvider._();

final class WindowsDdcCiServiceProvider
    extends
        $FunctionalProvider<
          WindowsDdcCiService,
          WindowsDdcCiService,
          WindowsDdcCiService
        >
    with $Provider<WindowsDdcCiService> {
  WindowsDdcCiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowsDdcCiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowsDdcCiServiceHash();

  @$internal
  @override
  $ProviderElement<WindowsDdcCiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WindowsDdcCiService create(Ref ref) {
    return windowsDdcCiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowsDdcCiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowsDdcCiService>(value),
    );
  }
}

String _$windowsDdcCiServiceHash() =>
    r'b1eea1384d7a875bb9b5b0dc68e92784f0eaf72f';

@ProviderFor(capabilitiesParser)
final capabilitiesParserProvider = CapabilitiesParserProvider._();

final class CapabilitiesParserProvider
    extends
        $FunctionalProvider<
          CapabilitiesParser,
          CapabilitiesParser,
          CapabilitiesParser
        >
    with $Provider<CapabilitiesParser> {
  CapabilitiesParserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'capabilitiesParserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$capabilitiesParserHash();

  @$internal
  @override
  $ProviderElement<CapabilitiesParser> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CapabilitiesParser create(Ref ref) {
    return capabilitiesParser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CapabilitiesParser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CapabilitiesParser>(value),
    );
  }
}

String _$capabilitiesParserHash() =>
    r'9e89e9288dc782b740741085dc7e116e74aae567';

@ProviderFor(loadMonitors)
final loadMonitorsProvider = LoadMonitorsProvider._();

final class LoadMonitorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RawPhysicalMonitor>>,
          List<RawPhysicalMonitor>,
          FutureOr<List<RawPhysicalMonitor>>
        >
    with
        $FutureModifier<List<RawPhysicalMonitor>>,
        $FutureProvider<List<RawPhysicalMonitor>> {
  LoadMonitorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadMonitorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadMonitorsHash();

  @$internal
  @override
  $FutureProviderElement<List<RawPhysicalMonitor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RawPhysicalMonitor>> create(Ref ref) {
    return loadMonitors(ref);
  }
}

String _$loadMonitorsHash() => r'640f425b3d828600cb189cdada9d6c6b4baffb47';

@ProviderFor(readCapabilities)
final readCapabilitiesProvider = ReadCapabilitiesFamily._();

final class ReadCapabilitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParsedCapabilities>,
          ParsedCapabilities,
          FutureOr<ParsedCapabilities>
        >
    with
        $FutureModifier<ParsedCapabilities>,
        $FutureProvider<ParsedCapabilities> {
  ReadCapabilitiesProvider._({
    required ReadCapabilitiesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'readCapabilitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readCapabilitiesHash();

  @override
  String toString() {
    return r'readCapabilitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ParsedCapabilities> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ParsedCapabilities> create(Ref ref) {
    final argument = this.argument as int;
    return readCapabilities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadCapabilitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readCapabilitiesHash() => r'3bc699f91313eaa4868260ad4ad78f2608a3b9b0';

final class ReadCapabilitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ParsedCapabilities>, int> {
  ReadCapabilitiesFamily._()
    : super(
        retry: null,
        name: r'readCapabilitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReadCapabilitiesProvider call(int handle) =>
      ReadCapabilitiesProvider._(argument: handle, from: this);

  @override
  String toString() => r'readCapabilitiesProvider';
}

@ProviderFor(readFeatureValue)
final readFeatureValueProvider = ReadFeatureValueFamily._();

final class ReadFeatureValueProvider
    extends
        $FunctionalProvider<
          AsyncValue<VcpReadResult>,
          VcpReadResult,
          FutureOr<VcpReadResult>
        >
    with $FutureModifier<VcpReadResult>, $FutureProvider<VcpReadResult> {
  ReadFeatureValueProvider._({
    required ReadFeatureValueFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'readFeatureValueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readFeatureValueHash();

  @override
  String toString() {
    return r'readFeatureValueProvider'
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
    return readFeatureValue(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadFeatureValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readFeatureValueHash() => r'82aa8256bb2b0833d1868b071eda3f42f6c33fc9';

final class ReadFeatureValueFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VcpReadResult>, (int, int)> {
  ReadFeatureValueFamily._()
    : super(
        retry: null,
        name: r'readFeatureValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReadFeatureValueProvider call(int handle, int code) =>
      ReadFeatureValueProvider._(argument: (handle, code), from: this);

  @override
  String toString() => r'readFeatureValueProvider';
}
