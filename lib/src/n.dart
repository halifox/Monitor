import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ddcci/capabilities_parser.dart';
import 'ddcci/models.dart';
import 'ddcci/windows_ddcci.dart';

part 'n.g.dart';

@Riverpod(keepAlive: true)
WindowsDdcCiService windowsDdcCiService(Ref ref) {
  return WindowsDdcCiService();
}

@Riverpod(keepAlive: true)
CapabilitiesParser capabilitiesParser(Ref ref) {
  return CapabilitiesParser();
}

@riverpod
Future<List<RawPhysicalMonitor>> loadMonitors(Ref ref) {
  final service = ref.read(windowsDdcCiServiceProvider);
  return service.loadMonitors();
}

@riverpod
Future<ParsedCapabilities> readCapabilities(Ref ref, int handle) async {
  final service = ref.read(windowsDdcCiServiceProvider);
  final readCapabilities = await service.readCapabilities(handle);
  final capabilitiesParser = ref.read(capabilitiesParserProvider);
  final parsedCapabilities = capabilitiesParser.parse(readCapabilities);
  return parsedCapabilities;
}

@riverpod
Future<VcpReadResult> readFeatureValue(Ref ref, int handle, int code) {
  final service = ref.read(windowsDdcCiServiceProvider);
  return service.readFeatureValue(handle, code);
}

// @riverpod
// Future<void> setFeatureValue(Ref ref, int handle, int code, int value) {
//   final service = ref.read(windowsDdcCiServiceProvider);
//   return service.setFeatureValue(handle, code, value);
// }
