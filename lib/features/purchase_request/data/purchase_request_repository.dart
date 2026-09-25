import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/enums/request_enums.dart';
import '../domain/models/purchase_request.dart';

/// Repository for managing purchase requests in Firestore.
class PurchaseRequestRepository {
  /// Creates a [PurchaseRequestRepository].
  PurchaseRequestRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns a stream of all purchase requests for the tenant.
  Stream<List<PurchaseRequest>> requestsStream(String tenantId) {
    return _firestore
        .collection(FirestorePaths.purchaseRequests(tenantId))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PurchaseRequest.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Returns a stream of requests for a specific requester.
  Stream<List<PurchaseRequest>> myRequestsStream(
      String tenantId, String requesterId) {
    return _firestore
        .collection(FirestorePaths.purchaseRequests(tenantId))
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PurchaseRequest.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Returns a stream of requests pending approval by a specific approver.
  Stream<List<PurchaseRequest>> pendingApprovalsStream(
      String tenantId, String approverEmployeeId) {
    return _firestore
        .collection(FirestorePaths.purchaseRequests(tenantId))
        .where('currentApproverEmployeeId', isEqualTo: approverEmployeeId)
        .where('status', isEqualTo: RequestStatus.pendingApproval.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PurchaseRequest.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Returns approved requests for a department in a given year.
  Future<List<PurchaseRequest>> getApprovedRequestsForDepartment(
    String tenantId,
    String departmentId,
    int year,
  ) async {
    final startOfYear = DateTime(year);
    final endOfYear = DateTime(year + 1);

    final snapshot = await _firestore
        .collection(FirestorePaths.purchaseRequests(tenantId))
        .where('departmentId', isEqualTo: departmentId)
        .where('status', isEqualTo: RequestStatus.approved.name)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfYear))
        .get();

    return snapshot.docs
        .map((doc) => PurchaseRequest.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Gets a single purchase request by ID.
  Future<PurchaseRequest?> getRequest(
      String tenantId, String requestId) async {
    final doc = await _firestore
        .doc(FirestorePaths.purchaseRequest(tenantId, requestId))
        .get();

    if (!doc.exists) return null;
    return PurchaseRequest.fromFirestore(doc.id, doc.data()!);
  }

  /// Creates a new purchase request.
  Future<String> createRequest(
      String tenantId, PurchaseRequest request) async {
    final ref = _firestore
        .collection(FirestorePaths.purchaseRequests(tenantId))
        .doc();

    await ref.set(request.copyWith(id: ref.id).toFirestore());
    return ref.id;
  }

  /// Updates an existing purchase request.
  Future<void> updateRequest(
      String tenantId, PurchaseRequest request) async {
    await _firestore
        .doc(FirestorePaths.purchaseRequest(tenantId, request.id))
        .update(request.toFirestore());
  }

  /// Deletes a purchase request.
  Future<void> deleteRequest(String tenantId, String requestId) async {
    await _firestore
        .doc(FirestorePaths.purchaseRequest(tenantId, requestId))
        .delete();
  }
}
