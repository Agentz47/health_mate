import 'package:flutter/material.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_repository.dart';

class HealthRecordProvider extends ChangeNotifier {
  final HealthRepository _repository;

  List<HealthRecord> _records = [];
  HealthRecord? _todayRecord;
  bool _isLoading = false;
  String? _errorMessage;

  HealthRecordProvider(this._repository);

  // Getters
  List<HealthRecord> get records => _records;
  HealthRecord? get todayRecord => _todayRecord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all records from database
  Future<void> loadRecords() async {
    _setLoading(true);
    _clearError();

    try {
      _records = await _repository.getAllRecords();
      await _loadTodayRecord();
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

  /// Add a new health record
  Future<bool> addRecord(HealthRecord record) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.addRecord(record);
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
