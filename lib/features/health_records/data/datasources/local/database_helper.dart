import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/date_formatter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.healthRecordsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');

    // Create metadata table for streak tracking
    await db.execute('''
      CREATE TABLE app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Initialize streak data
    await db.insert('app_metadata', {'key': 'current_streak', 'value': '0'});
    await db.insert('app_metadata', {'key': 'last_entry_date', 'value': ''});

    // Create user settings table
    await db.execute('''
      CREATE TABLE ${AppConstants.userSettingsTable} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Initialize default water goal
    await db.insert(AppConstants.userSettingsTable, {
      'key': 'water_goal',
      'value': AppConstants.defaultWaterGoal.toString()
    });

    // Create achievements table
    await db.execute('''
      CREATE TABLE ${AppConstants.achievementsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        earned_date TEXT,
        is_earned INTEGER DEFAULT 0
      )
    ''');

    // Insert achievement definitions
    await _insertAchievements(db);

    // Insert dummy records for testing
    await _insertDummyData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add metadata table for streak tracking
      await db.execute('''
        CREATE TABLE app_metadata (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      // Initialize streak data
      await db.insert('app_metadata', {'key': 'current_streak', 'value': '0'});
      await db.insert('app_metadata', {'key': 'last_entry_date', 'value': ''});
    }

    if (oldVersion < 3) {
      // Add user settings table
      await db.execute('''
        CREATE TABLE ${AppConstants.userSettingsTable} (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      // Initialize default water goal
      await db.insert(AppConstants.userSettingsTable, {
        'key': 'water_goal',
        'value': AppConstants.defaultWaterGoal.toString()
      });

      // Add achievements table
      await db.execute('''
        CREATE TABLE ${AppConstants.achievementsTable} (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          earned_date TEXT,
          is_earned INTEGER DEFAULT 0
        )
      ''');

      // Insert achievement definitions
      await _insertAchievements(db);
    }
  }

  Future<void> _insertDummyData(Database db) async {
    final now = DateTime.now();
    final dummyRecords = [
      {
        'date': DateFormatter.formatForDatabase(now),
        'steps': 8500,
        'calories': 2100,
        'water': 2000,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 1))),
        'steps': 10200,
        'calories': 2300,
        'water': 2500,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 2))),
        'steps': 7800,
        'calories': 1950,
        'water': 1800,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 3))),
        'steps': 12000,
        'calories': 2400,
        'water': 2200,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 4))),
        'steps': 6500,
        'calories': 1800,
        'water': 1500,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 5))),
        'steps': 9800,
        'calories': 2200,
        'water': 2400,
      },
      {
        'date': DateFormatter.formatForDatabase(now.subtract(const Duration(days: 6))),
        'steps': 11500,
        'calories': 2500,
        'water': 2600,
      },
    ];

    for (var record in dummyRecords) {
      await db.insert(AppConstants.healthRecordsTable, record);
    }
  }

  Future<void> _insertAchievements(Database db) async {
    final achievements = [
      {
        'id': 'bronze_steps',
        'name': '🥉 Bronze Steps',
        'description': 'Walk ${AppConstants.bronzeSteps} steps in a day',
        'earned_date': null,
        'is_earned': 0,
      },
      {
        'id': 'silver_steps',
        'name': '🥈 Silver Steps',
        'description': 'Walk ${AppConstants.silverSteps} steps in a day',
        'earned_date': null,
        'is_earned': 0,
      },
      {
        'id': 'gold_steps',
        'name': '🥇 Gold Steps',
        'description': 'Walk ${AppConstants.goldSteps} steps in a day',
        'earned_date': null,
        'is_earned': 0,
      },
      {
        'id': 'hydration_hero',
        'name': '💧 Hydration Hero',
        'description': 'Drink ${AppConstants.hydrationHeroWater}ml water in a day',
        'earned_date': null,
        'is_earned': 0,
      },
    ];

    for (var achievement in achievements) {
      await db.insert(AppConstants.achievementsTable, achievement);
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(AppConstants.healthRecordsTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return await db.query(
      AppConstants.healthRecordsTable,
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryByDate(String date) async {
    final db = await database;
    return await db.query(
      AppConstants.healthRecordsTable,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update(
      AppConstants.healthRecordsTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.healthRecordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Streak tracking methods
  Future<int> getCurrentStreak() async {
    final db = await database;
    final result = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: ['current_streak'],
    );
    if (result.isEmpty) return 0;
    return int.tryParse(result.first['value'] as String) ?? 0;
  }

  Future<String> getLastEntryDate() async {
    final db = await database;
    final result = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: ['last_entry_date'],
    );
    if (result.isEmpty) return '';
    return result.first['value'] as String;
  }

  Future<void> updateStreak(int streak, String lastDate) async {
    final db = await database;
    await db.update(
      'app_metadata',
      {'value': streak.toString()},
      where: 'key = ?',
      whereArgs: ['current_streak'],
    );
    await db.update(
      'app_metadata',
      {'value': lastDate},
      where: 'key = ?',
      whereArgs: ['last_entry_date'],
    );
  }

  Future<int> calculateAndUpdateStreak(String newEntryDate) async {
    final lastDate = await getLastEntryDate();
    int currentStreak = await getCurrentStreak();

    if (lastDate.isEmpty) {
      // First entry ever
      currentStreak = 1;
    } else {
      final lastEntry = DateFormatter.parseFromDatabase(lastDate);
      final newEntry = DateFormatter.parseFromDatabase(newEntryDate);
      final difference = newEntry.difference(lastEntry).inDays;

      if (difference == 1) {
        // Consecutive day - increment streak
        currentStreak++;
      } else if (difference == 0) {
        // Same day - keep streak (updating existing entry)
        // Do nothing
      } else {
        // Missed day(s) - reset streak
        currentStreak = 1;
      }
    }

    await updateStreak(currentStreak, newEntryDate);
    return currentStreak;
  }

  Future<List<String>> getAllUniqueDates() async {
    final db = await database;
    final result = await db.query(
      AppConstants.healthRecordsTable,
      columns: ['date'],
      distinct: true,
      orderBy: 'date DESC',
    );
    return result.map((row) => row['date'] as String).toList();
  }

  // User Settings methods
  Future<int> getWaterGoal() async {
    final db = await database;
    final result = await db.query(
      AppConstants.userSettingsTable,
      where: 'key = ?',
      whereArgs: ['water_goal'],
    );
    if (result.isEmpty) return AppConstants.defaultWaterGoal;
    return int.tryParse(result.first['value'] as String) ?? AppConstants.defaultWaterGoal;
  }

  Future<void> setWaterGoal(int goal) async {
    final db = await database;
    await db.update(
      AppConstants.userSettingsTable,
      {'value': goal.toString()},
      where: 'key = ?',
      whereArgs: ['water_goal'],
    );
  }

  // Achievements methods
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final db = await database;
    return await db.query(AppConstants.achievementsTable);
  }

  Future<List<Map<String, dynamic>>> getEarnedAchievements() async {
    final db = await database;
    return await db.query(
      AppConstants.achievementsTable,
      where: 'is_earned = ?',
      whereArgs: [1],
    );
  }

  Future<void> unlockAchievement(String achievementId) async {
    final db = await database;
    await db.update(
      AppConstants.achievementsTable,
      {
        'is_earned': 1,
        'earned_date': DateFormatter.formatForDatabase(DateTime.now()),
      },
      where: 'id = ? AND is_earned = 0',
      whereArgs: [achievementId],
    );
  }

  Future<void> checkAndUnlockAchievements(int steps, int water) async {
    if (steps >= AppConstants.goldSteps) {
      await unlockAchievement('gold_steps');
      await unlockAchievement('silver_steps');
      await unlockAchievement('bronze_steps');
    } else if (steps >= AppConstants.silverSteps) {
      await unlockAchievement('silver_steps');
      await unlockAchievement('bronze_steps');
    } else if (steps >= AppConstants.bronzeSteps) {
      await unlockAchievement('bronze_steps');
    }

    if (water >= AppConstants.hydrationHeroWater) {
      await unlockAchievement('hydration_hero');
    }
  }

  // Yesterday's data for comparison
  Future<Map<String, dynamic>?> getYesterdayRecord() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateString = DateFormatter.formatForDatabase(yesterday);
    final results = await queryByDate(dateString);
    return results.isNotEmpty ? results.first : null;
  }

  // Upsert today's step count (for step counter provider)
  Future<void> upsertTodaySteps({required String dateString, required int steps}) async {
    final db = await database;
    final existing = await db.query(
      AppConstants.healthRecordsTable,
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (existing.isNotEmpty) {
      // Update existing record with new step count
      await db.update(
        AppConstants.healthRecordsTable,
        {'steps': steps},
        where: 'date = ?',
        whereArgs: [dateString],
      );
    } else {
      // Insert new record with steps, calories=0, water=0
      await db.insert(
        AppConstants.healthRecordsTable,
        {
          'date': dateString,
          'steps': steps,
          'calories': 0,
          'water': 0,
        },
      );
    }
  }

  // Upsert today's steps and calories (for personalized calorie calculation)
  Future<void> upsertTodayStepsAndCalories({
    required String dateString,
    required int steps,
    required int calories,
  }) async {
    final db = await database;
    final existing = await db.query(
      AppConstants.healthRecordsTable,
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (existing.isNotEmpty) {
      // Update existing record with steps and calories
      await db.update(
        AppConstants.healthRecordsTable,
        {
          'steps': steps,
          'calories': calories,
        },
        where: 'date = ?',
        whereArgs: [dateString],
      );
    } else {
      // Insert new record with steps, calories, water=0
      await db.insert(
        AppConstants.healthRecordsTable,
        {
          'date': dateString,
          'steps': steps,
          'calories': calories,
          'water': 0,
        },
      );
    }
  }
}
