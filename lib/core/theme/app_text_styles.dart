import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTextStyles — shape only, no hardcoded colors.
///
/// الـ color بتيجي من الـ Theme تلقائياً عبر textTheme.
/// لو محتاج لون مختلف استخدم .copyWith(color: context.colors.xxx)
///
/// الاستخدام الصح:
///   Theme.of(context).textTheme.bodyMedium          // ✅ يأخذ اللون من الـ theme
///   AppTextStyles.bodyMedium                         // ✅ للـ theme definitions فقط
///   AppTextStyles.bodyMedium.copyWith(color: ...)    // ✅ لو محتاج override
abstract class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Cairo';

  // ─── Display ───────────────────────────────────────────────
  /// 36px bold — splash / onboarding
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// 28px bold — عناوين كبيرة
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.15,
    letterSpacing: -0.3,
  );

  // ─── Headline ──────────────────────────────────────────────
  /// 22px — عنوان الشاشة
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  /// 18px — عنوان section
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// 16px — عنوان card
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ─── Title ─────────────────────────────────────────────────
  /// 15px — اسم التمرين
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// 14px — عناصر القوائم
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// 13px — labels
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Body ──────────────────────────────────────────────────
  /// 14px — نص أساسي
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 13px — نص ثانوي
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 12px — نص صغير
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Label ─────────────────────────────────────────────────
  /// 14px bold — buttons
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// 12px bold — badges & tabs
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// 10px — caption & nav labels
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // ─── Special — ألوان semantic ثابتة مش بتتغير مع الـ theme ──
  /// أرقام Stats الكبيرة - 32px (اللون يجي من textTheme.displayLarge)
  static const TextStyle statNumber = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.0,
  );

  /// accent text — أخضر دايماً (semantic color مش theme-dependent)
  static const TextStyle accentLabel = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    height: 1.2,
  );
}
