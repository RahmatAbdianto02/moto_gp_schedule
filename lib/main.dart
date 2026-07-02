import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

// import 'package:flutter/material.dart';
// import 'package:moto_gp_schedule/data/models/datasources/local/motogp_local_datasource.dart';
// import 'package:moto_gp_schedule/data/models/datasources/remot/motogp_remote_datasource.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   print('--- Mulai test simpan & ambil dari database ---');

//   final remoteDataSource = MotoGpRemoteDataSource();
//   final localDataSource = MotoGpLocalDataSource();

//   try {
//     // LANGKAH 1: Ambil data dari internet (sama seperti test sebelumnya)
//     print('Step 1: Mengambil data dari internet...');
//     final year = await remoteDataSource.fetchCurrentSeasonYear();
//     final eventsFromApi = await remoteDataSource.fetchEvents(year);
//     print('Berhasil ambil ${eventsFromApi.length} event dari internet');

//     // LANGKAH 2: Ubah bentuk data, lalu simpan ke database
//     print('Step 2: Menyimpan ke database...');
//     final eventsData = eventsFromApi
//         .map((e) => EventWithSessionsData(event: e.event, sessions: e.sessions))
//         .toList();
//     await localDataSource.saveEvents(eventsData);
//     print('Berhasil disimpan ke database');

//     // LANGKAH 3: Ambil lagi dari database (bukan dari internet),
//     // untuk membuktikan datanya benar-benar tersimpan
//     print('Step 3: Mengambil ulang dari database...');
//     final eventsFromDb = await localDataSource.getAllEvents();
//     print('Jumlah event yang berhasil dibaca dari database: ${eventsFromDb.length}');

//     if (eventsFromDb.isNotEmpty) {
//       final firstEvent = eventsFromDb.first;
//       print('--- Contoh event pertama dari database ---');
//       print('Nama: ${firstEvent.name}');
//       print('Negara: ${firstEvent.country}');

//       final sessions = await localDataSource.getSessionsForEvent(firstEvent.eventId);
//       print('Jumlah sesi untuk event ini: ${sessions.length}');
//       if (sessions.isNotEmpty) {
//         print('Contoh sesi: ${sessions.first.shortname} - ${sessions.first.dateStartUtc}');
//       }
//     }

//     // LANGKAH 4: Cek waktu terakhir data di-update
//     final lastFetched = await localDataSource.getLastFetchedAt();
//     print('Data terakhir diambil pada: $lastFetched');

//     print('--- Test selesai, BERHASIL ---');
//   } catch (e) {
//     print('--- Test GAGAL ---');
//     print('Error: $e');
//   }

//   runApp(const TestApp());
// }

// class TestApp extends StatelessWidget {
//   const TestApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Cek hasil testing di Debug Console'),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:moto_gp_schedule/data/models/datasources/remot/motogp_remote_datasource.dart';


// void main() async {
//   // Baris ini wajib ada kalau mau pakai fungsi async sebelum runApp
//   WidgetsFlutterBinding.ensureInitialized();

//   // ===== INI BAGIAN TESTING =====
//   print('--- Mulai test fetch API ---');

//   final dataSource = MotoGpRemoteDataSource();

//   try {
//     print('Mengambil tahun season aktif...');
//     final year = await dataSource.fetchCurrentSeasonYear();
//     print('Tahun season aktif: $year');

//     print('Mengambil daftar event untuk tahun $year...');
//     final events = await dataSource.fetchEvents(year);
//     print('Jumlah event yang berhasil diambil: ${events.length}');

//     if (events.isNotEmpty) {
//       final firstEvent = events.first;
//       print('--- Contoh event pertama ---');
//       print('Nama: ${firstEvent.event.name}');
//       print('Negara: ${firstEvent.event.country}');
//       print('Sirkuit: ${firstEvent.event.circuitName}');
//       print('Jumlah sesi: ${firstEvent.sessions.length}');

//       if (firstEvent.sessions.isNotEmpty) {
//         final firstSession = firstEvent.sessions.first;
//         print('--- Contoh sesi pertama ---');
//         print('Nama sesi: ${firstSession.shortname} (${firstSession.name})');
//         print('Waktu mulai (UTC): ${firstSession.dateStartUtc}');
//         print('Status: ${firstSession.apiStatus}');
//       }
//     }

//     print('--- Test selesai, BERHASIL ---');
//   } catch (e) {
//     print('--- Test GAGAL ---');
//     print('Error: $e');
//   }
//   // ===== AKHIR BAGIAN TESTING =====

//   runApp(const TestApp());
// }

// class TestApp extends StatelessWidget {
//   const TestApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Cek hasil testing di Debug Console'),
//         ),
//       ),
//     );
//   }
// }