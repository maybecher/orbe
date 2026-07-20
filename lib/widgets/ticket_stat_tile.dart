import 'package:flutter/material.dart';

/// Small colored tile showing a ticket count by status, used in the
/// Início dashboard's summary row.
class TicketStatTile extends StatelessWidget {
  const TicketStatTile({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: text.headlineMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
