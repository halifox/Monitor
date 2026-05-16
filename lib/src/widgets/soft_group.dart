import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;

class SoftGroup extends StatelessWidget {
  const SoftGroup({required this.title, required this.children, this.initiallyExpanded = false, super.key});

  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Expander(
      leading: const Icon(Icons.widgets),
      header: Text(title),
      initiallyExpanded: initiallyExpanded,
      contentPadding: EdgeInsets.zero,
      content: Column(children: _withDividers(children)),
    );
  }
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
