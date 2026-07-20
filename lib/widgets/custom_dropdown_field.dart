import 'package:flutter/material.dart';

import '../styles/app_text_styles.dart';

/// Reusable labeled dropdown, matching [CustomTextField]'s label-above-field
/// layout so form screens stay visually consistent.
class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
