import 'package:flutter/material.dart';

import '../models/ticket.dart';
import '../styles/app_colors.dart';
import '../utils/ticket_visuals.dart';
import 'status_badge.dart';

/// Card with a ticket's full info: title, status, category/priority/date
/// chips, description and attached photo (if any). Shared by the
/// requester's ticket detail screen and the admin/technician's.
class TicketInfoCard extends StatelessWidget {
  const TicketInfoCard({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(ticket.title, style: text.titleLarge)),
                const SizedBox(width: 8),
                StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: iconForCategoryId(ticket.category.id),
                  label: ticket.category.name,
                ),
                _InfoChip(
                  icon: Icons.flag_rounded,
                  label: ticket.priority.label,
                  color: ticket.priority.color,
                ),
                _InfoChip(
                  icon: Icons.event_outlined,
                  label: _formatDate(ticket.createdAt),
                ),
                _InfoChip(
                  icon: Icons.person_outline,
                  label: ticket.requesterName,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(ticket.description, style: text.bodyLarge),
            if (ticket.attachmentBytes != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  ticket.attachmentBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: resolvedColor),
        ),
      ],
    );
  }
}
