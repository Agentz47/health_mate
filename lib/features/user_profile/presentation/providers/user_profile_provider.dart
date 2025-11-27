import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/user_profile_local.dart';

/// Provider for user profile state management
class UserProfileProvider extends ChangeNotifier {
  final UserProfileLocal _userProfileLocal;

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile?.hasAnyData ?? false;

  UserProfileProvider(this._userProfileLocal) {
    loadProfile();
  }

  /// Load profile from storage
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _userProfileLocal.loadProfile();
      if (data != null) {
        _profile = UserProfile.fromMap(data);
      } else {
        _profile = null;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save profile to storage
  Future<void> saveProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userProfileLocal.saveProfile(
        name: profile.name,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        age: profile.age,
      );
      _profile = profile;
    } catch (e) {
      debugPrint('Error saving profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear profile from storage
  Future<void> clearProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userProfileLocal.clearProfile();
      _profile = null;
    } catch (e) {
      debugPrint('Error clearing profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh profile from storage
  Future<void> refresh() async {
    await loadProfile();
  }
}
