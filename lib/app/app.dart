import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/budget/data/budget_repository.dart';
import '../features/budget/presentation/bloc/budget_bloc.dart';
import '../features/organization/data/organization_repository.dart';
import '../features/purchase_request/data/purchase_request_repository.dart';
import '../features/purchase_request/presentation/bloc/request_list_bloc.dart';
import '../features/workflow/data/workflow_repository.dart';
import '../features/workflow/presentation/bloc/inbox_bloc.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root application widget for ZWorkflow.
///
/// Sets up global repository and BLoC providers, adaptive styling
/// for Material (Android) and Cupertino (iOS), localization delegates,
/// and declarative navigation via [GoRouter].
class ZWorkflowApp extends StatefulWidget {
  /// Creates the root [ZWorkflowApp].
  const ZWorkflowApp({
    super.key,
    this.authRepository,
    this.organizationRepository,
    this.purchaseRequestRepository,
    this.workflowRepository,
    this.budgetRepository,
    this.authBloc,
    this.requestListBloc,
    this.inboxBloc,
    this.budgetBloc,
    this.locale,
  });

  /// Optional locale to override device locale.
  final Locale? locale;

  /// Optional injected [AuthRepository]. If null, a default instance is created.
  final AuthRepository? authRepository;

  /// Optional injected [OrganizationRepository].
  final OrganizationRepository? organizationRepository;

  /// Optional injected [PurchaseRequestRepository].
  final PurchaseRequestRepository? purchaseRequestRepository;

  /// Optional injected [WorkflowRepository].
  final WorkflowRepository? workflowRepository;

  /// Optional injected [BudgetRepository].
  final BudgetRepository? budgetRepository;

  /// Optional injected [AuthBloc]. If null, one will be created.
  final AuthBloc? authBloc;

  /// Optional injected [RequestListBloc].
  final RequestListBloc? requestListBloc;

  /// Optional injected [InboxBloc].
  final InboxBloc? inboxBloc;

  /// Optional injected [BudgetBloc].
  final BudgetBloc? budgetBloc;

  @override
  State<ZWorkflowApp> createState() => _ZWorkflowAppState();
}

class _ZWorkflowAppState extends State<ZWorkflowApp> {
  late final AuthRepository _authRepository;
  late final OrganizationRepository _organizationRepository;
  late final PurchaseRequestRepository _purchaseRequestRepository;
  late final WorkflowRepository _workflowRepository;
  late final BudgetRepository _budgetRepository;

  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepository();
    _organizationRepository =
        widget.organizationRepository ?? OrganizationRepository();
    _purchaseRequestRepository =
        widget.purchaseRequestRepository ?? PurchaseRequestRepository();
    _workflowRepository =
        widget.workflowRepository ?? WorkflowRepository();
    _budgetRepository = widget.budgetRepository ??
        BudgetRepository(
          requestRepository: _purchaseRequestRepository,
        );

    _authBloc = widget.authBloc ??
        AuthBloc(authRepository: _authRepository)
      ..add(const AuthCheckRequested());

    _router = createRouter(
      _authBloc,
      requestListBloc: widget.requestListBloc,
      inboxBloc: widget.inboxBloc,
      budgetBloc: widget.budgetBloc,
    );
  }

  @override
  void dispose() {
    if (widget.authBloc == null) {
      _authBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = defaultTargetPlatform == TargetPlatform.iOS;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<OrganizationRepository>.value(
            value: _organizationRepository),
        RepositoryProvider<PurchaseRequestRepository>.value(
            value: _purchaseRequestRepository),
        RepositoryProvider<WorkflowRepository>.value(
            value: _workflowRepository),
        RepositoryProvider<BudgetRepository>.value(value: _budgetRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
        ],
        child: isCupertino
            ? CupertinoApp.router(
                title: 'ZWorkflow',
                debugShowCheckedModeBanner: false,
                locale: widget.locale,
                theme: AppTheme.cupertinoLight,
                routerConfig: _router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              )
            : MaterialApp.router(
                title: 'ZWorkflow',
                debugShowCheckedModeBanner: false,
                locale: widget.locale,
                theme: AppTheme.materialLight,
                darkTheme: AppTheme.materialDark,
                themeMode: ThemeMode.system,
                routerConfig: _router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              ),
      ),
    );
  }
}
