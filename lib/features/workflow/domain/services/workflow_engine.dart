import '../../../organization/domain/models/employee.dart';
import '../../../purchase_request/domain/models/purchase_request.dart';
import '../models/approval_rule.dart';

/// Result of the workflow engine's rule evaluation.
class WorkflowEvaluation {
  /// Creates a [WorkflowEvaluation].
  const WorkflowEvaluation({
    required this.requiredLevels,
    required this.approvalChain,
    this.matchedRule,
  });

  /// Number of hierarchical levels required to approve.
  final int requiredLevels;

  /// Ordered list of approver employee IDs forming the approval chain.
  final List<String> approvalChain;

  /// The rule that was matched, if any.
  final ApprovalRule? matchedRule;
}

/// The core workflow engine that determines approval requirements.
///
/// Given a purchase request, the available approval rules, and the
/// organizational hierarchy, this engine:
/// 1. Finds the matching rule based on request type, amount, and department.
/// 2. Determines how many levels of approval are required.
/// 3. Walks up the hierarchy tree to build the approval chain.
class WorkflowEngine {
  /// Creates a [WorkflowEngine].
  const WorkflowEngine();

  /// Finds the applicable approval rule for the given request.
  ///
  /// Rules are matched by:
  /// 1. First, look for department-specific rules matching the request's
  ///    type and amount range.
  /// 2. If no department-specific rule is found, fall back to tenant-wide
  ///    default rules (where [ApprovalRule.departmentId] is null).
  /// 3. If no rule matches at all, returns null (defaults to 1 level).
  ApprovalRule? findMatchingRule({
    required PurchaseRequest request,
    required List<ApprovalRule> rules,
  }) {
    // Filter rules by request type
    final typeRules =
        rules.where((rule) => rule.type == request.type).toList();

    // Try department-specific rules first
    final deptRules = typeRules
        .where((rule) => rule.departmentId == request.departmentId)
        .toList();

    final deptMatch = _findAmountMatch(deptRules, request.estimatedAmount);
    if (deptMatch != null) return deptMatch;

    // Fall back to default (tenant-wide) rules
    final defaultRules = typeRules.where((rule) => rule.isDefault).toList();
    return _findAmountMatch(defaultRules, request.estimatedAmount);
  }

  /// Builds the approval chain by walking up the hierarchy tree.
  ///
  /// Starting from the requester, walks up through [Employee.managerId]
  /// links to collect [requiredLevels] approvers.
  ///
  /// Returns the ordered list of employee IDs who must approve.
  /// If the hierarchy is shorter than [requiredLevels], the chain
  /// stops at the top of the tree.
  List<String> buildApprovalChain({
    required String requesterId,
    required int requiredLevels,
    required Map<String, Employee> employeesById,
  }) {
    final chain = <String>[];
    var currentId = requesterId;

    for (var i = 0; i < requiredLevels; i++) {
      final current = employeesById[currentId];
      if (current == null || current.managerId == null) break;

      final managerId = current.managerId!;
      if (chain.contains(managerId)) break; // Prevent circular references

      chain.add(managerId);
      currentId = managerId;
    }

    return chain;
  }

  /// Evaluates a purchase request and returns the full workflow evaluation.
  ///
  /// This is the main entry point that combines rule matching and
  /// chain building.
  WorkflowEvaluation evaluate({
    required PurchaseRequest request,
    required List<ApprovalRule> rules,
    required Map<String, Employee> employeesById,
  }) {
    final matchedRule = findMatchingRule(request: request, rules: rules);
    final requiredLevels = matchedRule?.requiredLevels ?? 1;

    final chain = buildApprovalChain(
      requesterId: request.requesterId,
      requiredLevels: requiredLevels,
      employeesById: employeesById,
    );

    return WorkflowEvaluation(
      requiredLevels: requiredLevels,
      approvalChain: chain,
      matchedRule: matchedRule,
    );
  }

  /// Finds a rule whose amount range contains the given amount.
  ApprovalRule? _findAmountMatch(List<ApprovalRule> rules, double amount) {
    for (final rule in rules) {
      if (amount >= rule.minAmount && amount < rule.maxAmount) {
        return rule;
      }
    }
    return null;
  }
}
