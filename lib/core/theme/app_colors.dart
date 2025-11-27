import 'package:flutter/material.dart';

/// Semantic color tokens for Light and Dark themes
/// 
/// Provides consistent color semantics across the app.
/// Use these instead of hardcoding colors.
class AppColors {
  // ===== LIGHT THEME COLORS =====

  // Primary colors
  static const lightPrimary = Color(0xFF1E88E5);
  static const lightPrimaryVariant = Color(0xFF1565C0);
  static const lightOnPrimary = Color(0xFFFFFFFF);

  // Secondary colors
  static const lightSecondary = Color(0xFF26A69A);
  static const lightSecondaryVariant = Color(0xFF00897B);
  static const lightOnSecondary = Color(0xFFFFFFFF);

  // Background & Surface
  static const lightBackground = Color(0xFFF5F9FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF1A1A1A);
  static const lightOnSurface = Color(0xFF1A1A1A);

  // Error
  static const lightError = Color(0xFFD32F2F);
  static const lightOnError = Color(0xFFFFFFFF);

  // Semantic colors
  static const lightSuccess = Color(0xFF4CAF50);
  static const lightWarning = Color(0xFFFF9800);
  static const lightInfo = Color(0xFF2196F3);

  // Text colors
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF757575);
  static const lightTextDisabled = Color(0xFFBDBDBD);

  // Border colors
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightDivider = Color(0xFFE0E0E0);

  // Card colors
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightCardShadow = Color(0x1A000000);

  // Health metric colors (light mode)
  static const lightStepsColor = Color(0xFF4CAF50);
  static const lightWaterColor = Color(0xFF2196F3);
  static const lightCaloriesColor = Color(0xFFFF9800);
  static const lightHeartRateColor = Color(0xFFE91E63);
  static const lightSleepColor = Color(0xFF9C27B0);

  // ===== DARK THEME COLORS =====

  // Primary colors
  static const darkPrimary = Color(0xFF6366F1);
  static const darkPrimaryVariant = Color(0xFF4F46E5);
  static const darkOnPrimary = Color(0xFFFFFFFF);

  // Secondary colors
  static const darkSecondary = Color(0xFF8B5CF6);
  static const darkSecondaryVariant = Color(0xFF7C3AED);
  static const darkOnSecondary = Color(0xFFFFFFFF);

  // Background & Surface
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkOnBackground = Color(0xFFE2E8F0);
  static const darkOnSurface = Color(0xFFE2E8F0);

  // Error
  static const darkError = Color(0xFFEF5350);
  static const darkOnError = Color(0xFF000000);

  // Semantic colors
  static const darkSuccess = Color(0xFF66BB6A);
  static const darkWarning = Color(0xFFFFB74D);
  static const darkInfo = Color(0xFF42A5F5);

  // Text colors
  static const darkTextPrimary = Color(0xFFE2E8F0);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextDisabled = Color(0xFF64748B);

  // Border colors
  static const darkBorder = Color(0xFF334155);
  static const darkDivider = Color(0xFF334155);

  // Card colors
  static const darkCardBackground = Color(0xFF1E293B);
  static const darkCardShadow = Color(0x33000000);

  // Health metric colors (dark mode)
  static const darkStepsColor = Color(0xFF66BB6A);
  static const darkWaterColor = Color(0xFF42A5F5);
  static const darkCaloriesColor = Color(0xFFFFB74D);
  static const darkHeartRateColor = Color(0xFFEC407A);
  static const darkSleepColor = Color(0xFFAB47BC);

  // ===== HELPER METHODS =====

  /// Get primary color based on theme brightness
  static Color getPrimary(bool isDark) {
    return isDark ? darkPrimary : lightPrimary;
  }

  /// Get secondary color based on theme brightness
  static Color getSecondary(bool isDark) {
    return isDark ? darkSecondary : lightSecondary;
  }

  /// Get background color based on theme brightness
  static Color getBackground(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }

  /// Get surface color based on theme brightness
  static Color getSurface(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }

  /// Get text primary color based on theme brightness
  static Color getTextPrimary(bool isDark) {
    return isDark ? darkTextPrimary : lightTextPrimary;
  }

  /// Get text secondary color based on theme brightness
  static Color getTextSecondary(bool isDark) {
    return isDark ? darkTextSecondary : lightTextSecondary;
  }

  /// Get steps color based on theme brightness
  static Color getStepsColor(bool isDark) {
    return isDark ? darkStepsColor : lightStepsColor;
  }

  /// Get water color based on theme brightness
  static Color getWaterColor(bool isDark) {
    return isDark ? darkWaterColor : lightWaterColor;
  }

  /// Get calories color based on theme brightness
  static Color getCaloriesColor(bool isDark) {
    return isDark ? darkCaloriesColor : lightCaloriesColor;
  }

  /// Get card background color based on theme brightness
  static Color getCardBackground(bool isDark) {
    return isDark ? darkCardBackground : lightCardBackground;
  }
}
