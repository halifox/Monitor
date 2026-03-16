import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'src/ddcci/models.dart';
import 'src/ddcci/windows_ddcci.dart';
import 'src/ui/macos_settings_widgets.dart';

class _AppPalette {
  static const Color blue = Color(0xFF007AFF);
  static const Color sidebarLight = Color(0xFFE8E8E8);
  static const Color contentLight = Color(0xFFF2F2F7);
  static const Color sidebarDark = Color(0xFF2D2D2D);
  static const Color contentDark = Color(0xFF1E1E1E);
  static const Color separatorLight = Color(0x14000000);
  static const Color separatorDark = Color(0x26FFFFFF);
}

void main() {
  runApp(const DdcCiApp());
}

class DdcCiApp extends StatelessWidget {
  const DdcCiApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? _AppPalette.contentDark : _AppPalette.contentLight;
    final Color textColor = isDark ? Colors.white : Colors.black;
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _AppPalette.blue,
        brightness: brightness,
      ).copyWith(
        primary: _AppPalette.blue,
        surface: background,
      ),
      dividerColor: isDark ? _AppPalette.separatorDark : _AppPalette.separatorLight,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: _AppPalette.blue,
        scaffoldBackgroundColor: background,
        barBackgroundColor: background,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DDC/CI Control',
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const DdcCiDashboard(),
    );
  }
}

class DdcCiDashboard extends StatefulWidget {
  const DdcCiDashboard({super.key});

  @override
  State<DdcCiDashboard> createState() => _DdcCiDashboardState();
}

class _DdcCiDashboardState extends State<DdcCiDashboard> {
  static const Duration _sliderThrottleInterval = Duration(milliseconds: 500);

  final WindowsDdcCiService _service = WindowsDdcCiService();
  final Map<String, double> _sliderDrafts = <String, double>{};
  final Map<String, Timer> _sliderThrottleTimers = <String, Timer>{};
  final Map<String, int> _pendingSliderValues = <String, int>{};
  final Map<String, DateTime> _lastSliderCommitAt = <String, DateTime>{};
  final Set<String> _busyKeys = <String>{};

  List<MonitorSnapshot> _monitors = const <MonitorSnapshot>[];
  String? _selectedMonitorId;
  String _monitorQuery = '';
  String _featureQuery = '';
  bool _showUnsupported = false;
  bool _loading = true;
  String? _bannerMessage;
  bool _bannerIsError = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMonitors());
  }

  @override
  void dispose() {
    _cancelAllSliderTimers();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadMonitors() async {
    _cancelAllSliderTimers();
    setState(() {
      _loading = true;
      _bannerMessage = null;
    });
    try {
      final List<MonitorSnapshot> monitors = await _service.loadMonitors();
      setState(() {
        _monitors = monitors;
        _selectedMonitorId = monitors.isEmpty ? null : (_selectedMonitorId ?? monitors.first.id);
        if (!monitors.any((MonitorSnapshot monitor) => monitor.id == _selectedMonitorId)) {
          _selectedMonitorId = monitors.isEmpty ? null : monitors.first.id;
        }
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _bannerMessage = '刷新显示器失败: $error';
        _bannerIsError = true;
      });
    }
  }

  MonitorSnapshot? get _selectedMonitor {
    if (_selectedMonitorId == null) {
      return _monitors.isEmpty ? null : _monitors.first;
    }
    for (final MonitorSnapshot monitor in _monitors) {
      if (monitor.id == _selectedMonitorId) {
        return monitor;
      }
    }
    return _monitors.isEmpty ? null : _monitors.first;
  }

  List<MonitorSnapshot> get _filteredMonitors {
    final String query = _monitorQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _monitors;
    }
    return _monitors.where((MonitorSnapshot monitor) {
      final ParsedCapabilities? capabilities = monitor.capabilitiesData;
      final String haystack = <String>[
        monitor.description,
        capabilities?.model ?? '',
        capabilities?.displayType ?? '',
        capabilities?.mccsVersion ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _refreshSelectedMonitor() async {
    final MonitorSnapshot? selected = _selectedMonitor;
    if (selected == null) {
      return;
    }
    try {
      final MonitorSnapshot updated = await _service.refreshMonitor(selected.id);
      setState(() {
        _monitors = _monitors
            .map((MonitorSnapshot monitor) => monitor.id == updated.id ? updated : monitor)
            .toList();
        _bannerMessage = '已刷新 ${updated.description}';
        _bannerIsError = false;
      });
    } catch (error) {
      setState(() {
        _bannerMessage = '刷新显示器失败: $error';
        _bannerIsError = true;
      });
    }
  }

  Future<void> _saveSelectedMonitor() async {
    final MonitorSnapshot? selected = _selectedMonitor;
    if (selected == null) {
      return;
    }
    final String busyKey = '${selected.id}-save';
    setState(() {
      _busyKeys.add(busyKey);
    });
    try {
      await _service.saveSettings(selected.id);
      await _refreshSelectedMonitor();
      setState(() {
        _bannerMessage = '已请求显示器保存当前设置';
        _bannerIsError = false;
      });
    } catch (error) {
      setState(() {
        _bannerMessage = '$error';
        _bannerIsError = true;
      });
    } finally {
      setState(() {
        _busyKeys.remove(busyKey);
      });
    }
  }

  Future<void> _applyFeature(
    MonitorFeatureState feature,
    int value, {
    String? monitorId,
    bool preserveSliderDraft = false,
    bool showSuccessBanner = true,
  }) async {
    final String? resolvedMonitorId = monitorId ?? _selectedMonitor?.id;
    if (resolvedMonitorId == null) {
      return;
    }
    final String key = _featureKey(resolvedMonitorId, feature.code);
    setState(() {
      _busyKeys.add(key);
      if (showSuccessBanner) {
        _bannerMessage = null;
      }
    });
    try {
      await _service.setFeatureValue(resolvedMonitorId, feature.code, value);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final VcpReadResult readBack = await _service.readFeatureValue(resolvedMonitorId, feature.code);
      final MonitorSnapshot? currentMonitor = _monitorById(resolvedMonitorId);
      if (currentMonitor == null) {
        return;
      }
      final MonitorFeatureState currentFeature =
          _featureForMonitor(currentMonitor, feature.code) ?? feature;
      final MonitorSnapshot updated = _mergeFeatureUpdate(
        currentMonitor,
        currentFeature,
        value,
        readBack.success ? readBack : null,
      );
      setState(() {
        _monitors = _monitors
            .map((MonitorSnapshot monitor) => monitor.id == updated.id ? updated : monitor)
            .toList();
        if (showSuccessBanner) {
          _bannerMessage = '已写入 ${currentFeature.name} = $value';
          _bannerIsError = false;
        }
        if (!preserveSliderDraft) {
          _sliderDrafts.remove(key);
        }
      });
    } catch (error) {
      setState(() {
        _bannerMessage = '写入 ${feature.name} 失败: $error';
        _bannerIsError = true;
      });
    } finally {
      setState(() {
        _busyKeys.remove(key);
      });
    }
  }

  void _onSliderChanged(String monitorId, MonitorFeatureState feature, double value) {
    final String key = _featureKey(monitorId, feature.code);
    setState(() {
      _sliderDrafts[key] = value;
    });
    _pendingSliderValues[key] = value.round();
    _scheduleSliderCommit(monitorId, feature.code, flushNowIfPossible: true);
  }

  void _onSliderChangeEnd(String monitorId, MonitorFeatureState feature, double value) {
    final String key = _featureKey(monitorId, feature.code);
    _pendingSliderValues[key] = value.round();
    _sliderThrottleTimers.remove(key)?.cancel();
    unawaited(
      _commitPendingSliderValue(
        monitorId,
        feature.code,
        force: true,
        preserveSliderDraft: false,
        showSuccessBanner: true,
      ),
    );
  }

  void _scheduleSliderCommit(
    String monitorId,
    int code, {
    required bool flushNowIfPossible,
  }) {
    final String key = _featureKey(monitorId, code);
    if (!_pendingSliderValues.containsKey(key)) {
      return;
    }
    if (_busyKeys.contains(key)) {
      _restartSliderTimer(monitorId, code, _sliderThrottleInterval);
      return;
    }
    final DateTime now = DateTime.now();
    final DateTime? lastCommitAt = _lastSliderCommitAt[key];
    final Duration elapsed =
        lastCommitAt == null ? _sliderThrottleInterval : now.difference(lastCommitAt);
    if (flushNowIfPossible && elapsed >= _sliderThrottleInterval) {
      unawaited(
        _commitPendingSliderValue(
          monitorId,
          code,
          preserveSliderDraft: true,
          showSuccessBanner: false,
        ),
      );
      return;
    }
    final Duration delay =
        elapsed >= _sliderThrottleInterval ? _sliderThrottleInterval : _sliderThrottleInterval - elapsed;
    _restartSliderTimer(monitorId, code, delay);
  }

  void _restartSliderTimer(String monitorId, int code, Duration delay) {
    final String key = _featureKey(monitorId, code);
    _sliderThrottleTimers.remove(key)?.cancel();
    _sliderThrottleTimers[key] = Timer(delay, () {
      unawaited(
        _commitPendingSliderValue(
          monitorId,
          code,
          preserveSliderDraft: true,
          showSuccessBanner: false,
        ),
      );
    });
  }

  Future<void> _commitPendingSliderValue(
    String monitorId,
    int code, {
    bool force = false,
    required bool preserveSliderDraft,
    required bool showSuccessBanner,
  }) async {
    final String key = _featureKey(monitorId, code);
    final int? pendingValue = _pendingSliderValues[key];
    if (pendingValue == null) {
      return;
    }
    if (_busyKeys.contains(key)) {
      _restartSliderTimer(monitorId, code, _sliderThrottleInterval);
      return;
    }
    final DateTime now = DateTime.now();
    final DateTime? lastCommitAt = _lastSliderCommitAt[key];
    if (!force && lastCommitAt != null) {
      final Duration elapsed = now.difference(lastCommitAt);
      if (elapsed < _sliderThrottleInterval) {
        _restartSliderTimer(monitorId, code, _sliderThrottleInterval - elapsed);
        return;
      }
    }
    final MonitorSnapshot? monitor = _monitorById(monitorId);
    final MonitorFeatureState? feature = monitor == null ? null : _featureForMonitor(monitor, code);
    if (feature == null) {
      _pendingSliderValues.remove(key);
      _sliderThrottleTimers.remove(key)?.cancel();
      return;
    }
    _pendingSliderValues.remove(key);
    _sliderThrottleTimers.remove(key)?.cancel();
    _lastSliderCommitAt[key] = now;
    await _applyFeature(
      feature,
      pendingValue,
      monitorId: monitorId,
      preserveSliderDraft: preserveSliderDraft,
      showSuccessBanner: showSuccessBanner,
    );
  }

  MonitorSnapshot? _monitorById(String monitorId) {
    for (final MonitorSnapshot monitor in _monitors) {
      if (monitor.id == monitorId) {
        return monitor;
      }
    }
    return null;
  }

  MonitorFeatureState? _featureForMonitor(MonitorSnapshot monitor, int code) {
    for (final MonitorFeatureState feature in monitor.features) {
      if (feature.code == code) {
        return feature;
      }
    }
    for (final MonitorFeatureState feature in monitor.unknownFeatures) {
      if (feature.code == code) {
        return feature;
      }
    }
    return null;
  }

  void _cancelAllSliderTimers() {
    for (final Timer timer in _sliderThrottleTimers.values) {
      timer.cancel();
    }
    _sliderThrottleTimers.clear();
    _pendingSliderValues.clear();
    _lastSliderCommitAt.clear();
  }

  MonitorSnapshot _mergeFeatureUpdate(
    MonitorSnapshot monitor,
    MonitorFeatureState feature,
    int writtenValue,
    VcpReadResult? readBack,
  ) {
    final VcpReadResult fallbackRead =
        (feature.readResult ?? const VcpReadResult(success: true)).copyWith(
      success: true,
      currentValue: writtenValue,
      maximumValue: readBack?.maximumValue ?? feature.maximumValue,
      codeType: readBack?.codeType ?? feature.readResult?.codeType,
      windowsError: null,
    );
    final VcpReadResult mergedRead = readBack ?? fallbackRead;

    List<MonitorFeatureState> updateFeatureList(List<MonitorFeatureState> source) {
      return source.map((MonitorFeatureState item) {
        if (item.code != feature.code) {
          return item;
        }
        return item.copyWith(
          supported: true,
          readResult: mergedRead,
        );
      }).toList();
    }

    return monitor.copyWith(
      features: updateFeatureList(monitor.features),
      unknownFeatures: updateFeatureList(monitor.unknownFeatures),
    );
  }

  Future<void> _showNumericDialog(MonitorFeatureState feature) async {
    final TextEditingController controller = TextEditingController(
      text: feature.currentValue?.toString() ?? '',
    );
    final int? result = await showCupertinoDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(feature.name),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupertinoTextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              placeholder: '输入数值',
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text.trim())),
              child: const Text('写入'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result != null) {
      await _applyFeature(feature, result);
    }
  }

  Future<void> _showCapabilitiesDialog(MonitorSnapshot monitor) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('能力字符串'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: 560,
              child: _ReadOnlyCodeBlock(
                text: monitor.capabilities ?? '显示器没有返回 capability string。',
                minLines: 10,
                maxLines: 10,
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  List<MonitorFeatureState> _filterFeatures(List<MonitorFeatureState> features) {
    final String query = _featureQuery.trim().toLowerCase();
    return features.where((MonitorFeatureState feature) {
      if (!_showUnsupported && !feature.supported) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final String haystack = <String>[
        feature.name,
        feature.category,
        feature.description,
        '0x${feature.code.toRadixString(16).padLeft(2, '0').toLowerCase()}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Map<String, List<MonitorFeatureState>> _groupVisibleFeatures(MonitorSnapshot monitor) {
    final Map<String, List<MonitorFeatureState>> grouped = <String, List<MonitorFeatureState>>{};
    for (final MonitorFeatureState feature in _filterFeatures(monitor.features)) {
      grouped.putIfAbsent(feature.category, () => <MonitorFeatureState>[]).add(feature);
    }
    return grouped;
  }

  // ignore: unused_element
  Widget _buildMonitorPane(MonitorSnapshot? selected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<MonitorSnapshot> monitors = _filteredMonitors;
    return ColoredBox(
      color: isDark ? _AppPalette.sidebarDark : _AppPalette.sidebarLight,
      child: Column(
        children: <Widget>[
          _buildSidebarHeader(),
          Expanded(
            child: monitors.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '未检测到显示器',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ),
                  )
                : CupertinoScrollbar(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                      itemCount: monitors.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MonitorSnapshot monitor = monitors[index];
                        final bool isSelected = monitor.id == selected?.id;
                        return _buildMonitorListItem(monitor, isSelected);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? _AppPalette.separatorDark : _AppPalette.separatorLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              _TrafficLights(),
              SizedBox(width: 12),
              Text(
                'Displays',
                style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'DDC/CI',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          CupertinoSearchTextField(
            placeholder: '搜索显示器',
            onChanged: (String value) {
              setState(() {
                _monitorQuery = value;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            '${_filteredMonitors.length} 台显示器',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          if (_bannerMessage != null) ...<Widget>[
            const SizedBox(height: 10),
            _banner(_bannerMessage!, isError: _bannerIsError),
          ],
        ],
      ),
    );
  }

  Widget _buildMonitorListItem(MonitorSnapshot monitor, bool isSelected) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _selectedMonitorId = monitor.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A84FF).withValues(alpha: 0.10) : const Color(0x00FFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0A84FF) : const Color(0x14000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.desktopcomputer,
                size: 16,
                color: isSelected ? CupertinoColors.white : CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    monitor.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF0B57D0) : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${monitor.capabilitiesData?.model ?? '未知型号'} · ${monitor.features.where((MonitorFeatureState item) => item.supported).length} 项',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFF0B57D0),
              ),
            if (monitor.errorMessage != null && !isSelected)
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 16,
                color: CupertinoColors.systemRed,
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSettingsPane(MonitorSnapshot? selected) {
    if (selected == null) {
      return Container(
        color: const Color(0xFFF7F8FA),
        child: const Center(
          child: Text(
            '没有可显示的设备',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final Map<String, List<MonitorFeatureState>> grouped = _groupVisibleFeatures(selected);
    final List<MonitorFeatureState> unknownFeatures = _filterFeatures(selected.unknownFeatures);

    return Container(
      color: const Color(0xFFF7F8FA),
      child: Column(
        children: <Widget>[
          _buildContentToolbar(selected, grouped, unknownFeatures),
          Expanded(
            child: CupertinoScrollbar(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: <Widget>[
                  _buildSelectedMonitorHeader(selected, grouped, unknownFeatures),
                  const SizedBox(height: 18),
                  for (final String category in grouped.keys) ...<Widget>[
                    _buildCategorySection(selected, category, grouped[category]!),
                    const SizedBox(height: 18),
                  ],
                  if (unknownFeatures.isNotEmpty)
                    _buildCategorySection(selected, '厂商扩展 / 未命名 VCP', unknownFeatures),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentToolbar(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    final int visibleCount = grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length) +
        unknownFeatures.length;
    final bool saveBusy = _busyKeys.contains('${monitor.id}-save');
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        border: Border(
          left: BorderSide(color: Color(0x12000000)),
          bottom: BorderSide(color: Color(0x12000000)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  monitor.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: 2),
                Text(
                  'Settings',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 260,
            child: CupertinoSearchTextField(
              placeholder: '搜索设置项',
              onChanged: (String value) {
                setState(() {
                  _featureQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: _showUnsupported ? const Color(0xFF0A84FF) : const Color(0xFFF3F4F6),
            onPressed: () {
              setState(() {
                _showUnsupported = !_showUnsupported;
              });
            },
            child: Text(
              _showUnsupported ? '显示全部' : '隐藏不可用',
              style: TextStyle(
                color: _showUnsupported ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _toolbarButton(
            icon: CupertinoIcons.refresh,
            onPressed: () => _refreshSelectedMonitor(),
          ),
          const SizedBox(width: 8),
          _toolbarButton(
            icon: CupertinoIcons.arrow_down_circle,
            busy: saveBusy,
            onPressed: saveBusy ? null : () => _saveSelectedMonitor(),
          ),
          const SizedBox(width: 8),
          _toolbarButton(
            icon: CupertinoIcons.info_circle,
            onPressed: () => _showCapabilitiesDialog(monitor),
          ),
          const SizedBox(width: 10),
          _capsule('可见项', visibleCount.toString()),
        ],
      ),
    );
  }

  Widget _buildSelectedMonitorHeader(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  monitor.description,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              _capsule('型号', monitor.capabilitiesData?.model ?? '未知'),
              _capsule('类型', monitor.capabilitiesData?.displayType ?? '未知'),
              _capsule('功能分组', grouped.length.toString()),
              _capsule('可见项目', grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length).toString()),
              if (unknownFeatures.isNotEmpty) _capsule('扩展 VCP', unknownFeatures.length.toString()),
              _capsule(
                '水平同步',
                monitor.horizontalFrequency == null ? '未知' : '${monitor.horizontalFrequency} Hz',
              ),
              _capsule(
                '垂直同步',
                monitor.verticalFrequency == null ? '未知' : '${monitor.verticalFrequency} Hz',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    MonitorSnapshot monitor,
    String category,
    List<MonitorFeatureState> features,
  ) {
    return MacosSettingsGroup(
      title: category,
      children: features
          .map((MonitorFeatureState feature) => _buildFeatureRow(monitor, feature))
          .toList(),
    );
  }

  Widget _buildFeatureRow(MonitorSnapshot monitor, MonitorFeatureState feature) {
    final bool enabled = feature.supported;
    final bool busy = _busyKeys.contains(_featureKey(monitor.id, feature.code));
    return MacosSettingsTile(
      label: feature.name,
      subtitle: busy ? '${_featureSummaryZh(feature)} · 正在写入' : _featureSummaryZh(feature),
      icon: _featureIcon(feature),
      iconColor: _featureIconColor(feature),
      enabled: enabled,
      trailing: SizedBox(
        width: 320,
        child: _buildFeatureControlMac(monitor.id, feature, enabled: enabled && !busy),
      ),
    );
  }

  Widget _buildFeatureControlMac(
    String monitorId,
    MonitorFeatureState feature, {
    required bool enabled,
  }) {
    switch (feature.kind) {
      case VcpControlKind.action:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(
              text: feature.currentValue == null ? 'Command' : 'Now ${feature.currentValue}',
            ),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: 'Run',
              onPressed: enabled
                  ? () => _applyFeature(feature, feature.definition?.actionValue ?? 1)
                  : null,
            ),
          ],
        );
      case VcpControlKind.toggle:
        final bool isOn = (feature.currentValue ?? 0) == 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: isOn ? 'On' : 'Off'),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.92,
              child: CupertinoSwitch(
                value: isOn,
                onChanged: enabled ? (bool value) => _applyFeature(feature, value ? 1 : 2) : null,
              ),
            ),
          ],
        );
      case VcpControlKind.discrete:
        final int? currentValue = feature.currentValue;
        final String label = currentValue == null ? 'Select' : _optionLabel(feature, currentValue);
        final List<int> optionValues = _resolvedOptionValues(feature);
        return MacosPopupMenu<int>(
          value: label,
          items: optionValues,
          itemLabelBuilder: (int item) => _optionLabel(feature, item),
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.continuous:
        final int maxValue = (feature.maximumValue ?? 100).clamp(1, 65535);
        final String key = _featureKey(monitorId, feature.code);
        final double current = (_sliderDrafts[key] ?? (feature.currentValue ?? 0)).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _iconButton(
                  icon: CupertinoIcons.minus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() - 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoSlider(
                    value: current.clamp(0, maxValue.toDouble()),
                    max: maxValue.toDouble(),
                    onChanged: enabled
                        ? (double value) => _onSliderChanged(monitorId, feature, value)
                        : null,
                    onChangeEnd: enabled
                        ? (double value) => _onSliderChangeEnd(monitorId, feature, value)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                _iconButton(
                  icon: CupertinoIcons.plus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() + 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 10),
                MacosValueTag(text: '${current.round()}'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: <Widget>[
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '$maxValue',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                MacosSubtleButton(
                  label: 'Value',
                  onPressed: enabled ? () => _showNumericDialog(feature) : null,
                ),
              ],
            ),
          ],
        );
      case VcpControlKind.numeric:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: feature.currentValue?.toString() ?? 'Unreadable'),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: 'Edit',
              onPressed: enabled ? () => _showNumericDialog(feature) : null,
            ),
          ],
        );
    }
  }

  Widget _buildMonitorPaneMac(MonitorSnapshot? selected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<MonitorSnapshot> monitors = _filteredMonitors;
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? _AppPalette.sidebarDark : _AppPalette.sidebarLight,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.black26 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          _buildSidebarHeaderMac(),
          Expanded(
            child: monitors.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No displays found',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    itemCount: monitors.length,
                    itemBuilder: (BuildContext context, int index) {
                      final MonitorSnapshot monitor = monitors[index];
                      return _buildMonitorListItemZh(
                        monitor,
                        monitor.id == selected?.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeaderMac() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '显示器',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '共 ${_filteredMonitors.length} 台',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildMonitorListItemMac(MonitorSnapshot monitor, bool isSelected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int supportedCount =
        monitor.features.where((MonitorFeatureState item) => item.supported).length;
    final String model = monitor.capabilitiesData?.model ?? '未知型号';
    final Color foregroundColor =
        isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87);
    final Color secondaryColor =
        isSelected ? Colors.white.withValues(alpha: 0.76) : (isDark ? Colors.white38 : Colors.black45);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonitorId = monitor.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _AppPalette.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              CupertinoIcons.desktopcomputer,
              size: 18,
              color: isSelected ? Colors.white : (isDark ? Colors.blueAccent : _AppPalette.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    monitor.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$model · $supportedCount controls',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (monitor.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 14,
                  color: isSelected ? Colors.white : CupertinoColors.systemRed,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPaneMac(MonitorSnapshot? selected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDark ? _AppPalette.contentDark : _AppPalette.contentLight;
    final String title = selected?.description ?? '显示器';

    if (selected == null) {
      return ColoredBox(
        color: background,
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              automaticallyImplyLeading: false,
              largeTitle: Text(
                title,
                style: TextStyle(
                  fontFamily: '.AppleSystemUIFont',
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              backgroundColor: Colors.transparent,
              border: null,
              stretch: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
                child: Text(
                  '当前没有可用的 DDC/CI 显示器。',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final Map<String, List<MonitorFeatureState>> grouped = _groupVisibleFeatures(selected);
    final List<MonitorFeatureState> unknownFeatures = _filterFeatures(selected.unknownFeatures);

    return ColoredBox(
      color: background,
      child: CustomScrollView(
        key: ValueKey<String>('${selected.id}-$_featureQuery-$_showUnsupported'),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            automaticallyImplyLeading: false,
            largeTitle: Text(
              title,
              style: TextStyle(
                fontFamily: '.AppleSystemUIFont',
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: Colors.transparent,
            border: null,
            stretch: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_bannerMessage != null) ...<Widget>[
                    _banner(_bannerMessage!, isError: _bannerIsError),
                    const SizedBox(height: 20),
                  ],
                  _buildToolsGroupZh(selected, grouped, unknownFeatures),
                  _buildDetailsGroupZh(selected, grouped, unknownFeatures),
                  if (grouped.isEmpty && unknownFeatures.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        '当前显示器没有可展示的控制项。',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  for (final String category in grouped.keys)
                    _buildCategorySectionZh(selected, category, grouped[category]!),
                  if (unknownFeatures.isNotEmpty)
                    _buildCategorySectionZh(
                      selected,
                      '厂商扩展 / 未命名 VCP',
                      unknownFeatures,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildToolsGroupMac(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    final int visibleCount =
        grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length) +
            unknownFeatures.length;
    final bool saveBusy = _busyKeys.contains('${monitor.id}-save');
    return MacosSettingsGroup(
      title: 'Tools',
      children: <Widget>[
        MacosSettingsTile(
          label: 'Search controls',
          subtitle: 'Filter by control name, category, description or VCP code.',
          icon: CupertinoIcons.search,
          iconColor: const Color(0xFF8E8E93),
          trailing: SizedBox(
            width: 240,
            child: CupertinoSearchTextField(
              placeholder: 'Search controls',
              onChanged: (String value) {
                setState(() {
                  _featureQuery = value;
                });
              },
            ),
          ),
        ),
        MacosSettingsTile(
          label: 'Show unsupported controls',
          subtitle: 'Keep unsupported VCP codes visible, but leave them disabled.',
          icon: CupertinoIcons.eye,
          iconColor: _AppPalette.blue,
          trailing: CupertinoSwitch(
            value: _showUnsupported,
            onChanged: (bool value) {
              setState(() {
                _showUnsupported = value;
              });
            },
          ),
        ),
        MacosSettingsTile(
          label: 'Visible controls',
          subtitle: '${grouped.length} categories in the current view.',
          icon: CupertinoIcons.number_circle,
          iconColor: const Color(0xFF30D158),
          trailing: MacosValueTag(text: '$visibleCount'),
        ),
        MacosSettingsTile(
          label: 'Refresh values',
          subtitle: 'Read the current DDC/CI values from this monitor again.',
          icon: CupertinoIcons.refresh,
          iconColor: const Color(0xFFFF9F0A),
          trailing: MacosSubtleButton(
            label: 'Refresh',
            icon: CupertinoIcons.refresh,
            onPressed: _refreshSelectedMonitor,
          ),
        ),
        MacosSettingsTile(
          label: 'Save to monitor',
          subtitle: 'Request the display to persist its current configuration.',
          icon: CupertinoIcons.arrow_down_circle,
          iconColor: const Color(0xFF5856D6),
          trailing: MacosSubtleButton(
            label: saveBusy ? 'Saving' : 'Save',
            icon: CupertinoIcons.arrow_down_circle,
            busy: saveBusy,
            onPressed: saveBusy ? null : _saveSelectedMonitor,
          ),
        ),
        MacosSettingsTile(
          label: 'Capabilities string',
          subtitle: 'Inspect the raw capability string reported by the monitor.',
          icon: CupertinoIcons.info_circle,
          iconColor: const Color(0xFFFF375F),
          trailing: MacosSubtleButton(
            label: 'View',
            icon: CupertinoIcons.doc_text_search,
            onPressed: () => _showCapabilitiesDialog(monitor),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDetailsGroupMac(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    final int visibleCount =
        grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length) +
            unknownFeatures.length;
    return MacosSettingsGroup(
      title: 'Display Details',
      children: <Widget>[
        _buildInfoTileMac(
          label: 'Model',
          subtitle: 'Reported by the monitor capabilities string.',
          icon: CupertinoIcons.tag,
          iconColor: const Color(0xFF8E8E93),
          value: monitor.capabilitiesData?.model ?? 'Unknown',
        ),
        _buildInfoTileMac(
          label: 'Display type',
          subtitle: 'Decoded from the MCCS capabilities block.',
          icon: CupertinoIcons.rectangle_on_rectangle,
          iconColor: const Color(0xFF32ADE6),
          value: monitor.capabilitiesData?.displayType ?? 'Unknown',
        ),
        _buildInfoTileMac(
          label: 'MCCS version',
          subtitle: 'Version advertised through DDC/CI.',
          icon: CupertinoIcons.doc_plaintext,
          iconColor: const Color(0xFFFF9F0A),
          value: monitor.capabilitiesData?.mccsVersion ?? 'Unknown',
        ),
        _buildInfoTileMac(
          label: 'Visible categories',
          subtitle: 'Settings groups currently shown for this display.',
          icon: CupertinoIcons.square_grid_2x2,
          iconColor: const Color(0xFF30D158),
          value: '${grouped.length}',
        ),
        _buildInfoTileMac(
          label: 'Visible controls',
          subtitle: 'Count after applying the current filter.',
          icon: CupertinoIcons.slider_horizontal_3,
          iconColor: _AppPalette.blue,
          value: '$visibleCount',
        ),
        _buildInfoTileMac(
          label: 'Horizontal sync',
          subtitle: 'Reported timing information from Windows.',
          icon: CupertinoIcons.arrow_left_right,
          iconColor: const Color(0xFF5E5CE6),
          value: monitor.horizontalFrequency == null ? 'Unknown' : '${monitor.horizontalFrequency} Hz',
        ),
        _buildInfoTileMac(
          label: 'Vertical sync',
          subtitle: 'Reported timing information from Windows.',
          icon: CupertinoIcons.arrow_up_down,
          iconColor: const Color(0xFFBF5AF2),
          value: monitor.verticalFrequency == null ? 'Unknown' : '${monitor.verticalFrequency} Hz',
        ),
        if (unknownFeatures.isNotEmpty)
          _buildInfoTileMac(
            label: 'Vendor specific VCP',
            subtitle: 'Extra controls that are not mapped to the known catalog.',
            icon: CupertinoIcons.question_circle,
            iconColor: const Color(0xFFFF375F),
            value: '${unknownFeatures.length}',
          ),
        if (monitor.errorMessage != null)
          _buildInfoTileMac(
            label: 'Display status',
            subtitle: 'The monitor reported an access problem during the last query.',
            icon: CupertinoIcons.exclamationmark_triangle_fill,
            iconColor: const Color(0xFFFF3B30),
            value: monitor.errorMessage!,
          ),
      ],
    );
  }

  Widget _buildInfoTileMac({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return MacosSettingsTile(
      label: label,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCategorySectionMac(
    MonitorSnapshot monitor,
    String category,
    List<MonitorFeatureState> features,
  ) {
    return MacosSettingsGroup(
      title: category,
      children: features
          .map((MonitorFeatureState feature) => _buildFeatureRowMac(monitor, feature))
          .toList(),
    );
  }

  Widget _buildFeatureRowMac(MonitorSnapshot monitor, MonitorFeatureState feature) {
    final bool enabled = feature.supported;
    final bool busy = _busyKeys.contains(_featureKey(monitor.id, feature.code));
    return MacosSettingsTile(
      label: feature.name,
      subtitle: busy ? '${_featureSummary(feature)} · Writing…' : _featureSummary(feature),
      icon: _featureIcon(feature),
      iconColor: _featureIconColor(feature),
      enabled: enabled,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: _buildFeatureControlMac2(monitor.id, feature, enabled: enabled && !busy),
      ),
    );
  }

  Widget _buildFeatureControlMac2(
    String monitorId,
    MonitorFeatureState feature, {
    required bool enabled,
  }) {
    switch (feature.kind) {
      case VcpControlKind.action:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(
              text: feature.currentValue == null ? 'Command' : 'Now ${feature.currentValue}',
            ),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: 'Run',
              icon: CupertinoIcons.play_fill,
              onPressed: enabled
                  ? () => _applyFeature(feature, feature.definition?.actionValue ?? 1)
                  : null,
            ),
          ],
        );
      case VcpControlKind.toggle:
        final bool isOn = (feature.currentValue ?? 0) == 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: isOn ? 'On' : 'Off'),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.92,
              child: CupertinoSwitch(
                value: isOn,
                onChanged: enabled ? (bool value) => _applyFeature(feature, value ? 1 : 2) : null,
              ),
            ),
          ],
        );
      case VcpControlKind.discrete:
        final int? currentValue = feature.currentValue;
        final String label = currentValue == null ? 'Select' : _optionLabel(feature, currentValue);
        final List<int> optionValues = _resolvedOptionValues(feature);
        return MacosPopupMenu<int>(
          value: label,
          items: optionValues,
          itemLabelBuilder: (int item) => _optionLabel(feature, item),
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.continuous:
        final int maxValue = (feature.maximumValue ?? 100).clamp(1, 65535);
        final String key = _featureKey(monitorId, feature.code);
        final double current = (_sliderDrafts[key] ?? (feature.currentValue ?? 0)).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _iconButton(
                  icon: CupertinoIcons.minus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() - 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoSlider(
                    value: current.clamp(0, maxValue.toDouble()),
                    max: maxValue.toDouble(),
                    activeColor: _AppPalette.blue,
                    onChanged: enabled
                        ? (double value) => _onSliderChanged(monitorId, feature, value)
                        : null,
                    onChangeEnd: enabled
                        ? (double value) => _onSliderChangeEnd(monitorId, feature, value)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                _iconButton(
                  icon: CupertinoIcons.plus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() + 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 10),
                MacosValueTag(text: '${current.round()}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '$maxValue',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 8),
                MacosSubtleButton(
                  label: 'Value',
                  icon: CupertinoIcons.number,
                  onPressed: enabled ? () => _showNumericDialog(feature) : null,
                ),
              ],
            ),
          ],
        );
      case VcpControlKind.numeric:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: feature.currentValue?.toString() ?? 'Unreadable'),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: 'Edit',
              icon: CupertinoIcons.pencil,
              onPressed: enabled ? () => _showNumericDialog(feature) : null,
            ),
          ],
        );
    }
  }

  Widget _buildMonitorListItemZh(MonitorSnapshot monitor, bool isSelected) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int supportedCount =
        monitor.features.where((MonitorFeatureState item) => item.supported).length;
    final String model = monitor.capabilitiesData?.model ?? '未知型号';
    final Color foregroundColor =
        isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87);
    final Color secondaryColor =
        isSelected ? Colors.white.withValues(alpha: 0.76) : (isDark ? Colors.white38 : Colors.black45);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonitorId = monitor.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _AppPalette.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              CupertinoIcons.desktopcomputer,
              size: 18,
              color: isSelected ? Colors.white : (isDark ? Colors.blueAccent : _AppPalette.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    monitor.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$model · $supportedCount 项控制',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (monitor.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 14,
                  color: isSelected ? Colors.white : CupertinoColors.systemRed,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGroupZh(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    final int visibleCount =
        grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length) +
            unknownFeatures.length;
    final bool saveBusy = _busyKeys.contains('${monitor.id}-save');
    return MacosSettingsGroup(
      title: '操作',
      children: <Widget>[
        MacosSettingsTile(
          label: '不可用项目',
          subtitle: '控制是否显示当前显示器不支持的 VCP 项目。',
          icon: CupertinoIcons.eye,
          iconColor: _AppPalette.blue,
          trailing: MacosPopupMenu<bool>(
            value: _showUnsupported ? '显示' : '隐藏',
            items: const <bool>[false, true],
            itemLabelBuilder: (bool item) => item ? '显示不可用项目' : '隐藏不可用项目',
            selectedItemBuilder: (bool item) => item == _showUnsupported,
            onSelected: (bool value) {
              setState(() {
                _showUnsupported = value;
              });
            },
          ),
        ),
        MacosSettingsTile(
          label: '当前可见项目',
          subtitle: '当前界面共显示 ${grouped.length} 个分类。',
          icon: CupertinoIcons.number_circle,
          iconColor: const Color(0xFF30D158),
          trailing: MacosValueTag(text: '$visibleCount'),
        ),
        MacosSettingsTile(
          label: '刷新显示器',
          subtitle: '重新读取当前显示器的 DDC/CI 数值。',
          icon: CupertinoIcons.refresh,
          iconColor: const Color(0xFFFF9F0A),
          trailing: MacosSubtleButton(
            label: '刷新',
            icon: CupertinoIcons.refresh,
            onPressed: _refreshSelectedMonitor,
          ),
        ),
        MacosSettingsTile(
          label: '保存到显示器',
          subtitle: '请求显示器保存当前设置。',
          icon: CupertinoIcons.arrow_down_circle,
          iconColor: const Color(0xFF5856D6),
          trailing: MacosSubtleButton(
            label: saveBusy ? '保存中' : '保存',
            icon: CupertinoIcons.arrow_down_circle,
            busy: saveBusy,
            onPressed: saveBusy ? null : _saveSelectedMonitor,
          ),
        ),
        MacosSettingsTile(
          label: '能力字符串',
          subtitle: '查看显示器返回的原始 capabilities 内容。',
          icon: CupertinoIcons.info_circle,
          iconColor: const Color(0xFFFF375F),
          trailing: MacosSubtleButton(
            label: '查看',
            icon: CupertinoIcons.doc_text_search,
            onPressed: () => _showCapabilitiesDialog(monitor),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGroupZh(
    MonitorSnapshot monitor,
    Map<String, List<MonitorFeatureState>> grouped,
    List<MonitorFeatureState> unknownFeatures,
  ) {
    final int visibleCount =
        grouped.values.fold<int>(0, (int sum, List<MonitorFeatureState> items) => sum + items.length) +
            unknownFeatures.length;
    return MacosSettingsGroup(
      title: '显示器信息',
      children: <Widget>[
        _buildInfoTileZh(
          label: '型号',
          subtitle: '来自显示器上报的 capabilities 字符串。',
          icon: CupertinoIcons.tag,
          iconColor: const Color(0xFF8E8E93),
          value: monitor.capabilitiesData?.model ?? '未知',
        ),
        _buildInfoTileZh(
          label: '显示类型',
          subtitle: '根据 MCCS capabilities 内容解析。',
          icon: CupertinoIcons.rectangle_on_rectangle,
          iconColor: const Color(0xFF32ADE6),
          value: monitor.capabilitiesData?.displayType ?? '未知',
        ),
        _buildInfoTileZh(
          label: 'MCCS 版本',
          subtitle: '显示器通过 DDC/CI 声明的版本。',
          icon: CupertinoIcons.doc_plaintext,
          iconColor: const Color(0xFFFF9F0A),
          value: monitor.capabilitiesData?.mccsVersion ?? '未知',
        ),
        _buildInfoTileZh(
          label: '可见分类',
          subtitle: '当前显示的设置分组数量。',
          icon: CupertinoIcons.square_grid_2x2,
          iconColor: const Color(0xFF30D158),
          value: '${grouped.length}',
        ),
        _buildInfoTileZh(
          label: '可见控制项',
          subtitle: '当前界面展示的控制项总数。',
          icon: CupertinoIcons.slider_horizontal_3,
          iconColor: _AppPalette.blue,
          value: '$visibleCount',
        ),
        _buildInfoTileZh(
          label: '水平同步',
          subtitle: '来自 Windows 的时序信息。',
          icon: CupertinoIcons.arrow_left_right,
          iconColor: const Color(0xFF5E5CE6),
          value: monitor.horizontalFrequency == null ? '未知' : '${monitor.horizontalFrequency} Hz',
        ),
        _buildInfoTileZh(
          label: '垂直同步',
          subtitle: '来自 Windows 的时序信息。',
          icon: CupertinoIcons.arrow_up_down,
          iconColor: const Color(0xFFBF5AF2),
          value: monitor.verticalFrequency == null ? '未知' : '${monitor.verticalFrequency} Hz',
        ),
        if (unknownFeatures.isNotEmpty)
          _buildInfoTileZh(
            label: '厂商扩展 VCP',
            subtitle: '未映射到内置目录的扩展控制项。',
            icon: CupertinoIcons.question_circle,
            iconColor: const Color(0xFFFF375F),
            value: '${unknownFeatures.length}',
          ),
        if (monitor.errorMessage != null)
          _buildInfoTileZh(
            label: '显示器状态',
            subtitle: '最近一次读取时检测到访问异常。',
            icon: CupertinoIcons.exclamationmark_triangle_fill,
            iconColor: const Color(0xFFFF3B30),
            value: monitor.errorMessage!,
          ),
      ],
    );
  }

  Widget _buildInfoTileZh({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return MacosSettingsTile(
      label: label,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySectionZh(
    MonitorSnapshot monitor,
    String category,
    List<MonitorFeatureState> features,
  ) {
    return MacosSettingsGroup(
      title: category,
      children: features
          .map((MonitorFeatureState feature) => _buildFeatureRowFinal(monitor, feature))
          .toList(),
    );
  }

  // ignore: unused_element
  Widget _buildFeatureRowZh(MonitorSnapshot monitor, MonitorFeatureState feature) {
    final bool enabled = feature.supported;
    final bool busy = _busyKeys.contains(_featureKey(monitor.id, feature.code));
    return MacosSettingsTile(
      label: feature.name,
      subtitle: busy ? '${_featureSummary(feature)} · 正在写入' : _featureSummary(feature),
      icon: _featureIcon(feature),
      iconColor: _featureIconColor(feature),
      enabled: enabled,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: _buildFeatureControlZh(monitor.id, feature, enabled: enabled && !busy),
      ),
    );
  }

  Widget _buildFeatureControlZh(
    String monitorId,
    MonitorFeatureState feature, {
    required bool enabled,
  }) {
    switch (feature.kind) {
      case VcpControlKind.action:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(
              text: feature.currentValue == null ? '命令' : '当前 ${feature.currentValue}',
            ),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: '执行',
              icon: CupertinoIcons.play_fill,
              onPressed: enabled
                  ? () => _applyFeature(feature, feature.definition?.actionValue ?? 1)
                  : null,
            ),
          ],
        );
      case VcpControlKind.toggle:
        final int currentValue = (feature.currentValue ?? 0) == 1 ? 1 : 2;
        return MacosPopupMenu<int>(
          value: currentValue == 1 ? '开启' : '关闭',
          items: const <int>[1, 2],
          itemLabelBuilder: (int item) => item == 1 ? '开启' : '关闭',
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.discrete:
        final int? currentValue = feature.currentValue;
        final String label = currentValue == null ? '请选择' : _optionLabel(feature, currentValue);
        final List<int> optionValues = _resolvedOptionValues(feature);
        return MacosPopupMenu<int>(
          value: label,
          items: optionValues,
          itemLabelBuilder: (int item) => _optionLabel(feature, item),
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.continuous:
        final int maxValue = (feature.maximumValue ?? 100).clamp(1, 65535);
        final String key = _featureKey(monitorId, feature.code);
        final double current = (_sliderDrafts[key] ?? (feature.currentValue ?? 0)).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _iconButton(
                  icon: CupertinoIcons.minus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() - 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF1F2937),
                      inactiveTrackColor: const Color(0xFF4B5563),
                      thumbColor: Colors.white,
                      overlayColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: current.clamp(0, maxValue.toDouble()),
                      max: maxValue.toDouble(),
                      onChanged: enabled
                          ? (double value) => _onSliderChanged(monitorId, feature, value)
                          : null,
                      onChangeEnd: enabled
                          ? (double value) => _onSliderChangeEnd(monitorId, feature, value)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _iconButtonDark(
                  icon: CupertinoIcons.minus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() - 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 8),
                _iconButtonDark(
                  icon: CupertinoIcons.plus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() + 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 10),
                _InlineNumberField(
                  value: current.round(),
                  enabled: enabled,
                  onSubmitted: (int value) {
                    final int next = value.clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '$maxValue',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ],
        );
      case VcpControlKind.numeric:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: feature.currentValue?.toString() ?? '不可读'),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: '编辑',
              icon: CupertinoIcons.pencil,
              onPressed: enabled ? () => _showNumericDialog(feature) : null,
            ),
          ],
        );
    }
  }

  Widget _buildFeatureRowFinal(MonitorSnapshot monitor, MonitorFeatureState feature) {
    final bool enabled = feature.supported;
    final bool busy = _busyKeys.contains(_featureKey(monitor.id, feature.code));
    return MacosSettingsTile(
      label: feature.name,
      subtitle: busy ? '${_featureSummaryZh(feature)} · 正在写入' : _featureSummaryZh(feature),
      icon: _featureIcon(feature),
      iconColor: _featureIconColor(feature),
      enabled: enabled,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: _buildFeatureControlFinal(monitor.id, feature, enabled: enabled && !busy),
      ),
    );
  }

  Widget _buildFeatureControlFinal(
    String monitorId,
    MonitorFeatureState feature, {
    required bool enabled,
  }) {
    switch (feature.kind) {
      case VcpControlKind.action:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(
              text: feature.currentValue == null ? '命令' : '当前 ${feature.currentValue}',
            ),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: '执行',
              icon: CupertinoIcons.play_fill,
              onPressed: enabled
                  ? () => _applyFeature(feature, feature.definition?.actionValue ?? 1)
                  : null,
            ),
          ],
        );
      case VcpControlKind.toggle:
        final int currentValue = (feature.currentValue ?? 0) == 1 ? 1 : 2;
        return MacosPopupMenu<int>(
          value: currentValue == 1 ? '开启' : '关闭',
          items: const <int>[1, 2],
          itemLabelBuilder: (int item) => item == 1 ? '开启' : '关闭',
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.discrete:
        final int? currentValue = feature.currentValue;
        final String label = currentValue == null ? '请选择' : _optionLabel(feature, currentValue);
        final List<int> optionValues = _resolvedOptionValues(feature);
        return MacosPopupMenu<int>(
          value: label,
          items: optionValues,
          itemLabelBuilder: (int item) => _optionLabel(feature, item),
          selectedItemBuilder: (int item) => item == currentValue,
          enabled: enabled,
          onSelected: enabled
              ? (int item) {
                  unawaited(_applyFeature(feature, item));
                }
              : (_) {},
        );
      case VcpControlKind.continuous:
        final int maxValue = (feature.maximumValue ?? 100).clamp(1, 65535);
        final String key = _featureKey(monitorId, feature.code);
        final double current = (_sliderDrafts[key] ?? (feature.currentValue ?? 0)).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _iconButtonDark(
                  icon: CupertinoIcons.minus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() - 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF111827),
                      inactiveTrackColor: const Color(0xFF4B5563),
                      thumbColor: Colors.white,
                      overlayColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: current.clamp(0, maxValue.toDouble()),
                      max: maxValue.toDouble(),
                      onChanged: enabled
                          ? (double value) => _onSliderChanged(monitorId, feature, value)
                          : null,
                      onChangeEnd: enabled
                          ? (double value) => _onSliderChangeEnd(monitorId, feature, value)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _iconButtonDark(
                  icon: CupertinoIcons.plus,
                  enabled: enabled,
                  onPressed: () {
                    final int next = (current.round() + 1).clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
                const SizedBox(width: 10),
                _InlineNumberField(
                  value: current.round(),
                  enabled: enabled,
                  onSubmitted: (int value) {
                    final int next = value.clamp(0, maxValue);
                    _onSliderChanged(monitorId, feature, next.toDouble());
                    _onSliderChangeEnd(monitorId, feature, next.toDouble());
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '$maxValue',
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ],
        );
      case VcpControlKind.numeric:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            MacosValueTag(text: feature.currentValue?.toString() ?? '不可读'),
            const SizedBox(width: 8),
            MacosSubtleButton(
              label: '编辑',
              icon: CupertinoIcons.pencil,
              onPressed: enabled ? () => _showNumericDialog(feature) : null,
            ),
          ],
        );
    }
  }

  String _featureSummaryZh(MonitorFeatureState feature) {
    final String code = 'VCP 0x${feature.code.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    if (!feature.supported) {
      return '$code · 当前显示器不支持';
    }
    if (feature.currentValue != null && feature.maximumValue != null) {
      return '$code · ${feature.currentValue} / ${feature.maximumValue}';
    }
    if (feature.currentValue != null) {
      return '$code · ${feature.currentValue}';
    }
    return '$code · 当前值不可用';
  }

  Widget _iconButtonDark({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(30, 30),
      color: const Color(0xFF1F2937),
      disabledColor: const Color(0xFF4B5563),
      onPressed: enabled ? onPressed : null,
      child: Icon(icon, size: 14, color: CupertinoColors.white),
    );
  }

  IconData _featureIcon(MonitorFeatureState feature) {
    switch (feature.category) {
      case '亮度与对比度':
        return CupertinoIcons.sun_max;
      case '色彩':
        return CupertinoIcons.paintbrush;
      case '输入与电源':
        return CupertinoIcons.rectangle_on_rectangle;
      case '音频':
        return CupertinoIcons.speaker_2;
      case 'OSD 与图像':
        return CupertinoIcons.viewfinder;
      case '几何':
        return CupertinoIcons.arrow_up_left_arrow_down_right;
      case '系统':
        return CupertinoIcons.gear;
      default:
        return CupertinoIcons.slider_horizontal_3;
    }
  }

  String _featureSummary(MonitorFeatureState feature) {
    final String code = 'VCP 0x${feature.code.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    if (!feature.supported) {
      return '$code · Unsupported on this monitor';
    }
    if (feature.currentValue != null && feature.maximumValue != null) {
      return '$code · ${feature.currentValue} / ${feature.maximumValue}';
    }
    if (feature.currentValue != null) {
      return '$code · ${feature.currentValue}';
    }
    return '$code · Current value unavailable';
  }

  Color _featureIconColor(MonitorFeatureState feature) {
    switch (feature.category) {
      case '亮度与对比度':
        return const Color(0xFFFF9F0A);
      case '色彩':
        return const Color(0xFFBF5AF2);
      case '输入与电源':
        return const Color(0xFF32ADE6);
      case '音频':
        return const Color(0xFFFF375F);
      case 'OSD 与图像':
        return const Color(0xFF30D158);
      case '几何':
        return const Color(0xFF5E5CE6);
      case '系统':
        return const Color(0xFF8E8E93);
      default:
        return const Color(0xFF0A84FF);
    }
  }

  Widget _iconButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(30, 30),
      color: const Color(0xFFF3F4F6),
      disabledColor: CupertinoColors.systemGrey5,
      onPressed: enabled ? onPressed : null,
      child: Icon(icon, size: 14, color: CupertinoColors.black),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool busy = false,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(32, 32),
      color: const Color(0xFFF3F4F6),
      disabledColor: CupertinoColors.systemGrey5,
      onPressed: onPressed,
      child: busy
          ? const CupertinoActivityIndicator()
          : Icon(
              icon,
              size: 18,
              color: CupertinoColors.black,
      ),
    );
  }

  Widget _capsule(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _banner(String message, {required bool isError}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEBEA) : const Color(0xFFEAF7EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError ? const Color(0x22FF3B30) : const Color(0x2234C759),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: isError ? const Color(0xFFC9342C) : const Color(0xFF248A3D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MonitorSnapshot? selected = _selectedMonitor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color overlayColor = isDark
        ? Colors.black.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.55);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildMonitorPaneMac(selected),
                Expanded(
                  child: _buildSettingsPaneMac(selected),
                ),
              ],
            ),
            if (_loading)
              Positioned.fill(
                child: ColoredBox(
                  color: overlayColor,
                  child: const Center(
                    child: CupertinoActivityIndicator(radius: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<int> _resolvedOptionValues(MonitorFeatureState feature) {
    final Set<int> values = <int>{...feature.supportedValues};
    for (final VcpValueOption option in feature.definition?.options ?? const <VcpValueOption>[]) {
      values.add(option.value);
    }
    if (feature.currentValue != null) {
      values.add(feature.currentValue!);
    }
    final List<int> sorted = values.toList()..sort();
    return sorted;
  }

  String _optionLabel(MonitorFeatureState feature, int value) {
    for (final VcpValueOption option in feature.definition?.options ?? const <VcpValueOption>[]) {
      if (option.value == value) {
        return '${option.label} (0x${value.toRadixString(16).padLeft(2, '0').toUpperCase()})';
      }
    }
    return '0x${value.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  String _featureKey(String monitorId, int code) => '$monitorId-$code';
}

class _TrafficLights extends StatelessWidget {
  const _TrafficLights();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _TrafficLight(color: Color(0xFFFF5F57)),
        SizedBox(width: 6),
        _TrafficLight(color: Color(0xFFFEBB2E)),
        SizedBox(width: 6),
        _TrafficLight(color: Color(0xFF28C840)),
      ],
    );
  }
}

class _TrafficLight extends StatelessWidget {
  const _TrafficLight({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ReadOnlyCodeBlock extends StatefulWidget {
  const _ReadOnlyCodeBlock({
    required this.text,
    this.minLines = 8,
    this.maxLines = 8,
  });

  final String text;
  final int minLines;
  final int maxLines;

  @override
  State<_ReadOnlyCodeBlock> createState() => _ReadOnlyCodeBlockState();
}

class _ReadOnlyCodeBlockState extends State<_ReadOnlyCodeBlock> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant _ReadOnlyCodeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      readOnly: true,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171C23),
        borderRadius: BorderRadius.circular(16),
      ),
      style: const TextStyle(
        fontFamily: 'Consolas',
        color: Color(0xFFE7ECF3),
        fontSize: 13,
        height: 1.45,
      ),
    );
  }
}

class _InlineNumberField extends StatefulWidget {
  const _InlineNumberField({
    required this.value,
    required this.enabled,
    required this.onSubmitted,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onSubmitted;

  @override
  State<_InlineNumberField> createState() => _InlineNumberFieldState();
}

class _InlineNumberFieldState extends State<_InlineNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant _InlineNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final int? value = int.tryParse(_controller.text.trim());
    if (value == null) {
      _controller.text = '${widget.value}';
      return;
    }
    widget.onSubmitted(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: CupertinoTextField(
        controller: _controller,
        enabled: widget.enabled,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onSubmitted: (_) => _submit(),
        onEditingComplete: _submit,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4B5563)),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
