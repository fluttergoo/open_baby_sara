import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE timer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE activities(activityID TEXT PRIMARY KEY, activityType TEXT, createdAt TEXT,updatedAt TEXT,activityDateTime TEXT,data TEXT,createdBy TEXT,babyID TEXT,isSynced INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE leftPumpTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE rightPumpTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE sleepTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE pumpTotalTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE rightBreastfeedTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE leftBreastfeedTimer(id INTEGER PRIMARY KEY,startTime TEXT, isRunning INTEGER)''',
        );
        await db.execute(
          '''CREATE TABLE medications(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT)''',
        );
        await db.execute(
          '''CREATE TABLE vaccinations(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT)''',
        );
        await db.execute(
          '''CREATE TABLE relaxing_sound(id INTEGER PRIMARY KEY,sound_index INTEGER, isRunning INTEGER)''',
        );

      },
    );
  }

  static Future<void> closeDatabase() async {
    final db = _database;

    if (db != null) {
      await db.close();
    }
    _database = null;
  }
}
