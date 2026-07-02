import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern — hanya ada satu instance database di seluruh app
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'motogp_schedule.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel CachedEvent
    await db.execute('''
      CREATE TABLE cached_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        circuitName TEXT NOT NULL,
        seasonYear INTEGER NOT NULL,
        fetchedAt TEXT NOT NULL
      )
    ''');

    // Tabel CachedSession — eventId merujuk ke cached_events.eventId
    await db.execute('''
      CREATE TABLE cached_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL UNIQUE,
        eventId TEXT NOT NULL,
        shortname TEXT NOT NULL,
        name TEXT NOT NULL,
        kind TEXT NOT NULL,
        dateStartUtc TEXT NOT NULL,
        apiStatus TEXT NOT NULL,
        FOREIGN KEY (eventId) REFERENCES cached_events (eventId) ON DELETE CASCADE
      )
    ''');

    // Tabel Reminder — sessionId disimpan sebagai string reference,
    // bukan foreign key strict, supaya reminder tetap valid walau
    // cache session di-refresh (lihat catatan desain di SDD)
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL,
        sessionName TEXT NOT NULL,
        eventName TEXT NOT NULL,
        sessionStartUtc TEXT NOT NULL,
        minutesBefore INTEGER NOT NULL,
        triggerAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}