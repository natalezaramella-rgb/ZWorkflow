import 'package:equatable/equatable.dart';

/// Represents a department (reparto) within a tenant organization.
class Department extends Equatable {
  /// Creates a [Department].
  const Department({
    required this.id,
    required this.name,
    this.parentDepartmentId,
    this.budgetCapex = 0,
    this.budgetOpex = 0,
    this.year,
    this.isActive = true,
  });

  /// Unique document ID.
  final String id;

  /// Department name (e.g. "IT", "Marketing").
  final String name;

  /// Parent department ID for nested hierarchy, or null for root.
  final String? parentDepartmentId;

  /// Annual CAPEX budget allocated to this department.
  final double budgetCapex;

  /// Annual OPEX budget allocated to this department.
  final double budgetOpex;

  /// Budget year (e.g. 2026).
  final int? year;

  /// Whether this department is active.
  final bool isActive;

  /// Creates a copy with updated fields.
  Department copyWith({
    String? id,
    String? name,
    String? parentDepartmentId,
    double? budgetCapex,
    double? budgetOpex,
    int? year,
    bool? isActive,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
      budgetCapex: budgetCapex ?? this.budgetCapex,
      budgetOpex: budgetOpex ?? this.budgetOpex,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'parentDepartmentId': parentDepartmentId,
      'budgetCapex': budgetCapex,
      'budgetOpex': budgetOpex,
      'year': year,
      'isActive': isActive,
    };
  }

  /// Creates a [Department] from a Firestore document.
  factory Department.fromFirestore(String id, Map<String, dynamic> data) {
    return Department(
      id: id,
      name: data['name'] as String? ?? '',
      parentDepartmentId: data['parentDepartmentId'] as String?,
      budgetCapex: (data['budgetCapex'] as num?)?.toDouble() ?? 0,
      budgetOpex: (data['budgetOpex'] as num?)?.toDouble() ?? 0,
      year: data['year'] as int?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, parentDepartmentId, budgetCapex, budgetOpex, year, isActive];
}
