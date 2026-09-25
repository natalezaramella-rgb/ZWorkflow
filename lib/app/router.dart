import 'package:flutter/material.dart';
import 'package:z_workflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/budget/presentation/pages/budget_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/organization/presentation/pages/organization_settings_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/purchase_request/presentation/pages/request_form_page.dart';
import '../features/purchase_request/presentation/pages/request_list_page.dart';
import '../features/workflow/presentation/pages/approval_rules_page.dart';
import '../features/workflow/presentation/pages/inbox_page.dart';

/// Application route names.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String requests = '/requests';
  static const String newRequest = '/requests/new';
  static const String inbox = '/inbox';
  static const String budget = '/budget';
  static const String profile = '/profile';
  static const String organization = '/organization';
  static const String approvalRules = '/approval-rules';
}

/// Creates the application [GoRouter].
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Main shell with drawer
      ShellRoute(
        builder: (context, state, child) =>
            _AppShell(currentLocation: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.requests,
            builder: (context, state) => const RequestListPage(),
          ),
          GoRoute(
            path: AppRoutes.inbox,
            builder: (context, state) => const InboxPage(),
          ),
          GoRoute(
            path: AppRoutes.budget,
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.organization,
            builder: (context, state) =>
                const OrganizationSettingsPage(),
          ),
        ],
      ),

      // Full-screen routes
      GoRoute(
        path: AppRoutes.newRequest,
        builder: (context, state) => const RequestFormPage(),
      ),
      GoRoute(
        path: AppRoutes.approvalRules,
        builder: (context, state) => const ApprovalRulesPage(),
      ),
    ],
  );
}

/// Shell widget that wraps main pages with a Drawer.
class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (currentLocation) {
      case AppRoutes.dashboard:
        return l10n.dashboard;
      case AppRoutes.requests:
        return l10n.requests;
      case AppRoutes.inbox:
        return l10n.inbox;
      case AppRoutes.budget:
        return l10n.budget;
      case AppRoutes.profile:
        return l10n.profile;
      case AppRoutes.organization:
        return l10n.organization;
      default:
        return l10n.appTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_title(context))),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.work_outline_rounded,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: l10n.dashboard,
              route: AppRoutes.dashboard,
              currentLocation: currentLocation,
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: l10n.requests,
              route: AppRoutes.requests,
              currentLocation: currentLocation,
            ),
            _DrawerItem(
              icon: Icons.inbox_outlined,
              label: l10n.inbox,
              route: AppRoutes.inbox,
              currentLocation: currentLocation,
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.budget,
              route: AppRoutes.budget,
              currentLocation: currentLocation,
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: l10n.organization,
              route: AppRoutes.organization,
              currentLocation: currentLocation,
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: l10n.profile,
              route: AppRoutes.profile,
              currentLocation: currentLocation,
            ),
          ],
        ),
      ),
      floatingActionButton: currentLocation == AppRoutes.requests ||
              currentLocation == AppRoutes.dashboard
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.newRequest),
              icon: const Icon(Icons.add),
              label: Text(l10n.newRequest),
            )
          : null,
      body: child,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocation == route;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}

/// Converts a [Stream] into a [ChangeNotifier] for GoRouter refresh.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    // ignore: avoid_dynamic_calls
    _subscription.cancel();
    super.dispose();
  }
}
