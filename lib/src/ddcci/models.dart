enum VcpControlKind {
  continuous,
  discrete,
  toggle,
  action,
  numeric,
}

class VcpValueOption {
  const VcpValueOption(this.value, this.label);

  final int value;
  final String label;
}

class VcpFeatureDefinition {
  const VcpFeatureDefinition({
    required this.code,
    required this.name,
    required this.category,
    required this.description,
    required this.kind,
    this.options = const <VcpValueOption>[],
    this.actionValue,
    this.readOftenUnsupported = false,
  });

  final int code;
  final String name;
  final String category;
  final String description;
  final VcpControlKind kind;
  final List<VcpValueOption> options;
  final int? actionValue;
  final bool readOftenUnsupported;
}

class ParsedCapabilities {
  const ParsedCapabilities({
    required this.raw,
    required this.model,
    required this.displayType,
    required this.mccsVersion,
    required this.supportedCommands,
    required this.supportedVcpCodes,
    required this.supportedVcpValues,
  });

  final String raw;
  final String? model;
  final String? displayType;
  final String? mccsVersion;
  final Set<int> supportedCommands;
  final Set<int> supportedVcpCodes;
  final Map<int, Set<int>> supportedVcpValues;
}

class VcpReadResult {
  const VcpReadResult({
    required this.success,
    this.currentValue,
    this.maximumValue,
    this.codeType,
    this.windowsError,
  });

  final bool success;
  final int? currentValue;
  final int? maximumValue;
  final int? codeType;
  final int? windowsError;

  VcpReadResult copyWith({
    bool? success,
    int? currentValue,
    int? maximumValue,
    int? codeType,
    int? windowsError,
  }) {
    return VcpReadResult(
      success: success ?? this.success,
      currentValue: currentValue ?? this.currentValue,
      maximumValue: maximumValue ?? this.maximumValue,
      codeType: codeType ?? this.codeType,
      windowsError: windowsError ?? this.windowsError,
    );
  }
}

class MonitorFeatureState {
  const MonitorFeatureState({
    required this.code,
    required this.definition,
    required this.supported,
    required this.supportedValues,
    required this.readResult,
  });

  final int code;
  final VcpFeatureDefinition? definition;
  final bool supported;
  final Set<int> supportedValues;
  final VcpReadResult? readResult;

  String get name => definition?.name ?? '未识别 VCP 0x${code.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  String get category => definition?.category ?? '厂商扩展';

  String get description => definition?.description ?? '能力字符串声明了这个 VCP code，但 catalog 中没有命名定义。';

  VcpControlKind get kind {
    final VcpControlKind? preferred = definition?.kind;
    if (preferred != null) {
      return preferred;
    }
    if (readResult?.codeType == 0) {
      return VcpControlKind.action;
    }
    if (supportedValues.isNotEmpty) {
      return VcpControlKind.discrete;
    }
    if (readResult?.maximumValue != null && (readResult!.maximumValue ?? 0) > 1) {
      return VcpControlKind.continuous;
    }
    if (readResult?.maximumValue == 1) {
      return VcpControlKind.toggle;
    }
    return VcpControlKind.numeric;
  }

  bool get isMomentary => readResult?.codeType == 0 || kind == VcpControlKind.action;

  bool get canRead => readResult?.success ?? false;

  int? get currentValue => readResult?.currentValue;

  int? get maximumValue => readResult?.maximumValue;

  MonitorFeatureState copyWith({
    int? code,
    VcpFeatureDefinition? definition,
    bool? supported,
    Set<int>? supportedValues,
    VcpReadResult? readResult,
  }) {
    return MonitorFeatureState(
      code: code ?? this.code,
      definition: definition ?? this.definition,
      supported: supported ?? this.supported,
      supportedValues: supportedValues ?? this.supportedValues,
      readResult: readResult ?? this.readResult,
    );
  }
}

class MonitorSnapshot {
  const MonitorSnapshot({
    required this.id,
    required this.description,
    required this.capabilities,
    required this.capabilitiesData,
    required this.features,
    required this.unknownFeatures,
    this.horizontalFrequency,
    this.verticalFrequency,
    this.errorMessage,
  });

  final String id;
  final String description;
  final String? capabilities;
  final ParsedCapabilities? capabilitiesData;
  final List<MonitorFeatureState> features;
  final List<MonitorFeatureState> unknownFeatures;
  final int? horizontalFrequency;
  final int? verticalFrequency;
  final String? errorMessage;

  MonitorSnapshot copyWith({
    String? id,
    String? description,
    String? capabilities,
    ParsedCapabilities? capabilitiesData,
    List<MonitorFeatureState>? features,
    List<MonitorFeatureState>? unknownFeatures,
    int? horizontalFrequency,
    int? verticalFrequency,
    String? errorMessage,
  }) {
    return MonitorSnapshot(
      id: id ?? this.id,
      description: description ?? this.description,
      capabilities: capabilities ?? this.capabilities,
      capabilitiesData: capabilitiesData ?? this.capabilitiesData,
      features: features ?? this.features,
      unknownFeatures: unknownFeatures ?? this.unknownFeatures,
      horizontalFrequency: horizontalFrequency ?? this.horizontalFrequency,
      verticalFrequency: verticalFrequency ?? this.verticalFrequency,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
