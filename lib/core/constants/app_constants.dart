class AppConstants {
  // Database
  static const String databaseName = 'health_mate.db';
  static const int databaseVersion = 3; // Incremented for settings and achievements
  static const String healthRecordsTable = 'health_records';
  static const String metadataTable = 'app_metadata';
  static const String userSettingsTable = 'user_settings';
  static const String achievementsTable = 'user_achievements';

  // Colors
  static const String waterColorHex = '#2196F3';
  static const String caloriesColorHex = '#FF5722';
  static const String stepsColorHex = '#4CAF50';

  // Validation
  static const int minValue = 0;
  static const int maxSteps = 100000;
  static const int maxCalories = 10000;
  static const int maxWater = 10000; // ml
  
  // Goals & Achievements
  static const int defaultWaterGoal = 2000; // ml
  static const int bronzeSteps = 5000;
  static const int silverSteps = 8000;
  static const int goldSteps = 10000;
  static const int hydrationHeroWater = 2500; // ml
}
