import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../organization/data/organization_repository.dart';
import '../../../workflow/data/workflow_repository.dart';
import '../../../workflow/domain/models/approval_step.dart';
import '../../domain/enums/request_enums.dart';
import '../../domain/models/purchase_request.dart';

/// Detailed view of a single purchase request with live approval timeline
/// and action buttons for authorized approvers.
class RequestDetailPage extends StatefulWidget {
  /// Creates a [RequestDetailPage].
  const RequestDetailPage({super.key, required this.request});

  /// The purchase request to display.
  final PurchaseRequest request;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  late PurchaseRequest _currentRequest;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  Future<void> _onApprove() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = currentUser?.tenantId ?? 'tenant_zaramella';
    final workflowRepo = context.read<WorkflowRepository>();
    final orgRepo = context.read<OrganizationRepository>();

    final commentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.approve),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vuoi confermare l\'approvazione per il livello ${_currentRequest.currentApprovalLevel + 1} di ${_currentRequest.requiredApprovalLevels}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: '${l10n.comment} (opzionale)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusApproved),
            child: Text(l10n.approve),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final employees = await orgRepo.getEmployeesMap(tenantId);
      final currentEmp = employees[currentUser?.employeeId];
      final nextApproverId = currentEmp?.managerId;
      final nextApproverName =
          nextApproverId != null ? employees[nextApproverId]?.displayName : null;

      await workflowRepo.processApproval(
        tenantId: tenantId,
        request: _currentRequest,
        approverId: currentUser?.employeeId ?? 'approver',
        approverName: currentUser?.displayName ?? 'Approvatore',
        comment: commentController.text.trim().isNotEmpty ? commentController.text.trim() : null,
        nextApproverId: nextApproverId,
        nextApproverName: nextApproverName,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        final nextLevel = _currentRequest.currentApprovalLevel + 1;
        final isComplete = nextLevel >= _currentRequest.requiredApprovalLevels;
        _currentRequest = _currentRequest.copyWith(
          status: isComplete ? RequestStatus.approved : RequestStatus.pendingApproval,
          currentApprovalLevel: nextLevel,
          currentApproverEmployeeId: isComplete ? null : nextApproverId,
          currentApproverName: isComplete ? null : nextApproverName,
        );
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.requestApproved),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onReject() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = currentUser?.tenantId ?? 'tenant_zaramella';
    final workflowRepo = context.read<WorkflowRepository>();

    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reject),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inserisci il motivo obbligatorio del rifiuto:'),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l10n.rejectionReason,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Motivazione obbligatoria' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRejected),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      await workflowRepo.processRejection(
        tenantId: tenantId,
        request: _currentRequest,
        approverId: currentUser?.employeeId ?? 'approver',
        approverName: currentUser?.displayName ?? 'Approvatore',
        reason: reasonController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _currentRequest = _currentRequest.copyWith(
          status: RequestStatus.rejected,
          currentApproverEmployeeId: null,
          currentApproverName: null,
        );
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.requestRejected),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onRequestChanges() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = currentUser?.tenantId ?? 'tenant_zaramella';
    final workflowRepo = context.read<WorkflowRepository>();

    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.requestChanges),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Indica al richiedente quali modifiche apportare:'),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Dettagli modifiche richieste',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.statusChangesRequested),
            child: Text(l10n.requestChanges),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      await workflowRepo.processChangeRequest(
        tenantId: tenantId,
        request: _currentRequest,
        approverId: currentUser?.employeeId ?? 'approver',
        approverName: currentUser?.displayName ?? 'Approvatore',
        changeNotes: noteController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _currentRequest = _currentRequest.copyWith(
          status: RequestStatus.changesRequested,
          currentApproverEmployeeId: null,
          currentApproverName: null,
        );
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.changesRequested),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = currentUser?.tenantId ?? 'tenant_zaramella';

    final canTakeAction = _currentRequest.status == RequestStatus.pendingApproval &&
        (currentUser?.isAdmin == true ||
            currentUser?.employeeId == _currentRequest.currentApproverEmployeeId);

    final workflowRepo = context.read<WorkflowRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requests)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Header
            Text(
              _currentRequest.description,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status & Type Chips
            Row(
              children: [
                _StatusChip(status: _currentRequest.status),
                const SizedBox(width: 8),
                _TypeChip(type: _currentRequest.type),
                const SizedBox(width: 8),
                _PriorityChip(priority: _currentRequest.priority),
              ],
            ),
            const SizedBox(height: 24),

            // Detail fields
            _DetailRow(
              label: l10n.estimatedAmount,
              value: '€ ${_currentRequest.estimatedAmount.toStringAsFixed(2)}',
            ),
            _DetailRow(label: l10n.department, value: _currentRequest.departmentId),
            _DetailRow(label: l10n.requester, value: _currentRequest.requesterName),
            if (_currentRequest.categoryName != null)
              _DetailRow(label: l10n.category, value: _currentRequest.categoryName!),
            if (_currentRequest.supplierName != null)
              _DetailRow(label: l10n.supplier, value: _currentRequest.supplierName!),
            if (_currentRequest.notes != null && _currentRequest.notes!.isNotEmpty)
              _DetailRow(label: l10n.notes, value: _currentRequest.notes!),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Approval Level Progress
            Text(
              l10n.approvalHistory,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.approvalLevel(
                _currentRequest.currentApprovalLevel,
                _currentRequest.requiredApprovalLevels,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            if (_currentRequest.currentApproverName != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.currentApprover}: ${_currentRequest.currentApproverName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Live Steps Timeline from Firestore
            StreamBuilder<List<ApprovalStep>>(
              stream: workflowRepo.approvalStepsStream(tenantId, _currentRequest.id),
              builder: (context, snapshot) {
                final steps = snapshot.data ?? [];
                if (steps.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_outlined,
                            size: 20, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 8),
                        Text(
                          'Nessuna azione ancora registrata nella cronologia.',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: steps.map((step) => _ApprovalStepCard(step: step)).toList(),
                );
              },
            ),

            const SizedBox(height: 80), // Padding for sticky bottom bar
          ],
        ),
      ),
      bottomNavigationBar: canTakeAction
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _isProcessing
                    ? const Center(
                        heightFactor: 1,
                        child: CircularProgressIndicator(),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onRequestChanges,
                              icon: const Icon(Icons.edit_note, size: 18),
                              label: const Text('Modifiche'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.statusChangesRequested,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onReject,
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(l10n.reject),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.statusRejected,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _onApprove,
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(l10n.approve),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.statusApproved,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : null,
    );
  }
}

class _ApprovalStepCard extends StatelessWidget {
  const _ApprovalStepCard({required this.step});
  final ApprovalStep step;

  @override
  Widget build(BuildContext context) {
    Color actionColor;
    IconData actionIcon;
    switch (step.action) {
      case ApprovalAction.approved:
        actionColor = AppColors.statusApproved;
        actionIcon = Icons.check_circle_outline;
      case ApprovalAction.rejected:
        actionColor = AppColors.statusRejected;
        actionIcon = Icons.cancel_outlined;
      case ApprovalAction.changesRequested:
        actionColor = AppColors.statusChangesRequested;
        actionIcon = Icons.edit_note;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withValues(alpha: 0.15),
          child: Icon(actionIcon, color: actionColor, size: 20),
        ),
        title: Text(step.approverName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${step.level + 1} • ${step.action.name.toUpperCase()}'),
            if (step.comment != null && step.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '"${step.comment!}"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        trailing: step.timestamp != null
            ? Text(
                '${step.timestamp!.day}/${step.timestamp!.month} ${step.timestamp!.hour.toString().padLeft(2, '0')}:${step.timestamp!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              )
            : null,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RequestStatus status;

  Color get _color {
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

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.name, style: TextStyle(color: _color, fontSize: 12)),
      backgroundColor: _color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final RequestType type;

  @override
  Widget build(BuildContext context) {
    final color =
        type == RequestType.capex ? AppColors.primaryLight : AppColors.secondaryLight;
    return Chip(
      label: Text(type.name.toUpperCase(), style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final RequestPriority priority;

  Color get _color {
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
    return Chip(
      label: Text(priority.name, style: TextStyle(color: _color, fontSize: 12)),
      backgroundColor: _color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
