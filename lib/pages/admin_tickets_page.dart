import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/admin_provider.dart';
import '../routing/app_router.dart';
import '../widgets/ticket_card.dart';

/// Admin "Todos os chamados": every ticket in the system, across every
/// requester, most recent first.
class AdminTicketsPage extends ConsumerWidget {
  const AdminTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(adminTicketsControllerProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Todos os chamados')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminTicketsControllerProvider.future),
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              'Não foi possível carregar os chamados.',
              style: text.bodyMedium,
            ),
          ),
          data: (tickets) {
            final sorted = [...tickets]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sorted.isEmpty) {
              return Center(
                child: Text('Nenhum chamado no sistema ainda.', style: text.bodyMedium),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = sorted[index];
                return TicketCard(
                  ticket: ticket,
                  onTap: () => context.push(
                    AppRoutes.adminTicketDetailPath(ticket.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
