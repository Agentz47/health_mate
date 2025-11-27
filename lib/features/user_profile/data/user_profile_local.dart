import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for user profile using SharedPreferences
class UserProfileLocal {
  // SharedPreferences keys
  static const String _keyName = 'user_name';
  static const String _keyWeight = 'user_weight_kg';
  static const String _keyHeight = 'user_height_cm';
  static const String _keyAge = 'user_age';
  static const String _keyProfileExists = 'user_profile_exists';

  /// Save user profile data
  Future<void> saveProfile({
    String? name,
    double? weightKg,
    int? heightCm,
    int? age,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString(_keyName, name);
    }
    if (weightKg != null) {
      await prefs.setDouble(_keyWeight, weightKg);
    }
    if (heightCm != null) {
      await prefs.setInt(_keyHeight, heightCm);
    }
    if (age != null) {
      await prefs.setInt(_keyAge, age);
    }
    
    // Mark profile as existing if any data was saved
    if (name != null || weightKg != null || heightCm != null || age != null) {
      await prefs.setBool(_keyProfileExists, true);
    }
  }

  /// Load user profile data
  Future<Map<String, dynamic>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if profile exists
    if (!prefs.containsKey(_keyProfileExists) && 
        !prefs.containsKey(_keyName) && 
        !prefs.containsKey(_keyWeight)) {
      return null;
    }

    return {
      'name': prefs.getString(_keyName),
      'weightKg': prefs.getDouble(_keyWeight),
      'heightCm': prefs.getInt(_keyHeight),
      'age': prefs.getInt(_keyAge),
    };
  }

  /// Get user weight in kg
  Future<double?> getWeightKg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyWeight);
  }

  /// Check if profile exists (at least name or weight is saved)
  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileExists) ?? false;
  }

  /// Clear all profile data
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyWeight);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyAge);
    await prefs.remove(_keyProfileExists);
  }
}
