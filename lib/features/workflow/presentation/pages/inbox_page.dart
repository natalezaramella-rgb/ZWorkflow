import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../purchase_request/domain/models/purchase_request.dart';
import '../../../purchase_request/presentation/pages/request_detail_page.dart';
import '../bloc/inbox_bloc.dart';

/// Inbox page showing requests pending approval for the current user.
class InboxPage extends StatelessWidget {
  /// Creates an [InboxPage].
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<InboxBloc, InboxState>(
        builder: (context, state) {
          if (state is InboxLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Future<void> onRefresh() async {
            try {
              final authBloc = context.read<AuthBloc>();
              final authState = authBloc.state;
              final user =
                  authState is AuthAuthenticated ? authState.user : null;
              final tenantId = user?.tenantId ?? 'tenant_zaramella';
              final employeeId = user?.employeeId ?? user?.uid ?? '';
              context.read<InboxBloc>().add(InboxLoadPending(
                    tenantId: tenantId,
                    approverEmployeeId: employeeId,
                  ));
            } catch (_) {}
          }

          if (state is InboxLoaded) {
            if (state.pendingRequests.isEmpty) {
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 64, color: AppColors.budgetOk),
                            const SizedBox(height: 16),
                            Text(
                              l10n.requestsToApprove(0),
                              style: TextStyle(
                                  color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.pendingRequests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _InboxCard(request: state.pendingRequests[index]);
                },
              ),
            );
          }

          return Center(child: Text(l10n.noResults));
        },
      ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({required this.request});
  final PurchaseRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.description,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '€ ${request.estimatedAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Requester and type
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(
                    request.requesterName,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    request.type.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Approval level info
              Text(
                l10n.approvalLevel(
                    request.currentApprovalLevel, request.requiredApprovalLevels),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailPage(request: request),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: Text(l10n.requestChanges),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusChangesRequested,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailPage(request: request),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.reject),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusRejected,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailPage(request: request),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.approve),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusApproved,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
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
