import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';
import '../../data/repositories/health_repository_impl.dart';

class HealthRecordProvider extends ChangeNotifier {
  final HealthRepositoryImpl _repository;

  List<HealthRecord> _records = [];
  HealthRecord? _todayRecord;
  HealthRecord? _yesterdayRecord;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStreak = 0;
  int _waterGoal = 2000;
  List<Map<String, dynamic>> _achievements = [];

  HealthRecordProvider(this._repository);

  // Getters
  List<HealthRecord> get records => _records;
  HealthRecord? get todayRecord => _todayRecord;
  HealthRecord? get yesterdayRecord => _yesterdayRecord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStreak => _currentStreak;
  int get waterGoal => _waterGoal;
  List<Map<String, dynamic>> get achievements => _achievements;

  // Returns the list of achievements that are unlocked for today only
  List<Map<String, dynamic>> get earnedAchievements {
    final today = _todayRecord;
    if (today == null) return [];
    final List<Map<String, dynamic>> unlocked = [];
    for (final a in _achievements) {
      if (a['id'] == 'gold_steps' && today.steps >= 10000) {
        unlocked.add(a);
      } else if (a['id'] == 'silver_steps' && today.steps >= 8000) {
        unlocked.add(a);
      } else if (a['id'] == 'bronze_steps' && today.steps >= 5000) {
        unlocked.add(a);
      } else if (a['id'] == 'hydration_hero' && today.water >= 2500) {
        unlocked.add(a);
      }
    }
    return unlocked;
  }

  /// Load all records from database
  Future<void> loadRecords() async {
    _setLoading(true);
    _clearError();

    try {
      _records = await _repository.getAllRecords();
      await _loadTodayRecord();
      await _loadYesterdayRecord();
      await _loadStreak();
      await _loadWaterGoal();
      await _loadAchievements();
    } catch (e) {
      _setError('Failed to load records: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load today's record
  Future<void> _loadTodayRecord() async {
    try {
      _todayRecord = await _repository.getTodayRecord();
    } catch (e) {
      _setError('Failed to load today\'s record: $e');
    }
  }

  /// Load current streak
  Future<void> _loadStreak() async {
    try {
      _currentStreak = await _repository.getCurrentStreak();
    } catch (e) {
      _setError('Failed to load streak: $e');
    }
  }

  /// Load yesterday's record
  Future<void> _loadYesterdayRecord() async {
    try {
      _yesterdayRecord = await _repository.getYesterdayRecord();
    } catch (e) {
      // Not critical if yesterday's record doesn't exist
    }
  }

  /// Load water goal
  Future<void> _loadWaterGoal() async {
    try {
      _waterGoal = await _repository.getWaterGoal();
    } catch (e) {
      _setError('Failed to load water goal: $e');
    }
  }

  /// Load achievements
  Future<void> _loadAchievements() async {
    try {
      _achievements = await _repository.getAchievements();
    } catch (e) {
      _setError('Failed to load achievements: $e');
    }
  }

  /// Add a new health record
  Future<bool> addRecord(HealthRecord record) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.addRecord(record);
      await _repository.calculateAndUpdateStreak(record.date);
      await loadRecords(); // Reload all records
      return true;
    } catch (e) {
      _setError('Failed to add record: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing health record
  Future<bool> updateRecord(HealthRecord record) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateRecord(record);
      await _repository.calculateAndUpdateStreak(record.date);
      await loadRecords(); // Reload all records
      return true;
    } catch (e) {
      _setError('Failed to update record: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a health record
  Future<bool> deleteRecord(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteRecord(id);
      await loadRecords(); // Reload all records
      return true;
    } catch (e) {
      _setError('Failed to delete record: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Filter records by date
  List<HealthRecord> filterByDate(DateTime date) {
    return _records.where((record) {
      return record.date.year == date.year &&
          record.date.month == date.month &&
          record.date.day == date.day;
    }).toList();
  }

  /// Get records for a specific date range
  List<HealthRecord> getRecordsBetween(DateTime start, DateTime end) {
    return _records.where((record) {
      return record.date.isAfter(start.subtract(const Duration(days: 1))) &&
          record.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate total steps for today
  int get todaySteps => _todayRecord?.steps ?? 0;

  /// Calculate total calories for today
  int get todayCalories => _todayRecord?.calories ?? 0;

  /// Calculate total water for today
  int get todayWater => _todayRecord?.water ?? 0;

  /// Get motivational message based on streak
  String getStreakMessage() {
    if (_currentStreak == 0) return 'Start your streak today!';
    if (_currentStreak == 1) return 'Great start! Keep going!';
    if (_currentStreak < 7) return 'Keep it going!';
    if (_currentStreak < 30) return 'Amazing streak!';
    if (_currentStreak < 100) return 'Unstoppable!';
    return 'Legendary streak!';
  }

  /// Get water progress percentage
  double getWaterProgress() {
    if (_waterGoal == 0) return 0.0;
    final progress = todayWater / _waterGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Get smart insights based on today's data
  List<String> getSmartInsights() {
    final insights = <String>[];

    // Steps insights
    if (todaySteps < 3000) {
      insights.add('Try to move more tomorrow 🏃');
    } else if (todaySteps >= 10000) {
      insights.add('Fantastic! You hit 10,000 steps! 🎉');
    } else if (todaySteps >= 5000) {
      insights.add('Good progress on steps today! 👟');
    }

    // Water insights
    if (todayWater >= _waterGoal) {
      insights.add('Great job staying hydrated 💧');
    } else if (todayWater < _waterGoal / 2) {
      insights.add('Drink more water today! 🚰');
    }

    // Comparison insights
    if (_yesterdayRecord != null) {
      if (todaySteps > _yesterdayRecord!.steps) {
        insights.add('More active than yesterday! 📈');
      }
      if (todayWater > _yesterdayRecord!.water) {
        insights.add('Better hydration than yesterday! 💪');
      }
    }

    return insights.isEmpty ? ['Keep tracking your health daily! 📊'] : insights;
  }

  /// Get comparison data for today vs yesterday
  Map<String, Map<String, dynamic>> getComparisonData() {
    if (_yesterdayRecord == null) {
      return {
        'steps': {'today': todaySteps, 'yesterday': 0, 'change': todaySteps},
        'water': {'today': todayWater, 'yesterday': 0, 'change': todayWater},
        'calories': {'today': todayCalories, 'yesterday': 0, 'change': todayCalories},
      };
    }

    return {
      'steps': {
        'today': todaySteps,
        'yesterday': _yesterdayRecord!.steps,
        'change': todaySteps - _yesterdayRecord!.steps,
      },
      'water': {
        'today': todayWater,
        'yesterday': _yesterdayRecord!.water,
        'change': todayWater - _yesterdayRecord!.water,
      },
      'calories': {
        'today': todayCalories,
        'yesterday': _yesterdayRecord!.calories,
        'change': todayCalories - _yesterdayRecord!.calories,
      },
    };
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
