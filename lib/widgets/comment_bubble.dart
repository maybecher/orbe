import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../styles/app_colors.dart';

/// Chat-style bubble for a single [Comment], aligned right in the
/// requester's own color when [isMine] is true, left otherwise.
class CommentBubble extends StatelessWidget {
  const CommentBubble({super.key, required this.comment, required this.isMine});

  final Comment comment;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final bubbleColor = isMine ? AppColors.primary : scheme.surfaceContainerHighest;
    final textColor = isMine ? AppColors.textOnPrimary : scheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  comment.authorName,
                  style: text.labelLarge?.copyWith(color: textColor),
                ),
              ),
            Text(comment.message, style: text.bodyLarge?.copyWith(color: textColor)),
            const SizedBox(height: 4),
            Text(
              _time(comment.createdAt),
              style: text.bodyMedium?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
