import 'package:flutter_test/flutter_test.dart';
import 'package:z_workflow/core/services/database_seeder.dart';
import 'package:z_workflow/features/purchase_request/domain/enums/request_enums.dart';

void main() {
  group('DatabaseSeeder Data Integrity Tests', () {
    test('Standard Departments contain valid budgets and unique IDs', () {
      final departments = DatabaseSeeder.getStandardDepartments();
      expect(departments, isNotEmpty);

      final ids = <String>{};
      for (final dept in departments) {
        expect(ids.add(dept.id), isTrue,
            reason: 'Department ID ${dept.id} should be unique');
        expect(dept.name, isNotEmpty);
        expect(dept.budgetCapex, isPositive);
        expect(dept.budgetOpex, isPositive);
        expect(dept.year, 2026);
        expect(dept.isActive, isTrue);
      }
    });

    test('Standard Categories have unique IDs and names', () {
      final categories = DatabaseSeeder.getStandardCategories();
      expect(categories, isNotEmpty);

      final ids = <String>{};
      for (final cat in categories) {
        expect(ids.add(cat.id), isTrue,
            reason: 'Category ID ${cat.id} should be unique');
        expect(cat.name, isNotEmpty);
        expect(cat.isActive, isTrue);
      }
    });

    test('Standard Employees hierarchy is acyclic and referentially valid', () {
      final employees = DatabaseSeeder.getStandardEmployees();
      final departments = DatabaseSeeder.getStandardDepartments();
      final deptIds = departments.map((d) => d.id).toSet();
      final empMap = {for (final e in employees) e.id: e};

      // Check unique IDs and valid emails
      expect(empMap.length, employees.length);
      for (final emp in employees) {
        expect(emp.email, contains('@'));
        expect(deptIds.contains(emp.departmentId), isTrue,
            reason: 'Employee department must match a valid department');
      }

      // Root of hierarchy check (exactly 1 top manager with managerId == null)
      final topManagers = employees.where((e) => e.managerId == null).toList();
      expect(topManagers.length, 1);
      expect(topManagers.first.id, 'emp_ceo');

      // Referential integrity & acyclic hierarchy verification
      for (final emp in employees) {
        if (emp.managerId != null) {
          expect(empMap.containsKey(emp.managerId), isTrue,
              reason: 'Manager ${emp.managerId} must exist in employee list');
        }

        // Trace up the hierarchy to detect cycles
        final visited = <String>{emp.id};
        String? currentManagerId = emp.managerId;
        while (currentManagerId != null) {
          expect(visited.contains(currentManagerId), isFalse,
              reason: 'Cycle detected in employee hierarchy: $currentManagerId');
          visited.add(currentManagerId);
          currentManagerId = empMap[currentManagerId]?.managerId;
        }
      }
    });

    test('Standard Approval Rules cover OPEX tiers and CAPEX with valid amounts',
        () {
      final rules = DatabaseSeeder.getStandardApprovalRules();
      expect(rules, isNotEmpty);

      final opexRules = rules.where((r) => r.type == RequestType.opex).toList();
      final capexRules = rules.where((r) => r.type == RequestType.capex).toList();

      expect(opexRules.length, greaterThanOrEqualTo(3));
      expect(capexRules, isNotEmpty);

      for (final rule in rules) {
        expect(rule.minAmount, greaterThanOrEqualTo(0));
        expect(rule.maxAmount, greaterThan(rule.minAmount));
        expect(rule.requiredLevels, greaterThanOrEqualTo(1));
      }
    });

    test('Sample Purchase Requests and Approval Steps reference valid entities',
        () {
      final requests = DatabaseSeeder.getSampleRequests();
      final stepsMap = DatabaseSeeder.getSampleApprovalSteps();
      final employees = DatabaseSeeder.getStandardEmployees();
      final empIds = employees.map((e) => e.id).toSet();
      final departments = DatabaseSeeder.getStandardDepartments();
      final deptIds = departments.map((d) => d.id).toSet();
      final requestIds = requests.map((r) => r.id).toSet();

      expect(requests, isNotEmpty);
      expect(stepsMap, isNotEmpty);

      for (final req in requests) {
        expect(empIds.contains(req.requesterId), isTrue);
        expect(deptIds.contains(req.departmentId), isTrue);
        expect(req.estimatedAmount, isPositive);
        expect(req.description, isNotEmpty);
      }

      for (final entry in stepsMap.entries) {
        final reqId = entry.key;
        expect(requestIds.contains(reqId), isTrue,
            reason: 'Step entry key must reference an existing sample request');
        for (final step in entry.value) {
          expect(empIds.contains(step.approverId), isTrue,
              reason: 'Step approver must be a valid employee');
          expect(step.level, greaterThanOrEqualTo(0));
        }
      }
    });
  });
}
