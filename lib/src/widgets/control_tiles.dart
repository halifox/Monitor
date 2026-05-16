import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, Theme;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pureddcci/l10n/app_localizations.dart';
import 'package:pureddcci/src/providers.dart';
import 'package:pureddcci/src/pureddc/vcp_read_result.dart';

class StaticTextListTile<T extends Object> extends StatelessWidget {
  const StaticTextListTile(this.title, this.asyncData, this.transform, {super.key, this.style});

  final String title;
  final AsyncValue<T?> asyncData;
  final String Function(T value) transform;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: asyncData.when(
        data: (data) => data == null
            ? Text(l10n.noDataAvailable)
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Text(transform(data), style: style),
              ),
        error: (error, _) => Text(l10n.unavailable),
        loading: () => const SizedBox(width: 140, child: ProgressBar()),
      ),
    );
  }
}

class SiderListTile extends HookConsumerWidget {
  const SiderListTile(this.handle, this.code, this.title, {super.key});

  final int handle;
  final int code;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = useState<double>(0);
    final provider = featureValueProvider(handle, code);
    final vcpReadResult = ref.watch(provider);
    final int maximumValue = vcpReadResult.value?.maximumValue ?? 100;
    useEffect(() {
      sliderValue.value = vcpReadResult.value?.currentValue.toDouble() ?? 0;
      return null;
    }, [vcpReadResult.value?.currentValue]);
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: SizedBox(
        width: 240,
        child: Slider(
          label: sliderValue.value.toStringAsFixed(0),
          min: 0,
          max: maximumValue.toDouble(),
          value: sliderValue.value.clamp(0, maximumValue.toDouble()),
          onChanged: vcpReadResult.hasValue ? (value) => sliderValue.value = value : null,
          // TODO: also need to send the value here
          onChangeEnd: (v) async {
            final value = v.toInt();
            await ref.read(setFeatureValueProvider(handle, code, value).future);
          },
        ),
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
    final l10n = AppLocalizations.of(context)!;

    final selectedValue = useState<int?>(null);
    final provider = featureValueProvider(handle, code);
    final readResult = ref.watch(provider);
    final List<MapEntry<int, String>> optionEntries = options.entries.toList();
    useEffect(() {
      if (readResult.hasValue) {
        selectedValue.value = readResult.requireValue.currentValue;
      }
    }, [readResult]);
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: ComboBox<int>(
        placeholder: Text(l10n.unavailable, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38))),
        value: selectedValue.value,
        onChanged: (value) async {
          if (value == null) {
            return;
          }
          selectedValue.value = value;
          await ref.read(setFeatureValueProvider(handle, code, value).future);
        },
        items: optionEntries.map((entry) {
          final bool isEnabled = enabledValues == null || enabledValues!.contains(entry.key);
          return ComboBoxItem<int>(value: entry.key, enabled: readResult.hasValue && isEnabled, child: Text(entry.value));
        }).toList(),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = useTextEditingController();
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
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: 130, child: TextBox(controller: controller)),
          Padding(
            padding: .symmetric(horizontal: 4),
            child: FilledButton(
              onPressed: readResult.hasValue
                  ? () async {
                      int? value;
                      final String normalized = controller.text.trim();
                      if (normalized.isEmpty) {
                        return;
                      }
                      if (normalized.startsWith('0x') || normalized.startsWith('0X')) {
                        value = int.tryParse(normalized.substring(2), radix: 16);
                      } else {
                        value = int.tryParse(normalized);
                      }
                      if (value == null) {
                        return;
                      }
                      await ref.read(setFeatureValueProvider(handle, code, value).future);
                    }
                  : null,
              child: Text(l10n.write),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionListTile extends HookConsumerWidget {
  const ActionListTile(this.handle, this.code, this.title, this.options, {super.key});

  final int handle;
  final int code;
  final String title;
  final Map<int, String> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readResult = ref.watch(featureValueProvider(handle, code));
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ...options.entries.map((item) {
            return Padding(
              padding: .symmetric(horizontal: 4),
              child: FilledButton(
                onPressed: readResult.hasValue
                    ? () async {
                        final value = item.key;
                        await ref.read(setFeatureValueProvider(handle, code, value).future);
                      }
                    : null,
                child: Text(item.value),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class TextListTile extends HookConsumerWidget {
  const TextListTile(this.handle, this.code, this.title, this.transform, {super.key});

  final int handle;
  final int code;
  final String title;
  final String Function(VcpReadResult value) transform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final readResult = ref.watch(featureValueProvider(handle, code));
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(title),
      trailing: readResult.when(
        data: (data) => Text(transform(data)),
        error: (error, _) => Text(l10n.unavailable),
        loading: () => const SizedBox(width: 140, child: ProgressBar()),
      ),
    );
  }
}
