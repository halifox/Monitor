/// 表示 VCP feature 的控制类型。
///
/// 不同类型决定了 UI 应如何展示、以及读写时应如何理解数值：
/// - `continuous`：连续区间值，例如亮度、对比度；
/// - `discrete`：离散枚举值，例如输入源选择；
/// - `toggle`：通常只有开/关两种状态；
/// - `action`：瞬时动作型命令，写入某个值即可触发，不强调当前状态；
/// - `numeric`：数值型，但暂时无法进一步准确归类。
// enum VcpControlKind { continuous, discrete, toggle, action, numeric }

/// 表示某个离散型 VCP 值的候选项。
///
/// 例如输入源 VCP code 可能定义：
/// - `0x0F` => `DisplayPort`
/// - `0x11` => `HDMI`
///
/// 其中 `value` 是协议层数值，`label` 是给 UI 或日志使用的人类可读名称。
// class VcpValueOption {
//   const VcpValueOption(this.value, this.label);
//
//   final int value;
//   final String label;
// }

/// 描述一个已知的 VCP feature 定义。
///
/// 这个模型相当于本地 catalog 中的一条元数据记录，用来告诉上层：
/// - 某个 VCP code 代表什么含义；
/// - 它属于哪个功能分类；
/// - 应按哪种控制类型处理；
/// - 如果是离散枚举型，有哪些候选值；
/// - 某些动作型 feature 是否需要固定 `actionValue` 才能触发。
// class VcpFeatureDefinition {
//   const VcpFeatureDefinition({
//     required this.code,
//     required this.name,
//     required this.category,
//     required this.description,
//     required this.kind,
//     this.options = const <VcpValueOption>[],
//     this.actionValue,
//     this.readOftenUnsupported = false,
//   });
//
//   final int code;
//   final String name;
//   final String category;
//   final String description;
//   final VcpControlKind kind;
//   final List<VcpValueOption> options;
//   final int? actionValue;
//   final bool readOftenUnsupported;
// }

/// 表示对显示器 capabilities 字符串的结构化解析结果。
///
/// 该对象保留原始字符串，同时把最常用的信息拆分出来，
/// 便于后续做能力判断、UI 展示和 feature 扫描：
/// - `raw`：原始 capabilities 文本；
/// - `model` / `displayType` / `mccsVersion`：基础标识信息；
/// - `supportedCommands`：显示器声明支持的 DDC/CI 命令；
/// - `supportedVcpCodes`：显示器声明支持的 VCP code；
/// - `supportedVcpValues`：某些 VCP code 显式声明的离散可选值。
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

/// 封装一次 VCP 读取操作的结果。
///
/// `success` 表示底层读取是否成功；如果成功，通常还会带回：
/// - `currentValue`：当前值；
/// - `maximumValue`：最大值或上界；
/// - `codeType`：底层接口报告的类型信息，可辅助区分动作型和普通数值型；
/// - `windowsError`：若失败，可记录对应的 Windows 错误码，便于诊断。
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

  /// 返回一个带局部字段覆盖的新实例，便于在不可变数据流中更新读取结果。
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

/// 表示某台显示器上某个 VCP feature 的当前状态快照。
///
/// 这个对象把三个来源的信息合并在一起：
/// - `code`：协议层的 VCP 编号；
/// - `definition`：本地 catalog 中已知的语义定义；
/// - `readResult`：运行时从显示器读取到的实际值；
/// - `supported` / `supportedValues`：来自 capabilities 的能力声明。
///
/// 上层通常直接消费这个模型来驱动 UI，而不需要分别关心 catalog、
/// capabilities 和实时读取结果分别来自哪里。
// class MonitorFeatureState {
//   const MonitorFeatureState({
//     required this.code,
//     required this.definition,
//     required this.supported,
//     required this.supportedValues,
//     required this.readResult,
//   });
//
//   final int code;
//   final VcpFeatureDefinition? definition;
//   final bool supported;
//   final Set<int> supportedValues;
//   final VcpReadResult? readResult;
//
//   /// 优先使用 catalog 中的命名；未知 code 则回退到十六进制形式。
//   String get name =>
//       definition?.name ??
//       '未识别 VCP 0x${code.toRadixString(16).padLeft(2, '0').toUpperCase()}';
//
//   /// 已知 feature 返回所属分类；未知 feature 统一视为厂商扩展项。
//   String get category => definition?.category ?? '厂商扩展';
//
//   /// 提供该 feature 的说明文本，未知项则给出兜底解释。
//   String get description =>
//       definition?.description ?? '能力字符串声明了这个 VCP code，但 catalog 中没有命名定义。';
//
//   /// 推断当前 feature 应按哪种控制类型处理。
//   ///
//   /// 推断优先级如下：
//   /// 1. 如果 catalog 已经给出明确类型，直接采用；
//   /// 2. 若底层 `codeType == 0`，通常视为动作型；
//   /// 3. 若 capabilities 中声明了可选值列表，视为离散枚举型；
//   /// 4. 若存在大于 1 的最大值，倾向视为连续型；
//   /// 5. 若最大值恰好为 1，视为开关型；
//   /// 6. 其余情况降级为泛化 `numeric`。
//   VcpControlKind get kind {
//     final VcpControlKind? preferred = definition?.kind;
//     if (preferred != null) {
//       return preferred;
//     }
//     if (readResult?.codeType == 0) {
//       return VcpControlKind.action;
//     }
//     if (supportedValues.isNotEmpty) {
//       return VcpControlKind.discrete;
//     }
//     if (readResult?.maximumValue != null &&
//         (readResult!.maximumValue ?? 0) > 1) {
//       return VcpControlKind.continuous;
//     }
//     if (readResult?.maximumValue == 1) {
//       return VcpControlKind.toggle;
//     }
//     return VcpControlKind.numeric;
//   }
//
//   /// 是否属于“一次触发型”能力，而不是长期保持某个状态的控制项。
//   bool get isMomentary =>
//       readResult?.codeType == 0 || kind == VcpControlKind.action;
//
//   /// 当前 feature 是否已经成功读到有效值。
//   bool get canRead => readResult?.success ?? false;
//
//   /// 当前值的便捷访问器。
//   int? get currentValue => readResult?.currentValue;
//
//   /// 最大值的便捷访问器。
//   int? get maximumValue => readResult?.maximumValue;
//
//   /// 返回一个带局部字段覆盖的新实例，用于不可变状态更新。
//   MonitorFeatureState copyWith({
//     int? code,
//     VcpFeatureDefinition? definition,
//     bool? supported,
//     Set<int>? supportedValues,
//     VcpReadResult? readResult,
//   }) {
//     return MonitorFeatureState(
//       code: code ?? this.code,
//       definition: definition ?? this.definition,
//       supported: supported ?? this.supported,
//       supportedValues: supportedValues ?? this.supportedValues,
//       readResult: readResult ?? this.readResult,
//     );
//   }
// }

/// 表示一次显示器扫描后的整体快照。
///
/// 它聚合了识别显示器、解析能力字符串和读取 feature 结果所需的主要数据：
/// - `id` / `description`：用于标识和展示显示器；
/// - `capabilities` / `capabilitiesData`：原始能力串及其解析结果；
/// - `features`：能够识别并归类的 feature；
/// - `unknownFeatures`：显示器声明支持，但本地 catalog 尚未命名的 feature；
/// - `horizontalFrequency` / `verticalFrequency`：可选的运行频率信息；
/// - `errorMessage`：扫描或读取过程中记录的错误描述。
// class MonitorSnapshot {
//   const MonitorSnapshot({
//     required this.id,
//     required this.description,
//   });
//
//   final String id;
//   final String description;
//
//   /// 返回一个带局部字段覆盖的新快照，便于状态管理层做增量更新。
//   MonitorSnapshot copyWith({
//     String? id,
//     String? description,
//   }) {
//     return MonitorSnapshot(
//       id: id ?? this.id,
//       description: description ?? this.description,
//     );
//   }
// }
