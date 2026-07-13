import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moto_gp_schedule/data/models/cached_event.dart';
import 'package:moto_gp_schedule/data/models/cached_session.dart';

// urutan 2
// setelah membuat cetakan dari class cached_event lalu membuat moto_gp_remot 
//yang tugasnya pergi ke api dan ambil data 
// Kirim permintaan ke api.motogp.pulselive.com
// Terima data JSON
// Saring data yang dibutuhkan (hanya MotoGP, bukan Moto2/Moto3)
// Ubah JSON jadi object Dart (pakai fromMap())


class MotoGpRemoteDataSource {
  static const String _baseUrl = 'https://api.motogp.pulselive.com/motogp/v1';

  // Beberapa hidden API menolak request tanpa User-Agent yang wajar
  // method buat mengambil data 
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Android) MotoGpScheduleApp/1.0',
    'Accept': 'application/json',
  };

  /// Ambil tahun season yang sedang berjalan (current: true)
  /// dari GET /results/seasons
  Future<int> fetchCurrentSeasonYear() async {
    //Kirim permintaan ke API.
    final url = Uri.parse('$_baseUrl/results/seasons');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal fetch seasons: ${response.statusCode}');
    }
    //Ubah teks JSON tadi jadi List Dart yang bisa kita baca. Hasilnya list berisi 3 item (3 season).
    final List<dynamic> data = jsonDecode(response.body);

    final currentSeason = data.firstWhere(
      (season) => season['current'] == true,
      orElse: () => throw Exception('Tidak ada season dengan current: true'),
    );
      //Ambil angka tahunnya saja — return 2026
    return currentSeason['year'] as int;
  }

  /// Ambil semua event untuk season tertentu, sudah di-parse
  /// menjadi CachedEvent + list CachedSession per event.
  /// Filter: hanya broadcasts dengan type == "SESSION"
  /// dan category.acronym == "MGP" (SRS-D4, SRS-D5)
  Future<List<RemotEventData>> fetchEvents(int seasonYear) async {
    final url = Uri.parse('$_baseUrl/events?seasonYear=$seasonYear');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal fetch events: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final List<RemotEventData> result = [];

    final now = DateTime.now();

    for (final eventJson in data) {
      // Skip event tipe TEST (bukan GP race weekend)
      if (eventJson['kind'] == 'TEST') continue;

      final List<dynamic> broadcasts = eventJson['broadcasts'] ?? [];

      final sessions = <CachedSession>[];

      for (final broadcast in broadcasts) {
        // Filter SRS-D5: hanya type SESSION (exclude MEDIA)
        if (broadcast['type'] != 'SESSION') continue;

        // Filter SRS-D4: hanya kategori MotoGP
        final category = broadcast['category'];
        if (category == null || category['acronym'] != 'MGP') continue;

        try {
          sessions.add(
            CachedSession(
              sessionId: broadcast['id'] as String,
              eventId: eventJson['id'] as String,
              shortname: broadcast['shortname'] as String? ?? '',
              name: broadcast['name'] as String? ?? '',
              kind: broadcast['kind'] as String? ?? 'UNKNOWN',
              dateStartUtc: DateTime.parse(broadcast['date_start'] as String).toUtc(),
              apiStatus: broadcast['status'] as String? ?? 'UNKNOWN',
            ),
          );
        } catch (e) {
          // SRS-E3: jangan crash kalau satu broadcast gagal parse,
          // skip saja item itu, lanjut ke berikutnya
          continue;
        }
      }

      // Skip event yang tidak punya sesi MotoGP sama sekali
      if (sessions.isEmpty) continue;

      try {
        final event = CachedEvent(
          eventId: eventJson['id'] as String,
          name: eventJson['name'] as String? ?? 'Unknown Event',
          country: eventJson['country'] as String? ?? '',
          circuitName: eventJson['circuit']?['name'] as String? ?? '',
          seasonYear: seasonYear,
          fetchedAt: now,
        );

        result.add(RemotEventData(event: event, sessions: sessions));
      } catch (e) {
        // SRS-E3: skip event yang gagal parse, jangan crash
        continue;
      }
    }

    return result;
  }
}

/// Wrapper sederhana untuk membawa event + sesi-sesinya sekaligus,
/// dipakai sebagai hasil parsing sebelum disimpan ke SQLite
class RemotEventData {
  final CachedEvent event;
  final List<CachedSession> sessions;

  RemotEventData({required this.event, required this.sessions});
}