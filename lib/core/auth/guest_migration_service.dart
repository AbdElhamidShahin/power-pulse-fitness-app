import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys that hold local user data we want to migrate to / restore from Firestore.
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

  /// Path in Firestore: users/{uid}/data/local_cache
  static DocumentReference<Map<String, dynamic>> _docRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      firestore.collection('users').doc(uid).collection('data').doc('local_cache');

  // ─── Flow 3: Guest → Account (new sign-up or first-time login) ───────────
  //
  // Called when a Guest user successfully authenticates for the first time.
  // Uploads every non-empty local SharedPreferences key to Firestore under
  // the authenticated UID, using SET WITH MERGE so we never overwrite existing
  // Firestore data that was written by this account from another device.
  //
  // NOTE: This is intentionally only called for new accounts. For existing
  // accounts (Flow 4), restoreCloudDataToLocal() is called instead and
  // Firestore always wins.
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

    // SetOptions(merge: true) — never overwrites fields that already exist
    // in Firestore (protects existing account data on another device).
    await _docRef(firestore, uid).set(payload, SetOptions(merge: true));
  }

  // ─── Flow 4 & Flow 5: Existing account restore ────────────────────────────
  //
  // Called when an authenticated user signs in to an existing account, or on
  // app startup when a Firebase session is already active.
  // Firestore is the source of truth: download all keys and write them into
  // the local SharedPreferences cache. Does NOT touch Firestore.
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

  // ─── Persist authenticated changes back to Firestore ─────────────────────
  //
  // Call this after any user-initiated data change while authenticated, so
  // Firestore stays in sync. Uses merge so partial updates are safe.
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
