import 'package:equatable/equatable.dart';

/// Represents a purchase category configurable by the admin.
class Category extends Equatable {
  /// Creates a [Category].
  const Category({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  /// Unique document ID.
  final String id;

  /// Category name (e.g. "IT", "Marketing", "Materials").
  final String name;

  /// Whether this category is active and selectable.
  final bool isActive;

  /// Converts to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isActive': isActive,
    };
  }

  /// Creates a [Category] from a Firestore document.
  factory Category.fromFirestore(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
