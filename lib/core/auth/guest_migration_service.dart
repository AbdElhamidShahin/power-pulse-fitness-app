import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GuestMigrationService {
  static const _migrateKeys = [
    'user_profile',
    'nutrition_logs',
    'progress_entries',
    'weight_entries',
    'workout_sessions',
    'workout_plan',
    'active_workout_session',
  ];

  static DocumentReference<Map<String, dynamic>> _docRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      firestore.collection('users').doc(uid).collection('data').doc('local_cache');
static Future<void> migrateGuestDataToCloud({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
  }) async {
    final payload = <String, dynamic>{};

    for (final key in _migrateKeys) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          payload[key] = jsonDecode(raw);
        } catch (_) {
          payload[key] = raw;
        }
      }
    }

    if (payload.isEmpty) return;

   await _docRef(firestore, uid).set(payload, SetOptions(merge: true));
  }

 static Future<void> restoreCloudDataToLocal({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
  }) async {
    final snapshot = await _docRef(firestore, uid).get();

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || data.isEmpty) return;

    for (final key in _migrateKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        await prefs.setString(
          key,
          value is String ? value : jsonEncode(value),
        );
      }
    }
  }

static Future<void> syncLocalKeyToCloud({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
    required String key,
  }) async {
    final raw = prefs.getString(key);
    if (raw == null) return;

    dynamic value;
    try {
      value = jsonDecode(raw);
    } catch (_) {
      value = raw;
    }

    await _docRef(firestore, uid).set({key: value}, SetOptions(merge: true));
  }
}
