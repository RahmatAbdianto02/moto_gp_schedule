class Reminder {
  final int? id;
  final String sessionId;       // referensi ke CachedSession.sessionId
  final String sessionName;     // denormalized, untuk konten notifikasi (SRS-N5)
  final String eventName;
  final DateTime sessionStartUtc;
  final int minutesBefore;      // 10 / 15 / 30 / 60 / 120 (SRS-N2)
  final DateTime triggerAt;     // = sessionStartUtc - minutesBefore
  final bool isActive;

  Reminder({
    this.id,
    required this.sessionId,
    required this.sessionName,
    required this.eventName,
    required this.sessionStartUtc,
    required this.minutesBefore,
    required this.triggerAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'sessionName': sessionName,
      'eventName': eventName,
      'sessionStartUtc': sessionStartUtc.toIso8601String(),
      'minutesBefore': minutesBefore,
      'triggerAt': triggerAt.toIso8601String(),
      // SQLite tidak punya tipe boolean asli, disimpan sebagai 0/1
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as String,
      sessionName: map['sessionName'] as String,
      eventName: map['eventName'] as String,
      sessionStartUtc: DateTime.parse(map['sessionStartUtc'] as String),
      minutesBefore: map['minutesBefore'] as int,
      triggerAt: DateTime.parse(map['triggerAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }
}