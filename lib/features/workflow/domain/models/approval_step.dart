import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../purchase_request/domain/enums/request_enums.dart';

/// Represents a single step in the approval chain of a purchase request.
///
/// Each step records which approver took action, what action was taken,
/// and when it happened.
class ApprovalStep extends Equatable {
  /// Creates an [ApprovalStep].
  const ApprovalStep({
    required this.id,
    required this.approverId,
    required this.approverName,
    required this.level,
    required this.action,
    this.comment,
    this.timestamp,
  });

  /// Unique document ID.
  final String id;

  /// Employee ID of the approver who took action.
  final String approverId;

  /// Display name of the approver.
  final String approverName;

  /// The hierarchical level of this approval step (0-based).
  final int level;

  /// The action taken by the approver.
  final ApprovalAction action;

  /// Optional comment from the approver (mandatory for rejections).
  final String? comment;

  /// Timestamp when the action was taken.
  final DateTime? timestamp;

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'approverId': approverId,
      'approverName': approverName,
      'level': level,
      'action': action.name,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Creates an [ApprovalStep] from a Firestore document.
  factory ApprovalStep.fromFirestore(String id, Map<String, dynamic> data) {
    return ApprovalStep(
      id: id,
      approverId: data['approverId'] as String? ?? '',
      approverName: data['approverName'] as String? ?? '',
      level: data['level'] as int? ?? 0,
      action: ApprovalAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => ApprovalAction.approved,
      ),
      comment: data['comment'] as String?,
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, approverId, level, action, comment, timestamp];
}
