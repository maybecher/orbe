import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../styles/app_colors.dart';

/// Presentation mappings (icon/color) for ticket enums and categories,
/// shared by every widget that displays a [Ticket] so status/category/
/// priority always look the same across the app.
///
/// Categories are administrator-managed, so unlike status/priority there
/// is no fixed enum to switch on — the original five seeded categories
/// keep their specific icon by id; anything else (custom categories
/// created later) falls back to a generic icon.
IconData iconForCategoryId(String id) => switch (id) {
      'hardware' => Icons.devices_other_outlined,
      'software' => Icons.apps_outlined,
      'network' => Icons.wifi_outlined,
      'access' => Icons.lock_outline,
      'other' => Icons.help_outline,
      _ => Icons.label_outline,
    };

extension TicketPriorityVisuals on TicketPriority {
  Color get color => switch (this) {
        TicketPriority.low => AppColors.statusClosed,
        TicketPriority.medium => AppColors.statusOpen,
        TicketPriority.high => AppColors.statusInProgress,
        TicketPriority.urgent => AppColors.statusUrgent,
      };
}

extension TicketStatusVisuals on TicketStatus {
  Color get color => switch (this) {
        TicketStatus.open => AppColors.statusOpen,
        TicketStatus.inProgress => AppColors.statusInProgress,
        TicketStatus.resolved => AppColors.statusResolved,
        TicketStatus.closed => AppColors.statusClosed,
      };
}
