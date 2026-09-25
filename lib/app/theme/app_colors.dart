import 'package:flutter/material.dart';

/// Application color palette for ZWorkflow.
///
/// Professional, enterprise-grade color scheme suitable for a business
/// workflow application. Supports both light and dark themes.
abstract final class AppColors {
  // Primary brand colors
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0D2137);

  // Secondary accent colors
  static const Color secondaryLight = Color(0xFF00897B);
  static const Color secondaryDark = Color(0xFF80CBC4);

  // Surface colors
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Budget status colors
  static const Color budgetOk = Color(0xFF43A047);
  static const Color budgetWarning = Color(0xFFFFA000);
  static const Color budgetDanger = Color(0xFFE53935);

  // Request status colors
  static const Color statusDraft = Color(0xFF9E9E9E);
  static const Color statusSubmitted = Color(0xFF42A5F5);
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusApproved = Color(0xFF66BB6A);
  static const Color statusRejected = Color(0xFFEF5350);
  static const Color statusChangesRequested = Color(0xFFAB47BC);

  // Priority colors
  static const Color priorityLow = Color(0xFF78909C);
  static const Color priorityMedium = Color(0xFF42A5F5);
  static const Color priorityHigh = Color(0xFFFFA726);
  static const Color priorityUrgent = Color(0xFFEF5350);

  // Text
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Divider
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
}
