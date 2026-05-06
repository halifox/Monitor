import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pureddc/capabilities_parser.dart';
import 'pureddc/models.dart';
import 'pureddc/windows_pureddc.dart';

part 'n.g.dart';

@Riverpod(keepAlive: true)
WindowsPureDDCService windowsPureDDCService(Ref ref) {
  return WindowsPureDDCService();
}

@Riverpod(keepAlive: true)
CapabilitiesParser capabilitiesParser(Ref ref) {
  return CapabilitiesParser();
}

@riverpod
Future<List<RawPhysicalMonitor>> loadMonitors(Ref ref) {
  final service = ref.read(windowsPureDDCServiceProvider);
  return service.loadMonitors();
}

@riverpod
Future<ParsedCapabilities> readCapabilities(Ref ref, int handle) async {
  final service = ref.read(windowsPureDDCServiceProvider);
  final readCapabilities = await service.readCapabilities(handle);
  final capabilitiesParser = ref.read(capabilitiesParserProvider);
  final parsedCapabilities = capabilitiesParser.parse(readCapabilities);
  return parsedCapabilities;
}

@riverpod
Future<VcpReadResult> readFeatureValue(Ref ref, int handle, int code) {
  final service = ref.read(windowsPureDDCServiceProvider);
  return service.readFeatureValue(handle, code);
}

// @riverpod
// Future<void> setFeatureValue(Ref ref, int handle, int code, int value) {
//   final service = ref.read(windowsPureDDCServiceProvider);
//   return service.setFeatureValue(handle, code, value);
// }
