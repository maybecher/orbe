import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../styles/app_colors.dart';
import '../utils/ticket_visuals.dart';
import 'status_badge.dart';

/// Summary card for a single [Ticket], used in ticket list screens.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.onTap});

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final priorityColor = ticket.priority.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                style: text.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    iconForCategoryId(ticket.category.id),
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(ticket.category.name, style: text.bodyMedium),
                  const SizedBox(width: 14),
                  Icon(Icons.flag_rounded, size: 14, color: priorityColor),
                  const SizedBox(width: 4),
                  Text(
                    ticket.priority.label,
                    style: text.bodyMedium?.copyWith(color: priorityColor),
                  ),
                  const Spacer(),
                  if (ticket.attachmentBytes != null) ...[
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(_relativeDate(ticket.createdAt), style: text.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  }
}
