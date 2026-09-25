import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../enums/request_enums.dart';

/// Represents a purchase request submitted by an employee.
class PurchaseRequest extends Equatable {
  /// Creates a [PurchaseRequest].
  const PurchaseRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.departmentId,
    required this.description,
    required this.estimatedAmount,
    required this.type,
    required this.status,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
    this.costCenterId,
    this.costCenterName,
    this.requestDate,
    this.desiredDeliveryDate,
    this.priority = RequestPriority.medium,
    this.notes,
    this.currentApproverEmployeeId,
    this.currentApproverName,
    this.currentApprovalLevel = 0,
    this.requiredApprovalLevels = 1,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique document ID.
  final String id;

  /// Employee ID of the requester.
  final String requesterId;

  /// Display name of the requester.
  final String requesterName;

  /// Department the request belongs to.
  final String departmentId;

  /// Description of the purchase.
  final String description;

  /// Estimated cost in the tenant's currency.
  final double estimatedAmount;

  /// Whether this is a CAPEX or OPEX purchase.
  final RequestType type;

  /// Current status of the request in the workflow.
  final RequestStatus status;

  /// Category ID for this request.
  final String? categoryId;

  /// Category display name.
  final String? categoryName;

  /// Supplier ID.
  final String? supplierId;

  /// Supplier display name.
  final String? supplierName;

  /// Cost center ID.
  final String? costCenterId;

  /// Cost center display name.
  final String? costCenterName;

  /// Date the request was made.
  final DateTime? requestDate;

  /// Desired delivery date for the purchase.
  final DateTime? desiredDeliveryDate;

  /// Priority level.
  final RequestPriority priority;

  /// Additional notes.
  final String? notes;

  /// Employee ID of the current approver (if pending approval).
  final String? currentApproverEmployeeId;

  /// Display name of the current approver.
  final String? currentApproverName;

  /// The current approval level (0-based).
  final int currentApprovalLevel;

  /// Total number of approval levels required.
  final int requiredApprovalLevels;

  /// Timestamp when the request was created.
  final DateTime? createdAt;

  /// Timestamp when the request was last updated.
  final DateTime? updatedAt;

  /// Whether the request is still in progress (not finalized).
  bool get isInProgress =>
      status == RequestStatus.submitted ||
      status == RequestStatus.pendingApproval ||
      status == RequestStatus.resubmitted;

  /// Whether the request has been finalized (approved or rejected).
  bool get isFinalized =>
      status == RequestStatus.approved || status == RequestStatus.rejected;

  /// Creates a copy with updated fields.
  PurchaseRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? departmentId,
    String? description,
    double? estimatedAmount,
    RequestType? type,
    RequestStatus? status,
    String? categoryId,
    String? categoryName,
    String? supplierId,
    String? supplierName,
    String? costCenterId,
    String? costCenterName,
    DateTime? requestDate,
    DateTime? desiredDeliveryDate,
    RequestPriority? priority,
    String? notes,
    String? currentApproverEmployeeId,
    String? currentApproverName,
    int? currentApprovalLevel,
    int? requiredApprovalLevels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      departmentId: departmentId ?? this.departmentId,
      description: description ?? this.description,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      costCenterId: costCenterId ?? this.costCenterId,
      costCenterName: costCenterName ?? this.costCenterName,
      requestDate: requestDate ?? this.requestDate,
      desiredDeliveryDate: desiredDeliveryDate ?? this.desiredDeliveryDate,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      currentApproverEmployeeId:
          currentApproverEmployeeId ?? this.currentApproverEmployeeId,
      currentApproverName: currentApproverName ?? this.currentApproverName,
      currentApprovalLevel: currentApprovalLevel ?? this.currentApprovalLevel,
      requiredApprovalLevels:
          requiredApprovalLevels ?? this.requiredApprovalLevels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'departmentId': departmentId,
      'description': description,
      'estimatedAmount': estimatedAmount,
      'type': type.name,
      'status': status.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'costCenterId': costCenterId,
      'costCenterName': costCenterName,
      'requestDate':
          requestDate != null ? Timestamp.fromDate(requestDate!) : null,
      'desiredDeliveryDate': desiredDeliveryDate != null
          ? Timestamp.fromDate(desiredDeliveryDate!)
          : null,
      'priority': priority.name,
      'notes': notes,
      'currentApproverEmployeeId': currentApproverEmployeeId,
      'currentApproverName': currentApproverName,
      'currentApprovalLevel': currentApprovalLevel,
      'requiredApprovalLevels': requiredApprovalLevels,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [PurchaseRequest] from a Firestore document.
  factory PurchaseRequest.fromFirestore(
      String id, Map<String, dynamic> data) {
    return PurchaseRequest(
      id: id,
      requesterId: data['requesterId'] as String? ?? '',
      requesterName: data['requesterName'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      estimatedAmount:
          (data['estimatedAmount'] as num?)?.toDouble() ?? 0,
      type: RequestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => RequestType.opex,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.draft,
      ),
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      supplierId: data['supplierId'] as String?,
      supplierName: data['supplierName'] as String?,
      costCenterId: data['costCenterId'] as String?,
      costCenterName: data['costCenterName'] as String?,
      requestDate: data['requestDate'] is Timestamp
          ? (data['requestDate'] as Timestamp).toDate()
          : null,
      desiredDeliveryDate: data['desiredDeliveryDate'] is Timestamp
          ? (data['desiredDeliveryDate'] as Timestamp).toDate()
          : null,
      priority: RequestPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => RequestPriority.medium,
      ),
      notes: data['notes'] as String?,
      currentApproverEmployeeId:
          data['currentApproverEmployeeId'] as String?,
      currentApproverName: data['currentApproverName'] as String?,
      currentApprovalLevel: data['currentApprovalLevel'] as int? ?? 0,
      requiredApprovalLevels: data['requiredApprovalLevels'] as int? ?? 1,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        departmentId,
        description,
        estimatedAmount,
        type,
        status,
        categoryId,
        supplierId,
        costCenterId,
        requestDate,
        desiredDeliveryDate,
        priority,
        notes,
        currentApproverEmployeeId,
        currentApprovalLevel,
        requiredApprovalLevels,
      ];
}
