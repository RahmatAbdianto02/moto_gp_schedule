class AppConstants {
  AppConstants._();
  
  // Berapa jam sampai cache dianggap stale (SRS-D2)
  static const int cacheStaleHours = 24;

  // Pilihan menit reminder yang tersedia di UI (SRS-N2)
  static const List<int> reminderMinutes = [10, 15, 30, 60, 120];
  // Estimasi durasi sesi dalam menit (SRS-S2)
  // Dipakai untuk hitung status "Ongoing"

  static const Map<String, int> sessionDurationMinutes = {
    'PRACTICE': 45,
    'QUALIFY': 30,
    'SPRINT': 30,
    'RACE': 75,
  };

   
  // Filter untuk remote datasource
  static const String targetCategory = 'MGP';
  static const String sessionType = 'SESSION';

  
}
