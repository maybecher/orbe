import 'package:flutter/material.dart';

/// Visual variants for [CustomButton].
enum ButtonVariant { primary, outline }

/// Reusable full-width button with a built-in loading state.
///
/// While [isLoading] is true the button is disabled and shows a spinner,
/// preventing duplicate submissions during async actions.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isLoading ? null : onPressed;
    final Widget child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : _content();

    return switch (variant) {
      ButtonVariant.primary =>
        ElevatedButton(onPressed: action, child: child),
      ButtonVariant.outline =>
        OutlinedButton(onPressed: action, child: child),
    };
  }

  Widget _content() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
