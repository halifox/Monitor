import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureddc/src/constants/vcp_options.dart';
import 'package:pureddc/src/providers.dart';
import 'package:pureddc/src/pureddc/capabilities_parser.dart';
import 'package:pureddc/src/widgets/control_tiles.dart';
import 'package:pureddc/src/widgets/soft_group.dart';

class MonitorPage extends HookConsumerWidget {
  const MonitorPage(this.handle, {super.key});

  final int handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(monitorCapabilitiesProvider(handle));
    final rawCapabilities = capabilities.value;
    final Map<int, Set<int>> vcpValues = rawCapabilities != null
        ? CapabilitiesParser.parseVcpValues(rawCapabilities)
        : <int, Set<int>>{};

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
                      StaticTextListTile('Manufacturer name', ''),
                      StaticTextListTile(
                        'Product code',
                        rawCapabilities != null ? CapabilitiesParser.parseModel(rawCapabilities) : null,
                      ),
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
                      StaticTextListTile('Capabilities string', rawCapabilities),
                      StaticTextListTile('Control codes supported', _formatSupportedCodes(rawCapabilities)),
                      const PlaceholderListTile('Current timing'),
                      StaticTextListTile(
                        'MCCS compliance',
                        rawCapabilities != null ? CapabilitiesParser.parseMccsVersion(rawCapabilities) : null,
                      ),
                      const PlaceholderListTile('Command-line editor'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Display control',
                    children: <Widget>[
                      TextListTile(
                        handle,
                        0xAC,
                        'Horizontal frequency',
                        transform: (value) => "${(value.currentValue / 100.0).toStringAsFixed(2)} kHz",
                      ),
                      TextListTile(
                        handle,
                        0xAE,
                        'Vertical frequency',
                        transform: (value) => "${(value.currentValue / 100.0).toStringAsFixed(2)} Hz",
                      ),
                      TextListTile(handle, 0xC0, 'Display usage time'),
                      TextListTile(
                        handle,
                        0xC8,
                        'Display controller type',
                        transform: (value) {
                          final v = value.currentValue;
                          return switch (v) {
                            0x01 => "Intel",
                            0x02 => "ATI/AMD",
                            0x03 => "NVIDIA",
                            0x04 => "3dfx",
                            0x05 => "Matrox",
                            0x06 => "S3 Graphics",
                            0x07 => "Trident",
                            0x08 => "Number Nine",
                            0x09 => "Realtek",
                            _ => "Unknown ($v)",
                          };
                        },
                      ),
                      TextListTile(
                        handle,
                        0xC9,
                        'Display firmware level',
                        transform: (value) {
                          int rawValue = value.currentValue;
                          int major = (rawValue >> 8) & 0xFF;
                          int minor = rawValue & 0xFF;
                          return "$major.$minor";
                        },
                      ),
                      ComboBoxListTile(handle, 0xCA, 'OSD enable', vcpOsdEnableOptions, enabledValues: vcpValues[0xCA]),
                      ComboBoxListTile(handle, 0xCC, 'OSD language', vcpOsdLanguageOptions, enabledValues: vcpValues[0xCC]),
                      ComboBoxListTile(handle, 0xD6, 'Power mode', vcpPowerModeOptions, enabledValues: vcpValues[0xD6]),
                      TextListTile(
                        handle,
                        0xDF,
                        'VCP version',
                        transform: (value) {
                          int rawValue = value.currentValue;
                          int major = (rawValue >> 8) & 0xFF;
                          int minor = rawValue & 0xFF;
                          return "$major.$minor";
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Preset operations',
                    children: <Widget>[
                      ActionListTile(handle, 0x04, 'Restore factory defaults'),
                      ActionListTile(handle, 0x05, 'Restore factory luminance/contrast defaults'),
                      ActionListTile(handle, 0x06, 'Restore factory geometry defaults'),
                      ActionListTile(handle, 0x08, 'Restore factory color defaults'),
                      ActionListTile(handle, 0xB0, 'Settings'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Geometry',
                    children: <Widget>[
                      SiderListTile(handle, 0x20, 'Horizontal position (phase)'),
                      SiderListTile(handle, 0x22, 'Horizontal size'),
                      SiderListTile(handle, 0x24, 'Horizontal pincushion'),
                      SiderListTile(handle, 0x26, 'Horizontal pincushion balance'),
                      SiderListTile(handle, 0x28, 'Horizontal convergence R/B'),
                      SiderListTile(handle, 0x29, 'Horizontal convergence M/G'),
                      SiderListTile(handle, 0x2A, 'Horizontal linearity'),
                      SiderListTile(handle, 0x2C, 'Horizontal linearity balance'),
                      SiderListTile(handle, 0x30, 'Vertical position (phase)'),
                      SiderListTile(handle, 0x32, 'Vertical size'),
                      SiderListTile(handle, 0x34, 'Vertical pincushion'),
                      SiderListTile(handle, 0x36, 'Vertical pincushion balance'),
                      SiderListTile(handle, 0x38, 'Vertical convergence R/B'),
                      SiderListTile(handle, 0x39, 'Vertical convergence M/G'),
                      SiderListTile(handle, 0x3A, 'Vertical linearity'),
                      SiderListTile(handle, 0x3C, 'Vertical linearity balance'),
                      SiderListTile(handle, 0x40, 'Vertical parallelogram'),
                      SiderListTile(handle, 0x41, 'Vertical parallelogram balance'),
                      SiderListTile(handle, 0x42, 'Horizontal keystone'),
                      SiderListTile(handle, 0x43, 'Vertical keystone'),
                      SiderListTile(handle, 0x44, 'Rotation'),
                      SiderListTile(handle, 0x46, 'Top corner flare'),
                      SiderListTile(handle, 0x48, 'Top corner hook'),
                      SiderListTile(handle, 0x4A, 'Bottom corner flare'),
                      SiderListTile(handle, 0x4B, 'Bottom corner hook'),
                      ComboBoxListTile(handle, 0x82, 'Horizontal mirror (H)', vcpMirrorOptions, enabledValues: vcpValues[0x82]),
                      ComboBoxListTile(handle, 0x84, 'Vertical mirror (V)', vcpMirrorOptions, enabledValues: vcpValues[0x84]),
                      ComboBoxListTile(handle, 0x86, 'Display scaling', vcpDisplayScalingOptions, enabledValues: vcpValues[0x86]),
                      const PlaceholderListTile('Window position (T,L) - 0x95'),
                      const PlaceholderListTile('Window position (T,R) - 0x96'),
                      const PlaceholderListTile('Window position (B,L) - 0x97'),
                      const PlaceholderListTile('Window position (B,R) - 0x98'),
                      ComboBoxListTile(handle, 0xDA, 'Scan mode (TV)', vcpScanModeOptions, enabledValues: vcpValues[0xDA]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Image adjustment',
                    children: <Widget>[
                      NumericListTile(handle, 0x0B, 'Color temperature increment'),
                      NumericListTile(handle, 0x0C, 'Color temperature request'),
                      NumericListTile(handle, 0x0E, 'Clock'),
                      SiderListTile(handle, 0x10, 'Luminance'),
                      ComboBoxListTile(handle, 0x11, 'Flash tone enhancement', vcpFlashToneEnhancementOptions, enabledValues: vcpValues[0x11]),
                      SiderListTile(handle, 0x12, 'Contrast'),
                      NumericListTile(handle, 0x13, 'Backlight control'),
                      ComboBoxListTile(handle, 0x14, 'Select color preset', vcpColorPresetOptions, enabledValues: vcpValues[0x14]),
                      SiderListTile(handle, 0x16, 'Red video gain'),
                      const PlaceholderListTile('User color compensation - 0x17'),
                      SiderListTile(handle, 0x18, 'Green video gain'),
                      SiderListTile(handle, 0x1A, 'Blue video gain'),
                      const PlaceholderListTile('Focus - 0x1C'),
                      ComboBoxListTile(handle, 0x1F, 'Auto color setup', vcpAutoColorSetupOptions, enabledValues: vcpValues[0x1F]),
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
                      SiderListTile(handle, 0x6C, 'Red video black level'),
                      SiderListTile(handle, 0x6E, 'Green video black level'),
                      SiderListTile(handle, 0x70, 'Blue video black level'),
                      const PlaceholderListTile('Gamma - 0x72'),
                      const PlaceholderListTile('LUT size - 0x73'),
                      const PlaceholderListTile('Single point LUT operation - 0x74'),
                      const PlaceholderListTile('Block LUT operation - 0x75'),
                      const PlaceholderListTile('Adjust zoom - 0x7C'),
                      const PlaceholderListTile('White LED backlight control - 0x7D'),
                      const PlaceholderListTile('Red LED backlight control - 0x7E'),
                      const PlaceholderListTile('Green LED backlight control - 0x7F'),
                      const PlaceholderListTile('Blue LED backlight control - 0x81'),
                      SiderListTile(handle, 0x87, 'Sharpness'),
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
                      ComboBoxListTile(handle, 0xA2, 'Auto setup on/off', vcpAutoSetupOnOffOptions, enabledValues: vcpValues[0xA2]),
                      const PlaceholderListTile('Window control - 0xA4'),
                      const PlaceholderListTile('Window select - 0xA5'),
                      const PlaceholderListTile('Window size - 0xA6'),
                      const PlaceholderListTile('Window transparency - 0xA7'),
                      const PlaceholderListTile('Screen orientation - 0xAA'),
                      ComboBoxListTile(handle, 0xD4, 'Stereo video mode', vcpStereoVideoModeOptions, enabledValues: vcpValues[0xD4]),
                      ComboBoxListTile(handle, 0xDC, 'Display application', vcpDisplayApplicationOptions, enabledValues: vcpValues[0xDC]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(
                    title: 'Audio functions',
                    children: <Widget>[
                      SiderListTile(handle, 0x62, 'Speaker volume'),
                      SiderListTile(handle, 0x64, 'Microphone volume'),
                      ComboBoxListTile(handle, 0x8D, 'Audio mute', vcpMuteOptions, enabledValues: vcpValues[0x8D]),
                      SiderListTile(handle, 0x8F, 'Treble'),
                      SiderListTile(handle, 0x91, 'Bass'),
                      SiderListTile(handle, 0x93, 'Balance'),
                      ComboBoxListTile(handle, 0x94, 'Stereo mode', vcpStereoModeOptions, enabledValues: vcpValues[0x94]),
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
                      ActionListTile(handle, 0x01, 'Degauss'),
                      NumericListTile(handle, 0x02, 'New control value'),
                      ActionListTile(handle, 0x03, 'Soft controls'),
                      NumericListTile(handle, 0x52, 'Last value control'),
                      const PlaceholderListTile('Performance preserve - 0x54'),
                      ComboBoxListTile(handle, 0x60, 'Input select', vcpInputSourceOptions, enabledValues: vcpValues[0x60]),
                      ComboBoxListTile(handle, 0x66, 'Ambient light sensor', vcpAmbientLightSensorOptions, enabledValues: vcpValues[0x66]),
                      const PlaceholderListTile('Remote procedure call'),
                      const PlaceholderListTile('EDID operation - 0x78'),
                      const PlaceholderListTile('TV channel up/down'),
                      const PlaceholderListTile('Flat panel sub-pixel layout - 0xB2'),
                      const PlaceholderListTile('Source timing mode - 0xB4'),
                      TextListTile(handle, 0xB6, 'Display technology type'),
                      const PlaceholderListTile('Display descriptor length - 0xC2'),
                      const PlaceholderListTile('Display descriptor to transmit - 0xC3'),
                      const PlaceholderListTile('Enable display of display descriptor - 0xC4'),
                      const PlaceholderListTile('Application enable key - 0xC6'),
                      const PlaceholderListTile('Display enable key - 0xC7'),
                      const PlaceholderListTile('Status indicators - 0xCD'),
                      const PlaceholderListTile('Auxiliary display size - 0xCE'),
                      const PlaceholderListTile('Auxiliary display data - 0xCF'),
                      ComboBoxListTile(handle, 0xD0, 'Output select', vcpOutputSelectOptions, enabledValues: vcpValues[0xD0]),
                      const PlaceholderListTile('Operation mode'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftGroup(title: 'Manufacturer specific', children: _manufacturerSpecificChildren(handle)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

List<Widget> _manufacturerSpecificChildren(int handle) {
  final items = <Widget>[];
  for (int code = 0xE0; code <= 0xFC; code++) {
    items.add(PlaceholderListTile('Manufacturer specific - 0x${_hex(code)}'));
  }
  items.add(NumericListTile(handle, 0xFD, 'Manufacturer specific'));
  items.add(const PlaceholderListTile('Manufacturer specific - 0xFE'));
  items.add(NumericListTile(handle, 0xFF, 'Manufacturer specific'));
  return items;
}

String _hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();

String _capabilitiesStatus(AsyncValue<String> capabilities) {
  if (capabilities.hasValue) {
    return 'Supported';
  }
  if (capabilities.hasError) {
    return 'Unavailable';
  }
  return 'Loading...';
}

String? _formatSupportedCodes(String? rawCapabilities) {
  if (rawCapabilities == null) {
    return null;
  }
  final Set<int> commands = CapabilitiesParser.parseCommands(rawCapabilities);
  final Set<int> vcpCodes = CapabilitiesParser.parseVcpCodes(rawCapabilities);
  final String commandsStr = _formatHexSet(commands);
  final String vcpCodesStr = _formatHexSet(vcpCodes);
  return 'cmds: $commandsStr | vcp: $vcpCodesStr';
}

String _formatHexSet(Set<int> values) {
  if (values.isEmpty) {
    return '';
  }
  final List<int> sortedValues = values.toList()..sort();
  return sortedValues.map((value) => _hex(value)).join(' ');
}
