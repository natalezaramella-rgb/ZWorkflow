import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_workflow/l10n/app_localizations.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../budget/data/budget_repository.dart';
import '../../../budget/domain/services/budget_service.dart';
import '../../../organization/data/organization_repository.dart';
import '../../../organization/domain/models/category.dart';
import '../../../organization/domain/models/department.dart';
import '../../../organization/domain/models/employee.dart';
import '../../../workflow/data/workflow_repository.dart';
import '../../../workflow/domain/models/approval_rule.dart';
import '../../../workflow/domain/services/workflow_engine.dart';
import '../../data/purchase_request_repository.dart';
import '../../domain/enums/request_enums.dart';
import '../../domain/models/purchase_request.dart';
import '../bloc/request_form_bloc.dart';

/// Form page for creating a new purchase request with budget soft-block checks.
class RequestFormPage extends StatelessWidget {
  /// Creates a [RequestFormPage].
  const RequestFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestFormBloc(
        repository: context.read<PurchaseRequestRepository>(),
      ),
      child: const _RequestFormView(),
    );
  }
}

class _RequestFormView extends StatefulWidget {
  const _RequestFormView();

  @override
  State<_RequestFormView> createState() => _RequestFormViewState();
}

class _RequestFormViewState extends State<_RequestFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _supplierController = TextEditingController();

  RequestType _selectedType = RequestType.opex;
  RequestPriority _selectedPriority = RequestPriority.medium;
  DateTime? _desiredDeliveryDate;

  String? _selectedDepartmentId;
  String? _selectedCategoryId;

  List<Department> _departments = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  final BudgetService _budgetService = const BudgetService();
  final WorkflowEngine _workflowEngine = const WorkflowEngine();

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final authState = context.read<AuthBloc>().state;
    final tenantId =
        authState is AuthAuthenticated ? authState.user.tenantId ?? 'tenant_zaramella' : 'tenant_zaramella';

    final orgRepo = context.read<OrganizationRepository>();
    try {
      final deptsStream = orgRepo.departmentsStream(tenantId).first;
      final catsStream = orgRepo.categoriesStream(tenantId).first;

      final results = await Future.wait([deptsStream, catsStream]);
      if (mounted) {
        setState(() {
          _departments = results[0] as List<Department>;
          _categories = results[1] as List<Category>;

          if (_departments.isNotEmpty) {
            _selectedDepartmentId = _departments.first.id;
          }
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (_) {
      // In test harnesses or when Firestore is unpopulated, default safely
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _desiredDeliveryDate = picked);
    }
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    final authState = context.read<AuthBloc>().state;
    final currentUser = authState is AuthAuthenticated ? authState.user : null;
    final tenantId = currentUser?.tenantId ?? 'tenant_zaramella';
    final deptId = _selectedDepartmentId ?? currentUser?.departmentId ?? 'dept_it';
    final budgetRepo = context.read<BudgetRepository>();
    final workflowRepo = context.read<WorkflowRepository>();
    final orgRepo = context.read<OrganizationRepository>();

    setState(() => _isLoading = true);

    // 1. Budget Soft-Block Exceedance Check
    bool willExceed = false;
    double exceededBy = 0;
    double remaining = 0;

    Department? dept;
    try {
      dept = _departments.firstWhere((d) => d.id == deptId);
    } catch (_) {}

    if (dept != null) {
      try {
        final status = await budgetRepo.getBudgetStatus(
          tenantId,
          dept,
          dept.year ?? DateTime.now().year,
        );
        final tempReq = PurchaseRequest(
          id: '',
          requesterId: '',
          requesterName: '',
          departmentId: deptId,
          description: '',
          estimatedAmount: amount,
          type: _selectedType,
          status: RequestStatus.draft,
        );
        exceededBy = _budgetService.checkBudgetExceedance(
          request: tempReq,
          budgetStatus: status,
        );
        if (exceededBy > 0) {
          willExceed = true;
          remaining = _selectedType == RequestType.capex
              ? status.remainingCapex
              : status.remainingOpex;
        }
      } catch (_) {
        final allocated = _selectedType == RequestType.capex ? dept.budgetCapex : dept.budgetOpex;
        if (amount > allocated) {
          willExceed = true;
          exceededBy = amount - allocated;
          remaining = allocated;
        }
      }
    }

    if (willExceed && mounted) {
      setState(() => _isLoading = false);
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
          title: const Text('Attenzione: Budget Superato'),
          content: Text(
            'L\'importo inserito (€ ${amount.toStringAsFixed(2)}) supera il budget residuo '
            '(${remaining.toStringAsFixed(2)} €) di € ${exceededBy.toStringAsFixed(2)}.\n\n'
            'Trattandosi di un avviso soft-block, puoi comunque inviare la richiesta per sottoporla all\'approvazione del management.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Invia Comunque'),
            ),
          ],
        ),
      );

      if (proceed != true || !mounted) return;
      setState(() => _isLoading = true);
    }

    // 2. Evaluate approval chain with WorkflowEngine
    List<ApprovalRule> rules = [];
    Map<String, Employee> employees = {};
    try {
      rules = await workflowRepo.getRules(tenantId);
      employees = await orgRepo.getEmployeesMap(tenantId);
    } catch (_) {}

    final catName = _categories
        .where((c) => c.id == _selectedCategoryId)
        .map((c) => c.name)
        .firstOrNull;

    final initialReq = PurchaseRequest(
      id: '',
      requesterId: currentUser?.employeeId ?? 'emp_it_dev',
      requesterName: currentUser != null && currentUser.displayName.isNotEmpty
          ? currentUser.displayName
          : 'Richiedente',
      departmentId: deptId,
      description: _descriptionController.text.trim(),
      estimatedAmount: amount,
      type: _selectedType,
      status: RequestStatus.pendingApproval,
      categoryId: _selectedCategoryId,
      categoryName: catName,
      supplierName: _supplierController.text.trim().isNotEmpty
          ? _supplierController.text.trim()
          : null,
      priority: _selectedPriority,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      desiredDeliveryDate: _desiredDeliveryDate,
      requestDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final eval = _workflowEngine.evaluate(
      request: initialReq,
      rules: rules,
      employeesById: employees,
    );

    final firstApproverId =
        eval.approvalChain.isNotEmpty ? eval.approvalChain.first : null;
    final firstApproverName =
        firstApproverId != null ? employees[firstApproverId]?.displayName : null;

    final finalReq = initialReq.copyWith(
      requiredApprovalLevels: eval.requiredLevels,
      currentApprovalLevel: 0,
      currentApproverEmployeeId: firstApproverId,
      currentApproverName: firstApproverName,
    );

    if (mounted) {
      context.read<RequestFormBloc>().add(
            RequestFormSubmit(tenantId: tenantId, request: finalReq),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<RequestFormBloc, RequestFormState>(
      listener: (context, state) {
        if (state is RequestFormSuccess) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.requestSubmitted),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is RequestFormError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.newRequest)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Department Dropdown (if departments loaded)
                  if (_departments.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDepartmentId,
                      decoration: InputDecoration(
                        labelText: l10n.department,
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                      items: _departments
                          .map((d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedDepartmentId = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: l10n.estimatedAmount,
                      prefixIcon: const Icon(Icons.euro),
                      prefixText: '€ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obbligatorio';
                      final parsed =
                          double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return 'Inserisci un importo valido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Type (CAPEX / OPEX)
                  Text(l10n.type,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  SegmentedButton<RequestType>(
                    segments: [
                      ButtonSegment(
                          value: RequestType.opex, label: Text(l10n.opex)),
                      ButtonSegment(
                          value: RequestType.capex, label: Text(l10n.capex)),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (s) =>
                        setState(() => _selectedType = s.first),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  if (_categories.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: l10n.category,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedCategoryId = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Priority
                  DropdownButtonFormField<RequestPriority>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      labelText: l10n.priority,
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: RequestPriority.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPriority = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Supplier
                  TextFormField(
                    controller: _supplierController,
                    decoration: InputDecoration(
                      labelText: l10n.supplier,
                      prefixIcon: const Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Desired delivery date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.desiredDeliveryDate,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _desiredDeliveryDate != null
                            ? '${_desiredDeliveryDate!.day}/${_desiredDeliveryDate!.month}/${_desiredDeliveryDate!.year}'
                            : '—',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.notes,
                      prefixIcon: const Icon(Icons.note_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _onSubmit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_isLoading ? l10n.loading : l10n.submit),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
