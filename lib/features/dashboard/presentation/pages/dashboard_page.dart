import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../budget/domain/models/budget.dart';
import '../../../budget/presentation/bloc/budget_bloc.dart';
import '../../../purchase_request/domain/enums/request_enums.dart';
import '../../../purchase_request/domain/models/purchase_request.dart';
import '../../../purchase_request/presentation/bloc/request_list_bloc.dart';
import '../../../purchase_request/presentation/pages/request_detail_page.dart';
import '../../../workflow/presentation/bloc/inbox_bloc.dart';

/// Main dashboard showing live summary counters, pending approvals,
/// budget status, and recent purchase requests with detail navigation.
class DashboardPage extends StatelessWidget {
  /// Creates a [DashboardPage].
  const DashboardPage({
    super.key,
    this.requestListBloc,
    this.inboxBloc,
    this.budgetBloc,
    this.authBloc,
  });

  /// Optional injected [RequestListBloc] (useful for tests or standalone usage).
  final RequestListBloc? requestListBloc;

  /// Optional injected [InboxBloc] (useful for tests or standalone usage).
  final InboxBloc? inboxBloc;

  /// Optional injected [BudgetBloc] (useful for tests or standalone usage).
  final BudgetBloc? budgetBloc;

  /// Optional injected [AuthBloc] (useful for tests or standalone usage).
  final AuthBloc? authBloc;

  T? _resolveBloc<T extends BlocBase<Object?>>(
    BuildContext context,
    T? explicitBloc,
  ) {
    if (explicitBloc != null) return explicitBloc;
    try {
      return BlocProvider.of<T>(context);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAuthBloc = _resolveBloc<AuthBloc>(context, authBloc);
    final activeInboxBloc = _resolveBloc<InboxBloc>(context, inboxBloc);
    final activeRequestBloc =
        _resolveBloc<RequestListBloc>(context, requestListBloc);
    final activeBudgetBloc = _resolveBloc<BudgetBloc>(context, budgetBloc);

    // If no BLoCs are available in context or explicitly (e.g. basic widget tests),
    // render with initial fallback states so no ProviderNotFoundException is thrown.
    if (activeAuthBloc == null &&
        activeInboxBloc == null &&
        activeRequestBloc == null &&
        activeBudgetBloc == null) {
      return const _DashboardLayout(
        authState: AuthInitial(),
        inboxState: InboxInitial(),
        requestState: RequestListInitial(),
        budgetState: BudgetInitial(),
      );
    }

    Future<void> refresh() async {
      final authState = activeAuthBloc?.state;
      final user =
          authState is AuthAuthenticated ? authState.user : AppUser.empty;
      final tenantId = user.tenantId ?? 'tenant_zaramella';
      final employeeId = user.employeeId ?? user.uid;

      activeRequestBloc?.add(RequestListLoadAll(tenantId));
      activeInboxBloc?.add(InboxLoadPending(
        tenantId: tenantId,
        approverEmployeeId: employeeId,
      ));
      activeBudgetBloc?.add(BudgetLoadAll(
        tenantId: tenantId,
        year: DateTime.now().year,
      ));
    }

    return StreamBuilder<AuthState>(
      stream: activeAuthBloc?.stream,
      initialData: activeAuthBloc?.state ?? const AuthInitial(),
      builder: (context, authSnapshot) {
        final authState = authSnapshot.data ?? const AuthInitial();

        return StreamBuilder<InboxState>(
          stream: activeInboxBloc?.stream,
          initialData: activeInboxBloc?.state ?? const InboxInitial(),
          builder: (context, inboxSnapshot) {
            final inboxState = inboxSnapshot.data ?? const InboxInitial();

            return StreamBuilder<RequestListState>(
              stream: activeRequestBloc?.stream,
              initialData:
                  activeRequestBloc?.state ?? const RequestListInitial(),
              builder: (context, requestSnapshot) {
                final requestState =
                    requestSnapshot.data ?? const RequestListInitial();

                return StreamBuilder<BudgetState>(
                  stream: activeBudgetBloc?.stream,
                  initialData:
                      activeBudgetBloc?.state ?? const BudgetInitial(),
                  builder: (context, budgetSnapshot) {
                    final budgetState =
                        budgetSnapshot.data ?? const BudgetInitial();

                    return _DashboardLayout(
                      authState: authState,
                      inboxState: inboxState,
                      requestState: requestState,
                      budgetState: budgetState,
                      onRefresh: refresh,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  const _DashboardLayout({
    required this.authState,
    required this.inboxState,
    required this.requestState,
    required this.budgetState,
    this.onRefresh,
  });

  final AuthState authState;
  final InboxState inboxState;
  final RequestListState requestState;
  final BudgetState budgetState;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Current user resolution
    final user =
        authState is AuthAuthenticated ? authState.user : AppUser.empty;
    final currentEmployeeId = user.employeeId ?? user.uid;
    final userName = user.displayName;

    // 1. Pending Approvals counter
    String pendingValue = '—';
    int pendingCount = 0;
    if (inboxState is InboxLoaded) {
      pendingCount = (inboxState as InboxLoaded).pendingRequests.length;
      pendingValue = pendingCount.toString();
    } else if (inboxState is InboxLoading) {
      pendingValue = '...';
    }

    // 2. My Requests counter
    String myRequestsValue = '—';
    if (requestState is RequestListLoaded) {
      final requests = (requestState as RequestListLoaded).requests;
      if (currentEmployeeId.isNotEmpty) {
        final count =
            requests.where((r) => r.requesterId == currentEmployeeId).length;
        myRequestsValue = count.toString();
      } else {
        myRequestsValue = requests.length.toString();
      }
    } else if (requestState is RequestListLoading) {
      myRequestsValue = '...';
    }

    // 3. CAPEX Budget
    String capexValue = '—';
    String? capexSubtitle;
    if (budgetState is BudgetLoaded) {
      var totalAllocated = 0.0;
      var totalConsumed = 0.0;
      for (final b in (budgetState as BudgetLoaded).statuses) {
        totalAllocated += b.allocatedCapex;
        totalConsumed += b.consumedCapex;
      }
      final remaining = totalAllocated - totalConsumed;
      if (totalAllocated >= 1000) {
        capexValue = '€ ${(totalAllocated / 1000).toStringAsFixed(0)}k';
      } else {
        capexValue = '€ ${totalAllocated.toStringAsFixed(0)}';
      }
      if (totalAllocated > 0) {
        capexSubtitle =
            '€ ${(remaining / 1000).toStringAsFixed(0)}k ${l10n.budgetRemaining.toLowerCase()}';
      }
    } else if (budgetState is BudgetLoading) {
      capexValue = '...';
    }

    // 4. OPEX Budget
    String opexValue = '—';
    String? opexSubtitle;
    if (budgetState is BudgetLoaded) {
      var totalAllocated = 0.0;
      var totalConsumed = 0.0;
      for (final b in (budgetState as BudgetLoaded).statuses) {
        totalAllocated += b.allocatedOpex;
        totalConsumed += b.consumedOpex;
      }
      final remaining = totalAllocated - totalConsumed;
      if (totalAllocated >= 1000) {
        opexValue = '€ ${(totalAllocated / 1000).toStringAsFixed(0)}k';
      } else {
        opexValue = '€ ${totalAllocated.toStringAsFixed(0)}';
      }
      if (totalAllocated > 0) {
        opexSubtitle =
            '€ ${(remaining / 1000).toStringAsFixed(0)}k ${l10n.budgetRemaining.toLowerCase()}';
      }
    } else if (budgetState is BudgetLoading) {
      opexValue = '...';
    }

    Widget content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => context.push(AppRoutes.newRequest),
                icon: const Icon(Icons.add),
                tooltip: l10n.newRequest,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Approver alert banner if there are pending approvals
          if (pendingCount > 0) ...[
            Card(
              color: AppColors.statusPending.withValues(alpha: 0.12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.statusPending.withValues(alpha: 0.4),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go(AppRoutes.inbox),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.statusPending.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pending_actions_rounded,
                          color: AppColors.statusPending,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.requestsToApprove(pendingCount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tocca per esaminare e autorizzare',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Summary cards grid
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: l10n.pendingApproval,
                  value: pendingValue,
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.statusPending,
                  onTap: () => context.go(AppRoutes.inbox),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: l10n.myRequests,
                  value: myRequestsValue,
                  icon: Icons.description_outlined,
                  color: AppColors.primaryLight,
                  onTap: () => context.go(AppRoutes.requests),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: l10n.totalBudgetCapex,
                  value: capexValue,
                  subtitle: capexSubtitle,
                  icon: Icons.account_balance_outlined,
                  color: AppColors.budgetOk,
                  onTap: () => context.go(AppRoutes.budget),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: l10n.totalBudgetOpex,
                  value: opexValue,
                  subtitle: opexSubtitle,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.secondaryLight,
                  onTap: () => context.go(AppRoutes.budget),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent requests header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.allRequests,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (requestState is RequestListLoaded &&
                  (requestState as RequestListLoaded).requests.isNotEmpty)
                TextButton(
                  onPressed: () => context.go(AppRoutes.requests),
                  child: Text(l10n.requests),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Recent requests body
          _buildRecentRequests(context, l10n, theme),
        ],
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return Scaffold(
      body: SafeArea(child: content),
    );
  }

  Widget _buildRecentRequests(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (requestState is RequestListLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (requestState is RequestListLoaded) {
      final requests = (requestState as RequestListLoaded).requests;
      if (requests.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 48, color: AppColors.textSecondaryLight),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noResults,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final recentRequests = requests.take(5).toList();
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentRequests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _DashboardRequestItem(request: recentRequests[index]);
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined,
                  size: 48, color: AppColors.textSecondaryLight),
              const SizedBox(height: 8),
              Text(
                l10n.noResults,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardRequestItem extends StatelessWidget {
  const _DashboardRequestItem({required this.request});

  final PurchaseRequest request;

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.draft:
        return AppColors.statusDraft;
      case RequestStatus.submitted:
        return AppColors.statusSubmitted;
      case RequestStatus.pendingApproval:
        return AppColors.statusPending;
      case RequestStatus.approved:
        return AppColors.statusApproved;
      case RequestStatus.rejected:
        return AppColors.statusRejected;
      case RequestStatus.changesRequested:
        return AppColors.statusChangesRequested;
      case RequestStatus.resubmitted:
        return AppColors.statusSubmitted;
    }
  }

  String _statusText(RequestStatus status, AppLocalizations l10n) {
    switch (status) {
      case RequestStatus.draft:
        return l10n.draft;
      case RequestStatus.submitted:
        return l10n.submitted;
      case RequestStatus.pendingApproval:
        return l10n.statusPendingApproval;
      case RequestStatus.approved:
        return l10n.approved;
      case RequestStatus.rejected:
        return l10n.rejected;
      case RequestStatus.changesRequested:
        return l10n.statusChangesRequested;
      case RequestStatus.resubmitted:
        return l10n.submitted;
    }
  }

  Color _priorityColor(RequestPriority priority) {
    switch (priority) {
      case RequestPriority.low:
        return AppColors.priorityLow;
      case RequestPriority.medium:
        return AppColors.priorityMedium;
      case RequestPriority.high:
        return AppColors.priorityHigh;
      case RequestPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(request.status);

    final dateStr =
        '${request.requestDate.day.toString().padLeft(2, '0')}/${request.requestDate.month.toString().padLeft(2, '0')}/${request.requestDate.year}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RequestDetailPage(request: request),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Status chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.description,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusText(request.status, l10n).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Badges & Amount row
              Row(
                children: [
                  // Type badge (CAPEX / OPEX)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: request.type == RequestType.capex
                          ? AppColors.primaryLight.withValues(alpha: 0.1)
                          : AppColors.secondaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: request.type == RequestType.capex
                            ? AppColors.primaryLight
                            : AppColors.secondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Priority indicator dot
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _priorityColor(request.priority),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.priority.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),

                  const Spacer(),

                  // Amount
                  Text(
                    '€ ${request.estimatedAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Requester and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.requesterName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
