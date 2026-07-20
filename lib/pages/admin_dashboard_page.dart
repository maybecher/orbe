import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../styles/app_colors.dart';
import '../widgets/attended_chart.dart';
import '../widgets/ticket_stat_tile.dart';

/// Admin "Dashboard": aggregate indicators across every user's tickets,
/// plus the attended-tickets chart by day/week/month/year.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Não foi possível carregar os indicadores.',
            style: text.bodyMedium,
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(adminStatsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const AttendedChart(),
              const SizedBox(height: 24),
              Text('Chamados por status', style: text.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TicketStatTile(
                      count: stats.openCount,
                      label: 'Abertos',
                      color: AppColors.statusOpen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TicketStatTile(
                      count: stats.inProgressCount,
                      label: 'Em atendimento',
                      color: AppColors.statusInProgress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TicketStatTile(
                      count: stats.resolvedCount,
                      label: 'Resolvidos',
                      color: AppColors.statusResolved,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TicketStatTile(
                      count: stats.closedCount,
                      label: 'Fechados',
                      color: AppColors.statusClosed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Total de chamados',
                        value: stats.totalTickets,
                      ),
                      const Divider(),
                      _SummaryRow(
                        icon: Icons.people_outline,
                        label: 'Usuários cadastrados',
                        value: stats.totalUsers,
                      ),
                      const Divider(),
                      _SummaryRow(
                        icon: Icons.category_outlined,
                        label: 'Categorias',
                        value: stats.totalCategories,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: text.bodyLarge)),
          Text('$value', style: text.titleMedium),
        ],
      ),
    );
  }
}
