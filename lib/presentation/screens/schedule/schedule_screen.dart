import 'package:flutter/material.dart';
import 'package:moto_gp_schedule/presentation/screens/detail/detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal MotoGP 2026'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: provider.state == ScheduleState.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadSchedule(forceRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.events.length,
                itemBuilder: (context, index) {
                  final item = provider.events[index];
                  final event = item.event;

                  // Cek apakah semua sesi sudah selesai
                  final isCompleted = item.sessions.isNotEmpty &&
                      item.sessions.every(
                        (s) => provider.getSessionStatus(s) == 'completed',
                      );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isCompleted ? Colors.grey : Colors.red,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        event.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(event.circuitName),
                      trailing: Chip(
                        label: Text(
                          isCompleted ? 'Selesai' : 'Upcoming',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                        backgroundColor:
                            isCompleted ? Colors.grey : Colors.red,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(eventWithSessions: item))
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}