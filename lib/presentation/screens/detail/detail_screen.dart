import 'package:flutter/material.dart';
import 'package:moto_gp_schedule/data/models/datasources/repositories/motogp_repository.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/reminder_provider.dart';

class DetailScreen extends StatelessWidget {
  final EventWithSessions eventWithSessions;

  const DetailScreen({super.key, required this.eventWithSessions});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final reminderProvider = context.watch<ReminderProvider>();
    final event = eventWithSessions.event;
    final sessions = eventWithSessions.sessions;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(event.name),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info sirkuit
          Container(
            decoration: AppTheme.cardDecoration(color: AppTheme.cream),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primary,
                  child: const Text(
                    'INFO SIRKUIT',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.circuitName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.flag,
                              color: AppTheme.grey, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Negara: ${event.country}',
                            style: const TextStyle(color: AppTheme.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header jadwal sesi
          const Text(
            'JADWAL SESI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Daftar sesi
          ...sessions.map((session) {
            final status = scheduleProvider.getSessionStatus(session);
            final timeStr =
                scheduleProvider.formatSessionTime(session.dateStartUtc);

            // Warna badge berdasarkan status
            Color badgeColor;
            String badgeLabel;
            if (status == 'upcoming') {
              badgeColor = Colors.blue;
              badgeLabel = 'UPCOMING';
            } else if (status == 'ongoing') {
              badgeColor = Colors.green;
              badgeLabel = 'LIVE';
            } else {
              badgeColor = AppTheme.grey;
              badgeLabel = 'SELESAI';
            }

            // Cek apakah sesi ini punya reminder
            final sessionReminders =
                reminderProvider.getRemindersForSession(session.sessionId);
            final hasReminder = sessionReminders.isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: AppTheme.cardDecoration(
                color: status == 'ongoing'
                    ? Colors.green.shade50
                    : AppTheme.white,
              ),
              child: Row(
                children: [
                  // Badge nama sesi
                  Container(
                    width: 56,
                    constraints: const BoxConstraints(minHeight: 64),
                    color: status == 'completed'
                        ? AppTheme.grey
                        : AppTheme.primary,
                    child: Center(
                      child: Text(
                        session.shortname.length > 3
                            ? session.shortname.substring(0, 3)
                            : session.shortname,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  // Info sesi
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: AppTheme.grey,
                              fontSize: 12,
                            ),
                          ),
                          // Tampilkan reminder yang sudah di-set
                          if (hasReminder) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              children: sessionReminders.map((r) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.yellow,
                                    border: Border.all(
                                        color: AppTheme.black, width: 1),
                                  ),
                                  child: Text(
                                    '${r.minutesBefore}m',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Tombol bell + badge status
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            border: Border.all(
                                color: AppTheme.black, width: 1.5),
                          ),
                          child: Text(
                            badgeLabel,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tombol bell — hanya tampil kalau sesi belum selesai
                        if (status != 'completed')
                          GestureDetector(
                            onTap: () => _showReminderBottomSheet(
                              context,
                              session.sessionId,
                              session.name,
                              event.name,
                              session.dateStartUtc,
                              reminderProvider,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: hasReminder
                                    ? AppTheme.yellow
                                    : AppTheme.white,
                                border: Border.all(
                                    color: AppTheme.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppTheme.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                hasReminder
                                    ? Icons.notifications_active
                                    : Icons.notifications_none,
                                size: 18,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showReminderBottomSheet(
    BuildContext context,
    String sessionId,
    String sessionName,
    String eventName,
    DateTime sessionStartUtc,
    ReminderProvider reminderProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.black, width: 2),
      ),
      builder: (_) {
        return _ReminderBottomSheet(
          sessionId: sessionId,
          sessionName: sessionName,
          eventName: eventName,
          sessionStartUtc: sessionStartUtc,
          reminderProvider: reminderProvider,
        );
      },
    );
  }
}

class _ReminderBottomSheet extends StatefulWidget {
  final String sessionId;
  final String sessionName;
  final String eventName;
  final DateTime sessionStartUtc;
  final ReminderProvider reminderProvider;

  const _ReminderBottomSheet({
    required this.sessionId,
    required this.sessionName,
    required this.eventName,
    required this.sessionStartUtc,
    required this.reminderProvider,
  });

  @override
  State<_ReminderBottomSheet> createState() => _ReminderBottomSheetState();
}

class _ReminderBottomSheetState extends State<_ReminderBottomSheet> {
  final List<int> _options = [10, 15, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppTheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SET REMINDER',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.sessionName,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
      
            const Text(
              'INGATKAN SAYA:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
      
            // Pilihan menit
            ..._options.map((minutes) {
              final triggerAt = widget.sessionStartUtc
                  .subtract(Duration(minutes: minutes));
              final isExpired = triggerAt.isBefore(DateTime.now().toUtc());
              final hasThis = widget.reminderProvider
                  .hasReminder(widget.sessionId, minutes);
      
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isExpired
                      ? AppTheme.cream
                      : hasThis
                          ? AppTheme.yellow
                          : AppTheme.white,
                  border: Border.all(
                    color: isExpired ? AppTheme.grey : AppTheme.black,
                    width: 2,
                  ),
                  boxShadow: isExpired
                      ? []
                      : const [
                          BoxShadow(
                            color: AppTheme.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    minutes < 60
                        ? '$minutes menit sebelum'
                        : '${minutes ~/ 60} jam sebelum',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isExpired ? AppTheme.grey : AppTheme.black,
                    ),
                  ),
                  subtitle: isExpired
                      ? const Text(
                          'Waktu sudah lewat',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey,
                          ),
                        )
                      : null,
                  trailing: isExpired
                      ? null
                      : hasThis
                          ? GestureDetector(
                              onTap: () async {
                                final reminders = widget.reminderProvider
                                    .getRemindersForSession(widget.sessionId);
                                final reminder = reminders.firstWhere(
                                    (r) => r.minutesBefore == minutes);
                                await widget.reminderProvider
                                    .removeReminder(reminder.id!);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  border: Border.all(
                                      color: AppTheme.black, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppTheme.white,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () async {
                                final berhasil =
                                    await widget.reminderProvider.addReminder(
                                  sessionId: widget.sessionId,
                                  sessionName: widget.sessionName,
                                  eventName: widget.eventName,
                                  sessionStartUtc: widget.sessionStartUtc,
                                  minutesBefore: minutes,
                                );
                                if (!berhasil && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Waktu sudah lewat'),
                                    ),
                                  );
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  border: Border.all(
                                      color: AppTheme.black, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                ),
                              ),
                            ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}