import '../../domain/entities/health_record.dart';
import '../../domain/repositories/health_repository.dart';
import '../models/health_record_model.dart';
import '../datasources/local/database_helper.dart';
import '../../../../core/utils/date_formatter.dart';

class HealthRepositoryImpl implements HealthRepository {
  final DatabaseHelper _databaseHelper;

  HealthRepositoryImpl(this._databaseHelper);

  @override
  Future<int> addRecord(HealthRecord record) async {
    final model = HealthRecordModel.fromEntity(record);
    return await _databaseHelper.insert(model.toMap());
  }

  @override
  Future<List<HealthRecord>> getAllRecords() async {
    final maps = await _databaseHelper.queryAll();
    return maps.map((map) {
      return HealthRecordModel.fromMap(map).toEntity();
    }).toList();
  }

  @override
  Future<List<HealthRecord>> getRecordsByDate(DateTime date) async {
    final dateString = DateFormatter.formatForDatabase(date);
    final maps = await _databaseHelper.queryByDate(dateString);
    return maps.map((map) {
      return HealthRecordModel.fromMap(map).toEntity();
    }).toList();
  }

  @override
  Future<int> updateRecord(HealthRecord record) async {
    final model = HealthRecordModel.fromEntity(record);
    return await _databaseHelper.update(model.toMap());
  }

  @override
  Future<int> deleteRecord(int id) async {
    return await _databaseHelper.delete(id);
  }

  @override
  Future<HealthRecord?> getTodayRecord() async {
    final today = DateTime.now();
    final records = await getRecordsByDate(today);
    return records.isNotEmpty ? records.first : null;
  }

  @override
  Future<bool> hasRecordForDate(DateTime date) async {
    final records = await getRecordsByDate(date);
    return records.isNotEmpty;
  }

  // Streak tracking methods
  Future<int> getCurrentStreak() async {
    return await _databaseHelper.getCurrentStreak();
  }

  Future<int> calculateAndUpdateStreak(DateTime entryDate) async {
    final dateString = DateFormatter.formatForDatabase(entryDate);
    return await _databaseHelper.calculateAndUpdateStreak(dateString);
  }
}
