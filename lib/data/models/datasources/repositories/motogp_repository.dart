import 'package:moto_gp_schedule/data/models/cached_event.dart';
import 'package:moto_gp_schedule/data/models/cached_session.dart';
import 'package:moto_gp_schedule/data/models/datasources/local/motogp_local_datasource.dart';
import 'package:moto_gp_schedule/data/models/datasources/remot/motogp_remote_datasource.dart';
import 'package:moto_gp_schedule/data/models/reminder.dart';



/// Bungkusan sederhana: satu event beserta semua sesinya,
/// dipakai supaya Provider gampang nampilin di layar
class EventWithSessions {
  final CachedEvent event;
  final List<CachedSession> sessions;

  EventWithSessions({required this.event, required this.sessions});
}

class MotoGpRepository {
  final MotoGpRemoteDataSource remoteDataSource;
  final MotoGpLocalDataSource localDataSource;

  MotoGpRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // Data dianggap basi kalau sudah lebih dari 24 jam (SRS-D2)
  static const int _cacheStaleHours = 24;

  /// Fungsi utama buat ambil jadwal.
  /// Logikanya:
  /// 1. Cek data di database sudah ada belum, dan masih baru atau sudah basi
  /// 2. Kalau belum ada ATAU sudah basi -> coba ambil dari internet
  /// 3. Kalau ambil dari internet gagal (misal tidak ada koneksi) ->
  ///    tetap pakai data lama dari database (kalau ada)
  /// 4. Kalau tidak ada data sama sekali dan internet juga gagal -> lempar error
  Future<List<EventWithSessions>> getSchedule({bool forceRefresh = false}) async {
    final lastFetchedAt = await localDataSource.getLastFetchedAt();

    final isStale = lastFetchedAt == null ||
        DateTime.now().difference(lastFetchedAt).inHours >= _cacheStaleHours;

    final needsFetch = forceRefresh || isStale;

    if (needsFetch) {
      try {
        final year = await remoteDataSource.fetchCurrentSeasonYear();
        final eventsFromApi = await remoteDataSource.fetchEvents(year);

        final eventsData = eventsFromApi
            .map((e) => EventWithSessionsData(event: e.event, sessions: e.sessions))
            .toList();

        await localDataSource.saveEvents(eventsData);
      } catch (e) {
        // SRS-E1, SRS-E2: kalau fetch gagal, jangan langsung error.
        // Coba dulu pakai data lama dari database.
        final cachedEvents = await localDataSource.getAllEvents();
        if (cachedEvents.isEmpty) {
          // Tidak ada data sama sekali, baru benar-benar error
          rethrow;
        }
        // Ada data lama, lanjut pakai itu (tidak rethrow)
      }
    }

    // Ambil data dari database (baik itu yang baru saja di-fetch,
    // atau data lama kalau fetch tadi gagal/di-skip)
    return _loadFromDatabase();
  }

  Future<List<EventWithSessions>> _loadFromDatabase() async {
    final events = await localDataSource.getAllEvents();
    final result = <EventWithSessions>[];

    for (final event in events) {
      final sessions = await localDataSource.getSessionsForEvent(event.eventId);
      result.add(EventWithSessions(event: event, sessions: sessions));
    }

    return result;
  }

  Future<DateTime?> getLastFetchedAt() => localDataSource.getLastFetchedAt();

  // ===================== REMINDER =====================

  Future<void> addReminder(Reminder reminder) => localDataSource.addReminder(reminder);

  Future<List<Reminder>> getAllActiveReminders() =>
      localDataSource.getAllActiveReminders();

  Future<List<Reminder>> getRemindersForSession(String sessionId) =>
      localDataSource.getRemindersForSession(sessionId);

  Future<void> deleteReminder(int reminderId) =>
      localDataSource.deleteReminder(reminderId);

  Future<void> deleteRemindersForSession(String sessionId) =>
      localDataSource.deleteRemindersForSession(sessionId);
}