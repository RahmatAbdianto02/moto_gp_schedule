import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/datasources/repositories/motogp_repository.dart';
import '../../providers/schedule_provider.dart';

class DetailScreen extends StatelessWidget {
  final EventWithSessions eventWithSessions;

  const DetailScreen({super.key, required this.eventWithSessions});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final event = eventWithSessions.event;
    final sessions = eventWithSessions.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info sirkuit
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.circuitName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Negara: ${event.country}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Jadwal Sesi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Daftar sesi
          ...sessions.map((session) {
            final status = provider.getSessionStatus(session);
            final timeStr = provider.formatSessionTime(session.dateStartUtc);

            Color badgeColor;
            String badgeLabel;
            if (status == 'upcoming') {
              badgeColor = Colors.blue;
              badgeLabel = 'Upcoming';
            } else if (status == 'ongoing') {
              badgeColor = Colors.green;
              badgeLabel = 'Berlangsung';
            } else {
              badgeColor = Colors.grey;
              badgeLabel = 'Selesai';
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: badgeColor,
                  radius: 20,
                  child: Text(
                    session.shortname.length > 3
                        ? session.shortname.substring(0, 3)
                        : session.shortname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  session.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(timeStr),
                trailing: Chip(
                  label: Text(
                    badgeLabel,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: badgeColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}