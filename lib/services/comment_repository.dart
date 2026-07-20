import '../models/app_user.dart';
import '../models/comment.dart';

/// Contract for ticket comment data sources. Swapping [MockCommentRepository]
/// for a Firestore subcollection later requires no changes above this layer.
abstract interface class CommentRepository {
  Future<List<Comment>> fetchComments({required String ticketId});

  Future<Comment> addComment({
    required String ticketId,
    required String authorId,
    required String authorName,
    required UserRole authorRole,
    required String message,
  });
}

/// In-memory implementation used during development and for the portfolio
/// demo. Seeded with a sample technician reply on ticket 't1' so the
/// comment thread isn't empty on first run.
class MockCommentRepository implements CommentRepository {
  final List<Comment> _comments = [
    Comment(
      id: 'c1',
      ticketId: 't1',
      authorId: 'tech-1',
      authorName: 'Carlos Andrade',
      authorRole: UserRole.technician,
      message: 'Olá! Já estou verificando o seu notebook, retorno em breve.',
      createdAt: DateTime(2026, 7, 15, 10, 15),
    ),
  ];

  static const Duration _latency = Duration(milliseconds: 500);
  int _sequence = 2;

  @override
  Future<List<Comment>> fetchComments({required String ticketId}) async {
    await Future<void>.delayed(_latency);
    final comments = _comments.where((c) => c.ticketId == ticketId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  @override
  Future<Comment> addComment({
    required String ticketId,
    required String authorId,
    required String authorName,
    required UserRole authorRole,
    required String message,
  }) async {
    await Future<void>.delayed(_latency);
    final comment = Comment(
      id: 'c${_sequence++}',
      ticketId: ticketId,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      message: message.trim(),
      createdAt: DateTime.now(),
    );
    _comments.add(comment);
    return comment;
  }
}
