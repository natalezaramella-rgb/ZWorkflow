import 'package:equatable/equatable.dart';

/// Represents a cost center within a department.
class CostCenter extends Equatable {
  /// Creates a [CostCenter].
  const CostCenter({
    required this.id,
    required this.name,
    required this.code,
    this.isActive = true,
  });

  /// Unique document ID.
  final String id;

  /// Cost center name.
  final String name;

  /// Cost center code (e.g. "CC-001").
  final String code;

  /// Whether this cost center is active.
  final bool isActive;

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'isActive': isActive,
    };
  }

  /// Creates a [CostCenter] from a Firestore document.
  factory CostCenter.fromFirestore(String id, Map<String, dynamic> data) {
    return CostCenter(
      id: id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, code, isActive];
}
