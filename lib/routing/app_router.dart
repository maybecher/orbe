import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_user.dart';
import '../pages/admin_categories_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/admin_ticket_detail_page.dart';
import '../pages/admin_tickets_page.dart';
import '../pages/admin_users_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/new_ticket_page.dart';
import '../pages/profile_page.dart';
import '../pages/register_page.dart';
import '../pages/ticket_detail_page.dart';
import '../pages/tickets_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_main_scaffold.dart';
import '../widgets/main_scaffold.dart';

/// Named route paths for Orbe. Referencing these constants keeps navigation
/// calls free of magic strings.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String tickets = '/tickets';
  static const String newTicket = '/tickets/new';
  static const String ticketDetail = '/tickets/:id';
  static const String profile = '/profile';

  static String ticketDetailPath(String id) => '/tickets/$id';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String adminDashboard = '/admin';
  static const String adminTickets = '/admin/tickets';
  static const String adminTicketDetail = '/admin/tickets/:id';
  static const String adminUsers = '/admin/users';
  static const String adminCategories = '/admin/categories';
  static const String adminPrefix = '/admin';

  static String adminTicketDetailPath(String id) => '/admin/tickets/$id';

  static const Set<String> unauthenticated = {login, register, forgotPassword};
}

/// Bridges Riverpod's auth state to GoRouter: whenever authentication
/// changes, it notifies the router so [GoRouter.redirect] re-evaluates.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

/// The app's [GoRouter], exposed as a provider so it can react to auth
/// state and guard routes.
///
/// Admin/technician accounts live entirely under [AppRoutes.adminPrefix]
/// with no access to the regular user shell, and vice versa — the
/// redirect below enforces that split in both directions.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(authControllerProvider).value;
      final loggedIn = user != null;
      final goingToAuth =
          AppRoutes.unauthenticated.contains(state.matchedLocation);

      if (!loggedIn) return goingToAuth ? null : AppRoutes.login;

      final isAdmin = user.role == UserRole.admin;
      final goingToAdmin = state.matchedLocation.startsWith(AppRoutes.adminPrefix);

      if (goingToAuth) return isAdmin ? AppRoutes.adminDashboard : AppRoutes.home;
      if (isAdmin && !goingToAdmin) return AppRoutes.adminDashboard;
      if (!isAdmin && goingToAdmin) return AppRoutes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.newTicket,
        name: 'new-ticket',
        builder: (context, state) => const NewTicketPage(),
      ),
      GoRoute(
        path: AppRoutes.ticketDetail,
        name: 'ticket-detail',
        builder: (context, state) => TicketDetailPage(
          ticketId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTicketDetail,
        name: 'admin-ticket-detail',
        builder: (context, state) => AdminTicketDetailPage(
          ticketId: state.pathParameters['id']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.tickets,
              name: 'tickets',
              builder: (context, state) => const TicketsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminMainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminDashboard,
              name: 'admin-dashboard',
              builder: (context, state) => const AdminDashboardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminTickets,
              name: 'admin-tickets',
              builder: (context, state) => const AdminTicketsPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminUsers,
              name: 'admin-users',
              builder: (context, state) => const AdminUsersPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.adminCategories,
              name: 'admin-categories',
              builder: (context, state) => const AdminCategoriesPage(),
            ),
          ]),
        ],
      ),
    ],
  );
});
