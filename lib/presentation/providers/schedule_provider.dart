import 'package:flutter/material.dart';
import 'package:moto_gp_schedule/data/models/cached_session.dart';
import 'package:moto_gp_schedule/data/models/datasources/repositories/motogp_repository.dart';


enum ScheduleState { initial, loading, loaded, error }

class ScheduleProvider extends ChangeNotifier {
  final MotoGpRepository repository;

  ScheduleProvider({required this.repository});

  // ===================== STATE =====================

  ScheduleState _state = ScheduleState.initial;
  ScheduleState get state => _state;

  List<EventWithSessions> _events = [];
  List<EventWithSessions> get events => _events;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime? _lastFetchAt;
  DateTime? get lastFetchedAt => _lastFetchAt;

  // ===================== COMPUTED =====================

  EventWithSessions? get nextGp {
    try {
      return _events.firstWhere(
        (e) => e.sessions.any((s) => getSessionStatus(s) == 'upcoming'),
      );
    } catch (_) {
      return _events.isNotEmpty ? _events.last : null;
    }
  }

  // ===================== SESSION STATUS =====================

  String getSessionStatus(CachedSession session) {
    final now = DateTime.now().toUtc();
    final start = session.dateStartUtc;

    final durationMap = {
      'PRACTICE': 45,
      'QUALIFY': 30,
      'SPRINT': 30,
      'RACE': 75,
    };
    final durationMinutes = durationMap[session.kind] ?? 45;
    final end = start.add(Duration(minutes: durationMinutes));

    if (now.isBefore(start)) return 'upcoming';
    if (now.isBefore(end)) return 'ongoing';
    return 'completed';
  }

  // ===================== METHOD =====================

  Future<void> loadSchedule({bool forceRefresh = false}) async {
    _state = ScheduleState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await repository.getSchedule(forceRefresh: forceRefresh);
      _lastFetchAt = await repository.getLastFetchedAt();
      _state = ScheduleState.loaded;
    } catch (e) {
      _state = ScheduleState.error;
      _errorMessage = 'Gagal memuat jadwal. Periksa koneksi internet kamu';
    }

    notifyListeners();
  }
}