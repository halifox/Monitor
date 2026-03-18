import 'package:ddcci/src/ddcci/models.dart';
import 'package:ddcci/src/ddcci/windows_ddcci.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() {
  runApp(DdcCiApp());
}

class DdcCiApp extends StatelessWidget {
  const DdcCiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'DDC/CI Control Center',
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var topIndex = 0;
  final service = WindowsDdcCiService();
  List<MonitorSnapshot> monitors = [];

  @override
  void initState() {
    service.loadMonitors().then((List<MonitorSnapshot> value) {
      setState(() {
        monitors = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        items: monitors.map((monitor) {
          return PaneItem(
            icon: Icon(WindowsIcons.home),
            title: Text(monitor.description),
            body: VpsPage(service, monitor),
          );
        }).toList(),
        footerItems: [PaneItem(icon: Icon(WindowsIcons.settings), title: Text('Settings'), body: SettingsPage())],
      ),
    );
  }
}

class VpsPage extends StatefulWidget {
  const VpsPage(this.service, this.monitor, {super.key});

  final WindowsDdcCiService service;
  final MonitorSnapshot monitor;

  @override
  State<VpsPage> createState() => _VpsPageState();
}

class _VpsPageState extends State<VpsPage> {
  String? selectedColor = 'a';
  late final service = widget.service;
  late final monitor = widget.monitor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expander(
          header: Text('This text is in header'),
          initiallyExpanded: true,
          contentPadding: .zero,
          content: Column(
            children: [
              SiderListTile(service, monitor, 0x10, '亮度'),
              Divider(),
              ListTile(
                leading: const WindowsIcon(WindowsIcons.home),
                title: Text('输入源'),
                trailing: ComboBox<String>(
                  value: selectedColor,
                  items: [
                    ComboBoxItem(child: Text('a'), value: 'a'),
                    ComboBoxItem(child: Text('bvvvvvvvvvvvvvvvv'), value: 'bvvvvvvvvvvvvvvvv'),
                  ],
                  onChanged: (color) => setState(() => selectedColor = color),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

sealed class VcpUiState {
  const VcpUiState();
}

/// 1. 未读取
class Loading extends VcpUiState {
  const Loading();
}

/// 2. 成功
class Ready extends VcpUiState {
  final VcpReadResult result;

  const Ready(this.result);
}

/// 3. 支持但读取失败
class SupportedButFailed extends VcpUiState {
  final VcpReadResult result;

  const SupportedButFailed(this.result);
}

/// 4. 不支持
class Unsupported extends VcpUiState {
  const Unsupported();
}

class SiderListTile extends StatefulWidget {
  const SiderListTile(this.service, this.monitor, this.code, this.title, {super.key});

  final WindowsDdcCiService service;
  final MonitorSnapshot monitor;
  final int code;
  final String title;

  @override
  State<SiderListTile> createState() => _SiderListTileState();
}

class _SiderListTileState extends State<SiderListTile> {
  VcpUiState uiState = Loading();

  @override
  void initState() {
    try {
      MonitorFeatureState feature = widget.monitor.features.firstWhere((element) => element.code == widget.code);
      if (!feature.supported) {
        setState(() {
          uiState = Unsupported();
        });
        return;
      }
      widget.service.readFeatureValue(widget.monitor.id, widget.code).then((VcpReadResult result) {
        if (result.success) {
          setState(() {
            uiState = Ready(result);
          });
        } else {
          setState(() {
            uiState = SupportedButFailed(result);
          });
        }
      });
    } catch (e) {}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(WindowsIcons.home),
      title: Text(widget.title),
      trailing: switch (uiState) {
        Loading() => ProgressBar(),
        Ready(result: final result) => Slider(
          label: '${result.currentValue?.toInt()}',
          min: 0,
          max: result.maximumValue?.toDouble() ?? 100,
          value: result.currentValue?.toDouble() ?? 0,
          onChanged: (v) {
            setState(() {
              uiState = Ready(result.copyWith(currentValue: v.toInt()));
            });
          },
          onChangeEnd: (v) {
            widget.service.setFeatureValue(widget.monitor.id, widget.code, v.toInt());
          },
        ),
        SupportedButFailed() => Slider(value: 0, onChanged: null),
        Unsupported() => Text("Unsupported"),
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
