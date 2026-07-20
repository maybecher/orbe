import 'dart:typed_data';

import 'ticket_category.dart';

/// Lifecycle status of a support ticket.
enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get label => switch (this) {
        TicketStatus.open => 'Aberto',
        TicketStatus.inProgress => 'Em atendimento',
        TicketStatus.resolved => 'Resolvido',
        TicketStatus.closed => 'Fechado',
      };
}

/// Urgency level a requester assigns when opening a ticket.
enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get label => switch (this) {
        TicketPriority.low => 'Baixa',
        TicketPriority.medium => 'Média',
        TicketPriority.high => 'Alta',
        TicketPriority.urgent => 'Urgente',
      };
}

/// A support ticket opened by a user.
class Ticket {
  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.requesterId,
    required this.requesterName,
    this.attachmentBytes,
    this.ratingStars,
    this.ratingComment,
    this.resolvedAt,
  });

  final String id;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final String requesterId;
  final String requesterName;

  /// Photo attached when the ticket was opened, if any. Held in memory for
  /// the mock backend; a real backend would store this as an uploaded URL.
  final Uint8List? attachmentBytes;

  /// Service rating (1-5) given by the requester once the ticket is
  /// resolved, if any.
  final int? ratingStars;
  final String? ratingComment;

  /// When the ticket first moved to [TicketStatus.resolved]. Drives the
  /// admin dashboard's "attended" charts. Never cleared once set, even if
  /// the status later changes again.
  final DateTime? resolvedAt;

  bool get isRated => ratingStars != null;

  Ticket copyWith({
    TicketStatus? status,
    int? ratingStars,
    String? ratingComment,
    DateTime? resolvedAt,
  }) {
    return Ticket(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: status ?? this.status,
      createdAt: createdAt,
      requesterId: requesterId,
      requesterName: requesterName,
      attachmentBytes: attachmentBytes,
      ratingStars: ratingStars ?? this.ratingStars,
      ratingComment: ratingComment ?? this.ratingComment,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
