import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/features/auth/domain/models/app_user.dart';
import 'package:z_workflow/features/organization/domain/models/department.dart';
import 'package:z_workflow/features/organization/domain/models/employee.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';
import 'package:z_workflow/features/purchase_request/domain/models/purchase_request.dart';
import 'package:z_workflow/features/workflow/domain/models/approval_rule.dart';
import 'package:z_workflow/features/workflow/domain/models/approval_step.dart';

void main() {
  group('AppUser Model', () {
    test('serializes and deserializes correctly', () {
      const user = AppUser(
        uid: 'usr-1',
        email: 'user@example.com',
        displayName: 'John Doe',
        tenantId: 'tenant-abc',
        roles: [UserRole.requester, UserRole.approver],
      );

      final map = user.toFirestore();
      expect(map['email'], equals('user@example.com'));
      expect(map['displayName'], equals('John Doe'));
      expect(map['tenantId'], equals('tenant-abc'));
      expect(map['roles'], equals(['requester', 'approver']));

      final fromFirestore = AppUser.fromFirestore(map);
      expect(fromFirestore, equals(user));
      expect(fromFirestore.roles.contains(UserRole.approver), isTrue);
      expect(fromFirestore.roles.contains(UserRole.admin), isFalse);
    });

    test('empty user properties', () {
      expect(AppUser.empty.isEmpty, isTrue);
      expect(AppUser.empty.isNotEmpty, isFalse);
    });
  });

  group('Department Model', () {
    test('serializes and deserializes correctly', () {
      const dept = Department(
        id: 'dept-1',
        name: 'Engineering',
        budgetCapex: 150000,
        budgetOpex: 80000,
        year: 2026,
      );

      final map = dept.toFirestore();
      expect(map['name'], equals('Engineering'));
      expect(map['budgetCapex'], equals(150000));
      expect(map['budgetOpex'], equals(80000));
      expect(map['year'], equals(2026));

      final fromFirestore = Department.fromFirestore('dept-1', map);
      expect(fromFirestore, equals(dept));
    });
  });

  group('Employee Model', () {
    test('serializes and deserializes correctly with hierarchy manager', () {
      const emp = Employee(
        id: 'emp-1',
        uid: 'uid-firebase-1',
        email: 'emp@example.com',
        displayName: 'Alice Smith',
        departmentId: 'dept-1',
        managerId: 'emp-mgr',
        roles: [UserRole.requester],
        isActive: true,
      );

      final map = emp.toFirestore();
      expect(map['managerId'], equals('emp-mgr'));
      expect(map['departmentId'], equals('dept-1'));
      expect(map['isActive'], isTrue);

      final fromFirestore = Employee.fromFirestore('emp-1', map);
      expect(fromFirestore, equals(emp));
    });
  });

  group('PurchaseRequest Model', () {
    test('serializes, deserializes, and copies with updated fields', () {
      final now = DateTime(2026, 9, 23, 10, 0);
      final request = PurchaseRequest(
        id: 'req-1',
        requesterId: 'emp-1',
        requesterName: 'Alice',
        departmentId: 'dept-1',
        description: 'New Laptops',
        estimatedAmount: 5000,
        type: RequestType.capex,
        status: RequestStatus.draft,
        priority: RequestPriority.high,
        requestDate: now,
      );

      final map = request.toFirestore();
      expect(map['description'], equals('New Laptops'));
      expect(map['estimatedAmount'], equals(5000));
      expect(map['type'], equals('capex'));
      expect(map['status'], equals('draft'));
      expect(map['priority'], equals('high'));

      final fromFirestore = PurchaseRequest.fromFirestore('req-1', map);
      expect(fromFirestore.id, equals('req-1'));
      expect(fromFirestore.description, equals('New Laptops'));
      expect(fromFirestore.type, equals(RequestType.capex));
      expect(fromFirestore.status, equals(RequestStatus.draft));
      expect(fromFirestore.priority, equals(RequestPriority.high));

      final updated = request.copyWith(
        status: RequestStatus.pendingApproval,
        currentApprovalLevel: 1,
        currentApproverEmployeeId: 'emp-mgr',
      );
      expect(updated.status, equals(RequestStatus.pendingApproval));
      expect(updated.currentApprovalLevel, equals(1));
      expect(updated.currentApproverEmployeeId, equals('emp-mgr'));
    });
  });

  group('ApprovalRule & Step Models', () {
    test('ApprovalRule serialization', () {
      const rule = ApprovalRule(
        id: 'rule-1',
        type: RequestType.capex,
        minAmount: 10000,
        maxAmount: 50000,
        requiredLevels: 2,
      );

      final map = rule.toFirestore();
      expect(map['minAmount'], equals(10000));
      expect(map['requiredLevels'], equals(2));

      final fromFirestore = ApprovalRule.fromFirestore('rule-1', map);
      expect(fromFirestore.id, equals(rule.id));
      expect(fromFirestore.minAmount, equals(rule.minAmount));
    });

    test('ApprovalStep serialization', () {
      final now = DateTime(2026, 9, 23, 11, 0);
      final step = ApprovalStep(
        id: 'step-1',
        approverId: 'emp-mgr',
        approverName: 'Manager Bob',
        level: 1,
        action: ApprovalAction.approved,
        comment: 'All clear',
        timestamp: now,
      );

      final map = step.toFirestore();
      expect(map['action'], equals('approved'));
      expect(map['comment'], equals('All clear'));
      expect(map['level'], equals(1));

      final fromFirestore = ApprovalStep.fromFirestore('step-1', map);
      expect(fromFirestore.action, equals(ApprovalAction.approved));
      expect(fromFirestore.comment, equals('All clear'));
    });
  });
}
