import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/features/organization/domain/models/employee.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';
import 'package:z_workflow/features/workflow/domain/models/approval_rule.dart';
import 'package:z_workflow/features/workflow/domain/services/workflow_engine.dart';

void main() {
  const engine = WorkflowEngine();

  group('WorkflowEngine - Rule Matching', () {
    const tenantDefaultCapex = ApprovalRule(
      id: 'rule-capex-default',
      type: RequestType.capex,
      minAmount: 0,
      maxAmount: 10000,
      requiredLevels: 2,
    );

    const deptSpecificCapex = ApprovalRule(
      id: 'rule-capex-dept1',
      departmentId: 'dept-it',
      type: RequestType.capex,
      minAmount: 0,
      maxAmount: 10000,
      requiredLevels: 1,
    );

    const tenantDefaultOpex = ApprovalRule(
      id: 'rule-opex-default',
      type: RequestType.opex,
      minAmount: 0,
      maxAmount: 5000,
      requiredLevels: 1,
    );

    final rules = [tenantDefaultCapex, deptSpecificCapex, tenantDefaultOpex];

    test('prioritizes department-specific rule over tenant-wide rule', () {
      const request = PurchaseRequest(
        id: 'req-1',
        requesterId: 'emp-1',
        requesterName: 'Mario Rossi',
        departmentId: 'dept-it',
        description: 'New server',
        estimatedAmount: 5000,
        type: RequestType.capex,
        status: RequestStatus.submitted,
      );

      final matched = engine.findMatchingRule(request: request, rules: rules);
      expect(matched, isNotNull);
      expect(matched!.id, equals('rule-capex-dept1'));
      expect(matched.requiredLevels, equals(1));
    });

    test('falls back to tenant default rule when department has no specific rule', () {
      const request = PurchaseRequest(
        id: 'req-2',
        requesterId: 'emp-2',
        requesterName: 'Luigi Bianchi',
        departmentId: 'dept-hr',
        description: 'New office desks',
        estimatedAmount: 4000,
        type: RequestType.capex,
        status: RequestStatus.submitted,
      );

      final matched = engine.findMatchingRule(request: request, rules: rules);
      expect(matched, isNotNull);
      expect(matched!.id, equals('rule-capex-default'));
      expect(matched.requiredLevels, equals(2));
    });

    test('filters rules strictly by request type (CAPEX vs OPEX)', () {
      const request = PurchaseRequest(
        id: 'req-3',
        requesterId: 'emp-1',
        requesterName: 'Mario Rossi',
        departmentId: 'dept-it',
        description: 'Software subscription',
        estimatedAmount: 1200,
        type: RequestType.opex,
        status: RequestStatus.submitted,
      );

      final matched = engine.findMatchingRule(request: request, rules: rules);
      expect(matched, isNotNull);
      expect(matched!.id, equals('rule-opex-default'));
      expect(matched.type, equals(RequestType.opex));
    });

    test('returns null when request amount exceeds all rule ranges', () {
      const request = PurchaseRequest(
        id: 'req-4',
        requesterId: 'emp-1',
        requesterName: 'Mario Rossi',
        departmentId: 'dept-it',
        description: 'Datacenter acquisition',
        estimatedAmount: 500000,
        type: RequestType.capex,
        status: RequestStatus.submitted,
      );

      final matched = engine.findMatchingRule(request: request, rules: rules);
      expect(matched, isNull);
    });
  });

  group('WorkflowEngine - Hierarchy & Chain Evaluation', () {
    // Hierarchy:
    // emp-junior -> manager: emp-lead
    // emp-lead   -> manager: emp-director
    // emp-director -> manager: emp-ceo
    // emp-ceo    -> manager: null
    final employeesMap = {
      'emp-junior': const Employee(
        id: 'emp-junior',
        uid: 'uid-junior',
        email: 'junior@company.com',
        displayName: 'Junior Dev',
        departmentId: 'dept-it',
        managerId: 'emp-lead',
      ),
      'emp-lead': const Employee(
        id: 'emp-lead',
        uid: 'uid-lead',
        email: 'lead@company.com',
        displayName: 'Team Lead',
        departmentId: 'dept-it',
        managerId: 'emp-director',
      ),
      'emp-director': const Employee(
        id: 'emp-director',
        uid: 'uid-director',
        email: 'director@company.com',
        displayName: 'IT Director',
        departmentId: 'dept-it',
        managerId: 'emp-ceo',
      ),
      'emp-ceo': const Employee(
        id: 'emp-ceo',
        uid: 'uid-ceo',
        email: 'ceo@company.com',
        displayName: 'CEO',
        departmentId: 'dept-exec',
      ),
    };

    test('builds single level approval chain', () {
      const request = PurchaseRequest(
        id: 'req-10',
        requesterId: 'emp-junior',
        requesterName: 'Junior Dev',
        departmentId: 'dept-it',
        description: 'Monitor',
        estimatedAmount: 300,
        type: RequestType.opex,
        status: RequestStatus.submitted,
      );

      const rules = [
        ApprovalRule(
          id: 'rule-low-opex',
          type: RequestType.opex,
          minAmount: 0,
          maxAmount: 1000,
          requiredLevels: 1,
        ),
      ];

      final evaluation = engine.evaluate(
        request: request,
        rules: rules,
        employeesById: employeesMap,
      );

      expect(evaluation.requiredLevels, equals(1));
      expect(evaluation.approvalChain, equals(['emp-lead']));
    });

    test('builds multi-level sequential approval chain up the tree', () {
      const request = PurchaseRequest(
        id: 'req-11',
        requesterId: 'emp-junior',
        requesterName: 'Junior Dev',
        departmentId: 'dept-it',
        description: 'New workstation',
        estimatedAmount: 3500,
        type: RequestType.capex,
        status: RequestStatus.submitted,
      );

      const rules = [
        ApprovalRule(
          id: 'rule-high-capex',
          type: RequestType.capex,
          minAmount: 1000,
          maxAmount: 10000,
          requiredLevels: 3,
        ),
      ];

      final evaluation = engine.evaluate(
        request: request,
        rules: rules,
        employeesById: employeesMap,
      );

      expect(evaluation.requiredLevels, equals(3));
      expect(evaluation.approvalChain,
          equals(['emp-lead', 'emp-director', 'emp-ceo']));
    });

    test('handles top of hierarchy when fewer managers exist than required levels', () {
      const request = PurchaseRequest(
        id: 'req-12',
        requesterId: 'emp-director',
        requesterName: 'IT Director',
        departmentId: 'dept-it',
        description: 'Cloud contract',
        estimatedAmount: 25000,
        type: RequestType.opex,
        status: RequestStatus.submitted,
      );

      const rules = [
        ApprovalRule(
          id: 'rule-enterprise',
          type: RequestType.opex,
          minAmount: 0,
          maxAmount: 50000,
          requiredLevels: 3,
        ),
      ];

      final evaluation = engine.evaluate(
        request: request,
        rules: rules,
        employeesById: employeesMap,
      );

      // Only CEO is above IT Director
      expect(evaluation.approvalChain, equals(['emp-ceo']));
    });

    test('buildApprovalChain directly with custom levels', () {
      final chain = engine.buildApprovalChain(
        requesterId: 'emp-junior',
        requiredLevels: 2,
        employeesById: employeesMap,
      );

      expect(chain, equals(['emp-lead', 'emp-director']));
    });
  });
}
