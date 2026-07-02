import 'package:flutter/foundation.dart';
import 'package:moto_gp_schedule/data/models/datasources/repositories/motogp_repository.dart';
import 'package:moto_gp_schedule/data/models/reminder.dart';

class ReminderProvider extends ChangeNotifier {
  final MotoGpRepository repository;

  ReminderProvider({required this.repository});

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  Future<void> loadReminders() async {
    _reminders = await repository.getAllActiveReminders();
    notifyListeners();
  }

  Future<bool> addReminder({
    required String sessionId,
    required String sessionName,
    required String eventName,
    required DateTime sessionStartUtc,
    required int minutesBefore,
  }) async {
    final triggerAt = sessionStartUtc.subtract(Duration(minutes: minutesBefore));
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
    await repository.addReminder(reminder);
    await loadReminders();
    return true;
  }

  Future<void> removeReminder(int reminderId) async {
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
    await repository.deleteRemindersForSession(sessionId);
    await loadReminders();
  }
}