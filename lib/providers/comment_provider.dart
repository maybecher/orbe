import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import '../services/comment_repository.dart';
import 'auth_provider.dart';

/// Provides the active [CommentRepository]. Swap the implementation here
/// (e.g. to a Firestore subcollection) without touching the UI.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return MockCommentRepository();
});

/// Holds the comment thread for a single ticket, keyed by ticket id.
class CommentsController extends AsyncNotifier<List<Comment>> {
  CommentsController(this.ticketId);

  final String ticketId;

  @override
  Future<List<Comment>> build() async {
    return ref.read(commentRepositoryProvider).fetchComments(ticketId: ticketId);
  }

  Future<void> addComment(String message) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null || message.trim().isEmpty) return;

    final repository = ref.read(commentRepositoryProvider);
    final comment = await repository.addComment(
      ticketId: ticketId,
      authorId: user.id,
      authorName: user.name,
      authorRole: user.role,
      message: message,
    );

    state = AsyncValue.data([...?state.value, comment]);
  }
}

final commentsControllerProvider =
    AsyncNotifierProvider.family<CommentsController, List<Comment>, String>(
  (ticketId) => CommentsController(ticketId),
);
