import 'package:flutter/material.dart';

/// Central color palette for the Orbe design system.
///
/// Colors are the single source of truth for the app's visual identity:
/// a corporate deep blue paired with a technological purple accent.
/// Never hardcode a [Color] inside widgets — reference these constants.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF1E2A78); // deep corporate blue
  static const Color primaryDark = Color(0xFF141C54);
  static const Color primaryLight = Color(0xFF3A4CB0);
  static const Color secondary = Color(0xFF7C4DFF); // technological purple
  static const Color secondaryDark = Color(0xFF5E35D9);

  // Surfaces (light)
  static const Color background = Color(0xFFF4F5F9); // light gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDEFF5);

  // Surfaces (dark)
  static const Color backgroundDark = Color(0xFF0F1220);
  static const Color surfaceDark = Color(0xFF1A1E2E);
  static const Color surfaceVariantDark = Color(0xFF242A3D);

  // Text
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF3F4F8);
  static const Color textSecondaryDark = Color(0xFF9AA1B5);

  // Status (ticket lifecycle)
  static const Color statusOpen = Color(0xFF2F80ED); // blue
  static const Color statusInProgress = Color(0xFFF2994A); // orange
  static const Color statusResolved = Color(0xFF27AE60); // green
  static const Color statusClosed = Color(0xFF828EA0); // gray
  static const Color statusUrgent = Color(0xFFEB5757); // red

  // Feedback
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2994A);
  static const Color error = Color(0xFFEB5757);
  static const Color info = Color(0xFF2F80ED);

  // Borders & dividers
  static const Color border = Color(0xFFE2E5EE);
  static const Color borderDark = Color(0xFF2E3548);
}
