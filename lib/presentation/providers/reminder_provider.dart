import 'package:flutter/foundation.dart';
import 'package:moto_gp_schedule/data/models/datasources/repositories/motogp_repository.dart';
import 'package:moto_gp_schedule/notifications/notification_helper.dart';

import '../../data/models/reminder.dart';


class ReminderProvider extends ChangeNotifier {
  final MotoGpRepository repository;
  final _notifHelper = NotificationHelper.instance;

  ReminderProvider({required this.repository});

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  // Muat semua reminder + re-schedule notifikasi (SRS-N4)
  Future<void> loadReminders() async {
    _reminders = await repository.getAllActiveReminders();

    // Re-schedule semua reminder yang masih valid
    await _notifHelper.rescheduleAll(_reminders);

    notifyListeners();
  }

  // Tambah reminder baru
  Future<bool> addReminder({
    required String sessionId,
    required String sessionName,
    required String eventName,
    required DateTime sessionStartUtc,
    required int minutesBefore,
  }) async {
    final triggerAt =
        sessionStartUtc.subtract(Duration(minutes: minutesBefore));

    if (triggerAt.isBefore(DateTime.now().toUtc())) {
      return false;
    }

    final reminder = Reminder(
      sessionId: sessionId,
      sessionName: sessionName,
      eventName: eventName,
      sessionStartUtc: sessionStartUtc,
      minutesBefore: minutesBefore,
      triggerAt: triggerAt,
      isActive: true,
    );

    final id = await repository.addReminder(reminder);

    // Buat object reminder baru dengan id yang dapat dari database
    final reminderWithId = Reminder(
      id: id,
      sessionId: sessionId,
      sessionName: sessionName,
      eventName: eventName,
      sessionStartUtc: sessionStartUtc,
      minutesBefore: minutesBefore,
      triggerAt: triggerAt,
      isActive: true,
    );

    // Schedule notifikasi
    await _notifHelper.scheduleNotification(reminderWithId);

    await loadReminders();
    return true;
  }

  // Hapus reminder + batalkan notifikasi
  Future<void> removeReminder(int reminderId) async {
    await _notifHelper.cancelNotification(reminderId);
    await repository.deleteReminder(reminderId);
    await loadReminders();
  }

  List<Reminder> getRemindersForSession(String sessionId) {
    return _reminders.where((r) => r.sessionId == sessionId).toList();
  }

  bool hasReminder(String sessionId, int minutesBefore) {
    return _reminders.any(
      (r) => r.sessionId == sessionId && r.minutesBefore == minutesBefore,
    );
  }

  Future<void> removeRemindersForSession(String sessionId) async {
    final sessionReminders = getRemindersForSession(sessionId);
    for (final r in sessionReminders) {
      await _notifHelper.cancelNotification(r.id!);
    }
    await repository.deleteRemindersForSession(sessionId);
    await loadReminders();
  }
}