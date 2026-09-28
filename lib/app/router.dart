import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../features/auth/domain/models/app_user.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/budget/data/budget_repository.dart';
import '../features/budget/presentation/bloc/budget_bloc.dart';
import '../features/budget/presentation/pages/budget_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/organization/presentation/pages/organization_settings_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/purchase_request/data/purchase_request_repository.dart';
import '../features/purchase_request/presentation/bloc/request_list_bloc.dart';
import '../features/purchase_request/presentation/pages/request_form_page.dart';
import '../features/purchase_request/presentation/pages/request_list_page.dart';
import '../features/workflow/presentation/bloc/inbox_bloc.dart';
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
GoRouter createRouter(
  AuthBloc authBloc, {
  RequestListBloc? requestListBloc,
  InboxBloc? inboxBloc,
  BudgetBloc? budgetBloc,
}) {
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

      // Main shell with drawer and scoped BLoC providers
      ShellRoute(
        builder: (context, state, child) => _AppShell(
          currentLocation: state.matchedLocation,
          requestListBloc: requestListBloc,
          inboxBloc: inboxBloc,
          budgetBloc: budgetBloc,
          child: child,
        ),
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

/// Shell widget that provides scoped BLoCs for requests, inbox, and budget,
/// and wraps main pages with a responsive Drawer and AppBar.
class _AppShell extends StatefulWidget {
  const _AppShell({
    required this.child,
    required this.currentLocation,
    this.requestListBloc,
    this.inboxBloc,
    this.budgetBloc,
  });

  final Widget child;
  final String currentLocation;
  final RequestListBloc? requestListBloc;
  final InboxBloc? inboxBloc;
  final BudgetBloc? budgetBloc;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  RequestListBloc? _requestListBloc;
  InboxBloc? _inboxBloc;
  BudgetBloc? _budgetBloc;
  bool _ownsRequestListBloc = false;
  bool _ownsInboxBloc = false;
  bool _ownsBudgetBloc = false;
  String? _lastLoadedEmployeeId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestListBloc == null) {
      _initBlocs();
    }
  }

  void _initBlocs() {
    if (widget.requestListBloc != null) {
      _requestListBloc = widget.requestListBloc;
      _ownsRequestListBloc = false;
    } else {
      _requestListBloc = RequestListBloc(
        repository: context.read<PurchaseRequestRepository>(),
      );
      _ownsRequestListBloc = true;
    }

    if (widget.inboxBloc != null) {
      _inboxBloc = widget.inboxBloc;
      _ownsInboxBloc = false;
    } else {
      _inboxBloc = InboxBloc(
        requestRepository: context.read<PurchaseRequestRepository>(),
      );
      _ownsInboxBloc = true;
    }

    if (widget.budgetBloc != null) {
      _budgetBloc = widget.budgetBloc;
      _ownsBudgetBloc = false;
    } else {
      _budgetBloc = BudgetBloc(
        repository: context.read<BudgetRepository>(),
      );
      _ownsBudgetBloc = true;
    }

    _loadDataForCurrentUser();
  }

  void _loadDataForCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = user?.tenantId ?? 'tenant_zaramella';
    final employeeId = user?.employeeId ?? user?.uid ?? '';
    _lastLoadedEmployeeId = employeeId;

    _requestListBloc?.add(RequestListLoadAll(tenantId));
    _inboxBloc?.add(InboxLoadPending(
      tenantId: tenantId,
      approverEmployeeId: employeeId,
    ));
    _budgetBloc?.add(BudgetLoadAll(
      tenantId: tenantId,
      year: DateTime.now().year,
    ));
  }

  @override
  void dispose() {
    if (_ownsRequestListBloc) {
      _requestListBloc?.close();
    }
    if (_ownsInboxBloc) {
      _inboxBloc?.close();
    }
    if (_ownsBudgetBloc) {
      _budgetBloc?.close();
    }
    super.dispose();
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.currentLocation) {
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

    final providers = <BlocProvider>[];
    if (_requestListBloc != null) {
      providers.add(
          BlocProvider<RequestListBloc>.value(value: _requestListBloc!));
    }
    if (_inboxBloc != null) {
      providers.add(BlocProvider<InboxBloc>.value(value: _inboxBloc!));
    }
    if (_budgetBloc != null) {
      providers.add(BlocProvider<BudgetBloc>.value(value: _budgetBloc!));
    }

    return MultiBlocProvider(
      providers: providers,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            final currentEmployeeId =
                authState.user.employeeId ?? authState.user.uid;
            if (currentEmployeeId != _lastLoadedEmployeeId) {
              _loadDataForCurrentUser();
            }
          }
        },
        child: Scaffold(
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
                  currentLocation: widget.currentLocation,
                ),
                _DrawerItem(
                  icon: Icons.description_outlined,
                  label: l10n.requests,
                  route: AppRoutes.requests,
                  currentLocation: widget.currentLocation,
                ),
                _DrawerItem(
                  icon: Icons.inbox_outlined,
                  label: l10n.inbox,
                  route: AppRoutes.inbox,
                  currentLocation: widget.currentLocation,
                ),
                _DrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.budget,
                  route: AppRoutes.budget,
                  currentLocation: widget.currentLocation,
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: l10n.organization,
                  route: AppRoutes.organization,
                  currentLocation: widget.currentLocation,
                ),
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: l10n.profile,
                  route: AppRoutes.profile,
                  currentLocation: widget.currentLocation,
                ),
              ],
            ),
          ),
          floatingActionButton:
              widget.currentLocation == AppRoutes.requests ||
                      widget.currentLocation == AppRoutes.dashboard
                  ? FloatingActionButton.extended(
                      onPressed: () => context.push(AppRoutes.newRequest),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.newRequest),
                    )
                  : null,
          body: widget.child,
        ),
      ),
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
