import 'package:flutter/material.dart';

import '../styles/app_assets.dart';

/// Branded header (logo mark + title + subtitle) shared by the auth screens
/// to keep the login, register and recovery flows visually consistent.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(AppAssets.logoMark, height: 56),
        const SizedBox(height: 24),
        Text(title, style: text.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: text.bodyMedium),
      ],
    );
  }
}
