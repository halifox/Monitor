// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'n.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(windowsPureDDCService)
final windowsPureDDCServiceProvider = WindowsPureDDCServiceProvider._();

final class WindowsPureDDCServiceProvider
    extends
        $FunctionalProvider<
          WindowsPureDDCService,
          WindowsPureDDCService,
          WindowsPureDDCService
        >
    with $Provider<WindowsPureDDCService> {
  WindowsPureDDCServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowsPureDDCServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowsPureDDCServiceHash();

  @$internal
  @override
  $ProviderElement<WindowsPureDDCService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WindowsPureDDCService create(Ref ref) {
    return windowsPureDDCService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowsPureDDCService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowsPureDDCService>(value),
    );
  }
}

String _$windowsPureDDCServiceHash() =>
    r'dce14fcc4e999a31bc61a62a728d914684ad45b2';

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

String _$loadMonitorsHash() => r'6b225cd961ec63d26b72c2066aaadfae6f45e702';

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

String _$readCapabilitiesHash() => r'72a3de476be309485f1f06dbc4ae09a1b70c13e3';

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

String _$readFeatureValueHash() => r'6139c16585305dd3e777b6f40c8ef69b3bf45b77';

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
