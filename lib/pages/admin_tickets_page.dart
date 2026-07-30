import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/ticket.dart';
import '../models/ticket_category.dart';
import '../providers/admin_provider.dart';
import '../providers/category_provider.dart';
import '../routing/app_router.dart';
import '../utils/ticket_visuals.dart';
import '../widgets/ticket_card.dart';

/// Admin "Todos os chamados": every ticket in the system, across every
/// requester, filterable by status/category and searchable by
/// title/requester, most recent first.
class AdminTicketsPage extends ConsumerStatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  ConsumerState<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends ConsumerState<AdminTicketsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  TicketStatus? _statusFilter;
  String? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ticket> _applyFilters(List<Ticket> tickets) {
    final query = _query.trim().toLowerCase();
    return tickets.where((ticket) {
      if (_statusFilter != null && ticket.status != _statusFilter) return false;
      if (_categoryFilter != null && ticket.category.id != _categoryFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesTitle = ticket.title.toLowerCase().contains(query);
        final matchesRequester = ticket.requesterName.toLowerCase().contains(query);
        if (!matchesTitle && !matchesRequester) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(adminTicketsControllerProvider);
    final categories = ref.watch(categoriesControllerProvider).value ?? const [];
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Todos os chamados')),
      body: Column(
        children: [
          _FilterBar(
            searchController: _searchController,
            onSearchChanged: (value) => setState(() => _query = value),
            statusFilter: _statusFilter,
            onStatusChanged: (status) => setState(() => _statusFilter = status),
            categories: categories,
            categoryFilter: _categoryFilter,
            onCategoryChanged: (id) => setState(() => _categoryFilter = id),
          ),
          Expanded(
            child: RefreshIndicator(
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
                  if (tickets.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum chamado no sistema ainda.',
                        style: text.bodyMedium,
                      ),
                    );
                  }

                  final filtered = _applyFilters(tickets)
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum chamado corresponde ao filtro.',
                        style: text.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ticket = filtered[index];
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
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.categories,
    required this.categoryFilter,
    required this.onCategoryChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final TicketStatus? statusFilter;
  final ValueChanged<TicketStatus?> onStatusChanged;
  final List<TicketCategory> categories;
  final String? categoryFilter;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Buscar por título ou solicitante',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: statusFilter == null,
                onSelected: (_) => onStatusChanged(null),
              ),
              for (final status in TicketStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  selected: statusFilter == status,
                  selectedColor: status.color.withValues(alpha: 0.18),
                  labelStyle: statusFilter == status
                      ? TextStyle(color: status.color, fontWeight: FontWeight.w600)
                      : null,
                  onSelected: (_) => onStatusChanged(status),
                ),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: categoryFilter,
              isDense: true,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Categoria',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                for (final category in categories)
                  DropdownMenuItem(value: category.id, child: Text(category.name)),
              ],
              onChanged: onCategoryChanged,
            ),
          ],
        ],
      ),
    );
  }
}
