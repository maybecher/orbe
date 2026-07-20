import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../providers/comment_provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/comment_thread.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_stars.dart';
import '../widgets/ticket_info_card.dart';

/// Full detail of a single ticket: info, photo, comment thread, and the
/// rating prompt once it's resolved.
class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

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

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(ticketsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chamado')),
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
                    if (ticket.status == TicketStatus.resolved) ...[
                      const SizedBox(height: 24),
                      ticket.isRated
                          ? _RatedCard(ticket: ticket)
                          : _RatingForm(ticketId: ticket.id),
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

class _RatingForm extends ConsumerStatefulWidget {
  const _RatingForm({required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<_RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends ConsumerState<_RatingForm> {
  final _commentController = TextEditingController();
  int _stars = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _isSubmitting = true);

    await ref.read(ticketsControllerProvider.notifier).rateTicket(
          ticketId: widget.ticketId,
          stars: _stars,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Obrigado pela avaliação!')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avalie o atendimento', style: text.titleMedium),
            const SizedBox(height: 12),
            RatingStars(value: _stars, onChanged: (v) => setState(() => _stars = v)),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Deixe um comentário sobre o atendimento (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Enviar avaliação',
              isLoading: _isSubmitting,
              onPressed: _stars == 0 ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatedCard extends StatelessWidget {
  const _RatedCard({required this.ticket});

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
            Text('Sua avaliação', style: text.titleMedium),
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
