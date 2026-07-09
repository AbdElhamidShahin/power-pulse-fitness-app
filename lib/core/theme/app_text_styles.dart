import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Power Pulse — Text Styles
/// Font: Cairo — Arabic first
abstract class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Cairo';

  // ─── Display ───────────────────────────────────────────────
  /// شاشة الـ splash والـ onboarding - 36px bold
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// عناوين كبيرة - 28px
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.3,
  );

  // ─── Headline ──────────────────────────────────────────────
  /// عنوان الشاشة - 22px
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// عنوان section - 18px
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  /// عنوان card - 16px
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ─── Title ─────────────────────────────────────────────────
  /// اسم التمرين - 15px
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// عناصر القوائم - 14px
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  /// labels - 13px
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ─── Body ──────────────────────────────────────────────────
  /// نص اساسي - 14px
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// نص ثانوي - 13px
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// نص صغير - 12px
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // ─── Label ─────────────────────────────────────────────────
  /// buttons - 14px bold
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// badges & tabs - 12px
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// caption & nav labels - 10px
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // ─── Special ───────────────────────────────────────────────
  /// أرقام Stats الكبيرة - 32px
  static const TextStyle statNumber = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// accent text - أخضر bold
  static const TextStyle accentLabel = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    height: 1.2,
  );
}
