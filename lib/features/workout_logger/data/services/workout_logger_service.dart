import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_session_entity.dart';

abstract interface class WorkoutLoggerService {
  Future<WorkoutSession?> getActiveSession();
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String id);
  Future<List<WorkoutSession>> getAllSessions({int limitDays});
}

final class WorkoutLoggerServiceImpl implements WorkoutLoggerService {
  WorkoutLoggerServiceImpl(this._prefs);
  final SharedPreferences _prefs;

  static const _activeKey   = 'active_workout_session';
  static const _historyKey  = 'workout_sessions_history';

  @override
  Future<WorkoutSession?> getActiveSession() async {
    try {
      final raw = _prefs.getString(_activeKey);
      if (raw == null) return null;
      return WorkoutSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    try {
      if (session.isActive) {
        // احفظ كـ active
        await _prefs.setString(_activeKey, jsonEncode(session.toJson()));
      } else {
        // انتهت — احذف الـ active وأضفها للـ history
        await _prefs.remove(_activeKey);
        final all = await _allSessions();
        all.removeWhere((s) => s.id == session.id);
        all.add(session);
        await _prefs.setString(
            _historyKey, jsonEncode(all.map((s) => s.toJson()).toList()));
      }
    } catch (e) {
      throw CacheException(message: 'فشل حفظ الجلسة: $e');
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      final active = await getActiveSession();
      if (active?.id == id) await _prefs.remove(_activeKey);
      final all = await _allSessions();
      all.removeWhere((s) => s.id == id);
      await _prefs.setString(
          _historyKey, jsonEncode(all.map((s) => s.toJson()).toList()));
    } catch (e) {
      throw CacheException(message: 'فشل حذف الجلسة: $e');
    }
  }

  @override
  Future<List<WorkoutSession>> getAllSessions({int limitDays = 90}) async {
    try {
      final all = await _allSessions();
      final cutoff = DateTime.now().subtract(Duration(days: limitDays));
      return all
          .where((s) => s.startTime.isAfter(cutoff))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (_) {
      return [];
    }
  }

  Future<List<WorkoutSession>> _allSessions() async {
    final raw = _prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
