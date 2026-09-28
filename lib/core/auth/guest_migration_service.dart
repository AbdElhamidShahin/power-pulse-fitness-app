import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Keys that hold local user data we want to migrate to the cloud.
/// Each key maps to a Supabase table column / document path.
abstract class GuestMigrationService {
  // SharedPreferences keys that hold user-owned data
  static const _migrateKeys = [
    'user_profile',
    'nutrition_logs',
    'progress_entries',
    'weight_entries',
    'workout_sessions',
    'workout_plan',
    'active_workout_session',
  ];

  /// Call this once after a guest successfully authenticates.
  /// Uploads every non-empty local key to `user_data` table in Supabase
  /// under the authenticated UID. Does NOT wipe local data afterward —
  /// the caller should switch to authenticated mode.
  static Future<void> migrateGuestDataToCloud({
    required SharedPreferences prefs,
    required SupabaseClient supabase,
    required String uid,
  }) async {
    final payload = <String, dynamic>{'uid': uid};

    for (final key in _migrateKeys) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          payload[key] = jsonDecode(raw);
        } catch (_) {
          payload[key] = raw; // store as-is if not JSON
        }
      }
    }

    if (payload.length <= 1) return; // only uid, nothing to migrate

    // Upsert into `user_data` table.  Row = one document per user.
    await supabase.from('user_data').upsert(payload);
  }

  /// Restore cloud data into local SharedPreferences cache.
  /// Call this when an existing authenticated user signs in.
  static Future<void> restoreCloudDataToLocal({
    required SharedPreferences prefs,
    required SupabaseClient supabase,
    required String uid,
  }) async {
    final rows = await supabase
        .from('user_data')
        .select()
        .eq('uid', uid)
        .limit(1);

    if (rows.isEmpty) return;

    final row = rows.first as Map<String, dynamic>;

    for (final key in _migrateKeys) {
      if (row.containsKey(key) && row[key] != null) {
        final value = row[key];
        await prefs.setString(
          key,
          value is String ? value : jsonEncode(value),
        );
      }
    }
  }
}
