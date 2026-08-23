import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/cloud_sync_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_session_entity.dart';

abstract interface class WorkoutLoggerService {
  Future<WorkoutSession?> getActiveSession();
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String id);
  Future<List<WorkoutSession>> getAllSessions({int limitDays});
}

final class WorkoutLoggerServiceImpl implements WorkoutLoggerService {
  WorkoutLoggerServiceImpl(
    this._prefs,
    this._auth,
    this._firestore,
  );

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _activeKey   = 'active_workout_session';
  static const _historyKey  = 'workout_sessions_history';

  @override
  Future<WorkoutSession?> getActiveSession() async {
    try {
      final raw = _prefs.getString(_activeKey);
      if (raw == null) return null;
      return WorkoutSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    try {
      if (session.isActive) {
        await _prefs.setString(_activeKey, jsonEncode(session.toJson()));
      } else {
        await _prefs.remove(_activeKey);
        final all = await _allSessions();
        all.removeWhere((s) => s.id == session.id);
        all.add(session);
        await _prefs.setString(
            _historyKey, jsonEncode(all.map((s) => s.toJson()).toList()));

        CloudSyncService.syncKey(_prefs, _auth, _firestore, _historyKey);
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

      CloudSyncService.syncKey(_prefs, _auth, _firestore, _historyKey);
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
    } catch (e) { // ignore: returns null/empty on parse failure
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
