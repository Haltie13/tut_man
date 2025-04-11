import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Database? _db;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'tutoring.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Student(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pricePerHour TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Meeting(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT NOT NULL,
        duration INTEGER NOT NULL,
        eventId TEXT,
        calendarId TEXT,
        studentId INTEGER NOT NULL,
        price TEXT NOT NULL,
        paid INTEGER NOT NULL,
        description TEXT,
        FOREIGN KEY(studentId) REFERENCES Student(id)
      )
    ''');
  }

  Future<void> resetDB() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
    }
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'tutoring.db');
    await deleteDatabase(path);
    _db = null;
  }
}