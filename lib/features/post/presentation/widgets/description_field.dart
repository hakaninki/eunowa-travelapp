import 'package:flutter/material.dart';

class DescriptionField extends StatelessWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const DescriptionField({super.key, required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      maxLines: 3,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
    );
  }
}
