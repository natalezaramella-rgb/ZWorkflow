import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/budget.dart';
import '../bloc/budget_bloc.dart';

/// Budget overview page showing CAPEX/OPEX status per department.
class BudgetPage extends StatelessWidget {
  /// Creates a [BudgetPage].
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Future<void> onRefresh() async {
            try {
              final authBloc = context.read<AuthBloc>();
              final authState = authBloc.state;
              final user =
                  authState is AuthAuthenticated ? authState.user : null;
              final tenantId = user?.tenantId ?? 'tenant_zaramella';
              context.read<BudgetBloc>().add(BudgetLoadAll(
                    tenantId: tenantId,
                    year: DateTime.now().year,
                  ));
            } catch (_) {}
          }

          if (state is BudgetLoaded) {
            if (state.statuses.isEmpty) {
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Text(l10n.noResults,
                            style:
                                TextStyle(color: AppColors.textSecondaryLight)),
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
                itemCount: state.statuses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _BudgetCard(status: state.statuses[index]);
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.status});
  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Department name
            Text(
              status.departmentName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // CAPEX budget bar
            _BudgetBar(
              label: l10n.capex,
              allocated: status.allocatedCapex,
              consumed: status.consumedCapex,
              remaining: status.remainingCapex,
              percentage: status.capexPercentage,
              isExceeded: status.isCapexExceeded,
            ),
            const SizedBox(height: 12),

            // OPEX budget bar
            _BudgetBar(
              label: l10n.opex,
              allocated: status.allocatedOpex,
              consumed: status.consumedOpex,
              remaining: status.remainingOpex,
              percentage: status.opexPercentage,
              isExceeded: status.isOpexExceeded,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({
    required this.label,
    required this.allocated,
    required this.consumed,
    required this.remaining,
    required this.percentage,
    required this.isExceeded,
  });

  final String label;
  final double allocated;
  final double consumed;
  final double remaining;
  final double percentage;
  final bool isExceeded;

  Color get _barColor {
    if (isExceeded) return AppColors.budgetDanger;
    if (percentage > 0.8) return AppColors.budgetWarning;
    return AppColors.budgetOk;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
            Text(
              '€ ${remaining.toStringAsFixed(0)} ${l10n.budgetRemaining.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isExceeded
                    ? AppColors.budgetDanger
                    : AppColors.textSecondaryLight,
                fontWeight: isExceeded ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: _barColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(_barColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '€ ${consumed.toStringAsFixed(0)} / € ${allocated.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondaryLight),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
