import 'package:flutter/material.dart';

class AppColors {
  // Modern gradient color scheme
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);

  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF67E8F9);

  static const Color accent = Color(0xFF10B981);

  // Modern neutral background
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);

  // Modern text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Modern borders and dividers
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);

  // Modern status colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFECDCA);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Modern trip status colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusInProgress = Color(0xFF6366F1);
  static const Color statusCompleted = Color(0xFF10B981);

  // Modern status light backgrounds
  static const Color statusPendingLight = Color(0xFFFEF3C7);
  static const Color statusInProgressLight = Color(0xFFEDE9FE);
  static const Color statusCompletedLight = Color(0xFFD1FAE5);

  // Modern shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);

  // Modern card styling
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0F000000);

  // Modern shimmer colors
  static Color shimmerBase = const Color(0xFFE2E8F0);
  static Color shimmerHighlight = const Color(0xFFF8FAFC);
}

class AppGradients {
  // Modern primary gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern mesh gradients for cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern status gradients
  static const LinearGradient statusPendingGradient = LinearGradient(
    colors: [AppColors.statusPending, Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statusInProgressGradient = LinearGradient(
    colors: [AppColors.statusInProgress, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statusCompletedGradient = LinearGradient(
    colors: [AppColors.statusCompleted, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern app background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}