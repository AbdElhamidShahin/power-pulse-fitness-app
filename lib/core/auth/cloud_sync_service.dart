import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'guest_migration_service.dart';

/// A lightweight, fire-and-forget helper that syncs a local SharedPreferences
/// key (or the nutrition aggregate) to Firestore when the user is authenticated.
///
/// ALL failures are silently swallowed — the local operation always takes
/// priority and must never fail because of a cloud sync issue.
///
/// Usage (inside a repository or service after a successful local write):
///
///   CloudSyncService.syncKey(_prefs, _auth, _firestore, 'weight_entries');
///   CloudSyncService.syncNutrition(_prefs, _auth, _firestore);
abstract class CloudSyncService {
  // ─── Sync a single fixed key ──────────────────────────────────────────────
  static void syncKey(
    SharedPreferences prefs,
    FirebaseAuth auth,
    FirebaseFirestore firestore,
    String key,
  ) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return; // guest — nothing to sync

    // Fire and forget — never await in the calling layer.
    GuestMigrationService.syncLocalKeyToCloud(
      prefs: prefs,
      firestore: firestore,
      uid: uid,
      key: key,
    ).catchError((_) {
      // Network unavailable or Firestore error — local data is safe.
    });
  }

  // ─── Sync all nutrition keys (meals_* and water_*) ────────────────────────
  static void syncNutrition(
    SharedPreferences prefs,
    FirebaseAuth auth,
    FirebaseFirestore firestore,
  ) {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    GuestMigrationService.syncNutritionToCloud(
      prefs: prefs,
      firestore: firestore,
      uid: uid,
    ).catchError((_) {
      // Network unavailable or Firestore error — local data is safe.
    });
  }
}
