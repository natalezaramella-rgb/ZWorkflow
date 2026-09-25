/// Centralized Firestore collection and document path helpers.
///
/// All Firestore paths are defined here to avoid string duplication
/// and ensure consistency across repositories.
abstract final class FirestorePaths {
  // Top-level collections
  static const String tenants = 'tenants';
  static const String users = 'users';

  // Tenant sub-collections
  static String departments(String tenantId) =>
      '$tenants/$tenantId/departments';

  static String department(String tenantId, String deptId) =>
      '$tenants/$tenantId/departments/$deptId';

  static String employees(String tenantId) => '$tenants/$tenantId/employees';

  static String employee(String tenantId, String employeeId) =>
      '$tenants/$tenantId/employees/$employeeId';

  static String categories(String tenantId) => '$tenants/$tenantId/categories';

  static String category(String tenantId, String catId) =>
      '$tenants/$tenantId/categories/$catId';

  static String costCenters(String tenantId, String deptId) =>
      '$tenants/$tenantId/departments/$deptId/costCenters';

  static String costCenter(
          String tenantId, String deptId, String ccId) =>
      '$tenants/$tenantId/departments/$deptId/costCenters/$ccId';

  static String approvalRules(String tenantId) =>
      '$tenants/$tenantId/approvalRules';

  static String approvalRule(String tenantId, String ruleId) =>
      '$tenants/$tenantId/approvalRules/$ruleId';

  static String purchaseRequests(String tenantId) =>
      '$tenants/$tenantId/purchaseRequests';

  static String purchaseRequest(String tenantId, String requestId) =>
      '$tenants/$tenantId/purchaseRequests/$requestId';

  static String approvalSteps(String tenantId, String requestId) =>
      '$tenants/$tenantId/purchaseRequests/$requestId/approvalSteps';

  static String approvalStep(
          String tenantId, String requestId, String stepId) =>
      '$tenants/$tenantId/purchaseRequests/$requestId/approvalSteps/$stepId';

  static String suppliers(String tenantId) => '$tenants/$tenantId/suppliers';

  static String supplier(String tenantId, String supplierId) =>
      '$tenants/$tenantId/suppliers/$supplierId';
}
