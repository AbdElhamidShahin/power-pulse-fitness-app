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
  static bool _passwordRecoveryPending = false;

  static bool get isDone => _done;
  static bool get passwordRecoveryPending => _passwordRecoveryPending;

  static void markPasswordRecoveryPending() {
    _passwordRecoveryPending = true;
  }

  static void clearPasswordRecoveryPending() {
    _passwordRecoveryPending = false;
  }

  /// Flow (نفس المنطق القديم بالظبط):
  ///  1. فيه Supabase session  → restore cloud data → authenticated → home
  ///  2. مفيش session + guest  → home
  ///  3. مفيش session + none/authenticated (session انتهت) → entry
  static Future<void> determine() async {
    final prefs = await SharedPreferences.getInstance();
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      await UserModeService.setAuthenticated(prefs);
      try {
        // دمج (مش استبدال): البيانات المحلية الأحدث مبتضيعش.
        await GuestMigrationService.restoreCloudDataToLocal(
          prefs: prefs,
          supabase: supabase,
          uid: currentUser.id,
        ).timeout(_restoreTimeout);
      } catch (_) {
        // فشل الشبكة مقبول — الـ cache المحلي هو الـ fallback
      }
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
  /// التطبيق بيفتح "بره" (شاشة الدخول) لو مفيش حساب مسجّل، حتى لو المستخدم
  /// كان ضيف قبل كده. بعد ما يختار "كمّل كضيف" في الجلسة دي بس يدخل الرئيسية.
  /// (لو عايز الضيف يدخل على الرئيسية على طول: ارجع للشرط
  ///  `UserModeService.cachedMode != UserMode.guest`)
  static bool get needsEntry {
    if (Supabase.instance.client.auth.currentUser != null) return false;
    return !UserModeService.guestSessionActive;
  }

  /// هل المستخدم لازم يكمل الـ onboarding؟
  /// يُستخدم بعد login/signup للتحقق إذا كانت بيانات الـ profile موجودة.
  static Future<bool> needsOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = prefs.getString('user_profile');
    return profile == null || profile.isEmpty;
  }
}
