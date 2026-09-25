import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/features/budget/domain/services/budget_service.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';

void main() {
  const budgetService = BudgetService();

  group('BudgetService - computeStatus', () {
    test('computes consumed and remaining amounts correctly for CAPEX and OPEX', () {
      final approvedRequests = [
        const PurchaseRequest(
          id: 'req-1',
          requesterId: 'emp-1',
          requesterName: 'Mario Rossi',
          departmentId: 'dept-it',
          description: 'Laptops',
          estimatedAmount: 20000,
          type: RequestType.capex,
          status: RequestStatus.approved,
        ),
        const PurchaseRequest(
          id: 'req-2',
          requesterId: 'emp-2',
          requesterName: 'Luigi Bianchi',
          departmentId: 'dept-it',
          description: 'Cloud hosting',
          estimatedAmount: 5000,
          type: RequestType.opex,
          status: RequestStatus.approved,
        ),
        const PurchaseRequest(
          id: 'req-3',
          requesterId: 'emp-3',
          requesterName: 'Anna Verdi',
          departmentId: 'dept-it',
          description: 'Monitors',
          estimatedAmount: 10000,
          type: RequestType.capex,
          status: RequestStatus.approved,
        ),
      ];

      final status = budgetService.computeStatus(
        departmentId: 'dept-it',
        departmentName: 'IT Department',
        year: 2026,
        allocatedCapex: 50000,
        allocatedOpex: 20000,
        approvedRequests: approvedRequests,
      );

      // CAPEX: 20k + 10k = 30k consumed / 50k allocated
      expect(status.consumedCapex, equals(30000));
      expect(status.remainingCapex, equals(20000));
      expect(status.capexPercentage, equals(0.6));
      expect(status.isCapexExceeded, isFalse);

      // OPEX: 5k consumed / 20k allocated
      expect(status.consumedOpex, equals(5000));
      expect(status.remainingOpex, equals(15000));
      expect(status.opexPercentage, equals(0.25));
      expect(status.isOpexExceeded, isFalse);

      // Totals
      expect(status.totalAllocated, equals(70000));
      expect(status.totalConsumed, equals(35000));
      expect(status.totalRemaining, equals(35000));
    });

    test('handles empty approved requests list with zero consumption', () {
      final status = budgetService.computeStatus(
        departmentId: 'dept-sales',
        departmentName: 'Sales',
        year: 2026,
        allocatedCapex: 10000,
        allocatedOpex: 15000,
        approvedRequests: const [],
      );

      expect(status.consumedCapex, equals(0.0));
      expect(status.consumedOpex, equals(0.0));
      expect(status.remainingCapex, equals(10000));
      expect(status.remainingOpex, equals(15000));
      expect(status.capexPercentage, equals(0.0));
      expect(status.opexPercentage, equals(0.0));
    });
  });

  group('BudgetService - Exceedance & Soft Block Checks', () {
    final currentStatus = budgetService.computeStatus(
      departmentId: 'dept-mktg',
      departmentName: 'Marketing',
      year: 2026,
      allocatedCapex: 20000,
      allocatedOpex: 10000,
      approvedRequests: const [
        PurchaseRequest(
          id: 'req-mktg-1',
          requesterId: 'emp-1',
          requesterName: 'Mario',
          departmentId: 'dept-mktg',
          description: 'Campaign A',
          estimatedAmount: 8500,
          type: RequestType.opex,
          status: RequestStatus.approved,
        ),
      ],
    );

    test('detects when a new OPEX request fits within remaining budget', () {
      const newRequest = PurchaseRequest(
        id: 'req-new-1',
        requesterId: 'emp-1',
        requesterName: 'Mario',
        departmentId: 'dept-mktg',
        description: 'Event flyers',
        estimatedAmount: 1000,
        type: RequestType.opex,
        status: RequestStatus.draft,
      );

      expect(budgetService.wouldExceedBudget(
        request: newRequest,
        budgetStatus: currentStatus,
      ), isFalse);

      expect(budgetService.checkBudgetExceedance(
        request: newRequest,
        budgetStatus: currentStatus,
      ), equals(0.0));
    });

    test('detects when a new OPEX request exceeds remaining budget (soft block)', () {
      // Current consumed OPEX = 8500 / 10000, remaining = 1500
      // Request for 3000 exceeds by 1500
      const newRequest = PurchaseRequest(
        id: 'req-new-2',
        requesterId: 'emp-1',
        requesterName: 'Mario',
        departmentId: 'dept-mktg',
        description: 'Billboard advertising',
        estimatedAmount: 3000,
        type: RequestType.opex,
        status: RequestStatus.draft,
      );

      expect(budgetService.wouldExceedBudget(
        request: newRequest,
        budgetStatus: currentStatus,
      ), isTrue);

      final exceedance = budgetService.checkBudgetExceedance(
        request: newRequest,
        budgetStatus: currentStatus,
      );
      expect(exceedance, equals(1500));
    });

    test('detects when a new CAPEX request exceeds remaining budget', () {
      // Allocated CAPEX = 20000, consumed = 0
      const newRequest = PurchaseRequest(
        id: 'req-new-3',
        requesterId: 'emp-1',
        requesterName: 'Mario',
        departmentId: 'dept-mktg',
        description: 'Video Production Rig',
        estimatedAmount: 25000,
        type: RequestType.capex,
        status: RequestStatus.draft,
      );

      expect(budgetService.wouldExceedBudget(
        request: newRequest,
        budgetStatus: currentStatus,
      ), isTrue);

      final exceedance = budgetService.checkBudgetExceedance(
        request: newRequest,
        budgetStatus: currentStatus,
      );
      expect(exceedance, equals(5000));
    });
  });
}
