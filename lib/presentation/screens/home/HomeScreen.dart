import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MotoGP Schedule'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ScheduleProvider provider) {
    // Tampilkan loading spinner saat data sedang diambil
    if (provider.state == ScheduleState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilkan pesan error kalau gagal
    if (provider.state == ScheduleState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat jadwal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadSchedule(forceRefresh: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Tampilkan konten utama kalau data sudah siap
    final nextGp = provider.nextGp;

    return RefreshIndicator(
      onRefresh: () => provider.loadSchedule(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner kalau data dari cache (sudah lebih dari 24 jam)
          if (provider.lastFetchedAt != null &&
              DateTime.now().difference(provider.lastFetchedAt!).inHours >= 24)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data terakhir diperbarui: ${_formatDate(provider.lastFetchedAt!)}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          // Card GP berikutnya
          if (nextGp != null) ...[
            const Text(
              'GP Berikutnya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nextGp.event.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          nextGp.event.circuitName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Sesi selanjutnya:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    // Tampilkan sesi yang upcoming saja
                    ...nextGp.sessions
                        .where((s) =>
                            provider.getSessionStatus(s) == 'upcoming')
                        .take(3) // maksimal 3 sesi ditampilkan
                        .map((s) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(s.shortname),
                                  Text(
                                    _formatSessionTime(s.dateStartUtc),
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ] else
            const Center(
              child: Text(
                'Season selesai 🏁',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatSessionTime(DateTime utc) {
    // Konversi UTC ke WIB (UTC+7)
    final wib = utc.add(const Duration(hours: 7));
    final hour = wib.hour.toString().padLeft(2, '0');
    final minute = wib.minute.toString().padLeft(2, '0');
    return '${wib.day}/${wib.month} $hour:$minute WIB';
  }
}