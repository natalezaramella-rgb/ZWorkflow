import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/enums/request_enums.dart';
import '../../domain/models/purchase_request.dart';
import '../bloc/request_list_bloc.dart';
import 'request_detail_page.dart';

/// Page showing the list of purchase requests with filters.
class RequestListPage extends StatelessWidget {
  /// Creates a [RequestListPage].
  const RequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<RequestListBloc, RequestListState>(
        builder: (context, state) {
          if (state is RequestListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RequestListLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 64, color: AppColors.textSecondaryLight),
                    const SizedBox(height: 16),
                    Text(l10n.noResults,
                        style: TextStyle(color: AppColors.textSecondaryLight)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _RequestCard(request: state.requests[index]);
              },
            );
          }

          return Center(child: Text(l10n.noResults));
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

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
    final statusColor = _statusColor(request.status);

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
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.description,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Details row
              Row(
                children: [
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

                  // Priority dot
                  Container(
                    width: 8,
                    height: 8,
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
              const SizedBox(height: 4),

              // Requester info
              Text(
                request.requesterName,
                style: theme.textTheme.bodySmall?.copyWith(
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
