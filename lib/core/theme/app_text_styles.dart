import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central text styles extracted from scattered GoogleFonts.changa() calls.
/// Previously every widget defined its own inline TextStyle.
class AppTextStyles {
  AppTextStyles._();

  // ── App Bar ──────────────────────────────────────────────────────────────────
  /// Main app bar title — "Power Pulse" in Gim_view
  static TextStyle get appBarTitle => GoogleFonts.changa(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.textAmber,
      );

  /// Secondary app bar title (CustomAppBar widget)
  static TextStyle get appBarTitleSmall => GoogleFonts.changa(
        color: AppColors.textAmber,
        fontSize: 18,
      );

  /// AppBarTheme static style (used in ThemeData — must be const-compatible)
  static const TextStyle appBarThemeTitle = TextStyle(
    color: AppColors.textWhite,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  // ── Headings ─────────────────────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.changa(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  static TextStyle get headingMedium => GoogleFonts.changa(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  static TextStyle get headingSmall => GoogleFonts.changa(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textWhite,
      );

  // ── Body ─────────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.changa(
        fontSize: 20,
        color: AppColors.textWhite,
      );

  static TextStyle get bodyMedium => GoogleFonts.changa(
        fontSize: 18,
        color: AppColors.textWhite,
      );

  static TextStyle get bodySmall => GoogleFonts.changa(
        fontSize: 16,
        color: AppColors.textWhite,
        height: 1.5,
      );

  // ── Cards / Exercise list (costom_bosh, CustomTextField) ────────────────────
  static TextStyle get exerciseTitle => GoogleFonts.changa(
        fontSize: 20,
        color: AppColors.textAmber,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get exerciseDetails => GoogleFonts.changa(
        fontSize: 16,
        color: AppColors.textWhite,
      );

  // ── Home screen cards (custom_text_feild) ────────────────────────────────────
  static TextStyle get cardTitle => GoogleFonts.changa(
        fontSize: 22,
        color: AppColors.textWhite,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get cardSubtitle => GoogleFonts.changa(
        fontSize: 18,
        color: AppColors.textWhite,
      );

  // ── Tools screen (ToolsScreen._buildToolCard) ────────────────────────────────
  static TextStyle get toolCardTitle => GoogleFonts.changa(
        color: AppColors.toolCardText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  // ── Calculator screens (BMI, IBW, Calorie counter) ──────────────────────────
  static TextStyle get calcLabel => GoogleFonts.changa(
        color: AppColors.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get calcResult => GoogleFonts.changa(
        color: AppColors.textGreenAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get calcHeading => GoogleFonts.changa(
        color: Color(0xFFB2DFDB), // green[100]
        fontSize: 40,
      );

  // ── Buttons (helper.dart sizedBox widget) ────────────────────────────────────
  static TextStyle get buttonLabel => GoogleFonts.changa(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      );

  // ── Workout system screen (ChooseWorkoutSystemScreen) ───────────────────────
  static TextStyle get workoutOptionTitle => GoogleFonts.changa(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  // ── Tab bar (custom_tab_bar) ──────────────────────────────────────────────────
  static TextStyle tabBarItem(Color color) => GoogleFonts.changa(
        fontSize: 18,
        color: color,
        fontWeight: FontWeight.bold,
      );

  // ── Exercise list header (GetExerciseList widget) ────────────────────────────
  static TextStyle get exerciseListHeader => GoogleFonts.changa(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );
}
