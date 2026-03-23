import 'package:ddcci/src/ddcci/models.dart';
import 'package:ddcci/src/ddcci/windows_ddcci.dart';
import 'package:ddcci/src/n.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: DdcCiApp()));
}

class DdcCiApp extends HookConsumerWidget {
  const DdcCiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'DDC/CI Control Center',
      theme: FluentThemeData(brightness: Brightness.dark, accentColor: Colors.blue, visualDensity: VisualDensity.compact, fontFamily: 'Segoe UI'),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topIndex = useState(0);
    final AsyncValue<List<RawPhysicalMonitor>> value = ref.watch(loadMonitorsProvider);
    return NavigationView(
      pane: NavigationPane(
        selected: topIndex.value,
        onChanged: (index) => topIndex.value = index,
        items: value.when(
          data: (monitors) {
            return monitors.map((monitor) => PaneItem(icon: const Icon(WindowsIcons.home), title: Text(monitor.description), body: VpsPage(monitor))).toList();
          },
          error: (error, stackTrace) {
            return <NavigationPaneItem>[
              PaneItem(
                icon: const Icon(FluentIcons.error),
                title: const Text('Load failed'),
                body: Center(child: Text(error.toString())),
              ),
            ];
          },
          loading: () {
            return <NavigationPaneItem>[
              PaneItem(
                icon: const Icon(FluentIcons.sync),
                title: const Text('Loading'),
                body: const Center(child: ProgressBar()),
              ),
            ];
          },
        ),
        footerItems: <NavigationPaneItem>[PaneItem(icon: const Icon(WindowsIcons.settings), title: const Text('Settings'), body: const SettingsPage())],
      ),
    );
  }
}

class VpsPage extends HookConsumerWidget {
  const VpsPage(this.monitor, {super.key});

  final RawPhysicalMonitor monitor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ParsedCapabilities> capabilities = ref.watch(readCapabilitiesProvider(monitor.handle));
    final ParsedCapabilities? parsedCapabilities = capabilities.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ScrollConfiguration(
          behavior: const FluentScrollBehavior(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SoftGroup(
                    title: 'Display Identification',
                    initiallyExpanded: true,
                    children: <Widget>[
                      StaticTextListTile('Manufacturer name', monitor.description.isEmpty ? null : monitor.description),
                      StaticTextListTile('Product code', parsedCapabilities?.model),
                      const PlaceholderListTile('Serial number'),
                      const PlaceholderListTile('Manufactured'),
                      const PlaceholderListTile('EDID version'),
                      const PlaceholderListTile('Input type'),
                      const PlaceholderListTile('Preferred timing'),
                      const PlaceholderListTile('Extension blocks'),
                      const PlaceholderListTile('Raw data'),
                      StaticTextListTile('DDC/CI', _capabilitiesStatus(capabilities)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Command Interface',
                    initiallyExpanded: true,
                    children: <Widget>[
                      StaticTextListTile('Capabilities string', parsedCapabilities?.raw),
                      StaticTextListTile('Control codes supported', _formatSupportedCodes(parsedCapabilities)),
                      const PlaceholderListTile('Current timing'),
                      StaticTextListTile('MCCS compliance', parsedCapabilities?.mccsVersion),
                      const PlaceholderListTile('Command-line editor'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Display control',
                    children: <Widget>[
                      const PlaceholderListTile('Horizontal frequency - 0xAC'),
                      const PlaceholderListTile('Vertical frequency - 0xAE'),
                      TextListTile(monitor, 0xC0, 'Display usage time'),
                      TextListTile(monitor, 0xC8, 'Display controller type'),
                      TextListTile(monitor, 0xC9, 'Display firmware level'),
                      ComboBoxListTile(monitor, 0xCA, 'OSD enable', vcpOsdEnableOptions),
                      ComboBoxListTile(monitor, 0xCC, 'OSD language', vcpOsdLanguageOptions),
                      ComboBoxListTile(monitor, 0xD6, 'Power mode', vcpPowerModeOptions),
                      TextListTile(monitor, 0xDF, 'VCP version'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Preset operations',
                    children: <Widget>[
                      ActionListTile(monitor, 0x04, 'Restore factory defaults'),
                      ActionListTile(monitor, 0x05, 'Restore factory luminance/contrast defaults'),
                      ActionListTile(monitor, 0x06, 'Restore factory geometry defaults'),
                      ActionListTile(monitor, 0x08, 'Restore factory color defaults'),
                      ActionListTile(monitor, 0xB0, 'Settings'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Geometry',
                    children: <Widget>[
                      SiderListTile(monitor, 0x20, 'Horizontal position (phase)'),
                      SiderListTile(monitor, 0x22, 'Horizontal size'),
                      SiderListTile(monitor, 0x24, 'Horizontal pincushion'),
                      SiderListTile(monitor, 0x26, 'Horizontal pincushion balance'),
                      SiderListTile(monitor, 0x28, 'Horizontal convergence R/B'),
                      SiderListTile(monitor, 0x29, 'Horizontal convergence M/G'),
                      SiderListTile(monitor, 0x2A, 'Horizontal linearity'),
                      SiderListTile(monitor, 0x2C, 'Horizontal linearity balance'),
                      SiderListTile(monitor, 0x30, 'Vertical position (phase)'),
                      SiderListTile(monitor, 0x32, 'Vertical size'),
                      SiderListTile(monitor, 0x34, 'Vertical pincushion'),
                      SiderListTile(monitor, 0x36, 'Vertical pincushion balance'),
                      SiderListTile(monitor, 0x38, 'Vertical convergence R/B'),
                      SiderListTile(monitor, 0x39, 'Vertical convergence M/G'),
                      SiderListTile(monitor, 0x3A, 'Vertical linearity'),
                      SiderListTile(monitor, 0x3C, 'Vertical linearity balance'),
                      SiderListTile(monitor, 0x40, 'Vertical parallelogram'),
                      SiderListTile(monitor, 0x41, 'Vertical parallelogram balance'),
                      SiderListTile(monitor, 0x42, 'Horizontal keystone'),
                      SiderListTile(monitor, 0x43, 'Vertical keystone'),
                      SiderListTile(monitor, 0x44, 'Rotation'),
                      SiderListTile(monitor, 0x46, 'Top corner flare'),
                      SiderListTile(monitor, 0x48, 'Top corner hook'),
                      SiderListTile(monitor, 0x4A, 'Bottom corner flare'),
                      SiderListTile(monitor, 0x4B, 'Bottom corner hook'),
                      ComboBoxListTile(monitor, 0x82, 'Horizontal mirror (H)', vcpMirrorOptions),
                      ComboBoxListTile(monitor, 0x84, 'Vertical mirror (V)', vcpMirrorOptions),
                      ComboBoxListTile(monitor, 0x86, 'Display scaling', vcpDisplayScalingOptions),
                      const PlaceholderListTile('Window position (T,L) - 0x95'),
                      const PlaceholderListTile('Window position (T,R) - 0x96'),
                      const PlaceholderListTile('Window position (B,L) - 0x97'),
                      const PlaceholderListTile('Window position (B,R) - 0x98'),
                      ComboBoxListTile(monitor, 0xDA, 'Scan mode (TV)', vcpScanModeOptions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Image adjustment',
                    children: <Widget>[
                      NumericListTile(monitor, 0x0B, 'Color temperature increment'),
                      NumericListTile(monitor, 0x0C, 'Color temperature request'),
                      NumericListTile(monitor, 0x0E, 'Clock'),
                      SiderListTile(monitor, 0x10, 'Luminance'),
                      ComboBoxListTile(monitor, 0x11, 'Flash tone enhancement', vcpFlashToneEnhancementOptions),
                      SiderListTile(monitor, 0x12, 'Contrast'),
                      NumericListTile(monitor, 0x13, 'Backlight control'),
                      ComboBoxListTile(monitor, 0x14, 'Select color preset', vcpColorPresetOptions),
                      SiderListTile(monitor, 0x16, 'Red video gain'),
                      const PlaceholderListTile('User color compensation - 0x17'),
                      SiderListTile(monitor, 0x18, 'Green video gain'),
                      SiderListTile(monitor, 0x1A, 'Blue video gain'),
                      const PlaceholderListTile('Focus - 0x1C'),
                      ComboBoxListTile(monitor, 0x1F, 'Auto color setup', vcpAutoColorSetupOptions),
                      const PlaceholderListTile('Gray scale expansion - 0x2E'),
                      const PlaceholderListTile('Clock phase - 0x3E'),
                      const PlaceholderListTile('Horizontal moire - 0x56'),
                      const PlaceholderListTile('Vertical moire - 0x58'),
                      const PlaceholderListTile('6 axis saturation: Red - 0x59'),
                      const PlaceholderListTile('6 axis saturation: Yellow - 0x5A'),
                      const PlaceholderListTile('6 axis saturation: Green - 0x5B'),
                      const PlaceholderListTile('6 axis saturation: Cyan - 0x5C'),
                      const PlaceholderListTile('6 axis saturation: Blue - 0x5D'),
                      const PlaceholderListTile('6 axis saturation: Magenta - 0x5E'),
                      SiderListTile(monitor, 0x6C, 'Red video black level'),
                      SiderListTile(monitor, 0x6E, 'Green video black level'),
                      SiderListTile(monitor, 0x70, 'Blue video black level'),
                      const PlaceholderListTile('Gamma - 0x72'),
                      const PlaceholderListTile('LUT size - 0x73'),
                      const PlaceholderListTile('Single point LUT operation - 0x74'),
                      const PlaceholderListTile('Block LUT operation - 0x75'),
                      const PlaceholderListTile('Adjust zoom - 0x7C'),
                      const PlaceholderListTile('White LED backlight control - 0x7D'),
                      const PlaceholderListTile('Red LED backlight control - 0x7E'),
                      const PlaceholderListTile('Green LED backlight control - 0x7F'),
                      const PlaceholderListTile('Blue LED backlight control - 0x81'),
                      SiderListTile(monitor, 0x87, 'Sharpness'),
                      const PlaceholderListTile('Velocity scan modulation - 0x88'),
                      const PlaceholderListTile('TV saturation - 0x8A'),
                      const PlaceholderListTile('TV contrast - 0x8E'),
                      const PlaceholderListTile('Hue - 0x90'),
                      const PlaceholderListTile('TV black level luminance - 0x92'),
                      const PlaceholderListTile('Window background - 0x9A'),
                      const PlaceholderListTile('6-axis hue control Yellow - 0x9C'),
                      const PlaceholderListTile('6-axis hue control Green - 0x9D'),
                      const PlaceholderListTile('6-axis hue control Cyan - 0x9E'),
                      const PlaceholderListTile('6-axis hue control Blue - 0x9F'),
                      const PlaceholderListTile('6-axis hue control Magenta - 0xA0'),
                      ComboBoxListTile(monitor, 0xA2, 'Auto setup on/off', vcpAutoSetupOnOffOptions),
                      const PlaceholderListTile('Window control - 0xA4'),
                      const PlaceholderListTile('Window select - 0xA5'),
                      const PlaceholderListTile('Window size - 0xA6'),
                      const PlaceholderListTile('Window transparency - 0xA7'),
                      const PlaceholderListTile('Screen orientation - 0xAA'),
                      ComboBoxListTile(monitor, 0xD4, 'Stereo video mode', vcpStereoVideoModeOptions),
                      ComboBoxListTile(monitor, 0xDC, 'Display application', vcpDisplayApplicationOptions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Audio functions',
                    children: <Widget>[
                      SiderListTile(monitor, 0x62, 'Speaker volume'),
                      SiderListTile(monitor, 0x64, 'Microphone volume'),
                      ComboBoxListTile(monitor, 0x8D, 'Audio mute', vcpMuteOptions),
                      SiderListTile(monitor, 0x8F, 'Treble'),
                      SiderListTile(monitor, 0x91, 'Bass'),
                      SiderListTile(monitor, 0x93, 'Balance'),
                      ComboBoxListTile(monitor, 0x94, 'Stereo mode', vcpStereoModeOptions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'DPVL functions',
                    children: <Widget>[
                      const PlaceholderListTile('Monitor status - 0xB7'),
                      const PlaceholderListTile('Packet count'),
                      const PlaceholderListTile('Monitor x origin - 0xB9'),
                      const PlaceholderListTile('Monitor y origin - 0xBA'),
                      const PlaceholderListTile('Header error count - 0xBB'),
                      const PlaceholderListTile('Body CRC error count - 0xBC'),
                      const PlaceholderListTile('Client ID - 0xBD'),
                      const PlaceholderListTile('Link shutdown is disabled'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Miscellaneous functions',
                    children: <Widget>[
                      ActionListTile(monitor, 0x01, 'Degauss'),
                      NumericListTile(monitor, 0x02, 'New control value'),
                      ActionListTile(monitor, 0x03, 'Soft controls'),
                      NumericListTile(monitor, 0x52, 'Last value control'),
                      const PlaceholderListTile('Performance preserve - 0x54'),
                      ComboBoxListTile(monitor, 0x60, 'Input select', vcpInputSourceOptions),
                      ComboBoxListTile(monitor, 0x66, 'Ambient light sensor', vcpAmbientLightSensorOptions),
                      const PlaceholderListTile('Remote procedure call'),
                      const PlaceholderListTile('EDID operation - 0x78'),
                      const PlaceholderListTile('TV channel up/down'),
                      const PlaceholderListTile('Flat panel sub-pixel layout - 0xB2'),
                      const PlaceholderListTile('Source timing mode - 0xB4'),
                      TextListTile(monitor, 0xB6, 'Display technology type'),
                      const PlaceholderListTile('Display descriptor length - 0xC2'),
                      const PlaceholderListTile('Display descriptor to transmit - 0xC3'),
                      const PlaceholderListTile('Enable display of display descriptor - 0xC4'),
                      const PlaceholderListTile('Application enable key - 0xC6'),
                      const PlaceholderListTile('Display enable key - 0xC7'),
                      const PlaceholderListTile('Status indicators - 0xCD'),
                      const PlaceholderListTile('Auxiliary display size - 0xCE'),
                      const PlaceholderListTile('Auxiliary display data - 0xCF'),
                      ComboBoxListTile(monitor, 0xD0, 'Output select', vcpOutputSelectOptions),
                      const PlaceholderListTile('Operation mode'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(title: 'Manufacturer specific', children: _manufacturerSpecificChildren(monitor)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SoftGroup extends StatelessWidget {
  const SoftGroup({required this.title, required this.children, this.initiallyExpanded = false, super.key});

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Expander(
      header: Text(title),
      initiallyExpanded: initiallyExpanded,
      contentPadding: EdgeInsets.zero,
      content: Column(children: _withDividers(children)),
    );
  }
}

class StaticTextListTile extends StatelessWidget {
  const StaticTextListTile(this.title, this.value, {super.key});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(title),
      trailing: SizedBox(
        width: 420,
        child: Text(value ?? '', textAlign: TextAlign.end, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class PlaceholderListTile extends StatelessWidget {
  const PlaceholderListTile(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: const Icon(WindowsIcons.home), title: Text(title), trailing: const SizedBox(width: 180));
  }
}

class SiderListTile extends HookConsumerWidget {
  const SiderListTile(this.monitor, this.code, this.title, {super.key});

  final RawPhysicalMonitor monitor;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = useState<int>(0);
    final provider = readFeatureValueProvider(monitor.handle, code);
    final vcpReadResult = ref.watch(provider);
    ref.listen<AsyncValue<VcpReadResult>>(provider, (previous, next) {
      next.whenData((value) {
        if (value.success && value.currentValue != null) {
          sliderValue.value = value.currentValue!;
        }
      });
    });

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: vcpReadResult.when(
        data: (data) {
          if (!data.success) {
            return Text('Read failed: ${data.windowsError ?? '?'}');
          }
          final int maximumValue = data.maximumValue ?? 100;
          final double current = sliderValue.value.toDouble().clamp(0, maximumValue.toDouble());
          return SizedBox(
            width: 320,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('${sliderValue.value}/$maximumValue'),
                const SizedBox(width: 12),
                SizedBox(
                  width: 240,
                  child: Slider(
                    label: sliderValue.value.toString(),
                    min: 0,
                    max: maximumValue.toDouble(),
                    value: current,
                    onChanged: (value) => sliderValue.value = value.toInt(),
                    onChangeEnd: (value) async {
                      await _writeFeatureValue(ref, monitor, code, value.toInt());
                    },
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) => Text('Error: $error'),
        loading: () => const SizedBox(width: 140, child: ProgressBar()),
      ),
    );
  }
}

class ComboBoxListTile extends HookConsumerWidget {
  const ComboBoxListTile(this.monitor, this.code, this.title, this.options, {super.key});

  final RawPhysicalMonitor monitor;
  final int code;
  final String title;
  final Map<int, String> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = useState<int?>(null);
    final provider = readFeatureValueProvider(monitor.handle, code);
    final readResult = ref.watch(provider);
    ref.listen<AsyncValue<VcpReadResult>>(provider, (previous, next) {
      next.whenData((value) {
        if (value.currentValue != null) {
          selectedValue.value = value.currentValue;
        }
      });
    });

    final List<MapEntry<int, String>> optionEntries = options.entries.toList();

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: SizedBox(
        width: 360,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: readResult.when(
                data: (data) {
                  if (data.success && data.currentValue != null) {
                    return Text('Current: ${_labelForOption(data.currentValue, options)}', overflow: TextOverflow.ellipsis);
                  }
                  if (!data.success) {
                    return Text('Read failed: ${data.windowsError ?? '?'}', overflow: TextOverflow.ellipsis);
                  }
                  return const Text('-');
                },
                error: (error, _) => Text('Error: $error', overflow: TextOverflow.ellipsis),
                loading: () => const Text('Loading...'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 180,
              child: ComboBox<int>(
                value: selectedValue.value,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  selectedValue.value = value;
                  await _writeFeatureValue(ref, monitor, code, value);
                },
                items: optionEntries.map((entry) => ComboBoxItem<int>(value: entry.key, child: Text(entry.value))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumericListTile extends HookConsumerWidget {
  const NumericListTile(this.monitor, this.code, this.title, {super.key});

  final RawPhysicalMonitor monitor;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final statusMessage = useState<String?>(null);
    final provider = readFeatureValueProvider(monitor.handle, code);
    final readResult = ref.watch(provider);

    useEffect(() {
      final int? currentValue = readResult.value?.currentValue;
      if (currentValue != null && controller.text.trim().isEmpty) {
        controller.text = currentValue.toString();
      }
      return null;
    }, <Object?>[readResult.value?.currentValue]);

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: SizedBox(
        width: 420,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: readResult.when(
                data: (data) {
                  if (!data.success) {
                    return Text('Read failed: ${data.windowsError ?? '?'}', overflow: TextOverflow.ellipsis);
                  }
                  return Text(_formatReadResult(data), overflow: TextOverflow.ellipsis);
                },
                error: (error, _) => Text('Error: $error', overflow: TextOverflow.ellipsis),
                loading: () => const Text('Loading...'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: TextBox(controller: controller, placeholder: 'value / 0x..'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final int? parsedValue = _parseNumericInput(controller.text);
                if (parsedValue == null) {
                  statusMessage.value = 'Invalid value';
                  return;
                }
                await _writeFeatureValue(ref, monitor, code, parsedValue);
                statusMessage.value = 'Written';
              },
              child: const Text('Write'),
            ),
            if (statusMessage.value != null) ...<Widget>[const SizedBox(width: 8), SizedBox(width: 72, child: Text(statusMessage.value!, overflow: TextOverflow.ellipsis))],
          ],
        ),
      ),
    );
  }
}

class ActionListTile extends HookConsumerWidget {
  const ActionListTile(this.monitor, this.code, this.title, {super.key});

  final RawPhysicalMonitor monitor;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = useState<bool>(false);
    final statusMessage = useState<String?>(null);

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: SizedBox(
        width: 280,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(child: Text(statusMessage.value ?? 'Write value 1', overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isSubmitting.value
                  ? null
                  : () async {
                      isSubmitting.value = true;
                      try {
                        await _writeFeatureValue(ref, monitor, code, 1);
                        statusMessage.value = 'Executed';
                      } catch (error) {
                        statusMessage.value = error.toString();
                      } finally {
                        isSubmitting.value = false;
                      }
                    },
              child: Text(isSubmitting.value ? 'Working...' : 'Execute'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextListTile extends HookConsumerWidget {
  const TextListTile(this.monitor, this.code, this.title, {super.key});

  final RawPhysicalMonitor monitor;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readResult = ref.watch(readFeatureValueProvider(monitor.handle, code));

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: readResult.when(
        data: (data) {
          if (!data.success) {
            return Text('Read failed: ${data.windowsError ?? '?'}');
          }
          return Text(_formatReadResult(data));
        },
        error: (error, _) => Text('Error: $error'),
        loading: () => const SizedBox(width: 140, child: ProgressBar()),
      ),
    );
  }
}

const Map<int, String> vcpColorPresetOptions = <int, String>{0x01: 'sRGB', 0x02: 'Display native', 0x03: '4000K', 0x04: '5000K', 0x05: '6500K', 0x06: '7500K', 0x07: '8200K', 0x08: '9300K', 0x09: '10000K', 0x0A: '11500K', 0x0B: 'User 1', 0x0C: 'User 2', 0x0D: 'User 3'};

const Map<int, String> vcpInputSourceOptions = <int, String>{
  0x01: 'Analog video 1 (RGB)',
  0x02: 'Analog video 2 (RGB)',
  0x03: 'Digital video 1 (TMDS)',
  0x04: 'Digital video 2 (TMDS)',
  0x05: 'Composite video 1',
  0x06: 'Composite video 2',
  0x07: 'S-video 1',
  0x08: 'S-video 2',
  0x09: 'Tuner 1',
  0x0A: 'Tuner 2',
  0x0B: 'Tuner 3',
  0x0C: 'Component video 1',
  0x0D: 'Component video 2',
  0x0E: 'Component video 3',
  0x0F: 'DisplayPort 1',
  0x10: 'DisplayPort 2',
  0x11: 'HDMI 1',
  0x12: 'HDMI 2',
};

const Map<int, String> vcpOsdLanguageOptions = <int, String>{
  0x01: 'Chinese (Traditional/Hantai)',
  0x02: 'English',
  0x03: 'French',
  0x04: 'German',
  0x05: 'Italian',
  0x06: 'Japanese',
  0x07: 'Korean',
  0x08: 'Portuguese (Portugal)',
  0x09: 'Russian',
  0x0A: 'Spanish',
  0x0B: 'Swedish',
  0x0C: 'Turkish',
  0x0D: 'Chinese (Simplified/Kanta)',
  0x10: 'Portuguese (Br)',
  0x11: 'Arabic',
  0x12: 'Bulgarian',
  0x13: 'Croatian',
  0x14: 'Czech',
  0x15: 'Danish',
  0x16: 'Dutch',
  0x17: 'Estonian',
  0x18: 'Finnish',
  0x19: 'Greek',
  0x1A: 'Hebrew',
  0x1B: 'Hindi',
  0x1C: 'Hungarian',
  0x1D: 'Latvian',
  0x1E: 'Lithuanian',
  0x1F: 'Norwegian',
  0x20: 'Polish',
  0x21: 'Romanian',
  0x22: 'Serbian',
  0x23: 'Slovak',
  0x24: 'Slovenian',
  0x25: 'Thai',
  0x26: 'Ukrainian',
  0x27: 'Vietnamese',
};

const Map<int, String> vcpPowerModeOptions = <int, String>{0x01: 'On', 0x02: 'Standby', 0x03: 'Suspend', 0x04: 'Reduced power off', 0x05: 'Power off'};

const Map<int, String> vcpMuteOptions = <int, String>{0x01: 'Mute', 0x02: 'Unmute'};

const Map<int, String> vcpOsdEnableOptions = <int, String>{0x01: 'Disabled', 0x02: 'Enabled'};

const Map<int, String> vcpMirrorOptions = <int, String>{0x01: 'Normal mode', 0x02: 'Mirror mode'};

const Map<int, String> vcpDisplayScalingOptions = <int, String>{
  0x01: 'No scaling, 1:1',
  0x02: 'Max. image size with no AR distortion',
  0x03: 'Max. vertical size with no AR distortion',
  0x04: 'Max. horizontal size with no AR distortion',
  0x05: 'Max. vertical size with AR distortion',
  0x06: 'Max. horizontal size with AR distortion',
  0x07: 'Full mode',
  0x08: 'Zoom mode',
  0x09: 'Squeeze mode',
  0x0A: 'Variable',
};

const Map<int, String> vcpFlashToneEnhancementOptions = <int, String>{0x8000: 'Off - no enhancement', 0x4000: 'Enhancement 1 - not including skin tone', 0x2000: 'Enhancement 2 - including skin tone', 0x1000: 'Demo mode', 0x0800: 'User mode'};

const Map<int, String> vcpAutoColorSetupOptions = <int, String>{0x00: 'Inactive', 0x01: 'Activate', 0x02: 'Periodic'};

const Map<int, String> vcpAmbientLightSensorOptions = <int, String>{0x01: 'Disabled', 0x02: 'Enabled'};

const Map<int, String> vcpStereoModeOptions = <int, String>{0x00: 'Speaker off', 0x01: 'Mono', 0x02: 'Stereo', 0x03: 'Stereo expanded', 0x11: 'SRS 2.0', 0x12: 'SRS 2.1', 0x13: '5.1', 0x14: '7.1', 0xFF: 'Processor determined by source'};

const Map<int, String> vcpAutoSetupOnOffOptions = <int, String>{0x01: 'Off', 0x02: 'On'};

const Map<int, String> vcpScanModeOptions = <int, String>{0x00: 'Normal operation', 0x01: 'Underscan', 0x02: 'Overscan', 0x03: 'Widescreen'};

const Map<int, String> vcpDisplayApplicationOptions = <int, String>{
  0x00: 'Standard/default',
  0x01: 'Productivity',
  0x02: 'Mixed',
  0x03: 'Movie',
  0x04: 'User-defined',
  0x05: 'Games',
  0x06: 'Sports',
  0x07: 'Professional',
  0x08: 'Standard/default, intermediate power consumption',
  0x09: 'Standard/default, low power consumption',
  0x0A: 'Demonstration',
  0xF0: 'Dynamic contrast',
};

const Map<int, String> vcpOutputSelectOptions = <int, String>{
  0x01: 'Analog video 1 (RGB)',
  0x02: 'Analog video 2 (RGB)',
  0x03: 'Digital video 1 (TMDS)',
  0x04: 'Digital video 2 (TMDS)',
  0x05: 'Composite video 1',
  0x06: 'Composite video 2',
  0x07: 'S-video 1',
  0x08: 'S-video 2',
  0x09: 'Tuner 1',
  0x0A: 'Tuner 2',
  0x0B: 'Tuner 3',
  0x0C: 'Component video 1',
  0x0D: 'Component video 2',
  0x0E: 'Component video 3',
  0x0F: 'DisplayPort 1',
  0x10: 'DisplayPort 2',
  0x11: 'HDMI 1',
  0x12: 'HDMI 2',
};

const Map<int, String> vcpStereoVideoModeOptions = <int, String>{
  0x00: 'Disabled',
  0x01: 'Side-by-side interleave',
  0x02: '4-way interleave, even scan lines',
  0x04: '4-way interleave, odd scan lines',
  0x08: '2-way interleave, left eye first',
  0x10: '2-way interleave, right eye first',
  0x20: 'Field-sequential, left eye first',
  0x40: 'Field-sequential, right eye first',
};

Future<void> _writeFeatureValue(WidgetRef ref, RawPhysicalMonitor monitor, int code, int value) async {
  await ref.read(windowsDdcCiServiceProvider).setFeatureValue(monitor.handle, code, value);
  ref.invalidate(readFeatureValueProvider(monitor.handle, code));
}

List<Widget> _withDividers(List<Widget> children) {
  final List<Widget> result = <Widget>[];
  for (int index = 0; index < children.length; index++) {
    if (index > 0) {
      result.add(const Divider());
    }
    result.add(children[index]);
  }
  return result;
}

List<Widget> _manufacturerSpecificChildren(RawPhysicalMonitor monitor) {
  final List<Widget> items = <Widget>[];
  for (int code = 0xE0; code <= 0xFC; code++) {
    items.add(PlaceholderListTile('Manufacturer specific - 0x${_hex(code)}'));
  }
  items.add(NumericListTile(monitor, 0xFD, 'Manufacturer specific'));
  items.add(const PlaceholderListTile('Manufacturer specific - 0xFE'));
  items.add(NumericListTile(monitor, 0xFF, 'Manufacturer specific'));
  return items;
}

String _tileTitle(String title, int code) => '$title - 0x${_hex(code)}';

String _hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();

String _formatValue(int value) => '$value (0x${value.toRadixString(16).toUpperCase()})';

String _formatReadResult(VcpReadResult result) {
  if (!result.success) {
    return 'Read failed: ${result.windowsError ?? '?'}';
  }
  if (result.currentValue == null) {
    return 'No value';
  }
  if (result.maximumValue == null) {
    return _formatValue(result.currentValue!);
  }
  return '${_formatValue(result.currentValue!)} / max ${_formatValue(result.maximumValue!)}';
}

String _labelForOption(int? value, Map<int, String> options) {
  if (value == null) {
    return '-';
  }
  return options[value] ?? _formatValue(value);
}

String _capabilitiesStatus(AsyncValue<ParsedCapabilities> capabilities) {
  if (capabilities.hasValue) {
    return 'Supported';
  }
  if (capabilities.hasError) {
    return 'Unavailable';
  }
  return 'Loading...';
}

String? _formatSupportedCodes(ParsedCapabilities? capabilities) {
  if (capabilities == null) {
    return null;
  }
  final String commands = _formatHexSet(capabilities.supportedCommands);
  final String vcpCodes = _formatHexSet(capabilities.supportedVcpCodes);
  return 'cmds: $commands | vcp: $vcpCodes';
}

String _formatHexSet(Set<int> values) {
  if (values.isEmpty) {
    return '';
  }
  final List<int> sortedValues = values.toList()..sort();
  return sortedValues.map((value) => _hex(value)).join(' ');
}

int? _parseNumericInput(String raw) {
  final String normalized = raw.trim();
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.startsWith('0x') || normalized.startsWith('0X')) {
    return int.tryParse(normalized.substring(2), radix: 16);
  }
  return int.tryParse(normalized);
}

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}
