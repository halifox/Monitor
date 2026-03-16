import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MacosSettingsGroup extends StatelessWidget {
  const MacosSettingsGroup({
    super.key,
    required this.children,
    this.title,
  });

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white30 : Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: _separateWithDividers(children, isDark),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _separateWithDividers(List<Widget> widgets, bool isDark) {
    if (widgets.length <= 1) {
      return widgets;
    }
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 48,
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        );
      }
    }
    return result;
  }
}

class MacosSettingsTile extends StatelessWidget {
  const MacosSettingsTile({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.trailing,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor ?? CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            trailing,
          ],
        ),
      ),
    );
  }
}

class MacosPopupMenu<T> extends StatelessWidget {
  const MacosPopupMenu({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onSelected,
    this.selectedItemBuilder,
    this.enabled = true,
  });

  final String value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<T> onSelected;
  final bool Function(T item)? selectedItemBuilder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(
          isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F2F2),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        elevation: const WidgetStatePropertyAll<double>(16),
        shadowColor: WidgetStatePropertyAll<Color>(
          Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.all(6)),
      ),
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return Opacity(
          opacity: enabled ? 1 : 0.5,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: enabled ? () => controller.isOpen ? controller.close() : controller.open() : null,
            child: Container(
              constraints: const BoxConstraints(minWidth: 140),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.chevron_up_chevron_down,
                    size: 10,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      menuChildren: items.map((T item) {
        final bool selected = selectedItemBuilder?.call(item) ?? false;
        return MenuItemButton(
          onPressed: () => onSelected(item),
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 4),
            ),
            minimumSize: const WidgetStatePropertyAll<Size>(Size(140, 26)),
            fixedSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(26)),
            overlayColor: WidgetStatePropertyAll<Color>(
              CupertinoColors.activeBlue.withValues(alpha: 0.9),
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
                return Colors.white;
              }
              return isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
            }),
            shape: WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 20,
                child: selected ? const Icon(CupertinoIcons.check_mark, size: 14) : null,
              ),
              Expanded(
                child: Text(
                  itemLabelBuilder(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class MacosSubtleButton extends StatelessWidget {
  const MacosSubtleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      minimumSize: Size.zero,
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(6),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (busy)
            CupertinoActivityIndicator(
              radius: 6,
              color: isDark ? Colors.white70 : Colors.black54,
            )
          else if (icon != null)
            Icon(
              icon,
              size: 13,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          if (busy || icon != null) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class MacosValueTag extends StatelessWidget {
  const MacosValueTag({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minWidth: 46),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
