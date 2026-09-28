import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'guest_migration_service.dart';

abstract class CloudSyncService {
  static Future<void> syncKeys(List<String> keys) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in keys) {
        await GuestMigrationService.syncLocalKeyToCloud(
          prefs: prefs,
          firestore: FirebaseFirestore.instance,
          uid: user.uid,
          key: key,
        );
      }
    } catch (_) {
  }
  }

  static Future<void> syncWorkouts() =>
      syncKeys(['workout_sessions', 'active_workout_session']);

  static Future<void> syncProgress() =>
      syncKeys(['progress_entries', 'weight_entries']);

  static Future<void> syncNutrition() =>
      syncKeys(['nutrition_logs']);

  static Future<void> syncProfile() =>
      syncKeys(['user_profile']);
}
