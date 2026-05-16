
/// 封装一次 VCP 读取操作的结果。
///
/// `success` 表示底层读取是否成功；如果成功，通常还会带回：
/// - `currentValue`：当前值；
/// - `maximumValue`：最大值或上界；
/// - `codeType`：底层接口报告的类型信息，可辅助区分动作型和普通数值型；
/// - `windowsError`：若失败，可记录对应的 Windows 错误码，便于诊断。
class VcpReadResult {
  const VcpReadResult({
    required this.currentValue,
    required this.maximumValue,
    required this.codeType,
  });

  final int currentValue;
  final int maximumValue;
  final int codeType;

  /// 返回一个带局部字段覆盖的新实例，便于在不可变数据流中更新读取结果。
  VcpReadResult copyWith({
    int? currentValue,
    int? maximumValue,
    int? codeType,
  }) {
    return VcpReadResult(
      currentValue: currentValue ?? this.currentValue,
      maximumValue: maximumValue ?? this.maximumValue,
      codeType: codeType ?? this.codeType,
    );
  }
}
