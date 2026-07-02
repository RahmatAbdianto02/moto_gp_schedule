class ApiConstants {
  ApiConstants. _();
  // Private constructor — class ini tidak perlu di-instantiate
  static const String baseUrl = 'https://api.motogp.pulselive.com/motogp/v1';

  static const String seasons = '$baseUrl/results/seasons';
  // seasonYear diisi saat runtime, jadi pakai method
  static String events(int seasonYear) =>
   '$baseUrl/results/seasons/$seasonYear/events';
}