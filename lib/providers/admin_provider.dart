import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/ticket.dart';
import 'auth_provider.dart';
import 'category_provider.dart';
import 'ticket_provider.dart';

/// Aggregate counts shown on the admin dashboard.
class AdminStats {
  const AdminStats({
    required this.totalTickets,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.closedCount,
    required this.totalUsers,
    required this.totalCategories,
  });

  final int totalTickets;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int closedCount;
  final int totalUsers;
  final int totalCategories;
}

/// Combines tickets, users and categories from their respective
/// repositories into the counts the admin dashboard displays.
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final tickets = await ref.watch(ticketRepositoryProvider).fetchAllTickets();
  final users = await ref.watch(authRepositoryProvider).fetchAllUsers();
  final categories = await ref.watch(categoryRepositoryProvider).fetchCategories();

  return AdminStats(
    totalTickets: tickets.length,
    openCount: tickets.where((t) => t.status == TicketStatus.open).length,
    inProgressCount:
        tickets.where((t) => t.status == TicketStatus.inProgress).length,
    resolvedCount: tickets.where((t) => t.status == TicketStatus.resolved).length,
    closedCount: tickets.where((t) => t.status == TicketStatus.closed).length,
    totalUsers: users.length,
    totalCategories: categories.length,
  );
});

/// Holds every registered account for the "Gerenciar usuários" screen.
class AdminUsersController extends AsyncNotifier<List<AppUser>> {
  @override
  Future<List<AppUser>> build() async {
    return ref.read(authRepositoryProvider).fetchAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    await ref.read(authRepositoryProvider).deleteAccount(userId);
    final current = state.value ?? const [];
    state = AsyncValue.data(current.where((u) => u.id != userId).toList());
  }
}

final adminUsersControllerProvider =
    AsyncNotifierProvider<AdminUsersController, List<AppUser>>(
  AdminUsersController.new,
);

/// Holds every ticket in the system for the admin "Todos os chamados"
/// screen, and lets the admin/technician change a ticket's status.
class AdminTicketsController extends AsyncNotifier<List<Ticket>> {
  @override
  Future<List<Ticket>> build() async {
    return ref.read(ticketRepositoryProvider).fetchAllTickets();
  }

  Future<void> updateStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    final repository = ref.read(ticketRepositoryProvider);
    final updated = await repository.updateStatus(ticketId: ticketId, status: status);
    final current = state.value ?? const [];
    state = AsyncValue.data([
      for (final ticket in current)
        if (ticket.id == updated.id) updated else ticket,
    ]);
  }
}

final adminTicketsControllerProvider =
    AsyncNotifierProvider<AdminTicketsController, List<Ticket>>(
  AdminTicketsController.new,
);

/// A time bucket the "atendidos" chart on the dashboard groups by.
enum StatsPeriod { day, week, month, year }

/// One bar in the "atendidos" chart: a period label and how many tickets
/// were resolved in it.
class AttendedBucket {
  const AttendedBucket({required this.label, required this.count});
  final String label;
  final int count;
}

/// Buckets every resolved ticket's [Ticket.resolvedAt] into the last 7
/// days, 8 weeks, 12 months or 5 years, depending on [period] — the data
/// behind the admin dashboard's "atendidos" chart.
final attendedStatsProvider =
    FutureProvider.family<List<AttendedBucket>, StatsPeriod>((ref, period) async {
  final tickets = await ref.watch(ticketRepositoryProvider).fetchAllTickets();
  final resolvedDates = tickets
      .where((t) => t.resolvedAt != null)
      .map((t) => t.resolvedAt!)
      .toList();

  final now = DateTime.now();

  switch (period) {
    case StatsPeriod.day:
      return List.generate(7, (i) {
        final day = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i));
        final count = resolvedDates
            .where((d) => d.year == day.year && d.month == day.month && d.day == day.day)
            .length;
        return AttendedBucket(label: _dayLabel(day), count: count);
      });

    case StatsPeriod.week:
      final currentWeekStart = _startOfWeek(now);
      return List.generate(8, (i) {
        final weekStart = currentWeekStart.subtract(Duration(days: (7 - i) * 7));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final count = resolvedDates
            .where((d) => !d.isBefore(weekStart) && d.isBefore(weekEnd))
            .length;
        return AttendedBucket(label: _dayLabel(weekStart), count: count);
      });

    case StatsPeriod.month:
      return List.generate(12, (i) {
        final monthDate = DateTime(now.year, now.month - (11 - i), 1);
        final count = resolvedDates
            .where((d) => d.year == monthDate.year && d.month == monthDate.month)
            .length;
        return AttendedBucket(label: _monthAbbrev(monthDate.month), count: count);
      });

    case StatsPeriod.year:
      return List.generate(5, (i) {
        final year = now.year - (4 - i);
        final count = resolvedDates.where((d) => d.year == year).length;
        return AttendedBucket(label: '$year', count: count);
      });
  }
});

String _dayLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String _monthAbbrev(int month) => const [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ][month - 1];

DateTime _startOfWeek(DateTime date) {
  final atMidnight = DateTime(date.year, date.month, date.day);
  return atMidnight.subtract(Duration(days: atMidnight.weekday - 1));
}
