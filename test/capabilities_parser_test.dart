import 'package:ddcci/src/ddcci/capabilities_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CapabilitiesParser parser = CapabilitiesParser();

  test('parses model, version and VCP option blocks', () {
    const String raw =
        '(prot(monitor)type(LCD)model(U2723QE)cmds(01 02 03 07 0C E3 F3)vcp(10 12 14(01 04 05 08 0B) 60(0F 11 12) 62 D6(01 04 05))mccs_ver(2.2))';

    final capabilities = parser.parse(raw);

    expect(capabilities.model, 'U2723QE');
    expect(capabilities.displayType, 'LCD');
    expect(capabilities.mccsVersion, '2.2');
    expect(capabilities.supportedCommands, containsAll(<int>[0x01, 0x0C, 0xF3]));
    expect(capabilities.supportedVcpCodes, containsAll(<int>[0x10, 0x14, 0x60, 0xD6]));
    expect(capabilities.supportedVcpValues[0x14], containsAll(<int>[0x01, 0x04, 0x0B]));
    expect(capabilities.supportedVcpValues[0x60], containsAll(<int>[0x0F, 0x11, 0x12]));
  });

  test('returns empty sets when capability sections are absent', () {
    const String raw = '(prot(monitor)type(LCD)model(Test Panel))';

    final capabilities = parser.parse(raw);

    expect(capabilities.supportedCommands, isEmpty);
    expect(capabilities.supportedVcpCodes, isEmpty);
    expect(capabilities.supportedVcpValues, isEmpty);
  });
}
