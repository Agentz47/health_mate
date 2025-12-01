import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider for managing Light/Dark mode
/// 
/// Handles theme persistence using SharedPreferences and notifies listeners
/// when the theme changes.
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'is_dark_mode';
  
  bool _isDark = false;
  bool _isLoading = true;

  bool get isDark => _isDark;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    loadTheme();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> loadTheme() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_prefKey) ?? false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    await setTheme(!_isDark);
  }

  /// Set theme to specific mode
  /// 
  /// [isDark] - true for dark mode, false for light mode
  Future<void> setTheme(bool isDark) async {
    try {
      _isDark = isDark;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, isDark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Get ThemeMode for MaterialApp
  ThemeMode get themeMode {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
