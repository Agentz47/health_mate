/// User Profile entity
class UserProfile {
  final String? name;
  final double? weightKg;
  final int? heightCm;
  final int? age;

  UserProfile({
    this.name,
    this.weightKg,
    this.heightCm,
    this.age,
  });

  bool get hasAnyData => 
      name != null || weightKg != null || heightCm != null || age != null;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String?,
      weightKg: map['weightKg'] as double?,
      heightCm: map['heightCm'] as int?,
      age: map['age'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
    };
  }

  UserProfile copyWith({
    String? name,
    double? weightKg,
    int? heightCm,
    int? age,
  }) {
    return UserProfile(
      name: name ?? this.name,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
    );
  }
}
