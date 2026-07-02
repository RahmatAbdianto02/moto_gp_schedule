class CachedSession {
  final int? id; // null saat belum diinsert, auto increment dari SQLite
  final String sessionId;     // id dari broadcasts[].id di API
  final String eventId;       // foreign key ke CachedEvent
  final String shortname;     // "FP1", "Q1", "RAC", dll
  final String name;          // "Session 1", "Race", dll
  final String kind;          // "PRACTICE", "QUALIFY", "RACE", dll
  final DateTime dateStartUtc;
  final String apiStatus;     // "FINISHED", "UPCOMING", dll dari API

  CachedSession({
    this.id,
    required this.sessionId,
    required this.eventId,
    required this.shortname,
    required this.name,
    required this.kind,
    required this.dateStartUtc,
    required this.apiStatus,
  });

  // Konversi object -> Map, dipakai saat INSERT ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'eventId': eventId,
      'shortname': shortname,
      'name': name,
      'kind': kind,
      'dateStartUtc': dateStartUtc.toIso8601String(),
      'apiStatus': apiStatus,
    };
  }

  // Konversi Map (hasil query SELECT) -> object
  factory CachedSession.fromMap(Map<String, dynamic> map) {
    return CachedSession(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as String,
      eventId: map['eventId'] as String,
      shortname: map['shortname'] as String,
      name: map['name'] as String,
      kind: map['kind'] as String,
      dateStartUtc: DateTime.parse(map['dateStartUtc'] as String),
      apiStatus: map['apiStatus'] as String,
    );
  }
}