import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureddc/src/providers.dart';
import 'package:pureddc/src/pureddc/models.dart';

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
  const SiderListTile(this.handle, this.code, this.title, {super.key});

  final int handle;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = useState<int>(0);
    final provider = featureValueProvider(handle, code);
    final vcpReadResult = ref.watch(provider);
    ref.listen<AsyncValue<VcpReadResult>>(provider, (previous, next) {
      next.whenData((value) {
        sliderValue.value = value.currentValue;
      });
    });

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: vcpReadResult.when(
        data: (data) {
          final int maximumValue = data.maximumValue;
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
                      await _writeFeatureValue(ref, handle, code, value.toInt());
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
  const ComboBoxListTile(this.handle, this.code, this.title, this.options, {super.key, this.enabledValues});

  final int handle;
  final int code;
  final String title;
  final Map<int, String> options;
  final Set<int>? enabledValues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = useState<int?>(null);
    final provider = featureValueProvider(handle, code);
    final readResult = ref.watch(provider);
    ref.listen<AsyncValue<VcpReadResult>>(provider, (previous, next) {
      next.whenData((value) {
        selectedValue.value = value.currentValue;
      });
    });

    final List<MapEntry<int, String>> optionEntries = options.entries.toList();

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: readResult.when(
          data: (data) {
            return ComboBox<int>(
              value: selectedValue.value,
              onChanged: (value) async {
                if (value == null) {
                  return;
                }
                selectedValue.value = value;
                await _writeFeatureValue(ref, handle, code, value);
              },
              items: optionEntries.map((entry) {
                final bool isEnabled = enabledValues == null || enabledValues!.contains(entry.key);
                return ComboBoxItem<int>(
                  value: entry.key,
                  enabled: isEnabled,
                  child: Text(entry.value),
                );
              }).toList(),
            );
          },
          error: (error, _) => Text('Error: $error'),
          loading: () => const SizedBox(width: 180, child: ProgressBar()),
        ),
      ),
    );
  }
}

class NumericListTile extends HookConsumerWidget {
  const NumericListTile(this.handle, this.code, this.title, {super.key, this.transform = defaultTransform});

  final int handle;
  final int code;
  final String title;
  final String Function(VcpReadResult) transform;

  static String defaultTransform(VcpReadResult value) => value.currentValue.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final statusMessage = useState<String?>(null);
    final provider = featureValueProvider(handle, code);
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
                  return Text(transform(data), overflow: TextOverflow.ellipsis);
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
                await _writeFeatureValue(ref, handle, code, parsedValue);
                statusMessage.value = 'Written';
              },
              child: const Text('Write'),
            ),
            if (statusMessage.value != null) ...<Widget>[
              const SizedBox(width: 8),
              SizedBox(width: 72, child: Text(statusMessage.value!, overflow: TextOverflow.ellipsis)),
            ],
          ],
        ),
      ),
    );
  }
}

class ActionListTile extends HookConsumerWidget {
  const ActionListTile(this.handle, this.code, this.title, {super.key});

  final int handle;
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
                        await _writeFeatureValue(ref, handle, code, 1);
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
  const TextListTile(this.handle, this.code, this.title, {super.key, this.transform = defaultTransform});

  final int handle;
  final int code;
  final String title;
  final String Function(VcpReadResult value) transform;

  static String defaultTransform(VcpReadResult value) => value.currentValue.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readResult = ref.watch(featureValueProvider(handle, code));

    return ListTile(
      leading: const Icon(WindowsIcons.home),
      title: Text(_tileTitle(title, code)),
      trailing: readResult.when(
        data: (data) {
          return Text(transform(data));
        },
        error: (error, _) {
          print(error);
          return Text("不支持");
        },
        loading: () => const SizedBox(width: 140, child: ProgressBar()),
      ),
    );
  }
}

Future<void> _writeFeatureValue(WidgetRef ref, int handle, int code, int value) async {
  await ref.read(setFeatureValueProvider(handle, code, value).future);
  ref.invalidate(featureValueProvider(handle, code));
}

String _tileTitle(String title, int code) => '$title - 0x${_hex(code)}';

String _hex(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();

String _formatValue(int value) => '$value (0x${value.toRadixString(16).toUpperCase()})';

// String _formatReadResult(VcpReadResult result) {
//   return '${_formatValue(result.currentValue)} / max ${_formatValue(result.maximumValue)}';
// }

String _labelForOption(int value, Map<int, String> options) {
  return options[value] ?? _formatValue(value);
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
