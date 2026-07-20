import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../providers/admin_provider.dart';
import '../providers/comment_provider.dart';
import '../utils/ticket_visuals.dart';
import '../widgets/comment_thread.dart';
import '../widgets/rating_stars.dart';
import '../widgets/ticket_info_card.dart';

/// Admin/technician view of a single ticket: full info, a control to
/// change its status, the requester's rating (if any), and the same
/// comment thread the requester sees.
class AdminTicketDetailPage extends ConsumerStatefulWidget {
  const AdminTicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<AdminTicketDetailPage> createState() =>
      _AdminTicketDetailPageState();
}

class _AdminTicketDetailPageState extends ConsumerState<AdminTicketDetailPage> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;
  bool _isUpdatingStatus = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSendingComment = true);
    await ref
        .read(commentsControllerProvider(widget.ticketId).notifier)
        .addComment(message);
    _commentController.clear();
    if (mounted) setState(() => _isSendingComment = false);
  }

  Future<void> _changeStatus(TicketStatus status) async {
    setState(() => _isUpdatingStatus = true);
    await ref
        .read(adminTicketsControllerProvider.notifier)
        .updateStatus(ticketId: widget.ticketId, status: status);
    if (mounted) setState(() => _isUpdatingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(adminTicketsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Atender chamado')),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Não foi possível carregar o chamado.'),
        ),
        data: (tickets) {
          final ticket = _findTicket(tickets, widget.ticketId);
          if (ticket == null) {
            return const Center(child: Text('Chamado não encontrado.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    TicketInfoCard(ticket: ticket),
                    const SizedBox(height: 24),
                    _StatusControl(
                      current: ticket.status,
                      isUpdating: _isUpdatingStatus,
                      onChanged: _changeStatus,
                    ),
                    if (ticket.isRated) ...[
                      const SizedBox(height: 24),
                      _RequesterRatingCard(ticket: ticket),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'Comentários',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    CommentsList(ticketId: ticket.id),
                  ],
                ),
              ),
              CommentInputBar(
                controller: _commentController,
                isSending: _isSendingComment,
                onSend: _sendComment,
              ),
            ],
          );
        },
      ),
    );
  }

  Ticket? _findTicket(List<Ticket> tickets, String id) {
    for (final ticket in tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }
}

class _StatusControl extends StatelessWidget {
  const _StatusControl({
    required this.current,
    required this.isUpdating,
    required this.onChanged,
  });

  final TicketStatus current;
  final bool isUpdating;
  final ValueChanged<TicketStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status do chamado', style: text.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in TicketStatus.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: status == current,
                    selectedColor: status.color.withValues(alpha: 0.18),
                    labelStyle: status == current
                        ? TextStyle(color: status.color, fontWeight: FontWeight.w600)
                        : null,
                    onSelected: isUpdating ? null : (_) => onChanged(status),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequesterRatingCard extends StatelessWidget {
  const _RequesterRatingCard({required this.ticket});

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
            Text('Avaliação do usuário', style: text.titleMedium),
            const SizedBox(height: 8),
            RatingStars(value: ticket.ratingStars ?? 0),
            if (ticket.ratingComment != null && ticket.ratingComment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(ticket.ratingComment!, style: text.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
