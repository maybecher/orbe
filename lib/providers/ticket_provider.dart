import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/ticket_category.dart';
import '../services/ticket_repository.dart';
import 'auth_provider.dart';

/// Provides the active [TicketRepository]. Swap the implementation here
/// (e.g. to Firestore) without touching the UI or the controller.
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return MockTicketRepository();
});

/// Holds the current user's tickets. Rebuilds automatically when the
/// authenticated user changes (e.g. becomes null on sign-out).
class TicketsController extends AsyncNotifier<List<Ticket>> {
  @override
  Future<List<Ticket>> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return const [];
    return ref
        .read(ticketRepositoryProvider)
        .fetchTickets(requesterId: user.id, requesterName: user.name);
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    Uint8List? attachmentBytes,
  }) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final repository = ref.read(ticketRepositoryProvider);
    final ticket = await repository.createTicket(
      requesterId: user.id,
      requesterName: user.name,
      title: title,
      description: description,
      category: category,
      priority: priority,
      attachmentBytes: attachmentBytes,
    );

    state = AsyncValue.data([ticket, ...?state.value]);
  }

  Future<void> rateTicket({
    required String ticketId,
    required int stars,
    String? comment,
  }) async {
    final repository = ref.read(ticketRepositoryProvider);
    final updated = await repository.rateTicket(
      ticketId: ticketId,
      stars: stars,
      comment: comment,
    );

    final current = state.value ?? const [];
    state = AsyncValue.data([
      for (final ticket in current)
        if (ticket.id == updated.id) updated else ticket,
    ]);
  }
}

final ticketsControllerProvider =
    AsyncNotifierProvider<TicketsController, List<Ticket>>(TicketsController.new);
