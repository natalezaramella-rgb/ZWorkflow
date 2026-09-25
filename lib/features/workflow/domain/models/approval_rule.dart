import 'package:equatable/equatable.dart';

import '../../../purchase_request/domain/enums/request_enums.dart';

/// Represents an approval rule that determines how many hierarchical
/// levels of approval are required for a purchase request based on
/// its type (CAPEX/OPEX), amount range, and department.
class ApprovalRule extends Equatable {
  /// Creates an [ApprovalRule].
  const ApprovalRule({
    required this.id,
    required this.type,
    required this.minAmount,
    required this.maxAmount,
    required this.requiredLevels,
    this.departmentId,
  });

  /// Unique document ID.
  final String id;

  /// Whether this rule applies to CAPEX or OPEX requests.
  final RequestType type;

  /// Minimum amount (inclusive) for this rule to apply.
  final double minAmount;

  /// Maximum amount (exclusive) for this rule to apply.
  /// Use [double.infinity] for no upper limit.
  final double maxAmount;

  /// Number of hierarchical levels that must approve.
  final int requiredLevels;

  /// Department this rule applies to, or null for tenant-wide default.
  final String? departmentId;

  /// Whether this is a default (tenant-wide) rule.
  bool get isDefault => departmentId == null;

  /// Creates a copy with updated fields.
  ApprovalRule copyWith({
    String? id,
    RequestType? type,
    double? minAmount,
    double? maxAmount,
    int? requiredLevels,
    String? departmentId,
  }) {
    return ApprovalRule(
      id: id ?? this.id,
      type: type ?? this.type,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      requiredLevels: requiredLevels ?? this.requiredLevels,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'minAmount': minAmount,
      'maxAmount': maxAmount == double.infinity ? -1 : maxAmount,
      'requiredLevels': requiredLevels,
      'departmentId': departmentId,
    };
  }

  /// Creates an [ApprovalRule] from a Firestore document.
  factory ApprovalRule.fromFirestore(String id, Map<String, dynamic> data) {
    final maxAmountRaw = (data['maxAmount'] as num?)?.toDouble() ?? -1;
    return ApprovalRule(
      id: id,
      type: RequestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => RequestType.opex,
      ),
      minAmount: (data['minAmount'] as num?)?.toDouble() ?? 0,
      maxAmount: maxAmountRaw < 0 ? double.infinity : maxAmountRaw,
      requiredLevels: data['requiredLevels'] as int? ?? 1,
      departmentId: data['departmentId'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, minAmount, maxAmount, requiredLevels, departmentId];
}
