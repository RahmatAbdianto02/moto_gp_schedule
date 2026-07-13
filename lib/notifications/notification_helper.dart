import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/reminder.dart';

class NotificationHelper {
  // Singleton
  static final NotificationHelper instance = NotificationHelper._internal();
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Setup awal — dipanggil sekali di main.dart
  Future<void> initialize() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    android: androidSettings,
  );

  await _plugin.initialize(initSettings);

  // Minta izin notifikasi Android 13+
  final android = _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  
  if (android != null) {
    await android.requestNotificationsPermission();
  }
}

// Fungsi test saja — hapus setelah selesai test
Future<void> testNotification() async {
  print('=== MULAI TEST NOTIFIKASI TERJADWAL ===');

  try {
    final tzTrigger = tz.TZDateTime.now(tz.local).add(
      const Duration(seconds: 30),
    );

    print('=== NOTIFIKASI AKAN MUNCUL PUKUL: $tzTrigger ===');

    await _plugin.zonedSchedule(
      9999,
      'TEST TERJADWAL',
      'Notifikasi muncul otomatis setelah 30 detik!',
      tzTrigger,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motogp_reminder',
          'MotoGP Reminder',
          channelDescription: 'Pengingat sesi MotoGP',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('=== NOTIFIKASI TERJADWAL BERHASIL DI-SET ===');
  } catch (e) {
    print('=== ERROR: $e ===');
  }
}
  // Schedule satu notifikasi berdasarkan Reminder
  Future<void> scheduleNotification(Reminder reminder) async {
    // Kalau triggerAt sudah lewat, skip
    if (reminder.triggerAt.isBefore(DateTime.now().toUtc())) return;

    final tzTrigger = tz.TZDateTime.from(reminder.triggerAt, tz.local);

    await _plugin.zonedSchedule(
      reminder.id!, // id unik notifikasi
      '${reminder.eventName} — ${reminder.sessionName}', // judul
      'Dimulai dalam ${reminder.minutesBefore} menit', // isi
      tzTrigger,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motogp_reminder', // channel id
          'MotoGP Reminder', // channel name
          channelDescription: 'Pengingat sesi MotoGP',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Batalkan satu notifikasi
  Future<void> cancelNotification(int reminderId) async {
    await _plugin.cancel(reminderId);
  }

  // Batalkan semua notifikasi
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Re-schedule semua reminder aktif (dipanggil saat app dibuka)
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      await scheduleNotification(reminder);
    }
  }
}