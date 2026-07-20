import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../styles/app_text_styles.dart';
import '../utils/ticket_visuals.dart';

/// Small color-coded pill showing a [TicketStatus].
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelLarge.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}
