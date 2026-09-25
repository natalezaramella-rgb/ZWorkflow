import 'package:equatable/equatable.dart';

import '../../../purchase_request/domain/enums/request_enums.dart';

/// Represents a user within the ZWorkflow application.
///
/// Maps to both Firebase Auth and the `employees` Firestore collection.
class AppUser extends Equatable {
  /// Creates an [AppUser].
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.tenantId,
    this.employeeId,
    this.departmentId,
    this.roles = const [],
    this.managerId,
    this.isActive = true,
  });

  /// Firebase Auth UID.
  final String uid;

  /// User's email address.
  final String email;

  /// User's display name.
  final String displayName;

  /// The tenant (organization) this user belongs to.
  final String? tenantId;

  /// The employee document ID within the tenant.
  final String? employeeId;

  /// The department this user belongs to.
  final String? departmentId;

  /// The roles assigned to this user.
  final List<UserRole> roles;

  /// The employee ID of this user's direct manager.
  final String? managerId;

  /// Whether this user account is active.
  final bool isActive;

  /// Whether this user has the admin role.
  bool get isAdmin => roles.contains(UserRole.admin);

  /// Whether this user has the super admin role.
  bool get isSuperAdmin => roles.contains(UserRole.superAdmin);

  /// Whether this user has the controller role.
  bool get isController => roles.contains(UserRole.controller);

  /// Whether this user can approve requests.
  bool get canApprove =>
      roles.contains(UserRole.approver) || roles.contains(UserRole.admin);

  /// An empty user representing an unauthenticated state.
  static const empty = AppUser(uid: '', email: '', displayName: '');

  /// Whether this user is empty (unauthenticated).
  bool get isEmpty => this == empty;

  /// Whether this user is not empty (authenticated).
  bool get isNotEmpty => !isEmpty;

  /// Creates a copy with updated fields.
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? tenantId,
    String? employeeId,
    String? departmentId,
    List<UserRole>? roles,
    String? managerId,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tenantId: tenantId ?? this.tenantId,
      employeeId: employeeId ?? this.employeeId,
      departmentId: departmentId ?? this.departmentId,
      roles: roles ?? this.roles,
      managerId: managerId ?? this.managerId,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts this user to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'tenantId': tenantId,
      'employeeId': employeeId,
      'departmentId': departmentId,
      'roles': roles.map((r) => r.name).toList(),
      'managerId': managerId,
      'isActive': isActive,
    };
  }

  /// Creates an [AppUser] from a Firestore document map.
  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      tenantId: data['tenantId'] as String?,
      employeeId: data['employeeId'] as String?,
      departmentId: data['departmentId'] as String?,
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
  List<Object?> get props => [
        uid,
        email,
        displayName,
        tenantId,
        employeeId,
        departmentId,
        roles,
        managerId,
        isActive,
      ];
}
