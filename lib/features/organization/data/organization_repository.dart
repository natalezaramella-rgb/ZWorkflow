import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/models/category.dart';
import '../domain/models/cost_center.dart';
import '../domain/models/department.dart';
import '../domain/models/employee.dart';

/// Repository for managing the organizational structure within a tenant.
///
/// Handles CRUD operations for departments, employees, categories,
/// and cost centers in Firestore.
class OrganizationRepository {
  /// Creates an [OrganizationRepository].
  OrganizationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ── Departments ──────────────────────────────────────────────────

  /// Returns a stream of all departments for the given tenant.
  Stream<List<Department>> departmentsStream(String tenantId) {
    return _firestore
        .collection(FirestorePaths.departments(tenantId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Department.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Creates or updates a department.
  Future<void> saveDepartment(String tenantId, Department department) async {
    final ref = department.id.isEmpty
        ? _firestore.collection(FirestorePaths.departments(tenantId)).doc()
        : _firestore
            .doc(FirestorePaths.department(tenantId, department.id));
    await ref.set(department.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes a department.
  Future<void> deleteDepartment(String tenantId, String deptId) async {
    await _firestore
        .doc(FirestorePaths.department(tenantId, deptId))
        .delete();
  }

  // ── Employees ────────────────────────────────────────────────────

  /// Returns a stream of all employees for the given tenant.
  Stream<List<Employee>> employeesStream(String tenantId) {
    return _firestore
        .collection(FirestorePaths.employees(tenantId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Employee.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Returns all employees as a map keyed by employee ID.
  Future<Map<String, Employee>> getEmployeesMap(String tenantId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.employees(tenantId))
        .get();
    return {
      for (final doc in snapshot.docs)
        doc.id: Employee.fromFirestore(doc.id, doc.data()),
    };
  }

  /// Creates or updates an employee.
  Future<void> saveEmployee(String tenantId, Employee employee) async {
    final ref = employee.id.isEmpty
        ? _firestore.collection(FirestorePaths.employees(tenantId)).doc()
        : _firestore.doc(FirestorePaths.employee(tenantId, employee.id));
    await ref.set(employee.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes an employee.
  Future<void> deleteEmployee(String tenantId, String employeeId) async {
    await _firestore
        .doc(FirestorePaths.employee(tenantId, employeeId))
        .delete();
  }

  // ── Categories ───────────────────────────────────────────────────

  /// Returns a stream of all categories for the given tenant.
  Stream<List<Category>> categoriesStream(String tenantId) {
    return _firestore
        .collection(FirestorePaths.categories(tenantId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Creates or updates a category.
  Future<void> saveCategory(String tenantId, Category category) async {
    final ref = category.id.isEmpty
        ? _firestore.collection(FirestorePaths.categories(tenantId)).doc()
        : _firestore.doc(FirestorePaths.category(tenantId, category.id));
    await ref.set(category.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes a category.
  Future<void> deleteCategory(String tenantId, String categoryId) async {
    await _firestore
        .doc(FirestorePaths.category(tenantId, categoryId))
        .delete();
  }

  // ── Cost Centers ─────────────────────────────────────────────────

  /// Returns a stream of cost centers for a specific department.
  Stream<List<CostCenter>> costCentersStream(
      String tenantId, String deptId) {
    return _firestore
        .collection(FirestorePaths.costCenters(tenantId, deptId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CostCenter.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Creates or updates a cost center.
  Future<void> saveCostCenter(
      String tenantId, String deptId, CostCenter costCenter) async {
    final ref = costCenter.id.isEmpty
        ? _firestore
            .collection(FirestorePaths.costCenters(tenantId, deptId))
            .doc()
        : _firestore.doc(
            FirestorePaths.costCenter(tenantId, deptId, costCenter.id));
    await ref.set(costCenter.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes a cost center.
  Future<void> deleteCostCenter(
      String tenantId, String deptId, String ccId) async {
    await _firestore
        .doc(FirestorePaths.costCenter(tenantId, deptId, ccId))
        .delete();
  }
}
