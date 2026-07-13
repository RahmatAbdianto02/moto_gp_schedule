
// urutan 1
class CachedEvent {
  final int? id;
  final String eventId;       // id event dari API
  final String name;
  final String country;
  final String circuitName;
  final int seasonYear;
  final DateTime fetchedAt;   // untuk validasi stale 24 jam (SRS-D2)

  CachedEvent({
    this.id,
    required this.eventId,
    required this.name,
    required this.country,
    required this.circuitName,
    required this.seasonYear,
    required this.fetchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'country': country,
      'circuitName': circuitName,
      'seasonYear': seasonYear,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory CachedEvent.fromMap(Map<String, dynamic> map) {
    return CachedEvent(
      id: map['id'] as int?,
      eventId: map['eventId'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      circuitName: map['circuitName'] as String,
      seasonYear: map['seasonYear'] as int,
      fetchedAt: DateTime.parse(map['fetchedAt'] as String),
    );
  }
}