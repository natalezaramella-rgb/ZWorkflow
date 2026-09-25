import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../purchase_request/domain/enums/request_enums.dart';
import '../../purchase_request/domain/models/purchase_request.dart';
import '../domain/models/approval_rule.dart';
import '../domain/models/approval_step.dart';

/// Repository for managing workflow approval rules and steps in Firestore.
class WorkflowRepository {
  /// Creates a [WorkflowRepository].
  WorkflowRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ── Approval Rules ───────────────────────────────────────────────

  /// Returns a stream of all approval rules for the tenant.
  Stream<List<ApprovalRule>> rulesStream(String tenantId) {
    return _firestore
        .collection(FirestorePaths.approvalRules(tenantId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApprovalRule.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Returns all approval rules for the tenant.
  Future<List<ApprovalRule>> getRules(String tenantId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.approvalRules(tenantId))
        .get();
    return snapshot.docs
        .map((doc) => ApprovalRule.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Creates or updates an approval rule.
  Future<void> saveRule(String tenantId, ApprovalRule rule) async {
    final ref = rule.id.isEmpty
        ? _firestore
            .collection(FirestorePaths.approvalRules(tenantId))
            .doc()
        : _firestore.doc(FirestorePaths.approvalRule(tenantId, rule.id));
    await ref.set(rule.toFirestore(), SetOptions(merge: true));
  }

  /// Deletes an approval rule.
  Future<void> deleteRule(String tenantId, String ruleId) async {
    await _firestore
        .doc(FirestorePaths.approvalRule(tenantId, ruleId))
        .delete();
  }

  // ── Approval Steps ──────────────────────────────────────────────

  /// Returns a stream of approval steps for a specific request.
  Stream<List<ApprovalStep>> approvalStepsStream(
      String tenantId, String requestId) {
    return _firestore
        .collection(FirestorePaths.approvalSteps(tenantId, requestId))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApprovalStep.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Adds an approval step to a request.
  Future<void> addApprovalStep(
    String tenantId,
    String requestId,
    ApprovalStep step,
  ) async {
    await _firestore
        .collection(FirestorePaths.approvalSteps(tenantId, requestId))
        .doc()
        .set(step.toFirestore());
  }

  /// Approves the request, records the approval step, and advances the workflow.
  Future<void> processApproval({
    required String tenantId,
    required PurchaseRequest request,
    required String approverId,
    required String approverName,
    String? comment,
    String? nextApproverId,
    String? nextApproverName,
  }) async {
    final batch = _firestore.batch();

    final nextLevel = request.currentApprovalLevel + 1;
    final isFullyApproved = nextLevel >= request.requiredApprovalLevels;

    final stepRef = _firestore
        .collection(FirestorePaths.approvalSteps(tenantId, request.id))
        .doc();

    final step = ApprovalStep(
      id: stepRef.id,
      approverId: approverId,
      approverName: approverName,
      level: request.currentApprovalLevel,
      action: ApprovalAction.approved,
      comment: comment,
      timestamp: DateTime.now(),
    );

    batch.set(stepRef, step.toFirestore());

    final updatedRequest = request.copyWith(
      status: isFullyApproved
          ? RequestStatus.approved
          : RequestStatus.pendingApproval,
      currentApprovalLevel: nextLevel,
      currentApproverEmployeeId: isFullyApproved ? null : nextApproverId,
      currentApproverName: isFullyApproved ? null : nextApproverName,
      updatedAt: DateTime.now(),
    );

    final reqRef =
        _firestore.doc(FirestorePaths.purchaseRequest(tenantId, request.id));
    batch.update(reqRef, updatedRequest.toFirestore());

    await batch.commit();
  }

  /// Rejects the request with a mandatory reason.
  Future<void> processRejection({
    required String tenantId,
    required PurchaseRequest request,
    required String approverId,
    required String approverName,
    required String reason,
  }) async {
    final batch = _firestore.batch();

    final stepRef = _firestore
        .collection(FirestorePaths.approvalSteps(tenantId, request.id))
        .doc();

    final step = ApprovalStep(
      id: stepRef.id,
      approverId: approverId,
      approverName: approverName,
      level: request.currentApprovalLevel,
      action: ApprovalAction.rejected,
      comment: reason,
      timestamp: DateTime.now(),
    );

    batch.set(stepRef, step.toFirestore());

    final reqRef =
        _firestore.doc(FirestorePaths.purchaseRequest(tenantId, request.id));
    batch.update(reqRef, {
      'status': RequestStatus.rejected.name,
      'currentApproverEmployeeId': null,
      'currentApproverName': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Requests changes from the requester with specific feedback.
  Future<void> processChangeRequest({
    required String tenantId,
    required PurchaseRequest request,
    required String approverId,
    required String approverName,
    required String changeNotes,
  }) async {
    final batch = _firestore.batch();

    final stepRef = _firestore
        .collection(FirestorePaths.approvalSteps(tenantId, request.id))
        .doc();

    final step = ApprovalStep(
      id: stepRef.id,
      approverId: approverId,
      approverName: approverName,
      level: request.currentApprovalLevel,
      action: ApprovalAction.changesRequested,
      comment: changeNotes,
      timestamp: DateTime.now(),
    );

    batch.set(stepRef, step.toFirestore());

    final reqRef =
        _firestore.doc(FirestorePaths.purchaseRequest(tenantId, request.id));
    batch.update(reqRef, {
      'status': RequestStatus.changesRequested.name,
      'currentApproverEmployeeId': null,
      'currentApproverName': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
