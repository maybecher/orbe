import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import '../styles/app_colors.dart';
import 'comment_bubble.dart';

/// Renders a ticket's comment thread, aligning the current account's own
/// messages to the right. Shared by the requester's ticket detail screen
/// and the admin/technician's.
class CommentsList extends ConsumerWidget {
  const CommentsList({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsControllerProvider(ticketId));
    final currentUserId = ref.watch(authControllerProvider).value?.id;

    return commentsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(
        'Não foi possível carregar os comentários.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      data: (comments) {
        if (comments.isEmpty) {
          return Text(
            'Nenhum comentário ainda. Envie uma mensagem abaixo.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          children: [
            for (final comment in comments)
              CommentBubble(
                comment: comment,
                isMine: comment.authorId == currentUserId,
              ),
          ],
        );
      },
    );
  }
}

/// Text field + send button pinned to the bottom of a ticket detail
/// screen. The caller owns the controller and submission logic.
class CommentInputBar extends StatelessWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Escreva um comentário...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
