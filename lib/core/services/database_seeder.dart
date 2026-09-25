import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/organization/domain/models/category.dart';
import '../../features/organization/domain/models/department.dart';
import '../../features/organization/domain/models/employee.dart';
import '../../features/purchase_request/domain/enums/request_enums.dart';
import '../../features/purchase_request/domain/models/purchase_request.dart';
import '../../features/workflow/domain/models/approval_rule.dart';
import '../../features/workflow/domain/models/approval_step.dart';
import '../constants/firestore_paths.dart';

/// Service responsible for provisioning demo and initial data for a tenant
/// in Cloud Firestore or in local test memory.
class DatabaseSeeder {
  /// Creates a [DatabaseSeeder].
  DatabaseSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Default tenant ID used for seeding.
  static const String defaultTenantId = 'tenant_zaramella';

  /// Generates the standard departments list.
  static List<Department> getStandardDepartments({int year = 2026}) => [
        Department(
          id: 'dept_it',
          name: 'IT & Sistemi',
          budgetCapex: 50000,
          budgetOpex: 20000,
          year: year,
          isActive: true,
        ),
        Department(
          id: 'dept_prod',
          name: 'Produzione & Logistica',
          budgetCapex: 100000,
          budgetOpex: 40000,
          year: year,
          isActive: true,
        ),
        Department(
          id: 'dept_mktg',
          name: 'Marketing & Vendite',
          budgetCapex: 15000,
          budgetOpex: 30000,
          year: year,
          isActive: true,
        ),
        Department(
          id: 'dept_admin',
          name: 'Amministrazione & Finanza',
          budgetCapex: 10000,
          budgetOpex: 15000,
          year: year,
          isActive: true,
        ),
      ];

  /// Generates standard purchase categories.
  static List<Category> getStandardCategories() => const [
        Category(id: 'cat_hw', name: 'Hardware & Postazioni PC'),
        Category(id: 'cat_sw', name: 'Software & Licenze Cloud'),
        Category(id: 'cat_consulting', name: 'Consulenza & Servizi IT'),
        Category(id: 'cat_machinery', name: 'Macchinari & Attrezzature'),
        Category(id: 'cat_marketing', name: 'Campagne Pubblicitarie'),
        Category(id: 'cat_office', name: 'Cancelleria & Materiale Ufficio'),
      ];

  /// Generates standard hierarchical employees tree.
  ///
  /// Hierarchy:
  /// - emp_ceo (Mario Rossi - CEO)
  ///   - emp_it_dir (Luigi Bianchi - Direttore IT)
  ///     - emp_it_lead (Anna Verdi - Team Lead IT)
  ///       - emp_it_dev (Marco Neri - Senior Developer)
  ///   - emp_prod_mgr (Giuseppe Gialli - Resp. Produzione)
  ///   - emp_buyer (Elena Viola - Controller / Buyer)
  static List<Employee> getStandardEmployees() => const [
        Employee(
          id: 'emp_ceo',
          uid: 'uid_mario_rossi',
          email: 'mario.rossi@zaramella.com',
          displayName: 'Mario Rossi',
          departmentId: 'dept_admin',
          roles: [UserRole.superAdmin, UserRole.admin, UserRole.approver],
          managerId: null,
          isActive: true,
        ),
        Employee(
          id: 'emp_it_dir',
          uid: 'uid_luigi_bianchi',
          email: 'luigi.bianchi@zaramella.com',
          displayName: 'Luigi Bianchi',
          departmentId: 'dept_it',
          roles: [UserRole.approver, UserRole.requester],
          managerId: 'emp_ceo',
          isActive: true,
        ),
        Employee(
          id: 'emp_it_lead',
          uid: 'uid_anna_verdi',
          email: 'anna.verdi@zaramella.com',
          displayName: 'Anna Verdi',
          departmentId: 'dept_it',
          roles: [UserRole.approver, UserRole.requester],
          managerId: 'emp_it_dir',
          isActive: true,
        ),
        Employee(
          id: 'emp_it_dev',
          uid: 'uid_marco_neri',
          email: 'marco.neri@zaramella.com',
          displayName: 'Marco Neri',
          departmentId: 'dept_it',
          roles: [UserRole.requester],
          managerId: 'emp_it_lead',
          isActive: true,
        ),
        Employee(
          id: 'emp_prod_mgr',
          uid: 'uid_giuseppe_gialli',
          email: 'giuseppe.gialli@zaramella.com',
          displayName: 'Giuseppe Gialli',
          departmentId: 'dept_prod',
          roles: [UserRole.approver, UserRole.requester],
          managerId: 'emp_ceo',
          isActive: true,
        ),
        Employee(
          id: 'emp_buyer',
          uid: 'uid_elena_viola',
          email: 'elena.viola@zaramella.com',
          displayName: 'Elena Viola',
          departmentId: 'dept_admin',
          roles: [UserRole.controller, UserRole.requester],
          managerId: 'emp_ceo',
          isActive: true,
        ),
      ];

  /// Generates the standard approval rules.
  static List<ApprovalRule> getStandardApprovalRules() => const [
        // OPEX Tier 1: fino a € 1.000 -> 1 livello di approvazione
        ApprovalRule(
          id: 'rule_opex_tier1',
          type: RequestType.opex,
          minAmount: 0,
          maxAmount: 1000,
          requiredLevels: 1,
        ),
        // OPEX Tier 2: da € 1.000 a € 10.000 -> 2 livelli di approvazione
        ApprovalRule(
          id: 'rule_opex_tier2',
          type: RequestType.opex,
          minAmount: 1000,
          maxAmount: 10000,
          requiredLevels: 2,
        ),
        // OPEX Tier 3: oltre € 10.000 -> 3 livelli di approvazione
        ApprovalRule(
          id: 'rule_opex_tier3',
          type: RequestType.opex,
          minAmount: 10000,
          maxAmount: double.infinity,
          requiredLevels: 3,
        ),
        // CAPEX: Qualsiasi importo richiede almeno 2 livelli (Direttore + CEO)
        ApprovalRule(
          id: 'rule_capex_standard',
          type: RequestType.capex,
          minAmount: 0,
          maxAmount: double.infinity,
          requiredLevels: 2,
        ),
      ];

  /// Generates sample purchase requests with approval history.
  static List<PurchaseRequest> getSampleRequests() {
    final now = DateTime.now();

    return [
      // Richiesta 1: Già approvata (consuma 3.200 € dal budget OPEX IT)
      PurchaseRequest(
        id: 'req_seed_01',
        requesterId: 'emp_it_dev',
        requesterName: 'Marco Neri',
        departmentId: 'dept_it',
        description: 'Rinnovo licenze JetBrains All Products Pack & GitHub Enterprise',
        estimatedAmount: 3200,
        type: RequestType.opex,
        status: RequestStatus.approved,
        categoryId: 'cat_sw',
        categoryName: 'Software & Licenze Cloud',
        priority: RequestPriority.high,
        requestDate: now.subtract(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
        currentApprovalLevel: 2,
        requiredApprovalLevels: 2,
        notes: 'Licenze annuali indispensabili per lo sviluppo software.',
      ),

      // Richiesta 2: In attesa di approvazione (in carico ad Anna Verdi - Team Lead)
      PurchaseRequest(
        id: 'req_seed_02',
        requesterId: 'emp_it_dev',
        requesterName: 'Marco Neri',
        departmentId: 'dept_it',
        description: 'Istanza GPU Cloud per addestramento modelli AI interni',
        estimatedAmount: 4500,
        type: RequestType.opex,
        status: RequestStatus.pendingApproval,
        categoryId: 'cat_sw',
        categoryName: 'Software & Licenze Cloud',
        priority: RequestPriority.medium,
        currentApproverEmployeeId: 'emp_it_lead',
        currentApproverName: 'Anna Verdi',
        currentApprovalLevel: 0,
        requiredApprovalLevels: 2,
        requestDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        notes: 'Richiesta per test benchmark su modelli LLM locali.',
      ),

      // Richiesta 3: CAPEX in bozza (macchinari produzione)
      PurchaseRequest(
        id: 'req_seed_03',
        requesterId: 'emp_prod_mgr',
        requesterName: 'Giuseppe Gialli',
        departmentId: 'dept_prod',
        description: 'Acquisto nuovo carrello elevatore elettrico per magazzino',
        estimatedAmount: 28000,
        type: RequestType.capex,
        status: RequestStatus.draft,
        categoryId: 'cat_machinery',
        categoryName: 'Macchinari & Attrezzature',
        priority: RequestPriority.high,
        requiredApprovalLevels: 2,
        requestDate: now,
        createdAt: now,
      ),
    ];
  }

  /// Generates initial approval steps mapped by purchase request ID.
  static Map<String, List<ApprovalStep>> getSampleApprovalSteps() {
    final now = DateTime.now();

    return {
      'req_seed_01': [
        ApprovalStep(
          id: 'step_seed_01_1',
          approverId: 'emp_it_lead',
          approverName: 'Anna Verdi',
          level: 0,
          action: ApprovalAction.approved,
          comment: 'Approvato per il team di sviluppo.',
          timestamp: now.subtract(const Duration(days: 9)),
        ),
        ApprovalStep(
          id: 'step_seed_01_2',
          approverId: 'emp_it_dir',
          approverName: 'Luigi Bianchi',
          level: 1,
          action: ApprovalAction.approved,
          comment: 'Confermato rinnovo licenze corporate.',
          timestamp: now.subtract(const Duration(days: 8)),
        ),
      ],
      'req_seed_02': [],
      'req_seed_03': [],
    };
  }

  /// Seeds all initial data into Cloud Firestore under `tenants/[tenantId]`.
  Future<void> seedTenant({
    String tenantId = defaultTenantId,
    String tenantName = 'Zaramella SpA',
  }) async {
    final batch = _firestore.batch();

    // 1. Tenant Root Document
    final tenantRef = _firestore.collection(FirestorePaths.tenants).doc(tenantId);
    batch.set(tenantRef, {
      'name': tenantName,
      'createdAt': FieldValue.serverTimestamp(),
      'currency': 'EUR',
      'isActive': true,
    }, SetOptions(merge: true));

    // 2. Departments
    for (final dept in getStandardDepartments()) {
      final deptRef = _firestore
          .collection(FirestorePaths.departments(tenantId))
          .doc(dept.id);
      batch.set(deptRef, dept.toFirestore(), SetOptions(merge: true));
    }

    // 3. Categories
    for (final cat in getStandardCategories()) {
      final catRef = _firestore
          .collection(FirestorePaths.categories(tenantId))
          .doc(cat.id);
      batch.set(catRef, cat.toFirestore(), SetOptions(merge: true));
    }

    // 4. Employees
    for (final emp in getStandardEmployees()) {
      final empRef = _firestore
          .collection(FirestorePaths.employees(tenantId))
          .doc(emp.id);
      batch.set(empRef, emp.toFirestore(), SetOptions(merge: true));
    }

    // 5. Approval Rules
    for (final rule in getStandardApprovalRules()) {
      final ruleRef = _firestore
          .collection(FirestorePaths.approvalRules(tenantId))
          .doc(rule.id);
      batch.set(ruleRef, rule.toFirestore(), SetOptions(merge: true));
    }

    // 6. Purchase Requests
    for (final req in getSampleRequests()) {
      final reqRef = _firestore
          .collection(FirestorePaths.purchaseRequests(tenantId))
          .doc(req.id);
      batch.set(reqRef, req.toFirestore(), SetOptions(merge: true));
    }

    await batch.commit();

    // 7. Approval Steps (subcollections)
    final stepBatch = _firestore.batch();
    final stepsMap = getSampleApprovalSteps();
    for (final entry in stepsMap.entries) {
      final requestId = entry.key;
      for (final step in entry.value) {
        final stepRef = _firestore
            .collection(FirestorePaths.approvalSteps(tenantId, requestId))
            .doc(step.id);
        stepBatch.set(stepRef, step.toFirestore(), SetOptions(merge: true));
      }
    }
    await stepBatch.commit();
  }
}
