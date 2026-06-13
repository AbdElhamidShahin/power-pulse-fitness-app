import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Power Pulse — Typography
/// Cairo font — Arabic-first, emotionally athletic
class AppTextStyles {
  AppTextStyles._();

  // ── Display Hero — streak numbers, featured stats ─────────────────────────
  /// 52px / 900 — the ONE number that matters on screen
  static TextStyle get displayHero => GoogleFonts.cairo(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.0,
        letterSpacing: -1.5,
      );

  // ── Display metrics — BMI result, calorie total ───────────────────────────
  static TextStyle get displayMetrics => GoogleFonts.cairo(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.0,
        letterSpacing: -1.0,
      );

  // ── Headlines ─────────────────────────────────────────────────────────────
  /// 34px — hero card title, featured workout name
  static TextStyle get headlineHero => GoogleFonts.cairo(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      );

  /// 26px — screen titles, section titles
  static TextStyle get headlineLgMobile => GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headlineLg => headlineLgMobile;

  /// 20px — card titles
  static TextStyle get headlineMd => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// 17px — list item titles, labels
  static TextStyle get headingSmall => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get headingLarge  => headlineLgMobile;
  static TextStyle get headingMedium => headlineMd;

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLg => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );
  static TextStyle get bodyMd => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );
  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );
  static TextStyle get bodyMuted => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ── Labels ────────────────────────────────────────────────────────────────
  static TextStyle get labelCaps => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.4,
        height: 1.0,
      );
  static TextStyle get labelMuted => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
        height: 1.0,
      );
  static TextStyle get labelPrimary =>
      labelCaps.copyWith(color: AppColors.primary);

  // ── App bar / navigation ──────────────────────────────────────────────────
  static TextStyle get appBarTitle => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );
  static TextStyle get appBarTitleSmall => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
  static const TextStyle appBarThemeTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────
  static TextStyle get buttonLabel => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.onPrimary,
        letterSpacing: 0.2,
      );

  // ── Tool / calc screens ───────────────────────────────────────────────────
  static TextStyle get toolCardTitle  => headingSmall;
  static TextStyle get calcLabel      => headingSmall;
  static TextStyle get calcResult     => displayMetrics.copyWith(color: AppColors.success);
  static TextStyle get calcHeading    => headlineLgMobile.copyWith(color: AppColors.primary);

  // ── Exercise / workout ─────────────────────────────────────────────────────
  static TextStyle get exerciseTitle  => headingSmall.copyWith(color: AppColors.primary);
  static TextStyle get exerciseDetails => bodyMd.copyWith(color: AppColors.textSecondary);
  static TextStyle get exerciseListHeader => headlineLgMobile;

  // ── Cards ──────────────────────────────────────────────────────────────────
  static TextStyle get cardTitle    => headlineMd.copyWith(fontSize: 18);
  static TextStyle get cardSubtitle => bodyMd;
  static TextStyle get workoutOptionTitle => headingSmall;
  static TextStyle tabBarItem(Color color) =>
      bodyMd.copyWith(color: color, fontWeight: FontWeight.w700);
  static TextStyle get metricValue => displayMetrics.copyWith(fontSize: 28);
}
