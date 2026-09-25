import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../organization/domain/models/department.dart';
import '../../purchase_request/data/purchase_request_repository.dart';
import '../domain/models/budget.dart';
import '../domain/services/budget_service.dart';

/// Repository for computing and reading budget data.
class BudgetRepository {
  /// Creates a [BudgetRepository].
  BudgetRepository({
    FirebaseFirestore? firestore,
    PurchaseRequestRepository? requestRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _requestRepository =
            requestRepository ?? PurchaseRequestRepository();

  final FirebaseFirestore _firestore;
  final PurchaseRequestRepository _requestRepository;
  final BudgetService _budgetService = const BudgetService();

  /// Computes the budget status for a department in a given year.
  Future<BudgetStatus> getBudgetStatus(
    String tenantId,
    Department department,
    int year,
  ) async {
    final approvedRequests =
        await _requestRepository.getApprovedRequestsForDepartment(
      tenantId,
      department.id,
      year,
    );

    return _budgetService.computeStatus(
      departmentId: department.id,
      departmentName: department.name,
      year: year,
      allocatedCapex: department.budgetCapex,
      allocatedOpex: department.budgetOpex,
      approvedRequests: approvedRequests,
    );
  }

  /// Computes the budget status for all departments in a given year.
  Future<List<BudgetStatus>> getAllBudgetStatuses(
    String tenantId,
    int year,
  ) async {
    final deptSnapshot = await _firestore
        .collection(FirestorePaths.departments(tenantId))
        .get();

    final departments = deptSnapshot.docs
        .map((doc) => Department.fromFirestore(doc.id, doc.data()))
        .toList();

    final statuses = <BudgetStatus>[];
    for (final dept in departments) {
      final status = await getBudgetStatus(tenantId, dept, year);
      statuses.add(status);
    }

    return statuses;
  }
}
