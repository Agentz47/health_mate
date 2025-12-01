import '../entities/health_record.dart';

abstract class HealthRepository {
  /// Add a new health record
  Future<int> addRecord(HealthRecord record);

  /// Get all health records
  Future<List<HealthRecord>> getAllRecords();

  /// Get health records for a specific date
  Future<List<HealthRecord>> getRecordsByDate(DateTime date);

  /// Update an existing health record
  Future<int> updateRecord(HealthRecord record);

  /// Delete a health record by ID
  Future<int> deleteRecord(int id);

  /// Get the health record for today
  Future<HealthRecord?> getTodayRecord();

  /// Check if a record exists for a specific date
  Future<bool> hasRecordForDate(DateTime date);

  /// Upsert today's step count (update if exists, insert if not)
  Future<void> upsertTodaySteps({required String dateString, required int steps});

  /// Upsert today's steps and calories (update if exists, insert if not)
  Future<void> upsertTodayStepsAndCalories({
    required String dateString,
    required int steps,
    required int calories,
  });
}
