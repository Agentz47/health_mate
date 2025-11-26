class HealthRecord {
  final int? id;
  final DateTime date;
  final int steps;
  final int calories;
  final int water; // in ml

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  HealthRecord copyWith({
    int? id,
    DateTime? date,
    int? steps,
    int? calories,
    int? water,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
    );
  }

  @override
  String toString() {
    return 'HealthRecord(id: $id, date: $date, steps: $steps, calories: $calories, water: $water)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthRecord &&
        other.id == id &&
        other.date == date &&
        other.steps == steps &&
        other.calories == calories &&
        other.water == water;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        steps.hashCode ^
        calories.hashCode ^
        water.hashCode;
  }
}
