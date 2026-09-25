import 'package:equatable/equatable.dart';

/// Represents the budget status of a department for a given year.
///
/// This is a computed model that combines the allocated budget from
/// the [Department] with the consumed amounts calculated from
/// approved purchase requests.
class BudgetStatus extends Equatable {
  /// Creates a [BudgetStatus].
  const BudgetStatus({
    required this.departmentId,
    required this.departmentName,
    required this.year,
    required this.allocatedCapex,
    required this.allocatedOpex,
    required this.consumedCapex,
    required this.consumedOpex,
  });

  /// Department ID.
  final String departmentId;

  /// Department display name.
  final String departmentName;

  /// Budget year.
  final int year;

  /// Total CAPEX budget allocated for the year.
  final double allocatedCapex;

  /// Total OPEX budget allocated for the year.
  final double allocatedOpex;

  /// CAPEX budget consumed (sum of approved CAPEX requests).
  final double consumedCapex;

  /// OPEX budget consumed (sum of approved OPEX requests).
  final double consumedOpex;

  /// Remaining CAPEX budget.
  double get remainingCapex => allocatedCapex - consumedCapex;

  /// Remaining OPEX budget.
  double get remainingOpex => allocatedOpex - consumedOpex;

  /// Total allocated budget (CAPEX + OPEX).
  double get totalAllocated => allocatedCapex + allocatedOpex;

  /// Total consumed budget (CAPEX + OPEX).
  double get totalConsumed => consumedCapex + consumedOpex;

  /// Total remaining budget.
  double get totalRemaining => totalAllocated - totalConsumed;

  /// CAPEX consumption percentage (0.0 to 1.0+).
  double get capexPercentage =>
      allocatedCapex > 0 ? consumedCapex / allocatedCapex : 0;

  /// OPEX consumption percentage (0.0 to 1.0+).
  double get opexPercentage =>
      allocatedOpex > 0 ? consumedOpex / allocatedOpex : 0;

  /// Whether the CAPEX budget has been exceeded.
  bool get isCapexExceeded => consumedCapex > allocatedCapex;

  /// Whether the OPEX budget has been exceeded.
  bool get isOpexExceeded => consumedOpex > allocatedOpex;

  @override
  List<Object?> get props => [
        departmentId,
        year,
        allocatedCapex,
        allocatedOpex,
        consumedCapex,
        consumedOpex,
      ];
}
