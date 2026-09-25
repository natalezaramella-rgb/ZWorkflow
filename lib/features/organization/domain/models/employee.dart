import 'package:equatable/equatable.dart';

import '../../../purchase_request/domain/enums/request_enums.dart';

/// Represents an employee within a tenant organization.
///
/// Each employee has a position in the organizational hierarchy tree,
/// defined by [managerId] pointing to their direct manager.
class Employee extends Equatable {
  /// Creates an [Employee].
  const Employee({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.departmentId,
    this.roles = const [],
    this.managerId,
    this.isActive = true,
  });

  /// Unique document ID within the tenant's employees collection.
  final String id;

  /// Firebase Auth UID linked to this employee.
  final String uid;

  /// Employee's email address.
  final String email;

  /// Employee's display name.
  final String displayName;

  /// The department this employee belongs to.
  final String departmentId;

  /// Roles assigned to this employee.
  final List<UserRole> roles;

  /// The employee ID of this employee's direct manager.
  /// Null for the top of the hierarchy (e.g. CEO).
  final String? managerId;

  /// Whether this employee account is active.
  final bool isActive;

  /// Creates a copy with updated fields.
  Employee copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? departmentId,
    List<UserRole>? roles,
    String? managerId,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      departmentId: departmentId ?? this.departmentId,
      roles: roles ?? this.roles,
      managerId: managerId ?? this.managerId,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'departmentId': departmentId,
      'roles': roles.map((r) => r.name).toList(),
      'managerId': managerId,
      'isActive': isActive,
    };
  }

  /// Creates an [Employee] from a Firestore document.
  factory Employee.fromFirestore(String id, Map<String, dynamic> data) {
    return Employee(
      id: id,
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      departmentId: data['departmentId'] as String? ?? '',
      roles: (data['roles'] as List<dynamic>?)
              ?.map((r) => UserRole.values.firstWhere(
                    (e) => e.name == r,
                    orElse: () => UserRole.requester,
                  ))
              .toList() ??
          [],
      managerId: data['managerId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [id, uid, email, displayName, departmentId, roles, managerId, isActive];
}
