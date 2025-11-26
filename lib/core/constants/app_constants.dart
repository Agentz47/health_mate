class AppConstants {
  // Database
  static const String databaseName = 'health_mate.db';
  static const int databaseVersion = 1;
  static const String healthRecordsTable = 'health_records';

  // Colors
  static const String waterColorHex = '#2196F3';
  static const String caloriesColorHex = '#FF5722';
  static const String stepsColorHex = '#4CAF50';

  // Validation
  static const int minValue = 0;
  static const int maxSteps = 100000;
  static const int maxCalories = 10000;
  static const int maxWater = 10000; // ml
}
