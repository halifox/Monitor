import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureddc/src/providers.dart';
import 'package:pureddc/src/widgets/monitor_page.dart';

void main() {
  runApp(const ProviderScope(child: PureDDCApp()));
}

class PureDDCApp extends HookConsumerWidget {
  const PureDDCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'PureDDC Control Center',
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.compact,
        fontFamily: 'Segoe UI',
      ),
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
      final monitorName = ref.watch(logicalMonitorNameProvider(hMonitor));
      final physicalHandles = ref.watch(physicalMonitorsProvider(hMonitor));
      final paneItems = <NavigationPaneItem>[];
      for (final physicalHandle in physicalHandles) {
        paneItems.add(
          PaneItem(icon: const Icon(WindowsIcons.home), title: Text(monitorName), body: MonitorPage(physicalHandle)),
        );
      }
      if (paneItems.length == 1) {
        items.add(paneItems[0]);
      } else {
        items.add(PaneItemExpander(icon: const Icon(WindowsIcons.home), title: Text(monitorName), items: paneItems));
      }
    }

    return NavigationView(
      pane: NavigationPane(
        selected: selectedIndex.value,
        onChanged: (index) => selectedIndex.value = index,
        items: items,
        footerItems: [
          PaneItemAction(
            icon: const Icon(WindowsIcons.refresh),
            title: const Text("refresh"),
            onTap: () => ref.invalidate(logicalMonitorsProvider),
          ),
          PaneItem(icon: const Icon(WindowsIcons.settings), title: const Text('Settings'), body: const SettingsPage()),
        ],
      ),
    );
  }
}

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}
