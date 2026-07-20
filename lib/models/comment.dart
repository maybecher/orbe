import 'app_user.dart';

/// A single message in a ticket's comment thread.
class Comment {
  const Comment({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String ticketId;
  final String authorId;
  final String authorName;
  final UserRole authorRole;
  final String message;
  final DateTime createdAt;
}
