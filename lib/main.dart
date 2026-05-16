import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureddcci/src/providers.dart';
import 'package:pureddcci/src/widgets/monitor_page.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: PureDDCCIApp()));
}

class PureDDCCIApp extends HookConsumerWidget {
  const PureDDCCIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'PureDDCCI Control Center',
      theme: FluentThemeData(brightness: Brightness.dark, accentColor: Colors.blue, visualDensity: VisualDensity.compact, fontFamily: 'Segoe UI'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    final logicalMonitors = ref.watch(logicalMonitorsProvider);
    final items = <NavigationPaneItem>[];
    for (final hMonitor in logicalMonitors) {
      final paneItems = <NavigationPaneItem>[];
      final physicalHandles = ref.watch(physicalMonitorsProvider(hMonitor));
      for (final physicalHandle in physicalHandles) {
        final edidInfo = ref.watch(monitorEdidProvider(hMonitor));
        final monitorName = edidInfo.value?.manufacturerName ?? AppLocalizations.of(context)!.unknownMonitor;
        paneItems.add(PaneItem(icon: const Icon(Icons.monitor), title: Text(monitorName), body: MonitorPage(physicalHandle, hMonitor)));
      }
      if (paneItems.length > 1) {
        final logicalMonitorName = ref.watch(logicalMonitorNameProvider(hMonitor));
        items.add(PaneItemExpander(initiallyExpanded: true, icon: null, title: Text(logicalMonitorName), items: paneItems));
      } else {
        items.addAll(paneItems);
      }
    }

    return NavigationView(
      pane: NavigationPane(selected: selectedIndex.value, onChanged: (index) => selectedIndex.value = index, items: items),
    );
  }
}
