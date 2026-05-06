import 'models.dart';

/// 负责把显示器通过 DDC/CI 返回的 capabilities 原始字符串解析为结构化数据。
///
/// 这类字符串通常形如：
/// `prot(monitor)type(lcd)model(...)cmds(01 02 ...)vcp(10 12(01 02) D6)`
///
/// 解析目标主要包括：
/// 1. 提取 `model`、`type`、`mccs_ver` 等标量字段。
/// 2. 提取 `cmds(...)` 中声明的命令编号集合。
/// 3. 提取 `vcp(...)` 中声明的 VCP code，以及某些离散型 VCP code 对应的可选值。
///
/// 由于不同厂商返回的 capabilities 字符串并不总是完全规范，
/// 这里的实现偏向“容错解析”：
/// - 能识别的内容尽量提取出来；
/// - 无法识别的片段直接跳过；
/// - 缺失字段以 `null` 或空集合表示，而不是抛异常。
class CapabilitiesParser {
  const CapabilitiesParser();

  /// 解析完整的 capabilities 字符串，并返回统一的结构化结果。
  ///
  /// `raw` 会先做 `trim`，避免首尾空白影响匹配。
  /// 随后按字段分别提取，再组合成 [ParsedCapabilities]：
  /// - `model` / `displayType` / `mccsVersion`：标量文本字段；
  /// - `supportedCommands`：显示器声明支持的命令码集合；
  /// - `supportedVcpCodes`：显示器声明支持的 VCP code 集合；
  /// - `supportedVcpValues`：某些 VCP code 在 capabilities 中显式列出的可选值。
  ParsedCapabilities parse(String raw) {
    final String normalized = raw.trim();
    final String? model = _extractSection(normalized, 'model');
    final String? displayType = _extractSection(normalized, 'type');
    final String? mccsVersion = _extractSection(normalized, 'mccs_ver');
    final Set<int> commands = _parseHexList(
      _extractSection(normalized, 'cmds'),
    );
    final _VcpSection vcp = _parseVcpSection(
      _extractSection(normalized, 'vcp'),
    );

    return ParsedCapabilities(
      raw: normalized,
      model: _normalizeScalar(model),
      displayType: _normalizeScalar(displayType),
      mccsVersion: _normalizeScalar(mccsVersion),
      supportedCommands: commands,
      supportedVcpCodes: vcp.codes,
      supportedVcpValues: vcp.values,
    );
  }

  /*
   * 从整个 capabilities 字符串中提取指定 key 对应的括号内容。
   *
   * 例如：
   * source = "type(lcd)model(ABC)vcp(10 12)"
   * key = "model"
   * 返回 "ABC"
   *
   * 这里不能简单地找第一个右括号，因为有些 section 内部还会嵌套括号。
   * 因此使用 depth 计数的方式读取“平衡括号”：
   * - 读到 `(` 时深度加一；
   * - 读到 `)` 时深度减一；
   * - 深度重新回到 0 时，说明当前 section 结束。
   */
  String? _extractSection(String source, String key) {
    final String needle = '$key(';
    final int start = source.indexOf(needle);
    if (start < 0) {
      return null;
    }
    int depth = 1;
    final int contentStart = start + needle.length;
    for (int i = contentStart; i < source.length; i++) {
      final String char = source[i];
      if (char == '(') {
        depth++;
      } else if (char == ')') {
        depth--;
        if (depth == 0) {
          return source.substring(contentStart, i);
        }
      }
    }
    return null;
  }

  /*
   * 规范化单个标量字段。
   *
   * 某些显示器可能会返回空字符串、全空白字符串，或者某个字段本身不存在。
   * 这里统一把这些情况转换成 `null`，避免上层继续处理无意义的空文本。
   */
  String? _normalizeScalar(String? value) {
    if (value == null) {
      return null;
    }
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  /*
   * 把一段十六进制列表文本解析为整数集合。
   *
   * 这里专门匹配两个字符一组的十六进制 token，例如：
   * - "01 02 0C"
   * - "10(01 02) D6"
   *
   * 无论中间夹杂空格、括号或其他噪声，只要出现两位十六进制字符，
   * 就会被识别并转换为对应整数。最终使用 Set 去重。
   */
  Set<int> _parseHexList(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return <int>{};
    }
    final Iterable<RegExpMatch> matches = RegExp(
      r'[0-9A-Fa-f]{2}',
    ).allMatches(raw);
    return matches
        .map((RegExpMatch match) => int.parse(match.group(0)!, radix: 16))
        .toSet();
  }

  /*
   * 解析 `vcp(...)` section。
   *
   * VCP section 的典型格式类似：
   * `10 12(01 02) 52 D6(01 04 05)`
   *
   * 其中：
   * - `10`、`52` 表示支持的 VCP code；
   * - `12(01 02)` 表示 code `0x12` 支持离散值 `0x01`、`0x02`。
   *
   * 该方法会同时构建两部分结果：
   * - `codes`：所有出现过的 VCP code；
   * - `values`：只有在 code 后面明确跟了括号值列表时才记录。
   *
   * 解析过程按字符线性扫描，以兼容不规则空白和部分非标准格式。
   */
  _VcpSection _parseVcpSection(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const _VcpSection(<int>{}, <int, Set<int>>{});
    }

    final Set<int> codes = <int>{};
    final Map<int, Set<int>> values = <int, Set<int>>{};
    int index = 0;

    while (index < raw.length) {
      final String char = raw[index];
      if (_isWhitespace(char) || char == ')') {
        index++;
        continue;
      }
      final Match? codeMatch = RegExp(
        r'^[0-9A-Fa-f]{2}',
      ).matchAsPrefix(raw.substring(index));
      if (codeMatch == null) {
        index++;
        continue;
      }
      final String token = codeMatch.group(0)!;
      final int code = int.parse(token, radix: 16);
      codes.add(code);
      index += token.length;
      while (index < raw.length && _isWhitespace(raw[index])) {
        index++;
      }
      if (index < raw.length && raw[index] == '(') {
        final _SectionRead section = _readBalanced(raw, index);
        values[code] = _parseHexList(section.content);
        index = section.nextIndex;
      }
    }

    return _VcpSection(codes, values);
  }

  /*
   * 从给定的左括号位置开始，读取一段“平衡括号”内容。
   *
   * 返回值包含两部分：
   * - `content`：最外层括号内部的文本，不含包裹它的那对括号；
   * - `nextIndex`：读取完成后，下一个尚未消费的字符位置。
   *
   * 这个辅助方法主要服务于 `vcp(12(01 02))` 这种嵌套场景，
   * 避免简单字符串查找在遇到内层括号时提前结束。
   */
  _SectionRead _readBalanced(String source, int openingIndex) {
    int depth = 0;
    final StringBuffer buffer = StringBuffer();
    for (int i = openingIndex; i < source.length; i++) {
      final String char = source[i];
      if (char == '(') {
        depth++;
        if (depth == 1) {
          continue;
        }
      } else if (char == ')') {
        depth--;
        if (depth == 0) {
          return _SectionRead(buffer.toString(), i + 1);
        }
      }
      if (depth >= 1) {
        buffer.write(char);
      }
    }
    return _SectionRead(buffer.toString(), source.length);
  }

  /// 用最轻量的方式判断当前字符是否为空白字符。
  bool _isWhitespace(String value) => value.trim().isEmpty;
}

/// `vcp(...)` section 的解析结果。
///
/// 之所以单独建一个私有类型，是为了让 `_parseVcpSection` 同时返回：
/// - 支持的 VCP code 集合；
/// - 每个 code 对应的离散可选值映射。
class _VcpSection {
  const _VcpSection(this.codes, this.values);

  final Set<int> codes;
  final Map<int, Set<int>> values;
}

/// 表示一次平衡括号读取操作的结果。
///
/// `content` 是读取到的括号内部文本，
/// `nextIndex` 是后续扫描应继续开始的位置。
class _SectionRead {
  const _SectionRead(this.content, this.nextIndex);

  final String content;
  final int nextIndex;
}
