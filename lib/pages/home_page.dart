import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/ticket.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../routing/app_router.dart';
import '../styles/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_stat_tile.dart';

/// "Início" tab: greets the user, summarizes their tickets by status and
/// surfaces the most recent ones, with a quick action to open a new one.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final ticketsAsync = ref.watch(ticketsControllerProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Orbe')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ticketsControllerProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text('Olá, ${user?.name ?? 'usuário'}', style: text.headlineMedium),
            const SizedBox(height: 4),
            Text(user?.role.label ?? '', style: text.bodyMedium),
            const SizedBox(height: 24),
            ticketsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(
                'Não foi possível carregar seus chamados.',
                style: text.bodyMedium,
              ),
              data: (tickets) => _Dashboard(tickets: tickets),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Abrir chamado',
              icon: Icons.add_rounded,
              onPressed: () => context.push(AppRoutes.newTicket),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.tickets});

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final open = tickets.where((t) => t.status == TicketStatus.open).length;
    final inProgress =
        tickets.where((t) => t.status == TicketStatus.inProgress).length;
    final resolved = tickets
        .where((t) =>
            t.status == TicketStatus.resolved ||
            t.status == TicketStatus.closed)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TicketStatTile(
                count: open,
                label: 'Abertos',
                color: AppColors.statusOpen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TicketStatTile(
                count: inProgress,
                label: 'Em atendimento',
                color: AppColors.statusInProgress,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TicketStatTile(
                count: resolved,
                label: 'Resolvidos',
                color: AppColors.statusResolved,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (tickets.isEmpty)
          Text(
            'Você ainda não abriu nenhum chamado.',
            style: text.bodyMedium,
          )
        else ...[
          Row(
            children: [
              Text('Últimos chamados', style: text.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.tickets),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final ticket in tickets.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TicketCard(
                ticket: ticket,
                onTap: () =>
                    context.push(AppRoutes.ticketDetailPath(ticket.id)),
              ),
            ),
        ],
      ],
    );
  }
}
