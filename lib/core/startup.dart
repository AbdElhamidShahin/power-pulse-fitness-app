import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/guest_migration_service.dart';
import 'auth/user_mode_service.dart';

/// Startup logic — بيتنفّذ **مرة واحدة** في `main()` قبل `runApp`.
///
/// قبل كده كان الـ GoRouter `redirect` بيعمل SharedPreferences read +
/// Supabase cloud restore في كل navigation. دلوقتي كل الـ I/O هنا،
/// والـ router بيسأل [needsEntry] (in-memory فقط).
abstract class AppStartup {
  AppStartup._();

  /// أقصى وقت ننتظره لاستعادة بيانات الـ cloud وقت التشغيل.
  /// لو الشبكة بطيئة نكمل بالـ cache المحلي بدل ما الشاشة تفضل فاضية.
  static const Duration _restoreTimeout = Duration(seconds: 10);

  static bool _done = false;
  static bool get isDone => _done;

  /// Flow (نفس المنطق القديم بالظبط):
  ///  1. فيه Supabase session  → restore cloud data → authenticated → home
  ///  2. مفيش session + guest  → home
  ///  3. مفيش session + none/authenticated (session انتهت) → entry
  static Future<void> determine() async {
    final prefs = await SharedPreferences.getInstance();
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      try {
        await GuestMigrationService.restoreCloudDataToLocal(
          prefs: prefs,
          supabase: supabase,
          uid: currentUser.id,
        ).timeout(_restoreTimeout);
      } catch (_) {
        // فشل الشبكة مقبول — الـ cache المحلي هو الـ fallback
      }
      await UserModeService.setAuthenticated(prefs);
    } else {
      final mode = await UserModeService.getMode(prefs);
      if (mode == UserMode.authenticated) {
        // كان مسجّل دخول لكن الـ session انتهت
        await UserModeService.clearMode(prefs);
      }
    }
    _done = true;
  }

  /// **Synchronous — من غير I/O.** آمن للاستدعاء من `GoRouter.redirect`.
  ///
  /// `true` لو المستخدم لسه ماختارش (لا session ولا guest).
  /// `auth.currentUser` قيمة في الذاكرة، والـ mode متخزّن في
  /// [UserModeService.cachedMode] ويتحدّث تلقائياً مع كل setter.
  static bool get needsEntry {
    if (Supabase.instance.client.auth.currentUser != null) return false;
    return UserModeService.cachedMode != UserMode.guest;
  }
}
