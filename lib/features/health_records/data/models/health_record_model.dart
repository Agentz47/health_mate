import '../../domain/entities/health_record.dart';
import '../../../../core/utils/date_formatter.dart';

class HealthRecordModel {
  final int? id;
  final String date;
  final int steps;
  final int calories;
  final int water;

  HealthRecordModel({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  /// Convert from entity to model
  factory HealthRecordModel.fromEntity(HealthRecord entity) {
    return HealthRecordModel(
      id: entity.id,
      date: DateFormatter.formatForDatabase(entity.date),
      steps: entity.steps,
      calories: entity.calories,
      water: entity.water,
    );
  }

  /// Convert from model to entity
  HealthRecord toEntity() {
    return HealthRecord(
      id: id,
      date: DateFormatter.parseFromDatabase(date),
      steps: steps,
      calories: calories,
      water: water,
    );
  }

  /// Create from database map
  factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
    return HealthRecordModel(
      id: map['id'] as int?,
      date: map['date'] as String,
      steps: map['steps'] as int,
      calories: map['calories'] as int,
      water: map['water'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }
}
