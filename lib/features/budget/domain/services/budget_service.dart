import '../../../purchase_request/domain/enums/request_enums.dart';
import '../../../purchase_request/domain/models/purchase_request.dart';
import '../models/budget.dart';

/// Service that computes budget status and validates requests against budget.
///
/// This service calculates consumed budget by summing approved purchase
/// requests and provides soft-block warnings when a new request would
/// exceed the remaining budget.
class BudgetService {
  /// Creates a [BudgetService].
  const BudgetService();

  /// Computes the [BudgetStatus] for a department.
  ///
  /// Takes the allocated budgets and a list of approved requests
  /// for the department in the given year.
  BudgetStatus computeStatus({
    required String departmentId,
    required String departmentName,
    required int year,
    required double allocatedCapex,
    required double allocatedOpex,
    required List<PurchaseRequest> approvedRequests,
  }) {
    var consumedCapex = 0.0;
    var consumedOpex = 0.0;

    for (final request in approvedRequests) {
      if (request.type == RequestType.capex) {
        consumedCapex += request.estimatedAmount;
      } else {
        consumedOpex += request.estimatedAmount;
      }
    }

    return BudgetStatus(
      departmentId: departmentId,
      departmentName: departmentName,
      year: year,
      allocatedCapex: allocatedCapex,
      allocatedOpex: allocatedOpex,
      consumedCapex: consumedCapex,
      consumedOpex: consumedOpex,
    );
  }

  /// Checks whether approving a request would exceed the department budget.
  ///
  /// Returns the amount by which the budget would be exceeded, or 0.0
  /// if the request fits within the budget.
  double checkBudgetExceedance({
    required PurchaseRequest request,
    required BudgetStatus budgetStatus,
  }) {
    if (request.type == RequestType.capex) {
      final afterApproval =
          budgetStatus.consumedCapex + request.estimatedAmount;
      final exceedance = afterApproval - budgetStatus.allocatedCapex;
      return exceedance > 0 ? exceedance : 0.0;
    } else {
      final afterApproval =
          budgetStatus.consumedOpex + request.estimatedAmount;
      final exceedance = afterApproval - budgetStatus.allocatedOpex;
      return exceedance > 0 ? exceedance : 0.0;
    }
  }

  /// Whether approving the request would exceed the budget.
  bool wouldExceedBudget({
    required PurchaseRequest request,
    required BudgetStatus budgetStatus,
  }) {
    return checkBudgetExceedance(
            request: request, budgetStatus: budgetStatus) >
        0;
  }
}
