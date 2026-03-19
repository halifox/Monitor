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
  void initState() {
    // (prot(monitor)type(LCD)model(RTK)cmds(01 02 03 07 0C E3 F3)vcp(02 04 05 06 08 0B 0C 10 12 14(01 02 04 05 06 08 0B) 16 18 1A 52 60(01 03 04 0F 10 11 12) 87 AC AE B2 B6 C6 C8 CA CC(01 02 03 04 06 0A 0D) D6(01 04 05) DF FD FF)mswhql(1)asset_eep(40)mccs_ver(2.2))
    // (
    // prot(monitor)
    // type(LCD)
    // model(RTK)
    // cmds(01 02 03 07 0C E3 F3)
    // vcp(02 04 05 06 08 0B 0C 10 12 14(01 02 04 05 06 08 0B) 16 18 1A 52 60(01 03 04 0F 10 11 12) 87 AC AE B2 B6 C6 C8 CA CC(01 02 03 04 06 0A 0D) D6(01 04 05) DF FD FF)
    // mswhql(1)
    // asset_eep(40)
    // mccs_ver(2.2)
    // )
    print(widget.monitor.capabilities);
    super.initState();
  }

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
              SiderListTile(service, monitor, 0x12, '对比度'),
              Divider(),
              SiderListTile(service, monitor, 0x62, '音量'),
              Divider(),
              Divider(),
              FilledButtonListTile(service, monitor, 0x00, '??'),
              Divider(),
              TextListTile(service, monitor, 0xAC, 'AC'),
              TextListTile(service, monitor, 0xAE, 'AE'),
              TextListTile(service, monitor, 0xC0, 'C0'),
              TextListTile(service, monitor, 0xC8, 'C8'),
              TextListTile(service, monitor, 0xC9, 'C9'),
              ComboBoxListTile(service, monitor, 0xCC, 'OSD语言', vcpOsdLanguage),
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
  late MonitorFeatureState feature = widget.monitor.features.firstWhere((element) => element.code == widget.code);

  @override
  void initState() {
    try {
      widget.service.readFeatureValue(widget.monitor.id, widget.code).then((VcpReadResult result) {
        if (result.success) {
          setState(() {
            uiState = Ready(result);
          });
        } else if (feature.supported) {
          setState(() {
            uiState = SupportedButFailed(result);
          });
        } else {
          setState(() {
            uiState = Unsupported();
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

const vcpOsdLanguage = [
  "中文（繁体）",
  "英语",
  "法语",
  "德语",
  "意大利语",
  "日语",
  "韩语",
  "葡萄牙语（葡萄牙）",
  "俄语",
  "西班牙语",
  "瑞典语",
  "土耳其语",
  "中文（简体）",
  "葡萄牙语（巴西）",
  "阿拉伯语",
  "保加利亚语",
  "克罗地亚语",
  "捷克语",
  "丹麦语",
  "荷兰语",
  "爱沙尼亚语",
  "芬兰语",
  "希腊语",
  "希伯来语",
  "印地语",
  "匈牙利语",
  "拉脱维亚语",
  "立陶宛语",
  "挪威语",
  "波兰语",
  "罗马尼亚语",
  "塞尔维亚语",
  "斯洛伐克语",
  "斯洛文尼亚语",
  "泰语",
  "乌克兰语",
  "越南语",
];

class ComboBoxListTile extends StatefulWidget {
  const ComboBoxListTile(this.service, this.monitor, this.code, this.title, this.e, {super.key});

  final WindowsDdcCiService service;
  final MonitorSnapshot monitor;
  final int code;
  final String title;
  final List<String> e;

  @override
  State<ComboBoxListTile> createState() => _ComboBoxListTileState();
}

class _ComboBoxListTileState extends State<ComboBoxListTile> {
  VcpUiState uiState = Loading();
  late MonitorFeatureState feature = widget.monitor.features.firstWhere((element) => element.code == widget.code);

  @override
  void initState() {
    widget.service.readFeatureValue(widget.monitor.id, widget.code).then((VcpReadResult result) {
      if (result.success) {
        uiState = Ready(result);
      } else {
        uiState = SupportedButFailed(result);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(WindowsIcons.home),
      title: Text(widget.title),
      trailing: switch (uiState) {
        Loading() => ProgressBar(),
        Ready(result: final result) => ComboBox<int>(
          value: result.currentValue,
          onChanged: (value) async {
            if (value == null) {
              return;
            }
            await widget.service.setFeatureValue(widget.monitor.id, widget.code, value);
            setState(() {
              uiState = Ready(result.copyWith(currentValue: value));
            });
          },
          items: widget.e.asMap().entries.map((e) {
            final code = e.key + 1;
            return ComboBoxItem<int>(
              value: code,
              enabled: feature.supportedValues.contains(code),
              child: Text(e.value),
            );
          }).toList(),
        ),
        SupportedButFailed() => Text("SupportedButFailed"),
        Unsupported() => Text("Unsupported"),
      },
    );
  }
}

class FilledButtonListTile extends StatefulWidget {
  const FilledButtonListTile(this.service, this.monitor, this.code, this.title, {super.key});

  final WindowsDdcCiService service;
  final MonitorSnapshot monitor;
  final int code;
  final String title;

  @override
  State<FilledButtonListTile> createState() => _FilledButtonListTileState();
}

class _FilledButtonListTileState extends State<FilledButtonListTile> {
  VcpUiState uiState = Loading();

  @override
  void initState() {
    try {
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
        Ready(result: final result) => FilledButton(child: Text('执行'), onPressed: () {}),
        SupportedButFailed() => Slider(value: 0, onChanged: null),
        Unsupported() => Text("Unsupported"),
      },
    );
  }
}

class TextListTile extends StatefulWidget {
  const TextListTile(this.service, this.monitor, this.code, this.title, {super.key});

  final WindowsDdcCiService service;
  final MonitorSnapshot monitor;
  final int code;
  final String title;

  @override
  State<TextListTile> createState() => _TextListTileState();
}

class _TextListTileState extends State<TextListTile> {
  VcpUiState uiState = Loading();

  @override
  void initState() {
    try {
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
        Ready(result: final result) => Text(result.currentValue.toString()),
        SupportedButFailed(result: final result) => Text("SupportedButFailed:${result.windowsError}"),
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
