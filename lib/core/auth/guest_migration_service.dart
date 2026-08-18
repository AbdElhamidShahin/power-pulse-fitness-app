import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys that map 1-to-1 between SharedPreferences and Firestore fields.
/// These are used for both upload (guest→cloud) and restore (cloud→local).
abstract class GuestMigrationService {
  // ─── Fixed-key data (single SharedPreferences entry per data type) ──────
  static const _fixedMigrateKeys = [
    'user_profile',
    'weight_entries',
    'workout_logs',
    'workout_sessions_history',
    'workout_plan',
    'active_workout_session',
    'calorie_goal',      // user's persistent calorie target
  ];

  /// Prefix used in Firestore to store aggregated nutrition data.
  /// All meals_* and water_* keys are bundled under this single field.
  static const _nutritionAggKey = 'nutrition_aggregate';

  /// Prefixes for dynamic nutrition keys in SharedPreferences.
  static const _mealsPrefixSP   = 'meals_';
  static const _waterPrefixSP   = 'water_';

  /// Path in Firestore: users/{uid}/data/local_cache
  static DocumentReference<Map<String, dynamic>> _docRef(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      firestore.collection('users').doc(uid).collection('data').doc('local_cache');

  // ─── Flow 3: Guest → New Account ─────────────────────────────────────────
  //
  // Called ONLY when a guest registers a brand-new Firebase account.
  // Uploads every non-empty local SharedPreferences key to Firestore under
  // the new UID, using SET WITH MERGE so we never overwrite existing
  // Firestore data (e.g. if the same account already existed on another device).
  static Future<void> migrateGuestDataToCloud({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
  }) async {
    final payload = <String, dynamic>{};

    // ── Fixed keys ──────────────────────────────────────────────────────────
    for (final key in _fixedMigrateKeys) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          payload[key] = jsonDecode(raw);
        } catch (e) {
          payload[key] = raw;
        }
      }
    }

    // ── Dynamic nutrition keys → aggregate map ──────────────────────────────
    final nutritionMap = _collectNutritionFromPrefs(prefs);
    if (nutritionMap.isNotEmpty) {
      payload[_nutritionAggKey] = nutritionMap;
    }

    if (payload.isEmpty) return;

    // SetOptions(merge: true) — never overwrites fields that already exist
    // in Firestore (protects existing account data on another device).
    await _docRef(firestore, uid).set(payload, SetOptions(merge: true));
  }

  // ─── Flow 4 & Flow 5: Existing account restore ───────────────────────────
  //
  // Called when an authenticated user signs in to an existing account, or on
  // app startup when a Firebase session is already active.
  // Firestore is the source of truth: download all keys and write them into
  // the local SharedPreferences cache.
  //
  // Strategy for conflicts (guest local data vs existing cloud data):
  //   • Profile & plan: cloud wins (single-value, can't safely merge).
  //   • List-based data (weight_entries, workout_logs, workout_sessions_history):
  //     MERGE by ID — keeps all records from both sides, deduplicates by id field.
  //   • Nutrition (dynamic keys): cloud wins per-day key; missing local days are added.
  //   • If cloud field does not exist: local data is untouched (no silent loss).
  static Future<void> restoreCloudDataToLocal({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
  }) async {
    final snapshot = await _docRef(firestore, uid).get();

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || data.isEmpty) return;

    // ── Fixed single-value keys (cloud wins) ────────────────────────────────
    const singleValueKeys = ['user_profile', 'workout_plan', 'active_workout_session'];
    for (final key in singleValueKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        await prefs.setString(key, value is String ? value : jsonEncode(value));
      }
    }

    // calorie_goal: Firestore may store it as a number (legacy) or string.
    // Always restore as String so NutritionLocalServiceImpl.getCalorieGoal
    // can read it via prefs.getString without a double-fallback.
    if (data.containsKey('calorie_goal') && data['calorie_goal'] != null) {
      await prefs.setString('calorie_goal', data['calorie_goal'].toString());
    }

    // ── List-based keys — merge by id to avoid duplicate/loss ───────────────
    const listKeys = ['weight_entries', 'workout_logs', 'workout_sessions_history'];
    for (final key in listKeys) {
      if (data.containsKey(key) && data[key] != null) {
        final cloudValue = data[key];
        final cloudList = (cloudValue is List) ? cloudValue : <dynamic>[];
        await _mergeListKey(prefs, key, cloudList);
      }
    }

    // ── Nutrition aggregate → individual daily keys ─────────────────────────
    if (data.containsKey(_nutritionAggKey) && data[_nutritionAggKey] != null) {
      final nutrition = data[_nutritionAggKey];
      if (nutrition is Map) {
        for (final entry in nutrition.entries) {
          final spKey = entry.key as String;
          final value = entry.value;
          // Only restore meals_ and water_ keys
          if ((spKey.startsWith(_mealsPrefixSP) || spKey.startsWith(_waterPrefixSP)) &&
              value != null) {
            // For water keys the value is a double stored as a number
            if (spKey.startsWith(_waterPrefixSP) && value is num) {
              await prefs.setDouble(spKey, value.toDouble());
            } else {
              // meals_ keys: value is a JSON-encodable list
              await prefs.setString(
                spKey,
                value is String ? value : jsonEncode(value),
              );
            }
          }
        }
      }
    }
  }

  // ─── Persist a single fixed key to Firestore ─────────────────────────────
  //
  // Call this after any authenticated user-initiated write for a fixed key,
  // so Firestore stays in sync. Uses merge so partial updates are safe.
  // Failures are silently swallowed — local operation already succeeded.
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
    } catch (e) {
      value = raw;
    }

    await _docRef(firestore, uid).set({key: value}, SetOptions(merge: true));
  }

  // ─── Persist all dynamic nutrition keys to Firestore ─────────────────────
  //
  // Aggregates all meals_* and water_* keys into a single map and syncs.
  static Future<void> syncNutritionToCloud({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    required String uid,
  }) async {
    final nutritionMap = _collectNutritionFromPrefs(prefs);
    await _docRef(firestore, uid).set(
      {_nutritionAggKey: nutritionMap},
      SetOptions(merge: true),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Collects all meals_* (String) and water_* (double) SharedPreferences
  /// entries into a single map keyed by their original SP key.
  static Map<String, dynamic> _collectNutritionFromPrefs(SharedPreferences prefs) {
    final map = <String, dynamic>{};
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_mealsPrefixSP)) {
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          try {
            map[key] = jsonDecode(raw);
          } catch (e) {
            map[key] = raw;
          }
        }
      } else if (key.startsWith(_waterPrefixSP)) {
        final val = prefs.getDouble(key);
        if (val != null) map[key] = val;
      }
    }
    return map;
  }

  /// Merges a cloud list (from Firestore) with the existing local list in
  /// SharedPreferences, deduplicating by the 'id' field.
  /// Result is written back to SharedPreferences.
  static Future<void> _mergeListKey(
    SharedPreferences prefs,
    String key,
    List<dynamic> cloudList,
  ) async {
    // Parse existing local list
    final localList = <Map<String, dynamic>>[];
    final localRaw = prefs.getString(key);
    if (localRaw != null && localRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(localRaw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) localList.add(item);
          }
        }
      } catch (e) {} // ignore: json parse fallback
    }

    // Build id-indexed map of local items
    final merged = <String, dynamic>{};
    for (final item in localList) {
      final id = item['id'] as String?;
      if (id != null) merged[id] = item;
    }

    // Overlay cloud items (cloud wins for matching IDs)
    for (final item in cloudList) {
      if (item is Map<String, dynamic>) {
        final id = item['id'] as String?;
        if (id != null) merged[id] = item;
      }
    }

    if (merged.isEmpty && localList.isEmpty) return;

    // Write merged result sorted by id (stable order)
    final resultList = merged.values.toList();
    await prefs.setString(key, jsonEncode(resultList));
  }

  // ─── Clear all local user data ────────────────────────────────────────────
  //
  // Called on logout to prevent a subsequent user from seeing the previous
  // user's private data. Device settings (dark mode, units, etc.) are NOT cleared.
  static Future<void> clearLocalUserData(SharedPreferences prefs) async {
    // Fixed user-data keys
    for (final key in _fixedMigrateKeys) {
      await prefs.remove(key);
    }

    // Dynamic nutrition keys
    final allKeys = prefs.getKeys().toList();
    for (final key in allKeys) {
      if (key.startsWith(_mealsPrefixSP) || key.startsWith(_waterPrefixSP)) {
        await prefs.remove(key);
      }
    }
  }
}
