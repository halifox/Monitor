import 'models.dart';

abstract interface class DdcCiService {
  Future<List<MonitorSnapshot>> loadMonitors();

  Future<MonitorSnapshot> refreshMonitor(String monitorId);

  Future<void> saveSettings(String monitorId);

  Future<VcpReadResult> readFeatureValue(String monitorId, int code);

  Future<void> setFeatureValue(String monitorId, int code, int value);

  void dispose();
}
