import 'package:moto_gp_schedule/data/models/cached_event.dart';
import 'package:moto_gp_schedule/data/models/cached_session.dart';
import 'package:moto_gp_schedule/data/models/reminder.dart';

import 'database_helper.dart';


class MotoGpLocalDataSource {
  final dbHelper = DatabaseHelper.instance;

  // ===================== EVENT & SESSION =====================

  /// Simpan event + sesi-sesinya ke database.
  /// Dipanggil setelah berhasil fetch dari internet.
  Future<void> saveEvents(List<EventWithSessionsData> eventsData) async {
    final db = await dbHelper.database;

    // Hapus data lama dulu, supaya tidak ada data basi/dobel.
    // Kita selalu replace total setiap kali fetch baru berhasil.
    await db.delete('cached_sessions');
    await db.delete('cached_events');

    for (final data in eventsData) {
      // Simpan event-nya dulu
      await db.insert('cached_events', data.event.toMap());

      // Baru simpan semua sesi yang terkait event ini
      for (final session in data.sessions) {
        await db.insert('cached_sessions', session.toMap());
      }
    }
  }

  /// Ambil semua event yang tersimpan di database,
  /// diurutkan dari yang paling lama ke paling baru (SRS-S3)
  Future<List<CachedEvent>> getAllEvents() async {
    final db = await dbHelper.database;
    final maps = await db.query('cached_events');
    return maps.map((map) => CachedEvent.fromMap(map)).toList();
  }

  /// Ambil semua sesi yang dimiliki satu event tertentu
  Future<List<CachedSession>> getSessionsForEvent(String eventId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'cached_sessions',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return maps.map((map) => CachedSession.fromMap(map)).toList();
  }

  /// Cek kapan terakhir kali data di-fetch dari internet.
  /// Dipakai untuk tahu apakah data sudah "basi" (lebih dari 24 jam, SRS-D2)
  Future<DateTime?> getLastFetchedAt() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'cached_events',
      orderBy: 'fetchedAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DateTime.parse(maps.first['fetchedAt'] as String);
  }

  // ===================== REMINDER =====================

  /// Tambah reminder baru
  Future<int> addReminder(Reminder reminder) async {
    final db = await dbHelper.database;
    return await db.insert('reminders', reminder.toMap());
  }

  /// Ambil semua reminder yang masih aktif
  Future<List<Reminder>> getAllActiveReminders() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Ambil reminder untuk satu sesi tertentu saja
  /// (dipakai di layar detail, buat tahu reminder mana yang sudah di-set)
  Future<List<Reminder>> getRemindersForSession(String sessionId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'reminders',
      where: 'sessionId = ? AND isActive = ?',
      whereArgs: [sessionId, 1],
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Hapus satu reminder berdasarkan id-nya
  Future<void> deleteReminder(int reminderId) async {
    final db = await dbHelper.database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// Hapus semua reminder yang terkait satu sesi
  /// (dipanggil saat sesi sudah Completed, SRS-N6)
  Future<void> deleteRemindersForSession(String sessionId) async {
    final db = await dbHelper.database;
    await db.delete(
      'reminders',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }
}

/// Wrapper sama seperti di remote datasource, dipakai untuk
/// membawa satu event beserta sesi-sesinya sekaligus
class EventWithSessionsData {
  final CachedEvent event;
  final List<CachedSession> sessions;

  EventWithSessionsData({required this.event, required this.sessions});
}