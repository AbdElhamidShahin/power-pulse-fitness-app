import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// Extension بيخلي الـ widgets تقرأ الألوان الصح تلقائياً حسب الـ theme.
///
/// بدل ما تكتب:
/// ```dart
/// color: AppColors.bgDeep,  // ❌ دايماً light
/// ```
/// اكتب:
/// ```dart
/// color: context.colors.bgDeep,  // ✅ light أو dark تلقائياً
/// ```
extension AppThemeColors on BuildContext {
  /// يرجع لوحة الألوان المناسبة للـ theme الحالي.
  _AppColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? const _DarkColors() : const _LightColors();
  }
}

/// Contract — نفس الـ tokens في الاتنين
abstract class _AppColors {
  const _AppColors();

  // ─── Backgrounds ───────────────────────────────────────────
  Color get bgDeep;
  Color get bgSurface;
  Color get bgElevated;
  Color get bgHighest;

  // ─── Text ──────────────────────────────────────────────────
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;

  // ─── Borders ───────────────────────────────────────────────
  Color get borderSubtle;
  Color get borderMedium;

  // ─── Semantic (مش بتتغير مع الـ theme) ────────────────────
  Color get accent        => AppColors.accent;
  Color get accentDim     => AppColors.accentDim;
  Color get success       => AppColors.success;
  Color get successDim    => AppColors.successDim;
  Color get warning       => AppColors.warning;
  Color get warningDim    => AppColors.warningDim;
  Color get danger        => AppColors.danger;
  Color get dangerDim     => AppColors.dangerDim;
  Color get info          => AppColors.info;
  Color get infoDim       => AppColors.infoDim;
  Color get textOnAccent  => AppColors.textOnAccent;
  Color get textOnDark    => AppColors.textOnDark;

  // ─── Dark Cards (بتتغير) ───────────────────────────────────
  Color get bgDark;
  Color get bgDarkAlt;
}

/// Light palette
class _LightColors extends _AppColors {
  const _LightColors();

  @override Color get bgDeep      => AppColors.bgDeep;
  @override Color get bgSurface   => AppColors.bgSurface;
  @override Color get bgElevated  => AppColors.bgElevated;
  @override Color get bgHighest   => AppColors.bgHighest;
  @override Color get textPrimary   => AppColors.textPrimary;
  @override Color get textSecondary => AppColors.textSecondary;
  @override Color get textMuted     => AppColors.textMuted;
  @override Color get borderSubtle  => AppColors.borderSubtle;
  @override Color get borderMedium  => AppColors.borderMedium;
  @override Color get bgDark        => AppColors.bgDark;
  @override Color get bgDarkAlt     => AppColors.bgDarkAlt;
}

/// Dark palette
class _DarkColors extends _AppColors {
  const _DarkColors();

  @override Color get bgDeep      => AppColorsDark.bgDeep;
  @override Color get bgSurface   => AppColorsDark.bgSurface;
  @override Color get bgElevated  => AppColorsDark.bgElevated;
  @override Color get bgHighest   => AppColorsDark.bgHighest;
  @override Color get textPrimary   => AppColorsDark.textPrimary;
  @override Color get textSecondary => AppColorsDark.textSecondary;
  @override Color get textMuted     => AppColorsDark.textMuted;
  @override Color get borderSubtle  => AppColorsDark.borderSubtle;
  @override Color get borderMedium  => AppColorsDark.borderMedium;
  // في dark mode الكارت الداكنة بتبقى أغمق من bgSurface
  @override Color get bgDark        => AppColorsDark.bgDeep;
  @override Color get bgDarkAlt     => AppColorsDark.bgSurface;
}
