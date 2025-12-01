import 'package:flutter/material.dart';

// Gradient tokens for Light and Dark themes
 
// Provides professional, subtle gradients for backgrounds, cards, and buttons.
// All gradients are designed with WCAG accessibility in mind.
class AppGradients {
  // LIGHT THEME GRADIENTS 
  
  // Main app background gradient (Light mode)
  // Soft blue to white
  static const lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE3F2FD), // Light blue
      Color(0xFFFFFFFF), // White
    ],
  );

  // Card/Surface gradient (Light mode)
  // White to very light grey - subtle depth
  static const lightCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF), // Pure white
      Color(0xFFF4F8FB), // Very light blue-grey
    ],
  );

  // Primary button gradient (Light mode)
  // Blue gradient - trustworthy, medical feel
  static const lightPrimaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF42A5F5), // Light blue
      Color(0xFF1E88E5), // Medium blue
    ],
  );

  // Secondary button gradient (Light mode)
  // Teal gradient - calming, health-focused
  static const lightSecondaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF26A69A), // Teal
      Color(0xFF00897B), // Dark teal
    ],
  );

  // Accent gradient for metric cards (Light mode)
  // Subtle gradient for health metric cards
  static const lightMetricCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5F9FF), // Very light blue
      Color(0xFFFFFFFF), // White
    ],
  );

  // Steps card gradient (Light mode)
  static const lightStepsCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F5E9), // Light green
      Color(0xFFFFFFFF), // White
    ],
  );

  // Water card gradient (Light mode)
  static const lightWaterCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE1F5FE), // Light cyan
      Color(0xFFFFFFFF), // White
    ],
  );

  // Calories card gradient (Light mode)
  static const lightCaloriesCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF3E0), // Light orange
      Color(0xFFFFFFFF), // White
    ],
  );

  //  DARK THEME GRADIENTS 

  // Main app background gradient (Dark mode)
  // Navy to midnight
  static const darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A), // Deep navy
      Color(0xFF1E1E2E), // Midnight blue
    ],
  );

  // Card/Surface gradient (Dark mode)
  // Slate to navy - subtle depth with contrast
  static const darkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B), // Slate
      Color(0xFF0F172A), // Deep navy
    ],
  );

  // Primary button gradient (Dark mode)
  // Indigo gradient - modern, vibrant
  static const darkPrimaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF6366F1), // Bright indigo
      Color(0xFF4F46E5), // Deep indigo
    ],
  );

  // Secondary button gradient (Dark mode)
  // Purple gradient - elegant, premium
  static const darkSecondaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF8B5CF6), // Purple
      Color(0xFF7C3AED), // Deep purple
    ],
  );

  // Accent gradient for metric cards (Dark mode)
  static const darkMetricCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B), // Slate
      Color(0xFF0F172A), // Navy
    ],
  );

  // Steps card gradient (Dark mode)
  static const darkStepsCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A2E), // Dark green tint
      Color(0xFF0F172A), // Navy
    ],
  );

  // Water card gradient (Dark mode)
  static const darkWaterCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2A3A), // Dark blue tint
      Color(0xFF0F172A), // Navy
    ],
  );

  // Calories card gradient (Dark mode)
  static const darkCaloriesCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A1E1E), // Dark orange tint
      Color(0xFF0F172A), // Navy
    ],
  );

  // HELPER METHODS

  // Get background gradient based on theme brightness
  static LinearGradient getBackground(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }

  // Get card gradient based on theme brightness
  static LinearGradient getCard(bool isDark) {
    return isDark ? darkCard : lightCard;
  }

  // Get primary button gradient based on theme brightness
  static LinearGradient getPrimaryButton(bool isDark) {
    return isDark ? darkPrimaryButton : lightPrimaryButton;
  }

  // Get secondary button gradient based on theme brightness
  static LinearGradient getSecondaryButton(bool isDark) {
    return isDark ? darkSecondaryButton : lightSecondaryButton;
  }

  // Get metric card gradient based on theme brightness
  static LinearGradient getMetricCard(bool isDark) {
    return isDark ? darkMetricCard : lightMetricCard;
  }

  // Get steps card gradient based on theme brightness
  static LinearGradient getStepsCard(bool isDark) {
    return isDark ? darkStepsCard : lightStepsCard;
  }

  // Get water card gradient based on theme brightness
  static LinearGradient getWaterCard(bool isDark) {
    return isDark ? darkWaterCard : lightWaterCard;
  }

  // Get calories card gradient based on theme brightness
  static LinearGradient getCaloriesCard(bool isDark) {
    return isDark ? darkCaloriesCard : lightCaloriesCard;
  }
}
