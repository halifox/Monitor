/// 封装显示器 DDC/CI Capabilities 解析后的信息。
class CapabilitiesInfo {
  const CapabilitiesInfo({required this.rawString, required this.model, required this.type, required this.mccsVersion, required this.commands, required this.vcpCodes, required this.vcpValues});

  final String rawString;
  final String model;
  final String type;
  final String mccsVersion;
  final Set<int> commands;
  final Set<int> vcpCodes;
  final Map<int, Set<int>> vcpValues;

  factory CapabilitiesInfo.parse(String raw) {
    final trimmed = raw.trim();
    return CapabilitiesInfo(
      rawString: raw,
      model: _parseModel(trimmed),
      type: _parseType(trimmed),
      mccsVersion: _parseMccsVersion(trimmed),
      commands: _parseCommands(trimmed),
      vcpCodes: _parseVcpCodes(trimmed),
      vcpValues: _parseVcpValues(trimmed),
    );
  }

  static String _parseModel(String raw) {
    final String? value = _extractSection(raw.trim(), 'model');
    return _normalizeScalar(value);
  }

  static String _parseType(String raw) {
    final String? value = _extractSection(raw.trim(), 'type');
    return _normalizeScalar(value);
  }

  static String _parseMccsVersion(String raw) {
    final String? value = _extractSection(raw.trim(), 'mccs_ver');
    return _normalizeScalar(value);
  }

  static Set<int> _parseCommands(String raw) {
    final String? section = _extractSection(raw.trim(), 'cmds');
    return _parseHexList(section);
  }

  static Set<int> _parseVcpCodes(String raw) {
    final String? section = _extractSection(raw.trim(), 'vcp');
    final _VcpSection vcp = _parseVcpSection(section);
    return vcp.codes;
  }

  static Map<int, Set<int>> _parseVcpValues(String raw) {
    final String? section = _extractSection(raw.trim(), 'vcp');
    final _VcpSection vcp = _parseVcpSection(section);
    return vcp.values;
  }

  static String? _extractSection(String source, String key) {
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

  static String _normalizeScalar(String? value) {
    if (value == null) {
      return '';
    }
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return '';
    }
    return normalized;
  }

  static Set<int> _parseHexList(String? raw) {
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

  static _VcpSection _parseVcpSection(String? raw) {
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

  static _SectionRead _readBalanced(String source, int openingIndex) {
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

  static bool _isWhitespace(String value) => value.trim().isEmpty;
}

class _VcpSection {
  const _VcpSection(this.codes, this.values);

  final Set<int> codes;
  final Map<int, Set<int>> values;
}

class _SectionRead {
  const _SectionRead(this.content, this.nextIndex);

  final String content;
  final int nextIndex;
}
