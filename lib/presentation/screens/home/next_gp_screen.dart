import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/neo_loading.dart';

class NextGpScreen extends StatelessWidget {
  const NextGpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    if (provider.state == ScheduleState.initial ||
        provider.state == ScheduleState.loading) {
      return const Scaffold(
        backgroundColor: AppTheme.white,
        body: NeoLoading(),
      );
    }

    if (provider.state == ScheduleState.error) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          title: const Text('MOTOGP SCHEDULE'),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration(color: AppTheme.yellow),
                  child: const Icon(Icons.wifi_off, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'GAGAL MEMUAT DATA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.loadSchedule(forceRefresh: true),
                  child: const Text('COBA LAGI'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final nextGp = provider.nextGp;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('MOTOGP SCHEDULE'),
        
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.white,
      ),
    
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => provider.loadSchedule(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner data basi
            if (provider.lastFetchedAt != null &&
                DateTime.now()
                        .difference(provider.lastFetchedAt!)
                        .inHours >=
                    24)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration:
                    AppTheme.cardDecorationSmall(color: AppTheme.yellow),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data terakhir: ${provider.lastFetchedAt!.day}/${provider.lastFetchedAt!.month}/${provider.lastFetchedAt!.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Pilihan timezone
            const Text(
              'ZONA WAKTU',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['WIB', 'WITA', 'WIT'].map((tz) {
                final isSelected = provider.selectedTimezone == tz;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => provider.setTimezone(tz),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.white,
                        border: Border.all(color: AppTheme.black, width: 2.5),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: AppTheme.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ]
                            : const [
                                BoxShadow(
                                  color: AppTheme.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 0,
                                ),
                              ],
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          color:
                              isSelected ? AppTheme.white : AppTheme.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                        child: Text(tz),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Card GP berikutnya
            if (nextGp != null) ...[
              const Text(
                'GP BERIKUTNYA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: AppTheme.cardDecoration(color: AppTheme.cream),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: AppTheme.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextGp.event.name,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppTheme.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                nextGp.event.circuitName,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SESI SELANJUTNYA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...nextGp.sessions
                              .where((s) =>
                                  provider.getSessionStatus(s) == 'upcoming')
                              .take(3)
                              .map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: AppTheme.cardDecorationSmall(
                                          color: AppTheme.white),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            s.shortname,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            provider.formatSessionTime(
                                                s.dateStartUtc),
                                            style: const TextStyle(
                                              color: AppTheme.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration:
                    AppTheme.cardDecoration(color: AppTheme.yellow),
                child: const Center(
                  child: Text(
                    'SEASON SELESAI 🏁',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}