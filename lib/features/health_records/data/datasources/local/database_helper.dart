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

    // Insert dummy records for testing
    await _insertDummyData(db);
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
}
